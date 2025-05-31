# ΔE2000 — Accurate. Fast. C-powered.

This reference ΔE2000 [implementation in C](../../ciede-2000.c#L13) provides reliable and accurate perceptual color difference calculation.

Swift, Objective-C, Julia, D, and C++ can all seamlessly integrate this **C CIEDE2000** implementation.

Starting with GCC supporting C++14, the `ciede_2000` function can be used in constant expressions in C++.

## Verification

[![C99 CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-c.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-c.yml)

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
 CIEDE2000 Verification Summary :
- Last Verified Line : 61.3,109.1,2.76,40.1,29,123.3,66.8271373643388
- Duration  : 20.27 s
- Successes : 10000000
- Errors : 0
- Maximum Difference : 6.821210263296962e-13
```

[[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/calculator.html?L1=61.3&a1=109.1&b1=2.76&L2=40.1&a2=29&b2=123.3)] - [[Workflow Details](../../.github/workflows#workflow-details)]
