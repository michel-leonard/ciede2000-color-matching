# ΔE2000 — Accurate. Fast. Fortran-powered.

ΔE2000 is the current standard for quantifying color differences in a way that best matches human vision.

This canonical **Fortran** implementation offers an easy way to calculate these differences accurately and programmatically.

## Overview

The developed algorithm enables software to evaluate color similarities (or differences) with scientific rigor.

As a general rule, navy blue and yellow, which are very different colors, generally have a ΔE<sub>00</sub> of around 115.

Values such as 5 indicate greater closeness, making this both a simple and advanced method of color comparison.

## Implementation Details

The full source code, compatible with Fortran 2008 and 2018 standards, is available [here](../../ciede-2000.f90#L16) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.f90).

## Example usage in Fortran

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```fortran
! Compute the Delta E (CIEDE2000) color difference between two Lab colors in Fortran

! Color 1: L1 = 19.3166, a1 = 73.5, b1 = 122.428
! Color 2: L2 = 19.0,    a2 = 76.2, b2 = 91.372

delta_e = ciede_2000(l1, a1, b1, l2, a2, b2)
print '(F15.12)', delta_e

! Output: ΔE2000 = 9.60876174564
```
**Note** :
- L\* values nominally range from 0 to 100
- a\* and b\* values usually range from -128 to +127

For color inputs in **hexadecimal** (e.g., `#FFF`) or **RGB** formats, see examples for other languages :

[AWK](../awk#-flexibility), [C](../c#δe2000--accurate-fast-c-powered), [Dart](../dart#δe2000--accurate-fast-dart-powered), [Java](../java#δe2000--accurate-fast-java-powered), [JavaScript](../js#-flexibility), [Kotlin](../kt#δe2000--accurate-fast-kotlin-powered), [Lua](../lua#-flexibility), [PHP](../php#δe2000--accurate-fast-php-powered), [Python](../py#δe2000--accurate-fast-python-powered), [Ruby](../rb#δe2000--accurate-fast-ruby-powered), [Rust](../rs#δe2000--accurate-fast-rust-powered).

## Verification

[![Fortran CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-f90.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-f90.yml)

<details>
<summary>What is the testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by Fortran**, like this :

1. `command -v gfortran > /dev/null || { sudo apt-get update && sudo apt-get install gfortran ; }`
2. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install gcc ; }`
3. `gfortran-14 -std=f2008 -Wall -Wextra -pedantic -O3 -o ciede-2000-test tests/f90/ciede-2000-driver.f90`
4. `gcc -std=c99 -Wall -pedantic -Ofast -ffast-math -g tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
5. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
6. `./ciede-2000-test test-cases.csv | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.f90](ciede-2000-driver.f90#L95) for calculations and [test-f90.yml](../../.github/workflows/test-f90.yml) for automation.
</details>

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :
```
 CIEDE2000 Verification Summary :
  First Verified Line : 48.100,64.000,-13.000,94.580,105.00,82.800,48.15083434386784234
             Duration : 68.54 s
            Successes : 10000000
               Errors : 0
      Average Delta E : 62.9429
    Average Deviation : 4.2558570639839032e-15
    Maximum Deviation : 1.1368683772161603e-13
```

### Speed Benchmark

Measured speed : **2,527,965 calls per second**

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **GCC** : 13.3
- **GNU Fortran** : 13.3

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in Fortran** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=26&a1=-85.62&b1=-82.8&L2=45.3&a2=26.58&b2=-50.15) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Suitable in 30+ Languages](../../#implementations)

