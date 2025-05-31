# ΔE2000 — Accurate. Fast. Java-powered.

This reference ΔE2000 [implementation in Java](../../ciede-2000.java#L14) provides reliable and accurate perceptual color difference calculation.

Kotlin, Groovy, Scala, Clojure and JRuby can all seamlessly integrate this **Java CIEDE2000** implementation.

## Verification

[![Java CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-java.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-java.yml)

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
CIEDE2000 Verification Summary :
- Last Verified Line : 78.0300,-115.160,-53.1600,96.2500,-8.91000,20.1800,41.0667682716048
- Duration : 186.28 s
- Successes : 10000000
- Errors : 0
- Maximum Difference : 7.1054273576010019e-13
```

[[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/calculator.html?L1=78.03&a1=-115.16&b1=-53.16&L2=96.25&a2=-8.91&b2=20.18)] - [[Workflow Details](../../.github/workflows#workflow-details)]
