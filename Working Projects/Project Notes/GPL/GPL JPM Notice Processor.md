---
tags: [project, fs-roll-forward, tool]
---

# GPL JPM Notice Processor

Tool for processing JPM notices, feeding [[GPL FS Roll-Forward]]. **Use v5.4, not v4.**

2026-08-05: fixed a false-duplicate-detection bug caused by a new JPM notice layout — if a new layout appears again, check duplicate-detection logic first.

2026-08-10 (v5.4.2): fixed an FX Spot notice type that was silently dropped from the exported Journal with zero lines and no flag, plus a CSV UTF-8 BOM issue that corrupted em-dashes to "??". Found during the first Internal Audit cycle — see [[GPL FS Roll-Forward]].

## Related

- [[GPL UBS Statement Processor]] — sibling tool for the other custodian, same FS roll-forward.

## Full detail
`C:\Users\User\.claude\projects\c--Users-User-Desktop\memory\project_gpl_jpm_notice_processor.md`
