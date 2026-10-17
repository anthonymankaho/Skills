---
name: budget-forecast
description: When building budgets, forecasts, or rolling predictions for Hong Kong entities. Use for "annual budget", "rolling forecast", "variance analysis", "scenario planning", or "budget vs actuals". Incorporates HKFRS and two-tier profits tax.
metadata:
  version: 1.0.0
  jurisdiction: Hong Kong
---

# Budget Forecasting & Variance Analysis (HK Context)

Build budgets, forecasts, and variance analysis models for Hong Kong entities.

## Approach

1. **Base**: Start from last year's actuals (HKFRS-adjusted)
2. **Drivers**: Revenue volume × price, unit costs, headcount, overhead
3. **Scenarios**: Base / Upside / Downside with probability weights
4. **Variance**: Monthly rolling comparison of actual vs forecast

## Hong Kong-Specific Considerations
- Incorporate **two-tier profits tax** (8.25% / 16.5%) in projections — only ONE group entity eligible
- Factor in **HK labor market trends** (MPF contributions ~5%, statutory holidays)
- Seasonal patterns common in HK trade/commerce businesses
- Property rent escalation clauses typical in HK leases
- Quarterly dividend cycles affect cash flow timing

## Output
Budget document with scenario ranges, variance tracking template, and commentary on key assumptions.
