---
name: salaries-tax
description: Hong Kong Salaries Tax computation and self-assessment return preparation. Use for "compute salaries tax", "HK personal assessment", "Form 2A", "employee benefit tax", "bonus tax computation". Based on IRO s.8–11, Schedule 9.
metadata:
  version: 1.0.0
  jurisdiction: Hong Kong
  standards: HK IRD, IRO Cap. 112
---

# Salaries Tax Computation (IRO s.8–11)

Compute HK Salaries Tax for employees and pensioners.

## Charged On (s.8(1))
All employment income: wages, salary, bonuses, commissions, benefits-in-kind, termination payments, pension income (s.11).

## Computation

```
1.  Gross emoluments (salary + bonus + allowances + BIKE)           HK$ X
2.  LESS allowable deductions:
    • Earned income (actual capped at HK$350,000)                  HK$ Y
    • MPF/contributions (approved scheme, max HK$1,500/mo)         HK$ Z
    • Domestic employee services (max HK$72,500)                   HK$ W
    • Donation (max HK$10,000)                                     HK$ V
─────────────────────────────────────────────────────
3.  NET CHARGEABLE INCOME                                          HK$ N
4.  TAX calculated at progressive rates (Sch 9):
    First  HK$72,000       @ 2%     = HK$ A
    Next HK$72,000       @ 8%     = HK$ B
    Next HK$80,000       @ 13%    = HK$ C
    Next HK$80,000       @ 17%    = HK$ D
    Excess                   @ 17.5% = HK$ E
    TOTAL PROGRESSIVE TAX                                      HK$ P
5.  FLAT RATE ALTERNATIVE: Net chargeable income × 10%             HK$ F
─────────────────────────────────────────────────────
6.  SALARIES TAX PAYABLE = LOWER of (P) and (F)                   HK$ T
```

## Key Points
- Flat rate 10% available if progressive gives higher tax
- Benefits-in-kind valued at market value (s.8(2))
- Self-assessment return due within 1 month of issuance
- Double taxation relief available under applicable DTAs
