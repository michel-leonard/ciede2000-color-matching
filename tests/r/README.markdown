# ΔE2000 — Accurate. Fast. R-powered.

This reference ΔE2000 [implementation in R](../../ciede-2000.r#L12) provides reliable and accurate perceptual color difference calculation.

## Verification

[![R CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-r.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-r.yml)

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
CIEDE2000 Verification Summary :
- Last Verified Line : 6.0,-102.0,105.0,88.2,-123.0,50.0,81.650329714203579
- Duration : 115.89 s
- Successes : 10000000
- Errors : 0
- Maximum Difference : 9.9475983006414026e-14
```

[[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/calculator.html?L1=6&a1=-102&b1=105&L2=88.2&a2=-123&b2=50)] - [[Workflow Details](../../.github/workflows#workflow-details)]
