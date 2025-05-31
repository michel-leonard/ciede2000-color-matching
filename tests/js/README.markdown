# ΔE2000 — Accurate. Fast. JavaScript-powered.

This reference ΔE2000 [implementation in JavaScript](../../ciede-2000.js#L6) provides reliable and accurate perceptual color difference calculation.

TypeScript, Node.js and Deno can all seamlessly integrate this **JavaScript CIEDE2000** implementation.

## Verification

[![JavaScript CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-js.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-js.yml)

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
CIEDE2000 Verification Summary :
- Last Verified Line : 74.87,-74.4,-66.71,92.27,114.6,122.7,72.09723914114998
- Duration : 34.09 s
- Successes : 10000000
- Errors : 0
- Maximum Difference : 2.5579538487363607e-13
```

[[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/calculator.html?L1=74.87&a1=-74.4&b1=-66.71&L2=92.27&a2=114.6&b2=122.7)] - [[Workflow Details](../../.github/workflows#workflow-details)]
