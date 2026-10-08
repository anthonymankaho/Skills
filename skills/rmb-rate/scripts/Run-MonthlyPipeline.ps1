<#
Scheduled-task entry point. Fires daily (this machine's ScheduledTasks module
has no -Monthly trigger, so a plain daily 9am trigger is used instead), but
only actually runs the pipeline on the correct target day for that month - the
14th, rolled forward to 15th/16th/beyond past any Saturday, Sunday, or Hong
Kong public holiday (fetched live from the official 1823.gov.hk feed via
Get-HkHolidays.ps1). On any other day it logs and exits quietly.

On the target day: fetches the BOC rate (Get-BocCnhRate.ps1, pure PowerShell/regex,
no AI parsing needed), appends it to the workbook (update_rate.ps1), and creates
the Gmail draft with the snapshot attached (New-MonthlyEmailDraft.ps1). If the
month was already logged (e.g. a manual run happened earlier), update_rate.ps1's
own duplicate-month guard trips - that's treated as an informational skip, not
an error, and the email step is not run again.

Requires Excel closed on the workbook, and (per Excel COM's own unattended-use
limitations) the registered task must use Interactive logon - same constraint
as the Weekly Exchange Report project's scheduled task.

Hardening (2026-08-27): both live web fetches (holiday calendar, BOC rate) now
have a 20s timeout and a retry. Two daily firings (2026-08-18, 2026-08-26) were
found with a transcript that cut off mid-run with no error - almost certainly
an unbounded web request hang that got killed by something external (network
not up yet, session teardown) before it could throw a catchable error. Neither
happened to be a target day, so no data was at risk, but the check itself
silently failed instead of logging cleanly. The holiday fetch also now falls
back to a weekends-only rule (with a loud warning) if it still fails after
retrying, so a holiday-feed outage can't take down the whole daily check - only
degrades the specific public-holiday rollover for that one check.
#>

[CmdletBinding()]
param(
    [datetime]$Today = (Get-Date).Date
)

$ErrorActionPreference = 'Stop'
$scriptRoot = $PSScriptRoot
$skillRoot = Split-Path $scriptRoot -Parent
$projectRoot = Split-Path (Split-Path (Split-Path $skillRoot -Parent) -Parent) -Parent

$logDir = Join-Path $skillRoot 'Logs'
if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir | Out-Null }
$logFile = Join-Path $logDir ("run_{0}.log" -f (Get-Date -Format 'yyyyMMdd_HHmmss'))
Start-Transcript -Path $logFile -Append | Out-Null

function Invoke-WithRetry {
    param(
        [Parameter(Mandatory)][scriptblock]$ScriptBlock,
        [int]$Attempts = 2,
        [int]$DelaySeconds = 10
    )
    for ($i = 1; $i -le $Attempts; $i++) {
        try {
            return & $ScriptBlock
        } catch {
            if ($i -eq $Attempts) { throw }
            Write-Host "Attempt $i/$Attempts failed ($($_.Exception.Message)) - retrying in $DelaySeconds s..."
            Start-Sleep -Seconds $DelaySeconds
        }
    }
}

$status = 'ERROR (unexpected - no exit path reached, see above)'
try {
    Write-Host "=== Monthly RMB rate pipeline check: $($Today.ToString('yyyy-MM-dd')) ==="

    try {
        $holidays = Invoke-WithRetry { & (Join-Path $scriptRoot 'Get-HkHolidays.ps1') }
        $holidaySet = $holidays | ForEach-Object { $_.Date }
    } catch {
        Write-Host "WARNING: could not fetch the HK holiday calendar after retrying ($($_.Exception.Message)) - falling back to a weekends-only rule for today's check."
        $holidaySet = @()
    }

    function Get-TargetRunDate {
        param([datetime]$AnchorMonth, [object[]]$HolidaySet)
        $candidate = Get-Date -Year $AnchorMonth.Year -Month $AnchorMonth.Month -Day 14
        while ($candidate.DayOfWeek -in @('Saturday', 'Sunday') -or ($HolidaySet -contains $candidate.Date)) {
            $candidate = $candidate.AddDays(1)
        }
        return $candidate.Date
    }

    $targetDate = Get-TargetRunDate -AnchorMonth $Today -HolidaySet $holidaySet
    Write-Host "Target run date for $($Today.ToString('yyyy-MM')): $($targetDate.ToString('yyyy-MM-dd'))"

    if ($Today.Date -ne $targetDate) {
        $status = 'SKIP (not the target run date)'
        Write-Host "Today is not the target run date - skipping (not an error)."
        return
    }

    Write-Host "Today matches the target run date - running the full pipeline."

    $workbookPath = Join-Path $projectRoot 'FIN_Ex Rate HKD-RMB(BOC)_TEMP.xlsx'
    $dateString = $Today.ToString('yyyy-MM-dd')
    $snapshotPath = Join-Path $projectRoot ("FIN_Ex Rate HKD-RMB(BOC)_{0}.xlsx" -f $dateString)

    $rateInfo = Invoke-WithRetry { & (Join-Path $scriptRoot 'Get-BocCnhRate.ps1') }
    Write-Host "Fetched BOC rate - sell=$($rateInfo.SellRate) buy=$($rateInfo.BuyRate) -> workbook rate=$($rateInfo.WorkbookRate)"

    try {
        & (Join-Path $scriptRoot 'update_rate.ps1') -WorkbookPath $workbookPath -DateString $dateString -Rate $rateInfo.WorkbookRate -SnapshotPath $snapshotPath
    } catch {
        if ($_.Exception.Message -like '*already has an entry for*') {
            $status = 'SKIP (month already logged)'
            Write-Host "This month is already logged - skipping (not an error): $($_.Exception.Message)"
            return
        }
        throw
    }

    & (Join-Path $scriptRoot 'New-MonthlyEmailDraft.ps1') -WorkbookPath $workbookPath -SnapshotPath $snapshotPath

    $status = 'SUCCESS (full pipeline ran)'
    Write-Host "=== Pipeline complete ==="
} catch {
    $status = "ERROR: $($_.Exception.Message)"
    throw
} finally {
    Write-Host "=== Run status: $status ==="
    Stop-Transcript | Out-Null
}
