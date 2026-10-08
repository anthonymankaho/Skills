<#
Reads the Claude Code usage caches and reports the 7-day quota.
Usage:  powershell -NoProfile -File check-usage.ps1 [-ThresholdRemaining 10]
Output: key=value lines. The last line is  DECISION=HANDOFF  or  DECISION=OK.
Read-only: never touches .credentials.json.
#>
param([double]$ThresholdRemaining = 10)

$claude = Join-Path $env:USERPROFILE '.claude'
$cands = @()

# Source 1: usage-cache.json (utilization = USED percent, 0-100)
$f1 = Join-Path $claude 'usage-cache.json'
if (Test-Path $f1) {
    try {
        $j = Get-Content $f1 -Raw | ConvertFrom-Json
        if ($j.data.seven_day -and $null -ne $j.data.seven_day.utilization) {
            $cands += [pscustomobject]@{
                Source = 'usage-cache.json'
                Used   = [double]$j.data.seven_day.utilization
                At     = [DateTimeOffset]::FromUnixTimeMilliseconds([int64]$j.fetchedAt).LocalDateTime
                Reset  = ([DateTimeOffset]::Parse($j.data.seven_day.resets_at)).LocalDateTime
            }
        }
    } catch {}
}

# Source 2: vscode-claude-status-cache.json (utilization7d = USED fraction, 0-1)
$f2 = Join-Path $claude 'vscode-claude-status-cache.json'
if (Test-Path $f2) {
    try {
        $j = Get-Content $f2 -Raw | ConvertFrom-Json
        if ($null -ne $j.usageData.utilization7d) {
            $cands += [pscustomobject]@{
                Source = 'vscode-claude-status-cache.json'
                Used   = [double]$j.usageData.utilization7d * 100
                At     = ([DateTimeOffset]::Parse($j.updatedAt)).LocalDateTime
                Reset  = [DateTimeOffset]::FromUnixTimeSeconds([int64]$j.usageData.reset7dAt).LocalDateTime
            }
        }
    } catch {}
}

if (-not $cands) {
    "SOURCE=none"
    "NOTE=No usage cache readable. Ask the user to run /usage and read the 7-day figure."
    "DECISION=UNKNOWN"
    exit 0
}

$c = $cands | Sort-Object At -Descending | Select-Object -First 1
$remaining = [math]::Round(100 - $c.Used, 1)
$ageMin = [math]::Round(((Get-Date) - $c.At).TotalMinutes)

"SOURCE=$($c.Source)"
"SEVEN_DAY_USED_PCT=$([math]::Round($c.Used,1))"
"SEVEN_DAY_REMAINING_PCT=$remaining"
"SEVEN_DAY_RESETS_LOCAL=$($c.Reset.ToString('yyyy-MM-dd HH:mm'))"
"CACHE_AGE_MIN=$ageMin"
if ($ageMin -gt 30) { "NOTE=Cache is older than 30 min; confirm with /usage before relying on it." }
if ($remaining -lt $ThresholdRemaining) { "DECISION=HANDOFF" } else { "DECISION=OK" }
