---
tags: [project, mpl, accounting]
---

# MPL Accounting Module

Part of the MPL (Meyer Properties Limited) toolset, alongside [[MPL Property Management System]]. `MPL_Accounting.html`, opened via the launcher `MPL_Combined.html` (Desktop shortcut **MPL**), embeds `MPL_Journal_Generator_v8.html` as its Journal Generator tab.

State 2026-10-05: tabs in order — Chart of Accounts, Trial Balance, Ledger, Accounts Receivable (1910) open items, Accrual/Prepayment (1900/2500), **Bank Reconciliation** (moved out of the Journal Generator into its own tab; output redesigned to an HKICPA-style statement matching the production workbook's `20_Bank_Reconciliation` sheet — 7/7 validated against the user's own confirmed September 2026 reconciliation), Journal Generator, and Journal (draft → posted via an Excel round trip: Export → paste into `30_GJ_2026` → re-import). Repo: `C:\Users\User\Desktop\GitHub-Clones\MPL` (git, source of truth), copied to `Meyer\MPL\MPL Claude` after each merge. Launcher renamed `MPL_System.html` 2026-10-06.

Sharing gotcha (2026-10-06): the posted journal lives in the browser's localStorage, not in the file - a colleague opening the shared `MPL_System.html` saw Property Management (built-in seed data) but an empty MPL Accounting. Fixed first with **Export Data / Import Data** (one `.json` carrying every Accounting data set), then - at the user's request "saved to HTML not localStorage" - with **Save MPL_System.html with data** on the launcher: the page clones itself with every module's `mpl_*` keys in an `#embedded-data` block (TiddlyWiki-style self-save; a browser cannot write the file it opened), and a copy opened elsewhere loads the data on first open or asks when newer.

Known open item: two pre-existing real-data tests (`core.kpi.test.js`, `core.tb.test.js`) diverge by $20 from a separate workbook (`FIN_MPL0826_20260921_RV0.xlsx`) that hasn't caught up with a correction the user made this week to account 1260 — a genuine cross-document state mismatch, not a code bug; flagged to the user, not silently fixed.

## Related

- [[MPL Property Management System]] — the sibling property-management modules sharing the same launcher.
- [[Skill - Access Control Module]] — login/permission gate pattern used by the launcher.
- [[Skill - Bilingual Replies]] — this project requires every reply in English + Traditional Chinese.

## Full detail

`C:\Users\User\.claude\projects\c--Users-User-Desktop\memory\project_mpl_accounting_module.md`
