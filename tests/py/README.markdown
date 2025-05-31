# ΔE2000 — Accurate. Fast. Python-powered.

This reference ΔE2000 [implementation in Python](../../ciede-2000.py#L6) provides reliable and accurate perceptual color difference calculation.

## Verification

[![Python CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-py.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-py.yml)

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
CIEDE2000 Verification Summary :
- Last Verified Line : 60.28,-13.4,-97.3,67.0,36.66,70.0,60.02649500651052
- Duration : 119.55 s
- Successes : 10000000
- Errors : 0
- Maximum Difference : 5.6843418860808015e-14
```

[[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/calculator.html?L1=60.28&a1=-13.4&b1=-97.3&L2=67&a2=36.66&b2=70)] - [[Workflow Details](../../.github/workflows#workflow-details)]
