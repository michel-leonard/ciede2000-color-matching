# ΔE2000 — Accurate. Fast. Ruby-powered.

This reference ΔE2000 [implementation in Ruby](../../ciede-2000.rb#L6) provides reliable and accurate perceptual color difference calculation.

## Verification

[![Ruby CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-rb.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-rb.yml)

The test confirms full compliance with the standard, with no observed errors :

```
CIEDE2000 Verification Summary :
- Last Verified Line : 87.29,-113.03,-48.6,19,-51.6,1.82,69.80993443074732
- Duration : 72.72 s
- Successes : 10000000
- Errors : 0
- Maximum Difference : 0.0000000000000000e+00
```

[[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/calculator.html?L1=87.29&a1=-113.03&b1=-48.6&L2=19&a2=-51.6&b2=1.82)] - [[Workflow Details](../../.github/workflows#workflow-details)]
