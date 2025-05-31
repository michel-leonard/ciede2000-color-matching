# ΔE2000 — Accurate. Fast. Julia-powered.

This reference ΔE2000 [implementation in Julia](../../ciede-2000.jl#L9) provides reliable and accurate perceptual color difference calculation.

## Verification

[![Julia CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-jl.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-jl.yml)

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
 CIEDE2000 Verification Summary :
- Last Verified Line : 53.0,-96.0,-45.0,12.5,-106.0,-26.1,33.361091064492946
- Duration : 83.98 s
- Successes : 10000000
- Errors : 0
- Maximum Difference : 2.2737367544323206e-13
```

[[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/calculator.html?L1=53&a1=-96&b1=-45&L2=12.5&a2=-106&b2=-26.1)] - [[Workflow Details](../../.github/workflows#workflow-details)]
