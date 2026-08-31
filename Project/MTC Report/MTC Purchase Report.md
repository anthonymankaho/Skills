---
tags: [project, mtc-purchase-report]
---

# MTC Purchase Report

PowerShell replacement for UiPath RPA steps 5–8 of the monthly MTC Purchase Report (Material Receipt Report). EPICOR login/export (steps 1–4) stays manual — browser automation for that step previously caused Excel zombie processes in testing. Two script options: Script A (Excel COM, retroactively recalculates commission/cost for all rows) or Script B (no Excel needed, faster, only computes new rows). 2026-08-11: fixed a bug where the script's write overwrote a Table's header row, causing Excel to silently delete the Table object — PivotTables now correctly extend to new data. Shares its exchange-rate source file with [[MTC Sales Report]].

*Note: reconstructed from the project's files/git history, not built via direct collaboration with Claude — treat as observation, not recollection.*

## Related
- [[MTC Sales Report]] — sibling project, shares `Sales-Data-MTC-Mthly Rate.xlsx` as the exchange-rate source.
- [[Global Purchase Report RPA]] — another UiPath-to-PowerShell rebuild, same shape (manual portal step kept manual).

## Full detail
`C:\Users\User\.claude\projects\c--Users-User-Desktop\memory\project_mtc_purchase_report_claude.md`
