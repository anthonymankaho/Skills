<#
Appends one row to the "Data" sheet of the BOC HKD/CNH exchange rate workbook,
syncs the "Data for chart" dashboard table (see ChartTableSync.ps1 - this table
is NOT a live view of "Data" and drifted 4 months stale before being caught and
fixed on 2026-09-14), refreshes the pivot table/chart, saves the workbook in
place, and saves a dated snapshot copy for distribution. Mirrors the original
UiPath RPA steps, but uses Excel COM directly so pivot/chart refresh works
headlessly.
#>
param(
    [Parameter(Mandatory = $true)][string]$WorkbookPath,
    [Parameter(Mandatory = $true)][string]$DateString,   # yyyy-MM-dd
    [Parameter(Mandatory = $true)][double]$Rate,         # HKD1 = X CNH (sell, offshore)
    [Parameter(Mandatory = $true)][string]$SnapshotPath, # full path for the dated copy
    [switch]$Force                                       # allow a second entry in the same month
)

$ErrorActionPreference = "Stop"
$xlUp = -4162

$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$excel.DisplayAlerts = $false
$wb = $null

try {
    $wb = $excel.Workbooks.Open($WorkbookPath)
    $dataSheet = $wb.Sheets.Item("Data")

    $lastRow = $dataSheet.Cells.Item($dataSheet.Rows.Count, 1).End($xlUp).Row
    $newRow = $lastRow + 1

    $entryDate = [datetime]::ParseExact($DateString, "yyyy-MM-dd", $null)

    $lastDateValue = $dataSheet.Cells.Item($lastRow, 1).Value2
    if ($lastDateValue) {
        $lastDate = [datetime]::FromOADate($lastDateValue)
        if (-not $Force -and $lastDate.Year -eq $entryDate.Year -and $lastDate.Month -eq $entryDate.Month) {
            throw "Row $lastRow already has an entry for $($lastDate.ToString('yyyy-MM')) (rate=$($dataSheet.Cells.Item($lastRow, 3).Value2)). Pass -Force to add a second entry for the same month."
        }
    }

    # Carry the date/rate cell formatting forward from the previous row.
    $dataSheet.Cells.Item($lastRow, 1).Copy() | Out-Null
    $dataSheet.Cells.Item($newRow, 1).PasteSpecial(-4122) | Out-Null   # xlPasteFormats
    $dataSheet.Cells.Item($lastRow, 3).Copy() | Out-Null
    $dataSheet.Cells.Item($newRow, 3).PasteSpecial(-4122) | Out-Null

    $dataSheet.Cells.Item($newRow, 1).Value2 = $entryDate.ToOADate()
    $dataSheet.Cells.Item($newRow, 3).Value2 = $Rate

    # Set these explicitly rather than trusting the template's pre-filled formulas -
    # at least one row (89) in the source workbook was found to be missing them.
    $dataSheet.Cells.Item($newRow, 2).Formula = ('=IF(A{0}="","",TEXT(WEEKDAY(A{0}),"DDD"))' -f $newRow)
    $dataSheet.Cells.Item($newRow, 4).Formula = ('=IF(A{0}="","",TEXT(A{0},"mmm"))' -f $newRow)
    $dataSheet.Cells.Item($newRow, 5).Formula = ('=IF(A{0}="","",TEXT(A{0},"yyyy"))' -f $newRow)
    $dataSheet.Cells.Item($newRow, 6).Formula = ('=IF(A{0}="","",TEXT(A{0},"yyyy""-""mm"))' -f $newRow)

    # Keep the "Data for chart" dashboard table (and its chart/stats) in sync.
    # Non-fatal by design: this table is a display nicety, not the source of
    # truth, so a failure here logs a warning and lets the critical path (Data
    # sheet + snapshot + email) proceed rather than blocking the whole run.
    try {
        . (Join-Path $PSScriptRoot 'ChartTableSync.ps1')
        Sync-ChartTableRow -Workbook $wb -DataRow $newRow
        Repair-LatestRateFormula -Workbook $wb
    } catch {
        Write-Host "WARNING: 'Data for chart' sync failed ($($_.Exception.Message)) - Data sheet update still proceeding; the dashboard chart/stats may need a manual look."
    }

    foreach ($sheet in $wb.Sheets) {
        foreach ($pt in $sheet.PivotTables()) {
            $pt.RefreshTable() | Out-Null
        }
    }
    $wb.RefreshAll()
    $excel.CalculateFullRebuild()

    $wb.Save()
    $wb.SaveCopyAs($SnapshotPath)

    Write-Output "OK row=$newRow date=$DateString rate=$Rate snapshot=$SnapshotPath"
}
finally {
    if ($wb) { $wb.Close($false) }
    $excel.Quit()
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($excel) | Out-Null
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
}
