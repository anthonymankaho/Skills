---
tags: [skill, pattern, html, excel]
---

# Skill: Excel to Interactive HTML Report

COM export + DataTables/flatpickr pattern for turning periodic Excel reports into single-file interactive HTML. Grown from real bugs found via testing, not code review — see the skill file for the full gotcha list (flatpickr mobile-swap, WebKit `new Date()` partial-string parsing, DataTables `scrollX`/`autoWidth` column-shift, chart-color consistency, extracting a labeled sub-table by cell instead of scraping native export).

## Used by
- [[Weekly Exchange Rate RPA]] — original source of most gotchas (17-tab HTML rebuild).
- [[Global Purchase Report RPA]] — 2026-08-25 session added the scrollX/autoWidth and chart-color gotchas, plus the "extract by cell" pattern for the Exchange Rate sub-table.

## Full detail (the actual skill file, not just this summary)
`C:\Users\User\.claude\skills\excel-to-interactive-html-report\SKILL.md`
