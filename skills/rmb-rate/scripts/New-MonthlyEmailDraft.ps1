<#
Creates a Gmail DRAFT (never sends) for the monthly RMB(CNH) exchange rate email,
via the Gmail REST API directly (gmail.compose scope only - this script never calls
the send endpoint). Reuses the same OAuth app/token as the weekly exchange rate
project (Weekly Exchange Report - CLAUDE\Scripts\Connect-GmailOAuth.ps1) - the
encrypted token here was copied from there and is decryptable because Windows DPAPI
ties it to this Windows user/machine, not to the file's location.

Unlike the chat-based Gmail connector tool, the direct API supports attachments, so
this script attaches the dated snapshot workbook automatically - no manual attach step.

Run update_rate.ps1 first to append the month's rate and produce the snapshot file;
this script reads the latest date/rate straight from the workbook (source of truth)
rather than taking them as separate parameters, so it can't drift out of sync.
#>

[CmdletBinding()]
param(
    [string]$WorkbookPath = (Join-Path (Split-Path (Split-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -Parent) -Parent) 'FIN_Ex Rate HKD-RMB(BOC)_TEMP.xlsx'),
    [string]$SnapshotPath,
    [string[]]$To = @(
        'joycelam@ic.meyer-mhk.com', 'maylau@meyer-mhk.com', 'keithy@meyer-mtc.com', 'mhyuen@meyer-mtc.com',
        'bessyl@meyer-mts.com', 'pccken@silverstone-stc.com', 'yunyu@raco-ril.com', 'starchan@meyer-mzq.com',
        'yanh@silverstone-stc.com', 'kenny@meyer-mzq.com', 'zoew@meyer-mhk.com'
    ),
    [string[]]$Cc = @('stevenc@meyer-mhk.com')
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'GmailOAuth.Common.ps1')

if (-not (Test-Path $WorkbookPath)) {
    throw "Workbook not found: $WorkbookPath"
}

function Format-Base64Wrapped {
    param([string]$Base64, [int]$LineLength = 76)
    $sb = New-Object System.Text.StringBuilder
    for ($i = 0; $i -lt $Base64.Length; $i += $LineLength) {
        $len = [Math]::Min($LineLength, $Base64.Length - $i)
        [void]$sb.AppendLine($Base64.Substring($i, $len))
    }
    return $sb.ToString()
}

# ---- Read the latest date/rate straight from the workbook (read-only open) ----
$xlUp = -4162
$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$excel.DisplayAlerts = $false
$entryDate = $null
$rate = $null
try {
    $wb = $excel.Workbooks.Open($WorkbookPath, 0, $true)
    $dataSheet = $wb.Worksheets.Item('Data')
    $lastRow = $dataSheet.Cells.Item($dataSheet.Rows.Count, 1).End($xlUp).Row
    $entryDate = [datetime]::FromOADate($dataSheet.Cells.Item($lastRow, 1).Value2)
    $rate = $dataSheet.Cells.Item($lastRow, 3).Value2
    $wb.Close($false)
} finally {
    $excel.Quit()
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($excel) | Out-Null
}
if (-not $entryDate -or -not $rate) { throw "Could not read the latest date/rate from $WorkbookPath - run update_rate.ps1 first." }

$dateString = $entryDate.ToString('yyyy-MM-dd')
$rateString = [Math]::Round($rate, 4).ToString('0.0###')

if (-not $SnapshotPath) {
    $SnapshotPath = Join-Path (Split-Path $WorkbookPath -Parent) ("FIN_Ex Rate HKD-RMB(BOC)_{0}.xlsx" -f $dateString)
}
if (-not (Test-Path $SnapshotPath)) {
    throw "Snapshot not found: $SnapshotPath - run update_rate.ps1 first (it creates this file)."
}
$attachmentFileName = [System.IO.Path]::GetFileName($SnapshotPath)

Write-Host "Workbook   : $WorkbookPath"
Write-Host "Snapshot   : $SnapshotPath"
Write-Host "Date/Rate  : $dateString / $rateString"
Write-Host "Recipients : $($To.Count) in To, Cc: $($Cc -join ', ')"

$accessToken = Get-GmailAccessToken

$bodyText = @"
Dear May,

Please see the attached file,

Today, the CNH exchange rate is HKD1 = $rateString (sell rates & offshore).

Anthony
"@

$attachmentBytes = [System.IO.File]::ReadAllBytes($SnapshotPath)
$attachmentBase64 = Format-Base64Wrapped -Base64 ([Convert]::ToBase64String($attachmentBytes))

$boundary = "----=_MonthlyRmbRate_$([guid]::NewGuid().ToString('N'))"
$toHeader = ($To -join ', ')
$ccHeader = ($Cc -join ', ')
$subject = "RMB(CNH) Exchange Rate as at $dateString"

$mimeLines = @(
    "To: $toHeader",
    "Cc: $ccHeader",
    "Subject: $subject",
    "MIME-Version: 1.0",
    "Content-Type: multipart/mixed; boundary=`"$boundary`"",
    "",
    "--$boundary",
    "Content-Type: text/plain; charset=`"UTF-8`"",
    "",
    $bodyText,
    "",
    "--$boundary",
    "Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet; name=`"$attachmentFileName`"",
    "Content-Disposition: attachment; filename=`"$attachmentFileName`"",
    "Content-Transfer-Encoding: base64",
    "",
    $attachmentBase64,
    "--$boundary--"
)
$mime = $mimeLines -join "`r`n"

$rawBytes = [System.Text.Encoding]::UTF8.GetBytes($mime)
$rawBase64Url = [Convert]::ToBase64String($rawBytes).Replace('+', '-').Replace('/', '_').Replace('=', '')

$payload = @{ message = @{ raw = $rawBase64Url } } | ConvertTo-Json -Depth 5
$payloadBytes = [System.Text.Encoding]::UTF8.GetBytes($payload)

$headers = @{ Authorization = "Bearer $accessToken" }
$response = Invoke-RestMethod -Uri 'https://gmail.googleapis.com/gmail/v1/users/me/drafts' -Method Post `
    -Headers $headers -ContentType 'application/json; charset=utf-8' -Body $payloadBytes

Write-Host "Draft created - id: $($response.id)"
Write-Host "Open Gmail to review it (recipients + attachment already correct), then send yourself."
