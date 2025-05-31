# ΔE2000 — Accurate. Fast. PHP-powered.

This reference ΔE2000 [implementation in PHP](../../ciede-2000.php#L8) provides reliable and accurate perceptual color difference calculation.

## Verification

[![PHP CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-php.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-php.yml)

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
CIEDE2000 Verification Summary :
- Last Verified Line : 3.46,126.39,-67.46,25.29,-81.88,122.51,116.17876479257
- Duration : 119.00 s
- Successes : 10000000
- Errors : 0
- Maximum Difference : 5.0022208597511053e-12
```

[[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/calculator.html?L1=3.46&a1=126.39&b1=-67.46&L2=25.29&a2=-81.88&b2=122.51)] - [[Workflow Details](../../.github/workflows#workflow-details)]
