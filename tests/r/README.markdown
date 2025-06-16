# ΔE2000 — Accurate. Fast. R-powered.

This canonical vectorized ΔE2000 implementation written in R provides reliable and accurate perceptual **color difference** calculation.

## Overview

The developed algorithm enables your software to measure color similarity and difference with scientific rigor.

For reference, two very distinct colors typically have a ΔE2000 value greater than 12.

Lower values indicate greater closeness, making it a **state-of-the-art method** for comparing colors.

## Implementation Details

The full source code released on March 1, 2025, is available [here](../../ciede-2000.r#L12) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.r).

## Example usage in R

A basic **Delta E 2000** calculation between 2 colors in the **L\*a\*b\* color space** can be performed with  the `ciede_2000_classic` function :

```r
# Define the L*a*b* components for two colors
l1 <- 19.3166; a1 <- 73.5; b1 <- 122.428
l2 <- 19.0;    a2 <- 76.2; b2 <- 91.372

# Compute Delta E 2000 difference
delta_e <- ciede_2000_classic(l1, a1, b1, l2, a2, b2)
print(delta_e)

# Expected output: 9.60876174564
```

**Note**: L\* is usually between 0 and 100, a\* and b\* between -128 and +127.

For color inputs in **hexadecimal** (e.g., `#FFF`) or **RGB** formats, see examples for other languages :

[AWK](../awk#-flexibility), [C](../c#δe2000--accurate-fast-c-powered), [Dart](../dart#δe2000--accurate-fast-dart-powered), [Java](../java#δe2000--accurate-fast-java-powered), [JavaScript](../js#-flexibility), [Kotlin](../kt#δe2000--accurate-fast-kotlin-powered), [Lua](../lua#-flexibility), [PHP](../php#δe2000--accurate-fast-php-powered), [Python](../py#δe2000--accurate-fast-python-powered), [Ruby](../rb#δe2000--accurate-fast-ruby-powered), [Rust](../rs#δe2000--accurate-fast-rust-powered).

## Verification

[![R CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-r.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-r.yml)
<details>
<summary>What is the testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by R**, like this :

1. `command -v Rscript > /dev/null || { sudo apt-get update && sudo apt-get install -y r-base ; }`
2. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install -y gcc ; }`
3. `gcc -std=c99 -Wall -pedantic -Ofast tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
4. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
5. `Rscript tests/r/ciede-2000-driver.r test-cases.csv | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.r](ciede-2000-driver.r#L118) for calculations and [test-r.yml](../../.github/workflows/test-r.yml) for automation.
</details>

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
 CIEDE2000 Verification Summary :
  First Verified Line : 21.6,57.07,52.05,71.79,-57.38,106,80.753645227437261
             Duration : 144.46 s
            Successes : 10000000
               Errors : 0
      Average Delta E : 62.9342
    Average Deviation : 4.0356553931975016e-15
    Maximum Deviation : 1.1368683772161603e-13
```

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **R** : 4.5.0
- **GCC** : 13.3.0

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in R** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=6&a1=-102&b1=105&L2=88.2&a2=-123&b2=50) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Used in 30+ Languages](../../#implementations)

