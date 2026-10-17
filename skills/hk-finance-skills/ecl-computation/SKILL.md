---
name: ecl-computation
description: Calculate Expected Credit Loss (ECL) under HKFRS 9 for financial instruments and loan portfolios. Use for "ECL model", "credit impairment", "HKFRS 9 Stage 1/2/3", "lifetime PD", "stage migration".
metadata:
  version: 1.0.0
  jurisdiction: Hong Kong
  standards: HKFRS 9
---

# ECL Computation (HKFRS 9)

Expected Credit Loss measurement for financial assets under Hong Kong FRS 9.

## Three-Stage Model

| Stage | Trigger | Measurement Basis | Example |
|-------|---------|------------------|---------|
| **Stage 1** | Performing (no significant increase in credit risk since origination) | 12-month ECL | New loans, performing receivables |
| **Stage 2** | Significant Increase in Credit Risk (SICR) but not credit-impaired | Lifetime ECL | Delinquent >90 days, downgrade |
| **Stage 3** | Credit-impaired (objective evidence of default) | Lifetime ECL (Gross carried amount) | Overdue >90 days, bankruptcy |

## ECL Formula
**ECL = PD × LGD × EAD × Discount Factor**
- **PD**: Probability of Default
- **LGD**: Loss Given Default (% of exposure lost)
- **EAD**: Exposure at Default (outstanding balance + accrued)
- **Discount Factor**: Present value at origination

## Backstop
If no reasonable forward-looking information available, use historical loss rates adjusted for macroeconomic factors (GDP growth, unemployment, property prices in HK).

## Output
ECL calculation model, stage classification matrix, movement analysis between stages, and provision journal entries.
