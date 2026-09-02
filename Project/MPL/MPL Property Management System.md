---
tags: [project, mpl, property-management]
---

# MPL Property Management System

Part of the MPL (Meyer Properties Limited) toolset, alongside [[MPL Accounting Module]]. Three-module roadmap behind one launcher `MPL_Combined.html` (Desktop shortcut **MPL**) — `localStorage`-backed, no server, deliberately no shared GL integration between modules.

1. **Owned Property** (`MPL_Property_Register.html`) — NCA register, Annual Depreciation, Impairment Test, Lease Status. Built and reviewed.
2. **Property Income** (`MPL_DN_CN_Receipt_Generator.html`) — Debit Note / Credit Note / Receipt, pixel-matched to the real letterhead. Built, pushed to GitHub.
3. **Property Expenses & Tax** (HK Rating, Macau Property Tax, Macau Renda) — not started.

Access control (login + per-tile permissions) lives at the launcher level in `MPL_Combined.html`, gating its 4 top-level tiles (MPL Accounting / Property Management / Debit-Credit Note / Payment Requisition) — not inside the individual tool files; "one gate per boundary" was the key lesson from correcting an earlier, wrongly-scoped build. Canonical source: `C:\Users\User\Desktop\GitHub-Clones\MPL` (git), copied to `Meyer\MPL\MPL Claude` after each merge.

## Related

- [[MPL Accounting Module]] — the sibling accounting module sharing the same launcher.
- [[Skill - Access Control Module]] — the reusable login/permission pattern built here.

## Full detail

`C:\Users\User\.claude\projects\c--Users-User-Desktop\memory\project_mpl_property_management_system.md`
