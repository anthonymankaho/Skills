---
name: hk-finance-skills
description: A comprehensive collection of AI agent skills for Hong Kong financial professionals, accountants, and finance teams. Built on HKFRS/HKAS (IFRS/IAS) standards and HK IRD tax rules, including internal audit processing aligned with HKICPA requirements. Works with Claude Code and any agent that supports the Agent Skills spec.
metadata:
  version: 1.0.0
  jurisdiction: Hong Kong
  standards: HKFRS/HKAS, IFRS/IAS, HK IRD, HKICPA
---

# HK Finance Skills — Overview

A curated set of specialized financial skills for Hong Kong practice. Each skill carries domain-specific knowledge, referencing the correct accounting standards (HKFRS/HKAS = IFRS/IAS), Hong Kong Inland Revenue Ordinance provisions, and HKICPA professional standards.

## Structure

```
hk-finance-skills/
├── SKILL.md                  # Main skill definition (this file)
├── skills/                   # Individual skill directories (22 skills total)
│   ├── financial-analysis/        — Ratio analysis, trend analysis under HKFRS
│   ├── statement-preparation/     — Financial statements per HKFRS/HKAS
│   ├── budget-forecast/          — Annual budgets, rolling forecasts
│   ├── journal-entry/            — Accruals, prepaids, payroll under HKFRS
│   ├── automated-reconciliation/ — Bank recs, intercompany eliminations
│   ├── close-management/         — Close calendars, task sequencing
│   ├── inventory-costing/        — FIFO/weighted avg, NRV per HKAS 2
│   ├── fixed-asset-accounting/   — Capitalization, depreciation, impairment
│   ├── corporate-consolidation/  — Group consolidation per HKFRS 10
│   ├── tax-planning/             — HK IRD focused tax optimization
│   ├── profits-tax/              — HK Profits Tax computation & filing
│   ├── salaries-tax/             — HK Salaries Tax computation
│   ├── deferred-tax/             — HKAS 12 + IRO s.16A
│   ├── revenue-recognition/      — HKFRS 15
│   ├── lease-accounting/         — HKFRS 16
│   ├── internal-audit/           — HKICPA Internal Audit Processing pipeline
│   ├── audit-checklist/          — HKSAs framework audit procedures
│   ├── risk-assessment/          — COSO ERM, ISO 31000 risk management
│   ├── treasury-management/      — Cash forecasting, liquidity
│   ├── ecl-computation/          — HKFRS 9 Expected Credit Loss
│   └── working-capital-analysis/ — CCC, DSO/DIO/DPO
├── standards/                # Accounting & tax standard references
└── foundations/              # Shared context API layer
```

## Standards Hierarchy

1. **Primary**: HKFRS (issued by HKICPA) / HKAS — identical to IFRS/IAS unless noted
2. **Tax**: Inland Revenue Ordinance (Cap. 112), DIPN/SOIPN guidance notes
3. **Audit**: HKISAs (Hong Kong Standards on Auditing) / HKICPA Professional Standards
4. **Supplementary**: If primary is silent, fall back to IFRS/IAS or US GAAP equivalents

## Usage

When the user works on any financial task — accounting, tax, auditing, valuation, compliance — check if a relevant skill matches the domain. Each skill's description field triggers when it applies.

Skills cross-reference each other via relative links (e.g., `./skills/statement-preparation/SKILL.md`). Read shared context from `foundations/context-api/` before executing specialized tasks.

## Capability Inventory

### Financial Analysis & Reporting
| Skill | Description |
|-------|-------------|
| `financial-analysis` | Ratio analysis, trend analysis, performance evaluation under HKFRS |
| `statement-preparation` | Monthly/quarterly/annual financial statements following HKFRS/HKAS |
| `budget-forecast` | Annual budgets, rolling forecasts, variance analysis |
| `three-statement-modeling` | Integrated income statement, balance sheet, cash flow models |
| `company-valuation` | DCF, comparables, precedent transactions |

### Accounting Operations
| Skill | Description |
|-------|-------------|
| `journal-entry` | Accruals, prepaids, payroll, corrections under HKFRS |
| `automated-reconciliation` | Bank recs, intercompany eliminations, account reconciliations |
| `close-management` | Close calendars, task sequencing, fast close |
| `inventory-costing` | FIFO/weighted average, absorption costing, NRV write-downs per HKAS 2 |
| `fixed-asset-accounting` | Capitalization, depreciation, impairment, disposals per HKAS 16/36 |

### Tax (HK IRD Focused)
| Skill | Description |
|-------|-------------|
| `tax-planning` | Hong Kong tax optimization, local tax laws, IRD compliance |
| `profits-tax` | HK Profits Tax computation & filing (s.14–16, Schedule 8B) |
| `salaries-tax` | HK Salaries Tax computation & self-assessment returns |
| `deferred-tax` | Temporary differences, DTA recognition, HKAS 12 + IRO s.16A |

### Compliance & Audit (HKICPA)
| Skill | Description |
|-------|-------------|
| `internal-audit` | Full HKICPA internal audit processing pipeline (planning→fieldwork→reporting→follow-up) |
| `audit-checklist` | Generate comprehensive audit checklists, working papers, test procedures per HKSAs |

### Risk & Treasury
| Skill | Description |
|-------|-------------|
| `risk-assessment` | Risk identification, heat maps, mitigation strategies (COSO ERM, ISO 31000) |
| `treasury-management` | Cash forecasting, working capital, liquidity management |
| `ecl-computation` | Expected Credit Loss (ECL) under HKFRS 9 for financial instruments |
| `working-capital-analysis` | CCC, DSO/DIO/DPO, cash release programs |

### Advanced Accounting
| Skill | Description |
|-------|-------------|
| `revenue-recognition` | Apply HKFRS 15 revenue recognition for contracts & performance obligations |
| `lease-accounting` | HKFRS 16 lease accounting: ROU assets, lease liabilities, modifications |
| `corporate-consolidation` | Consolidated financial statements for group entities with elimination entries (HKFRS 10) |
