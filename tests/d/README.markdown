# ΔE2000 — Accurate. Fast. D-powered.

To calculate color differences precisely using the CIEDE2000 formula, this is efficiently implemented in the **D** programming language.

## Overview

The developed algorithm enables software to evaluate color similarities (or differences) with native performance and scientific rigor.

As a general rule, 🔵 navy blue and 🟡 yellow, which are very different colors, have a ΔE\*<sub>00</sub> of around 115.

Values [such as 5](https://michel-leonard.github.io/ciede2000-color-matching/de2000-rgb-pairs.html?seq=50&delta-e=5) indicate greater closeness, making this both a simple and advanced method of color comparison.

## Implementation Details

The full source code released on March 1, 2025, is available [here](../../ciede-2000.d#L8) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.d).

A **templated** ΔE<sub>00</sub> function is available [here](ciede-2000-generic.d#L19), which supports both **32-bit** single-precision and **64-bit** double-precision computations.

<details>
<summary>What two options are available for matching ΔE2000 calculations with existing calculations ?</summary>

#### Option 1 (default)
 This often-used option consists of a coding simplification that is a historical legacy of early implementations :
```d
h_m += PI;
// if (h_m < PI) h_m += PI; else h_m -= PI;
```

#### Option 2 (compatible with Gaurav Sharma’s precise calculations)
There’s no room for ambiguity, this inversion of the commented line in the source code ensures compliance with the official :
```d
// h_m += PI;
if (h_m < PI) h_m += PI; else h_m -= PI;
```

**Note** : the difference between the two options is minimal (±0.0003 on the calculated color difference) and usually overlooked.
</details>

## Example usage in D

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```d
// Compute the Delta E (CIEDE2000) color difference between two L*a*b* colors in D

// Color 1: l1 = 26.8   a1 = 41.6   b1 = -3.4
// Color 2: l2 = 24.9   a2 = 47.4   b2 = 5.2

double deltaE = ciede_2000(l1, a1, b1, l2, a2, b2);
writeln(format("%.12f", deltaE));

// .................................................. This shows a ΔE2000 of 5.1279872048
// As explained in the comments, compliance with Gaurav Sharma would display 5.1280011106
```

**Note** : L\* is nominally between 0 and 100, a\* and b\* generally between -128 and +127.

For color inputs in **hexadecimal** (e.g., `#FFF`) or **RGB** formats, see examples for other languages :

[AWK](../awk#-flexibility), [C](../c#δe2000--accurate-fast-c-powered), [Dart](../dart#δe2000--accurate-fast-dart-powered), [Java](../java#δe2000--accurate-fast-java-powered), [JavaScript](../js#-flexibility), [Kotlin](../kt#δe2000--accurate-fast-kotlin-powered), [Lua](../lua#-flexibility), [PHP](../php#δe2000--accurate-fast-php-powered), [Python](../py#δe2000--accurate-fast-python-powered), [Ruby](../rb#δe2000--accurate-fast-ruby-powered), [Rust](../rs#δe2000--accurate-fast-rust-powered).

## Verification

[![D CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-d.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-d.yml)

<details>
<summary>What is the testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by D**, like this :

1. `command -v ldc2 > /dev/null || { sudo apt-get update && sudo apt-get install ldc ; }`
2. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install gcc ; }`
3. `cp -p tests/d/ciede-2000-driver.d tests/d/main.d`
4. `ldc2 -O -release -boundscheck=off -of=ciede2000-test tests/d/main.d`
5. `gcc -std=c99 -Wall -pedantic -O2 -g tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
6. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
7. `./ciede2000-test test-cases.csv | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.d](ciede-2000-driver.d#L90) for calculations and [test-d.yml](../../.github/workflows/test-d.yml) for automation.
</details>

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
CIEDE2000 Verification Summary :
  First Verified Line : 74.89,45,-76,6.73,-44,-26,71.548789861265547
             Duration : 25.83 s
            Successes : 10000000
               Errors : 0
      Average Delta E : 62.9274
    Average Deviation : 1.4724418154199448e-14
    Maximum Deviation : 3.5527136788005009e-13
```

> [!IMPORTANT]
> To correct this D source code to exact match certain third-party ΔE2000 functions, follow the comments in the source code.

> This formula, "small" in size, is an essential pillar of color management, deserving of this rigorous, tested and reliable industrial treatment.

## Performance Benchmark

Measured speed : 4,877,350 calls per second on :
- Ubuntu 24.04.2 LTS
- LLVM D compiler 1.40.1
- GCC 13.3

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in D** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=14&a1=36.8&b1=-39.9&L2=21&a2=7.9&b2=8.8) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Suitable in 40+ Languages](../../#implementations)

