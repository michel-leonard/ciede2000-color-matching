# ΔE2000 — Accurate. Fast. Swift-powered.

This reference ΔE2000 [implementation in Swift](../../ciede-2000.swift#L8) provides reliable and accurate perceptual color difference calculation.

Objective-C can seamlessly integrate this **Swift CIEDE2000** implementation.

## Verification

[![Swift CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-swift.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-swift.yml)

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
 CIEDE2000 Verification Summary :
- Last Verified Line : 46.0,-62.8,-10.0,65.0,-116.5,-20.0,20.83717562908332
- Duration : 71.14 s
- Successes : 10000000
- Errors : 0
- Maximum Difference : 1.7053025658242404e-13
```

[[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/calculator.html?L1=46&a1=-62.8&b1=-10&L2=65&a2=-116.5&b2=-20)] - [[Workflow Details](../../.github/workflows#workflow-details)]
