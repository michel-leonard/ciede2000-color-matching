# ΔE2000 — Accurate. Fast. Go-powered.

This reference ΔE2000 [implementation in Go](../../ciede-2000.go#L10) provides reliable and accurate perceptual color difference calculation.

## Verification

[![Go CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-go.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-go.yml)

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
CIEDE2000 Verification Summary :
- Last Verified Line : 65,-50,10.5,20.82,71,-34.1,66.1874029523774
- Duration : 30.54 s
- Successes : 10000000
- Errors : 0
- Maximum Difference : 7.3896444519050419e-13
```

[[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/calculator.html?L1=65&a1=-50&b1=10.5&L2=20.82&a2=71&b2=-34.1)] - [[Workflow Details](../../.github/workflows#workflow-details)]
