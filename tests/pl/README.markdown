# ΔE2000 — Accurate. Fast. Perl-powered.

ΔE2000 is the best method for accurately quantifying color differences as perceived by the human eye.

This canonical implementation in **Perl** offers a simple way of calculating these differences accurately and programmatically.

## Overview

The developed algorithm enables software to evaluate color similarities (or differences) with scientific rigor.

As a general rule, navy blue and yellow, which are very different colors, generally have a ΔE<sub>00</sub> of around 115.

Values such as 5 indicate greater closeness, making this both a simple and advanced method of color comparison.

## Implementation Details

The full source code (released March 1, 2025) is available [here](../../ciede-2000.pl#L10) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.pl).

## Example usage in Perl

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```pl
# Compute the Delta E (CIEDE2000) color difference between two Lab colors in Perl

# L1 = 19.3166    a1 = 73.5     b1 = 122.428
# L2 = 19.0       a2 = 76.2     b2 = 91.372

my $deltaE = ciede_2000($L1, $a1, $b1, $L2, $a2, $b2);
print $deltaE;  # Output: 9.60876174564
```

**Note** : L\* is nominally between 0 and 100, a\* and b\* typically between -128 and +127.

For color inputs in **hexadecimal** (e.g., `#FFF`) or **RGB** formats, see examples for other languages :

[AWK](../awk#-flexibility), [C](../c#δe2000--accurate-fast-c-powered), [Dart](../dart#δe2000--accurate-fast-dart-powered), [Java](../java#δe2000--accurate-fast-java-powered), [JavaScript](../js#-flexibility), [Kotlin](../kt#δe2000--accurate-fast-kotlin-powered), [Lua](../lua#-flexibility), [PHP](../php#δe2000--accurate-fast-php-powered), [Python](../py#δe2000--accurate-fast-python-powered), [Ruby](../rb#δe2000--accurate-fast-ruby-powered), [Rust](../rs#δe2000--accurate-fast-rust-powered).

## Verification

[![Perl CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-pl.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-pl.yml)

<details>
<summary>What is the testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by Perl**, like this :

1. `command -v perl > /dev/null || { sudo apt-get update && sudo apt-get install perl ; }`
2. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install gcc ; }`
3. `gcc -std=c99 -Wall -pedantic -Ofast -ffast-math -g tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
4. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
5. `perl tests/pl/ciede-2000-driver.pl test-cases.csv | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.pl](ciede-2000-driver.pl#L85) for calculations and [test-pl.yml](../../.github/workflows/test-pl.yml) for automation.
</details>

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
CIEDE2000 Verification Summary :
  First Verified Line : 2,-126.1,-93.21,61.07,-94.6,65.5,70.390530131414
             Duration : 59.14 s
            Successes : 10000000
               Errors : 0
      Average Delta E : 62.9418
    Average Deviation : 4.5890806760207067e-14
    Maximum Deviation : 5.6843418860808015e-13
```

### Speed Benchmark

This function was measured at a speed of 438,140 calls per second.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **GCC** : 13.3
- **Perl** : 5.38.2

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in Perl** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=96.9&a1=-59.79&b1=95.34&L2=88.21&a2=25.24&b2=-35.11) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Suitable in 30+ Languages](../../#implementations)
