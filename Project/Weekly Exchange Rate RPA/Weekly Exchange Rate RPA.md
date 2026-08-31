---
tags: [project, exchange-rate, rpa]
---

# Weekly Exchange Rate RPA

Weekly multi-currency exchange-rate report, rebuilt from UiPath RPA into PowerShell. Was itself converted into a 17-tab interactive HTML version this same session's era of work — the source of most of the DataTables/flatpickr gotchas now written up in [[Skill - Excel to Interactive HTML Report]].

## Known issues found & fixed
- Recent pivot-table error (see full memory for detail).
- The IE tab-strip redirect bug, flatpickr mobile-swap bug, and WebKit `new Date()` partial-string bug — all found via real device/browser testing, not code review.

## Related
- [[RMB CNH Exchange Rate (May Lau)]] reuses this project's Gmail OAuth setup for attachment-capable drafts.
- [[Monthly Exchange Rate RPA]] is a **separate** project — different report, different recipients, don't conflate the two.
- Feeds lessons into [[Skill - Excel to Interactive HTML Report]].
- Full script-by-script list: [[Weekly Exchange Rate RPA - PowerShell Scripts Reference]].

## Full detail
`C:\Users\User\.claude\projects\c--Users-User-Desktop\memory\project_weekly_exchange_rate_rpa.md`
