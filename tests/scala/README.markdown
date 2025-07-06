# ΔE2000 — Accurate. Fast. Scala-powered.

To calculate color differences precisely using the CIEDE2000 formula, this is efficiently implemented in the **Scala** programming language.

## Overview

The developed algorithm enables software to evaluate color similarities (or differences) with native performance and scientific rigor.

As a general rule, 🔵 navy blue and 🟡 yellow, which are very different colors, have a ΔE\*<sub>00</sub> of around 115.

Values [such as 5](https://michel-leonard.github.io/ciede2000-color-matching/de2000-rgb-pairs.html?seq=50&delta-e=5) indicate greater closeness, making this both a simple and advanced method of color comparison.

## Implementation Details

The full source code released on March 1, 2025, is available [here](../../ciede-2000.scala#L8) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.scala).

## Example usage in Scala

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```scala
// Compute the Delta E (CIEDE2000) color difference between two Lab colors in Scala

// L1 = 19.3166        a1 = 73.5           b1 = 122.428
// L2 = 19.0           a2 = 76.2           b2 = 91.372

val deltaE: Double = ciede_2000(l1, a1, b1, l2, a2, b2);
printf("%.12f", deltaE);

// This shows a ΔE2000 of 9.60876174564
```

**Note** : L\* is nominally between 0 and 100, a\* and b\* generally between -128 and +127.

For color inputs in **hexadecimal** (e.g., `#FFF`) or **RGB** formats, see examples for other languages :

[AWK](../awk#-flexibility), [C](../c#δe2000--accurate-fast-c-powered), [Dart](../dart#δe2000--accurate-fast-dart-powered), [Java](../java#δe2000--accurate-fast-java-powered), [JavaScript](../js#-flexibility), [Kotlin](../kt#δe2000--accurate-fast-kotlin-powered), [Lua](../lua#-flexibility), [PHP](../php#δe2000--accurate-fast-php-powered), [Python](../py#δe2000--accurate-fast-python-powered), [Ruby](../rb#δe2000--accurate-fast-ruby-powered), [Rust](../rs#δe2000--accurate-fast-rust-powered).

## Verification

[![Scala CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-scala.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-scala.yml)

<details>
<summary>What is the testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by Scala**, like this :

1. `command -v scalac > /dev/null || { sudo apt-get update && sudo apt-get install scala ; }`
2. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install gcc ; }`
3. `cp -p tests/scala/ciede-2000-driver.scala Main.scala`
4. `scalac Main.scala`
5. `gcc -std=c99 -Wall -pedantic -Ofast -ffast-math -g tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
6. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
7. `scala Main test-cases.csv | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.scala](ciede-2000-driver.scala#L91) for calculations and [test-scala.yml](../../.github/workflows/test-scala.yml) for automation.
</details>

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
CIEDE2000 Verification Summary :
  First Verified Line : 27,-123,101,44,42.0000098,-99,70.204734814936900
             Duration : 36.29 s
            Successes : 10000000
               Errors : 0
      Average Delta E : 63.0868
    Average Deviation : 5.4e-15
    Maximum Deviation : 2.3e-13
```

> This formula, "small" in size, is an essential pillar of color management, deserving of this rigorous, tested and reliable industrial treatment.

## Performance Benchmark

Measured speed : 4,500,312  calls per second on :
- Ubuntu 24.04.2 LTS
- Scala 2.11.12
- GCC 13.3

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in Scala** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=27&a1=-123&b1=101&L2=44&a2=42.0000098&b2=-99) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Suitable in 30+ Languages](../../#implementations)
