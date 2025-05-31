# ΔE2000 — Accurate. Fast. VBA-powered.

This reference ΔE2000 [implementation in VBA](../../ciede-2000.bas#L9) provides reliable and accurate perceptual color difference calculation.

VB6 can seamlessly integrate this **VBA CIEDE2000** implementation.

## Verification

[![VBA CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-bas.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-bas.yml)

The test made using FreeBASIC confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
CIEDE2000 Verification Summary :
- Last Verified Line :  19,-99.59999999999999,-117.5, 39.4, 108, 37, 124.824695300409
- Duration : 143.80 s
- Successes : 10000000
- Errors : 0
- Maximum Difference : 2.8421709430404007e-13
```

[[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/calculator.html?L1=19&a1=-99.6&b1=-117.5&L2=39.4&a2=108&b2=37)] - [[Workflow Details](../../.github/workflows#workflow-details)]
