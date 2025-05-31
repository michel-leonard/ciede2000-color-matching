# ΔE2000 — Accurate. Fast. D-powered.

This reference ΔE2000 [implementation in D](../../ciede-2000.d#L8) provides reliable and accurate perceptual color difference calculation.

## Verification

[![D CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-d.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-d.yml)

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
CIEDE2000 Verification Summary :
- Last Verified Line : 12.0,124.1,40.0,47.8,-5.6,108.1,73.534567506685860
- Duration : 23.10 s
- Successes : 10000000
- Errors : 0
- Maximum Difference : 3.5527136788005009e-13
```

[[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/calculator.html?L1=12&a1=124.1&b1=40&L2=47.8&a2=-5.6&b2=108.1)] - [[Workflow Details](../../.github/workflows#workflow-details)]
