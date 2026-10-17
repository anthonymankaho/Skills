---
name: automated-reconciliation
description: When automating bank reconciliations, intercompany eliminations, or account reconciliations. Use for "bank rec", "intercompany matching", "account reconciliation process", or "month-end recon". HKFRS and HKAS context included.
metadata:
  version: 1.0.0
  jurisdiction: Hong Kong
---

# Automated Reconciliation

Bank recs, intercompany matching, and account reconciliations at scale.

## Process

1. **Extract** bank statements, subledger details, GL postings
2. **Match** transactions using deterministic rules (amount + date + ref) + fuzzy logic for tolerances
3. **Identify** unmatched items — flag for manual review
4. **Document** reconciliation package with aging analysis

## Hong Kong Context
- Bank statements from HK banks typically available T+1
- Intercompany eliminations require consideration of **HKFRS 10** (control assessment)
- FX translations for foreign operations: **HKAS 21** mechanics
- MPF payments need separate tracking from salaries payable

## Output
Completed reconciliation package ready for sign-off, with exceptions list and aging of open items.
