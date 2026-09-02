---
tags: [project, fs-roll-forward, tool]
---

# GPL UBS Statement Processor

Tool for processing UBS Statement of Assets PDFs (all 3 portfolios: 546-130106-01/02/03), feeding [[GPL FS Roll-Forward]]. **Use v2.10.**

2026-08-06: fixed a Table-of-Contents page-collision bug (section regexes were matching the ToC's own mention of a header instead of the real one) and a PIK bond-vs-equity distinction (equity-side PIK is a share count, not a dollar amount — deliberately not journalled, per explicit instruction).

2026-08-10/11: during the first Internal Audit cycle, traced a $22,428 Bonds-schedule gap to Accrued Interest being dropped in a separate combine step (`Rebuild-Combined.ps1`) — not a bug in this app itself.

## Related

- [[GPL JPM Notice Processor]] — sibling tool for the other custodian, same FS roll-forward.

## Full detail
`C:\Users\User\.claude\projects\c--Users-User-Desktop\memory\project_gpl_ubs_statement_processor.md`
