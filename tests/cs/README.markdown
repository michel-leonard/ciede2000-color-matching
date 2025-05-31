# ΔE2000 — Accurate. Fast. C#-powered.

This reference ΔE2000 [implementation in C#](../../ciede-2000.cs#L6) provides reliable and accurate perceptual color difference calculation.

VB.NET and F# can both seamlessly integrate this **C# CIEDE2000** implementation.

## Verification

[![C# CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-cs.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-cs.yml)

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
CIEDE2000 Verification Summary :
- Last Verified Line : 81,80,-29,31,47.3,124.1,77.29380412017679
- Duration : 29.57 s
- Successes : 10000000
- Errors : 0
- Maximum Difference : 8.5265128291212022e-14
```

[[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/calculator.html?L1=81&a1=80&b1=-29&L2=31&a2=47.3&b2=124.1)] - [[Workflow Details](../../.github/workflows#workflow-details)]
