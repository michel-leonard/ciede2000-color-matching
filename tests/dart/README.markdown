# ΔE2000 — Accurate. Fast. Dart-powered.

This reference ΔE2000 [implementation in Dart](../../ciede-2000.dart#L8) provides reliable and accurate perceptual color difference calculation.

JavaScript, Java / Kotlin (Android), Swift / Objective-C (iOS) can all seamlessly integrate this **Dart CIEDE2000** implementation.

## Verification

[![Dart CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-dart.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-dart.yml)

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
CIEDE2000 Verification Summary :
- Last Verified Line : 93.0,-90.0,-101.0,79.6,-104.0,82.6,64.04915875144532
- Duration : 45.77 s
- Successes : 10000000
- Errors : 0
- Maximum Difference : 8.5265128291212022e-14
```

[[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/calculator.html?L1=93&a1=-90&b1=-101&L2=79.6&a2=-104&b2=82.6)] - [[Workflow Details](../../.github/workflows#workflow-details)]
