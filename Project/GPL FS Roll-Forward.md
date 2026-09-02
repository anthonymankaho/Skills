---
tags: [project, fs-roll-forward]
---

# GPL FS Roll-Forward

Financial statement roll-forward project. Jul-2026 close fully completed (JPM + UBS both processed, `FIN_GPlume 2026-07_20260810_RV1.xlsx` is current — RV1 supersedes RV0, a same-day correcting entry for Xandria Limited related-party interest). GL-posting step (journal CSV → `G. GL 2026` column mapping) still not formalized as a script.

The 3-stage **AI MFS Governance Framework** (Builder=Claude Code → Preparer=Copilot in Excel → Auditor=Claude Code, Gemini at year-end only) is now the confirmed operating model — see [[Reference - AI MFS Governance Framework]]. First Internal Audit cycle run 2026-08-10/11; findings at `GPL Claude\GPL_FS_CLAUDE\Internal Audit\InternalAudit_Report_202607.md` (2 JPM tool bugs fixed, 1 UBS reconciliation gap traced to Accrued Interest, 1 disclosure gap, 1 correcting-entry trace). Monthly management-email drafting is automated (`scripts/New-GPLMonthlyEmailDraft.ps1`, Gmail draft-only).

## Related
- [[GPL JPM Notice Processor]] — the JPM notice-processing tool feeding into this roll-forward.
- [[GPL UBS Statement Processor]] — the UBS statement-processing tool, the other custodian feeding this roll-forward.
- Sibling roll-forward project: [[EIC FS Roll-Forward]].
- Likely uses [[Skill - Incremental Report File Chaining]] given the roll-forward/period-chaining nature of this work — confirmed relevant 2026-08-10/11: found a stale `Dashboard Data` sheet and stale SoCE/Cash-Flow period labels in the same workbook, exactly this bug class.

## Full detail
`C:\Users\User\.claude\projects\c--Users-User-Desktop\memory\project_gpl_fs_roll_forward.md`
