# ΔE2000 — Accurate. Fast. Pascal-powered.

This reference ΔE2000 [implementation in Pascal](../../ciede-2000.pas#L9) provides reliable and accurate perceptual color difference calculation.

Object Pascal (Delphi) can seamlessly integrate this **Pascal CIEDE2000** implementation.

## Verification

[![Pascal CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-pas.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-pas.yml)

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
CIEDE2000 Verification Summary :
- Last Verified Line : 44.4,10.0,-52.1,23.0,-25.0,1.0,35.795648993468809
- Duration : 56.05 s
- Successes : 10000000
- Errors : 0
- Maximum Difference : 3.5527136788005009e-13
```

[[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/calculator.html?L1=44.4&a1=10&b1=-52.1&L2=23&a2=-25&b2=1)] - [[Workflow Details](../../.github/workflows#workflow-details)]
