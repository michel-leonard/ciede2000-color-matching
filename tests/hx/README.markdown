# ΔE2000 — Accurate. Fast. Haxe-powered.

This reference ΔE2000 [implementation in Haxe](../../ciede-2000.hx#L9) provides reliable and accurate perceptual color difference calculation.

JavaScript, Python, Java can all seamlessly integrate this **Haxe CIEDE2000** implementation.

## Verification

[![Haxe CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-hx.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-hx.yml)

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
CIEDE2000 Verification Summary :
- Last Verified Line : 81,-107,-35,66,51,89.2,67.1522966823427794
- Duration : 104.04 s
- Successes : 10000000
- Errors : 0
- Maximum Difference : 1.1368683772161603e-13
```

[[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/calculator.html?L1=81&a1=-107&b1=-35&L2=66&a2=51&b2=89.2)] - [[Workflow Details](../../.github/workflows#workflow-details)]
