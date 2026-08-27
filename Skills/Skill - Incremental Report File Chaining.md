---
tags: [skill, pattern]
---

# Skill: Incremental Report File Chaining

Personal skill for a recurring bug pattern: **stale-template / date-window bugs** in periodic report rebuilds. Core rule: don't pick a "base" file by comparing timestamps across candidate files — parse the actual period/date encoded in the data or filename instead.

Check this skill for **any** periodic-report rebuild before writing file-selection logic.

## Where this bit us for real
- [[Global Purchase Report RPA]]'s `Generate-PurchaseReportHtml.ps1` picked the wrong source file because it sorted candidates by file-touch time instead of the reporting period in the filename — found via real VBA-button testing, fixed 2026-08-25.

## Related
- Also informs [[GPL FS Roll-Forward]] and [[EIC FS Roll-Forward]] (roll-forward = chained periods by nature).

## Full detail
`C:\Users\User\.claude\projects\c--Users-User-Desktop\memory\reference_incremental_report_file_chaining_skill.md`
