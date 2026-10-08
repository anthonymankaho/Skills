---
name: rmb-rate
description: Monthly BOC HK CNH/HKD exchange rate update - fetch the rate, append it to the tracking workbook, and draft the distribution email to May Lau and team.
---

# Monthly RMB (CNH) exchange rate update

This replaces the old UiPath process ("Monthly 14th CNH Exchange to May Lau (BOC DATA)",
see `../../../project.json`) with the same steps, run around the 14th of each month:
fetch the Bank of China (Hong Kong) offshore RMB rate, log it, save a dated snapshot,
and draft the notification email. Nothing is sent automatically - a human always
reviews the Gmail draft before hitting send.

Workbook: `../../../FIN_Ex Rate HKD-RMB(BOC)_TEMP.xlsx` (the `Data` sheet is the
source of truth; `HKD TO CHN (SELL PRICE)` and `Data for chart` are display/reporting
sheets fed by it).

## This now runs automatically (added 2026-07-31, confirmed firing 2026-08-10)

A Windows Scheduled Task (`MonthlyRmbCnhExchangeRateReport`) fires
`scripts/Run-MonthlyPipeline.ps1` daily at 9:00 AM. The script itself decides
whether to actually act: it fetches the live Hong Kong public holiday calendar
(`scripts/Get-HkHolidays.ps1`, from the official 1823.gov.hk feed - no annual
maintenance needed) and computes the target day as the 14th, rolled forward past
any Saturday/Sunday/HK public holiday (so if the 14th and 15th are both
non-working days, it runs on the 16th - and keeps rolling forward further if
needed, though that hasn't happened in practice). On any other day it logs a
one-line skip and exits - not an error.

**Confirmed genuinely running, including a real end-to-end firing:** on
2026-08-14 the task ran fully unattended - fetched the rate, wrote `Data` row
90, saved the snapshot, and created the Gmail draft - with zero manual/Claude
involvement. See real log excerpts in `SOP.md`'s History section.

Observed quirk (harmless): if the PC wasn't logged in over a weekend, the task's
"start when available" setting fires a catch-up run shortly after login, in
addition to the regular 9:00 AM firing that same day - both just re-run the same
skip/guard logic, so this never causes a duplicate action.

**Hardening (2026-08-27):** two firings (2026-08-18, 2026-08-26) were found
with a transcript that cut off abruptly right after starting, no error, no
proper close - almost certainly an unbounded web request hang (holiday-feed
fetch) that got killed externally before it could throw a catchable error.
Neither was a target day, so no data was at risk, but the check itself failed
silently instead of logging cleanly. Fixed: both `Get-HkHolidays.ps1` and
`Get-BocCnhRate.ps1` now have a 20s request timeout; `Run-MonthlyPipeline.ps1`
retries each fetch once via a shared `Invoke-WithRetry` helper, and the holiday
fetch specifically falls back to a weekends-only rule (with a loud `WARNING:`
line) if it still fails after retrying, rather than taking down the whole
day's check. Every run now ends with an explicit `=== Run status: ... ===`
line (`SKIP`/`SUCCESS`/`ERROR: <message>`) so a failure is never silent again.

On the target day it runs the full pipeline itself, with no AI/Claude session
needed at runtime: `scripts/Get-BocCnhRate.ps1` (pure PowerShell/regex fetch -
the underlying rates URL is static HTML, no JS rendering, so no WebFetch/AI
parsing step is required unattended) -> `update_rate.ps1` -> `New-MonthlyEmailDraft.ps1`.
If the month is already logged (e.g. someone ran it manually earlier that month),
the duplicate-month guard is caught and treated as an informational skip - no
duplicate draft gets created.

**Requirements for the scheduled run to actually fire successfully:**
- The workbook must be **closed** in Excel (both scripts drive it via COM).
- Per Excel COM's own unattended-use limitations, the task's logon type is
  Interactive - **the Windows user must be logged in** at 9:00 AM (same
  constraint already accepted for the Weekly Exchange Report project's task).
  Confirmed in practice: no log is written on weekend days the PC wasn't on.
- Logs land in `scripts/Logs/run_<timestamp>.log` (one per firing, including
  the skip days) - check there first if a month seems to have been missed.

This does **not** replace the ability to run it manually/early - see "Steps"
below for how to walk through it yourself (e.g. to test, or to log an
off-cycle rate). `Run-MonthlyPipeline.ps1` also accepts `-Today <date>` to
dry-run the target-day logic for any date without waiting for the real clock.

## Steps

1. **Fetch the rate.** Use WebFetch on:
   `https://www.bochk.com/whk/rates/exchangeRatesHKD/exchangeRatesHKD-input.action?lang=hk`
   (this is the raw rates iframe behind the public page - the outer
   `hkdrates.html` page is JS-shell only and won't return numbers).
   Ask it to report the `人民幣(離岸)` (offshore RMB / CNH) row, both the
   `客戶賣出` (customer sell) and `客戶買入` (customer buy) values, and the
   "資料更新於" timestamp shown on the page.

2. **Compute the logged rate.** The workbook stores "HKD1 = X CNH, sell rate,
   offshore", which is the **reciprocal** of BOC's `客戶賣出` value for
   `人民幣(離岸)` (BOC quotes HKD-per-1-CNH; the sheet wants CNH-per-1-HKD).
   `Rate = 1 / 客戶賣出`, rounded to 4 decimal places.
   Example: 客戶賣出 = 1.151100 -> Rate = 0.8687.

3. **Pick the entry date.** Default to today's date. If running late (e.g. well
   after the 14th), it's fine to log it as the run date - just be consistent
   with the email subject/body date below.

4. **Update the workbook.** Run the bundled script (requires Excel installed
   locally; close the workbook in Excel first if it's open):

   ```powershell
   powershell -File "scripts/update_rate.ps1" `
     -WorkbookPath "<absolute path to>FIN_Ex Rate HKD-RMB(BOC)_TEMP.xlsx" `
     -DateString "YYYY-MM-DD" `
     -Rate <computed rate> `
     -SnapshotPath "<same folder>\FIN_Ex Rate HKD-RMB(BOC)_YYYY-MM-DD.xlsx"
   ```

   The script finds the last populated row in the `Data` sheet, appends the new
   date/rate, fills in the day/month/year helper formulas explicitly (don't rely
   on the template's pre-filled formulas - at least one row was found missing
   them), refreshes any pivot tables, saves the workbook in place, and saves the
   dated snapshot copy. It refuses to add a second entry for a month that's
   already logged unless you pass `-Force`.

   **`Data for chart` is now kept in sync automatically (fixed 2026-09-14).**
   This dashboard sheet was previously a known gap - its manually-curated
   table drifted 4 months stale (May through Sep 2026) before being caught and
   fixed. Root cause fully understood now: the table's 2025+ rows are sorted
   newest-first, and only the top 12 rows are left visible (`hidden="1"` on
   the rest) - a deliberate trailing-12-month display window for chart2 (whose
   cached series had exactly 12 points), not an accident. A second, related
   bug was also found and fixed: the "Latest Rate" dashboard stat used
   `INDEX(...,COUNTA(...))`, a positional lookup that assumed ascending order
   and silently grabbed the *oldest* row of the reversed block instead of the
   newest. `update_rate.ps1` now calls `ChartTableSync.ps1`'s
   `Sync-ChartTableRow` (inserts the new row above the current peak,
   preserving the visible-window size and alternating row banding) and
   `Repair-LatestRateFormula` (a date-based `MATCH(MAX(...))` lookup instead
   of the positional one) every month - non-fatally, so a failure here logs a
   warning but never blocks the critical Data-sheet-update-and-email path. See
   `ChartTableSync.ps1`'s header comment for the full mechanics, including a
   real gotcha worth knowing before touching this sheet again: a whole-row
   Copy/PasteSpecial for styling tripled the file size (applied formatting
   across all 16,384 columns instead of the 6 in use) - fixed by doing
   per-cell Copy/PasteSpecial instead, and by setting formulas *before*
   formatting (setting a date-look-alike formula on an unformatted cell
   triggers Excel's auto-date-formatting, silently undoing formatting set
   beforehand).

5. **Draft the notification email — with the attachment included.** Run:

   ```powershell
   powershell -File "scripts/New-MonthlyEmailDraft.ps1"
   ```

   This creates the Gmail draft via a direct Gmail REST API call (`gmail.compose`
   scope, drafts-only — it never calls the send endpoint), reusing the same OAuth
   app/token as the Weekly Exchange Report project (`Credentials/gmail_oauth_token.enc`,
   Windows-DPAPI-encrypted to this user/machine). Unlike the chat-based
   `mcp__claude_ai_Gmail__create_draft` tool (which cannot attach files), this
   script reads the latest date/rate straight from the workbook and attaches the
   dated snapshot automatically — no manual attach step needed.

   Do **not** use `mcp__claude_ai_Gmail__create_draft` for this step — it was the
   original approach and is kept working for other uses, but any draft it creates
   for this process will be missing the attachment.

   Recipients/subject/body defaults already match the SOP (`to`/`cc` list below);
   override with `-To`/`-Cc` only for testing.

   - `to` (default): joycelam@ic.meyer-mhk.com, maylau@meyer-mhk.com,
     keithy@meyer-mtc.com, mhyuen@meyer-mtc.com, bessyl@meyer-mts.com,
     pccken@silverstone-stc.com, yunyu@raco-ril.com, starchan@meyer-mzq.com,
     yanh@silverstone-stc.com, kenny@meyer-mzq.com, zoew@meyer-mhk.com
   - `cc` (default): stevenc@meyer-mhk.com
   - `subject`: `RMB(CNH) Exchange Rate as at <date>`
   - `body`: `Dear May, / Please see the attached file, / Today, the CNH exchange
     rate is HKD1 = <rate> (sell rates & offshore). / Anthony`

   If `Connect-GmailOAuth.ps1` was never re-run in this folder and the stored
   token has expired/been revoked, `Get-GmailAccessToken` will throw — see
   `../../../Weekly Exchange Report - CLAUDE/Docs/PHASE3_GMAIL_OAUTH_SETUP.md`
   for the reauthorization steps (same OAuth app is shared between both projects).

6. **Report back** with: the fetched BOC values, the computed rate, the row
   number written, the snapshot file path, and the Gmail draft ID/link — plus a
   reminder to review the draft (recipients + attachment are already correct)
   before sending.
