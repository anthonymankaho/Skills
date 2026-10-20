---
tags: [project, mtc-sales-report]
---

# MTC Sales Report

Claude Code replacement for the manual data-entry portion of the monthly MTC sales/commission RPA process. HTML import tool stages rows from IVR032/exchange-rate/commission/PO-comm source files; `Combine-Into-Master.ps1` (real Excel COM automation, not the original SheetJS approach which corrupted pivot tables) merges them into the master workbook. Dynamic "Performance dashboard" tab rebuilt so its slicers actually drive PivotCharts. 2026-08-12: found and fixed a formula-decay bug (Cust_Countries silently went static, corrupting Geographic Performance data for months) and added a safety check to catch the same class of bug automatically going forward.

## Related
- [[Wait for explicit PowerShell orders]] — general default; overridden for this project by an explicit blanket approval from the user (2026-08-12).
- [[Bilingual replies]] — applied throughout.
- Sibling PS-rebuild-of-manual-RPA project: [[Global Purchase Report RPA]].

## Full detail
`C:\Users\User\.claude\projects\c--Users-User-Desktop\memory\project_mtc_sales_report_claude.md`
