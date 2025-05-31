# ΔE2000 — Accurate. Fast. Racket-powered.

This reference ΔE2000 [implementation in Racket](../../ciede-2000.rkt#L8) provides reliable and accurate perceptual color difference calculation.

## Verification

[![Racket CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-rkt.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-rkt.yml)

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
CIEDE2000 Verification Summary :
- Last Verified Line : 67.2,111.7,-81.0,97.4,108.6,5.0,30.387652005578015
- Duration : 82.23 s
- Successes : 10000000
- Errors : 0
- Maximum Difference : 2.5579538487363607e-13
```

[[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/calculator.html?L1=67.2&a1=111.7&b1=-81&L2=97.4&a2=108.6&b2=5)] - [[Workflow Details](../../.github/workflows#workflow-details)]
