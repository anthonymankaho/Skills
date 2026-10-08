<#
Defines Sync-ChartTableRow and Repair-LatestRateFormula, dot-sourced by both
update_rate.ps1 (one row per month, going forward) and the one-time backfill
that fixed the 4 months (Jun-Sep 2026) missing as of 2026-09-14.

Background: the "Data for chart" sheet's dashboard table is NOT a live view of
"Data" - it's a fixed range (currently $A$34:$A$<lastRow>, mirrored by the Excel
Table "ExchangeRateTable" and chart2's series) built from individual per-cell
cross-sheet formulas (=Data!A<n>, =Data!B<n>, etc). Rows for 2019-2024 are
ascending (oldest to newest); at some point rows for 2025 onward were pasted in
descending order (newest first) on top of that, and that descending block simply
stopped being extended when new months were added to "Data" - drifting 4 months
stale before this was caught and fixed.

Sync-ChartTableRow finds the current "peak" row (the most recent entry already
present) by scanning down column A for the first point where the date value
decreases from one row to the next - everything up to and including that peak
row is the ascending 2019-2024 block; everything after it is the descending
2025+ block. It inserts exactly one new row immediately above the peak (pushing
the peak and everything below it down by one), matching the descending block's
alternating row-banding style, then points that new row's formulas at the given
Data-sheet row. Because the insertion happens inside the range every dependent
formula/table/chart already references, Excel auto-extends all of them - no
manual chart or table range editing needed.

Important discovery (2026-09-14): the 12 rows immediately below the peak are
NOT hidden, and everything past that IS hidden (`hidden="1"` on the row) -
this exactly matches chart2's cached series, which has 12 points. This isn't
incidental: it's a deliberate trailing-12-month display window, and it's *why*
this block is sorted newest-first in the first place - a human just inserts the
new month at the top and lets the 13th-oldest row silently fall into the hidden
zone below. Sync-ChartTableRow preserves this window size (measured fresh each
call, not hardcoded) after every insert, so the chart keeps showing exactly the
trailing N months rather than slowly including more and more history.

Also important: all Insert/Copy/PasteSpecial operations here work on Range
objects restricted to columns A:F, never whole Rows() objects - a whole-row
Insert/PasteSpecial was found (2026-09-14) to materialize explicit per-cell
styles across all 16,384 columns instead of just the 6 in use, roughly
tripling the file size for what should have been a handful of new cells. Row
height/hidden state is unaffected by column-restricted operations, so those are
set explicitly afterward instead of relying on them to "come along for the ride".

To backfill multiple missing months, call Sync-ChartTableRow once per missing
Data row, oldest first (e.g. 88, then 89, then 90, then 91) - each call re-scans
for the current peak, so this naturally builds up the correct newest-first order
without any special-casing for how many rows are missing.
#>

function Sync-ChartTableRow {
    param(
        [Parameter(Mandatory)]$Workbook,
        [Parameter(Mandatory)][int]$DataRow
    )

    $xlUp = -4162
    $chartWs = $Workbook.Worksheets.Item('Data for chart')
    $firstRow = 34
    $lastRow = $chartWs.Cells.Item($chartWs.Rows.Count, 1).End($xlUp).Row

    $peakRow = $null
    for ($r = $firstRow; $r -lt $lastRow; $r++) {
        $cur = $chartWs.Cells.Item($r, 1).Value2
        $next = $chartWs.Cells.Item($r + 1, 1).Value2
        if ($cur -and $next -and ($next -lt $cur)) {
            $peakRow = $r
            break
        }
    }
    if (-not $peakRow) {
        throw "Sync-ChartTableRow: could not find the ascending/descending transition row in 'Data for chart' (A$firstRow`:A$lastRow) - the sheet's structure may have changed; needs a manual look before this can run safely."
    }

    $peakFormulaA = $chartWs.Cells.Item($peakRow, 1).Formula
    if ($peakFormulaA -notmatch '^=Data!A(\d+)$') {
        throw "Sync-ChartTableRow: unexpected formula at 'Data for chart'!A$peakRow ('$peakFormulaA') - expected a plain '=Data!A<n>' reference."
    }
    $lastChartedDataRow = [int]$Matches[1]

    if ($DataRow -le $lastChartedDataRow) {
        Write-Host "Sync-ChartTableRow: Data row $DataRow is already <= last charted Data row $lastChartedDataRow - skipping."
        return
    }

    # Measure the current trailing-visible-window size (consecutive non-hidden
    # rows starting at the peak), so it can be preserved exactly after the
    # insert shifts everything down by one - not hardcoded, in case it's ever
    # deliberately changed (e.g. to show 24 months instead of 12).
    $windowSize = 0
    for ($r = $peakRow; $r -le $lastRow; $r++) {
        if ($chartWs.Rows.Item($r).Hidden) { break }
        $windowSize++
    }

    # Capture a reference to the row that will end up directly below the new row
    # (i.e. the current peak, after it shifts down by one) so we can copy its
    # OPPOSITE banding style onto the new row - guarantees local alternation
    # regardless of which phase the block happens to be in.
    $styleSourceRowAfterShift = $peakRow + 2   # (peakRow+1) pre-shift -> +1 more after this insert

    # Must be a whole-row Insert - this range sits inside the "ExchangeRateTable"
    # Excel Table, which rejects a partial-width Range.Insert ("Cannot move
    # cells in a filtered range or table"). Formatting is fixed up per-cell
    # afterward instead (see below), since a whole-row Copy/PasteSpecial for
    # styling was found (2026-09-14) to materialize explicit per-cell styles
    # across all 16,384 columns instead of just the 6 in use, roughly tripling
    # the file size.
    $chartWs.Rows("$peakRow`:$peakRow").Insert(-4121, 1) | Out-Null   # xlShiftDown, xlFormatFromRightOrBelow

    foreach ($col in 'A', 'B', 'C', 'D', 'E', 'F') {
        $chartWs.Range("$col$peakRow").Formula = "=Data!$col$DataRow"
    }

    # Set explicit formatting AFTER the formula, not before - setting .Formula
    # on an unformatted cell whose result looks like a date was found
    # (2026-09-14) to trigger Excel's auto-date-formatting, silently
    # overwriting formatting set beforehand. Also: Range.Style is a NAMED style
    # (e.g. "Normal") - a separate layer from the direct per-cell formatting
    # (fill/border/number format) that actually creates the banding, so setting
    # .Style copies nothing useful here; per-cell Copy/PasteSpecial(xlPasteFormats)
    # is required - scoped to one cell at a time (not a whole row) to avoid the
    # 16,384-column bloat found earlier.
    foreach ($col in 'A', 'B', 'C', 'D', 'E', 'F') {
        $chartWs.Range("$col$styleSourceRowAfterShift").Copy() | Out-Null
        $chartWs.Range("$col$peakRow").PasteSpecial(-4122) | Out-Null   # xlPasteFormats
    }

    # Re-apply the trailing-visible-window invariant: the new peak through
    # (peak + windowSize - 1) visible, everything below that hidden - this is
    # what pushes the 13th-newest row into the hidden zone, exactly matching
    # the sheet's existing (until now, manually maintained) convention.
    $newLastRow = $lastRow + 1
    for ($r = $peakRow; $r -le $newLastRow; $r++) {
        $chartWs.Rows.Item($r).Hidden = ($r -ge ($peakRow + $windowSize))
    }

    Write-Host "Sync-ChartTableRow: inserted chart row $peakRow -> Data!$DataRow (previous peak was Data!$lastChartedDataRow); visible window = $windowSize rows."
}

function Repair-LatestRateFormula {
    param([Parameter(Mandatory)]$Workbook)

    $xlUp = -4162
    $chartWs = $Workbook.Worksheets.Item('Data for chart')
    $firstRow = 34
    $lastRow = $chartWs.Cells.Item($chartWs.Rows.Count, 1).End($xlUp).Row

    # B6 ("Latest Rate") used to be =INDEX(C34:C116,COUNTA(C34:C116)) - a
    # positional lookup that assumed ascending order and silently broke once the
    # 2025+ block was pasted in descending order. Replaced with a date-based
    # lookup that finds the rate for whichever row actually has the maximum
    # date - correct regardless of row order, current or future.
    $chartWs.Range('B6').Formula = "=INDEX(C$firstRow`:C$lastRow,MATCH(MAX(A$firstRow`:A$lastRow),A$firstRow`:A$lastRow,0))"
    Write-Host "Repair-LatestRateFormula: B6 now =INDEX(C$firstRow`:C$lastRow,MATCH(MAX(A$firstRow`:A$lastRow),A$firstRow`:A$lastRow,0))"
}
