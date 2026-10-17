---
name: profits-tax
description: Hong Kong Profits Tax computation, filing preparation, and IRD liaison. Use for "compute profits tax", "HK profits tax return", "Form 2 preparation", "assessable profit calculation", "IRD Form 2". Based on Inland Revenue Ordinance s.14–16, Schedule 8B.
metadata:
  version: 1.0.0
  jurisdiction: Hong Kong
  standards: HK IRD, IRO Cap. 112
---

# Profits Tax Computation (IRO s.14–16)

Compute Hong Kong Profits Tax for corporations, sole proprietors, and partnerships.

## Charging Basis
Under s.14(1): every person carrying on a trade/profession/business in HK is charged tax on assessable profits arising in or derived from HK. Territorial source principle — led cases include *Hang Seng Bank*, *HK-TVB International*, *Kwong Mile*.

## Computation Template

```
1.  Adjusted profit per accounts (HKFRS-adjusted)               HK$ X
2.  ADD back disallowable expenses (DIPN 4)                     HK$ Y
3.  LESS allowable capital allowances (Schedule 4)              HK$ Z
4.  LESS unutilized losses brought forward                      HK$ W
─────────────────────────────────────────────────────
5.  ASSESSABLE PROFIT                                         HK$ A
6.  TAX @ applicable rate:
    • Sole Prop / Partnership: 15% flat                        HK$ A×15%
    • Corporation (Tier 1): 8.25% on first HK$2M              HK$ B
    • Corporation (Tier 2): 16.5% on excess                    HK$ C
    Total Tax Liability                                        HK$ T
7.  LESS advance tax (previous year)                            HK$ D
─────────────────────────────────────────────────────
8.  BALANCE PAYABLE / (REFUNDABLE)                              HK$ E
```

## Key Rules
- **Two-tier rate**: only ONE group entity eligible for 8.25% preferential rate (Sch 8B)
- **Capital gains excluded**: sale of capital assets not taxable (s.14 exclusion)
- **Dividends exempt**: dividends from HK subsidiary not taxable (s.14D)
- **Basis period**: generally current year basis; transitional rules apply for new businesses
- **FSIE regime**: foreign-sourced income may be exempt if conditions met (FY 2019/20+)
- **R&D deduction**: 300% enhanced expense deduction (FY 2024/25+)

## Key DIPN References
| DIPN | Topic | Relevance |
|------|-------|-----------|
| DIPN 1 | Meaning of Trade/Profession/Business | Basic classification |
| DIPN 2 | Computation of Assessable Profit | Standard format |
| DIPN 4 | Disallowed Expenses | Deduction rules |
| DIPN 21 | Locality of Profits | Source testing |
| DIPN 61 | Transfer Pricing | Arm's length principle |

## Output
Completed profits tax computation in IRD-approved format, ready for CPA review and Form 2 submission.
