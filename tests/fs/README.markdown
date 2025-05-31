# ΔE2000 — Accurate. Fast. F#-powered.

This reference ΔE2000 [implementation in F#](../../ciede-2000.fs#L8) provides reliable and accurate perceptual color difference calculation.

C#, VB.NET and PowerShell can all seamlessly integrate this **F# CIEDE2000** implementation.

## Verification

[![F# CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-fs.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-fs.yml)

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
CIEDE2000 Verification Summary :
- Last Verified Line : 4.00,104.59,-12.00,78.74,5.87,11.00,75.430859126624028
- Duration : 154.29 s
- Successes : 10000000
- Errors : 0
- Maximum Difference : 8.5265128291212022e-14
```

[[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/calculator.html?L1=4&a1=104.59&b1=-12&L2=78.74&a2=5.87&b2=11)] - [[Workflow Details](../../.github/workflows#workflow-details)]
