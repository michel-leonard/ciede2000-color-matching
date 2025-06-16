# ΔE2000 — Accurate. Fast. D-powered.

Calculate perceptually accurate color differences using the CIEDE2000 formula, implemented efficiently in the D programming language.

## Overview

The presented algorithm enables your software to measure color similarity and difference with scientific rigor.

Typically, two distinctly different colors have a ΔE2000 value greater than 12.

Lower values indicate greater closeness, making it a **state-of-the-art method** for comparing colors.

## Implementation Details

The full source code released on March 1, 2025, is available [here](../../ciede-2000.d#L8) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.d).

## Example usage in D

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```d
// Example usage of the ΔE*00 function in D

// L1 = 19.3166        a1 = 73.5           b1 = 122.428
// L2 = 19.0           a2 = 76.2           b2 = 91.372

double deltaE = ciede_2000(l1, a1, b1, l2, a2, b2);
writeln(format("%.12f", deltaE));

// This shows a ΔE2000 of 9.60876174564
```

**Note**: L\* is usually between 0 and 100, a\* and b\* between -128 and +127.

For color inputs in **hexadecimal** (e.g., `#FFF`) or **RGB** formats, see examples for other languages :

[AWK](../awk#-flexibility), [C](../c#δe2000--accurate-fast-c-powered), [Dart](../dart#δe2000--accurate-fast-dart-powered), [Java](../java#δe2000--accurate-fast-java-powered), [JavaScript](../js#-flexibility), [Kotlin](../kt#δe2000--accurate-fast-kotlin-powered), [Lua](../lua#-flexibility), [PHP](../php#δe2000--accurate-fast-php-powered), [Python](../py#δe2000--accurate-fast-python-powered), [Ruby](../rb#δe2000--accurate-fast-ruby-powered), [Rust](../rs#δe2000--accurate-fast-rust-powered).

## Verification

[![D CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-d.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-d.yml)

<details>
<summary>What is the testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by D**, like this :

1. `command -v ldc2 > /dev/null || { sudo apt-get update && sudo apt-get install -y ldc ; }`
2. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install -y gcc ; }`
3. `cp -p tests/d/ciede-2000-driver.d tests/d/main.d`
4. `ldc2 -O -release -boundscheck=off -of=ciede2000-test tests/d/main.d`
5. `gcc -std=c99 -Wall -pedantic -Ofast tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
6. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
7. `./ciede2000-test test-cases.csv | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.d](ciede-2000-driver.d#L125) for calculations and [test-d.yml](../../.github/workflows/test-d.yml) for automation.
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

## Performance Benchmark

Measured speed : 4,877,350 calls per second on :
- Ubuntu 24.04.2 LTS
- LLVM D compiler 1.40.1
- GCC 13.3.0

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in D** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=12&a1=124.1&b1=40&L2=47.8&a2=-5.6&b2=108.1) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Used in 30+ Languages](../../#implementations)

