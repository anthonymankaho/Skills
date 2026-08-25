---
tags: [project, purchase-report, rpa]
---

# Global Purchase Report RPA

Monthly report merging purchase data from 7 entities (MHK, STC, MZQ, MIL, RACO, TVS, MAZAL) — historically a UiPath RPA process, now being rebuilt in PowerShell (merge/report-generation step only; EPICOR export and email/MMS upload stay manual).

## Current state
- Interactive HTML report generator (`build_report.js` + `Generate-PurchaseReportHtml.ps1`) heavily reworked: item-level collapse toggle, DB chart color consistency, column autofit, Ignore/Consider filter with plain-language labels, Exchange Rate page rebuilt as a DataTables page, source-file auto-detection fixed to sort by reporting period (not file-touch time).
- Fixed a real corrupted-named-range bug in `OUTSIDETEMP.xlsx` (18 PivotTables were failing to refresh).
- VBA button prototype (`HtmlUpdateModule.bas`) sandbox-tested for triggering the HTML build from Excel — not yet deployed (macro-security policy unconfirmed).
- Known gap: MAZ's PEN exchange rate isn't in the `STANDARD EXCHANGE RATE` source file — `Get-PenExchangeRate.ps1` now fetches it from the Pacific Exchange Rate Service (UBC Sauder), not yet wired into the report.
- Open decision: TVS has no graceful skip-if-missing (unlike MAZ) — July 2026 build blocked until TVS data arrives.

## Related
- Category: [[PS]]
- Uses [[Skill - Excel to Interactive HTML Report]] and [[Skill - Incremental Report File Chaining]] extensively.
- Distinct from [[RMB CNH Exchange Rate (May Lau)]] and the exchange rate projects below (different report, different entity scope).

## Full detail
`C:\Users\User\.claude\projects\c--Users-User-Desktop\memory\project_global_purchase_report_rpa.md`
Project folder: `C:\Users\User\Desktop\Global Purchase Report Claude\`
