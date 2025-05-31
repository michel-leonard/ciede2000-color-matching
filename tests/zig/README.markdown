# ΔE2000 — Accurate. Fast. Zig-powered.

This reference ΔE2000 [implementation in Zig](../../ciede-2000.zig#L9) provides reliable and accurate perceptual color difference calculation.

C and C++ can both seamlessly integrate this **Zig CIEDE2000** implementation.

## Verification

[![Zig CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-zig.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-zig.yml)

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
CIEDE2000 Verification Summary :
- Last Verified Line : 2,79,-25,82,-103.9,-121.7,142.6368553866863
- Duration : 98.25 s
- Successes : 10000000
- Errors : 0
- Maximum Difference : 2.7000623958883807e-13
```

[[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/calculator.html?L1=2&a1=79&b1=-25&L2=82&a2=-103.9&b2=-121.7)] - [[Workflow Details](../../.github/workflows#workflow-details)]
