---
name: deferred-tax
description: Deferred tax computation under HKAS 12 and IRO s.16A. Use for "deferred tax asset", "temporary differences", "DTA recognition", "tax base computation", "deferred tax liability".
metadata:
  version: 1.0.0
  jurisdiction: Hong Kong
  standards: HKAS 12, HK IRD
---

# Deferred Tax (HKAS 12 / IRO s.16A)

Compute deferred tax assets and liabilities arising from temporary differences between accounting and tax bases.

## Key Principles (HKAS 12)

1. **Temporary Differences** arise when carrying amount ≠ tax base of an asset/liability
2. **Deferred Tax Liability**: taxable temporary difference → future tax payable
3. **Deferred Tax Asset**: deductible temporary difference → future tax benefit (recognized if probable sufficient taxable profit)

## Common Temporary Differences (HK Context)

| Item | Carrying Amount | Tax Base | Difference | DT Effect |
|------|----------------|----------|------------|-----------|
| Capital allowances > depreciation | Lower | Higher | Deductible | DTA |
| Accelerated tax depreciation | Lower | Higher | Deductible | DTA |
| Provisions (HKAS 37) | Provisions | Zero (not deductible until paid) | Taxable | DHL |
| Unrealized FX gains (BS) | HKFRS value | Historical cost | Variable | Both |
| Goodwill (non-amortized) | Carrying amount | Zero (not deductible) | Taxable | DHL |

## HKAS 12 Recognition Criteria
- **DTA**: recognize only if probable future taxable profit available
- **Discounting**: not permitted (HKAS 12.53)
- **Measurement**: use enacted/substantively enacted tax rates expected when reversing

## Output
Deferred tax schedule, journal entries, and note disclosure draft per HKAS 12.58–81.
