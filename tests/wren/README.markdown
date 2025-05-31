# ΔE2000 — Accurate. Fast. Wren-powered.

This reference ΔE2000 [implementation in Wren](../../ciede-2000.wren#L6) provides reliable and accurate perceptual color difference calculation.

## Verification

[![Wren CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-wren.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-wren.yml)

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
CIEDE2000 Verification Summary :
- Last Verified Line : 52,-99.5,52.9,55,26.7,-102,61.089264322199
- Duration : 82.89 s
- Successes : 10000000
- Errors : 0
- Maximum Difference : 5.0306425691815093e-12
```

[[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/calculator.html?L1=52&a1=-99.5&b1=52.9&L2=55&a2=26.7&b2=-102)] - [[Workflow Details](../../.github/workflows#workflow-details)]
