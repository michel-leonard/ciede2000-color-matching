# ΔE2000 — Accurate. Fast. Nim-powered.

This reference ΔE2000 [implementation in Nim](../../ciede-2000.nim#L10) provides reliable and accurate perceptual color difference calculation.


## Verification

[![Nim CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-nim.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-nim.yml)

The test confirms full compliance with the standard, with no observed errors :

```
CIEDE2000 Verification Summary :
- Last Verified Line : 72.0,61.0,69.7,59.0,-2.0,57.1,34.96186783663614
- Duration : 56.45 s
- Successes : 10000000
- Errors : 0
- Maximum Difference : 0.0000000000000000e+00
```

[[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/calculator.html?L1=72&a1=61&b1=69.7&L2=59&a2=-2&b2=57.1)] - [[Workflow Details](../../.github/workflows#workflow-details)]
