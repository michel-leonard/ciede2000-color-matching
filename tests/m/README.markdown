# ΔE2000 — Accurate. Fast. MATLAB-powered.

This canonical vectorized ΔE2000 implementation written in MATLAB provides reliable and accurate perceptual **color difference** calculation.

## Overview

This algorithm allows your software to precisely measure color similarity and difference, adhering to scientific standards.  

As a general guideline, two colors with a ΔE2000 value above 12 are considered perceptually very different.

## Implementation Details

The full source code, last updated on March 1, 2025, can be viewed [here](../../ciede-2000.m#L12) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.m).

## Example usage in MATLAB

Two methods of calling the ΔE\*00 function are provided :
- `ciede_2000_classic` accepts six floating-point scalars representing two individual colors in L\*a\*b\* space.
- `ciede_2000` accepts vectors of color components for batch processing multiple color pairs simultaneously.

A simple **Delta E 2000** calculation between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000_classic` function :

```matlab
% Example usage of the CIEDE2000 function in MATLAB

% Color 1: L1 = 19.3166, a1 = 73.5, b1 = 122.428
% Color 2: L2 = 19.0,    a2 = 76.2, b2 = 91.372

deltaE = ciede_2000_classic(L1, a1, b1, L2, a2, b2);
disp(deltaE);

% Output: ΔE2000 = 9.60876174564
```

**Note**: L\* is usually between 0 and 100, a\* and b\* between -128 and +127.

For color inputs in **hexadecimal** (e.g., `#FFF`) or **RGB** formats, see examples for other languages :

[AWK](../awk#-flexibility), [C](../c#δe2000--accurate-fast-c-powered), [Dart](../dart#δe2000--accurate-fast-dart-powered), [Java](../java#δe2000--accurate-fast-java-powered), [JavaScript](../js#-flexibility), [Kotlin](../kt#δe2000--accurate-fast-kotlin-powered), [Lua](../lua#-flexibility), [PHP](../php#δe2000--accurate-fast-php-powered), [Python](../py#δe2000--accurate-fast-python-powered), [Ruby](../rb#δe2000--accurate-fast-ruby-powered), [Rust](../rs#δe2000--accurate-fast-rust-powered).

## Verification

[![Matlab CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-m.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-m.yml)

<details>
<summary>What is the testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by Matlab**, like this :

1. `command -v octave > /dev/null || { sudo apt-get update && sudo apt-get install -y octave ; }`
2. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install -y gcc ; }`
3. `cp -p tests/m/ciede-2000-driver.m main.m`
4. `gcc -std=c99 -Wall -pedantic -Ofast tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
5. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
6. `octave --quiet --eval 'main("test-cases.csv")'  | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.m](ciede-2000-driver.m#L12) for calculations and [test-m.yml](../../.github/workflows/test-m.yml) for automation.
</details>

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
 CIEDE2000 Verification Summary :
  First Verified Line : 40.49,96.7,-36,25,14.66,21,39.649865240613799
             Duration : 193.56 s
            Successes : 10000000
               Errors : 0
      Average Delta E : 62.9472
    Average Deviation : 4.1116844332056426e-15
    Maximum Deviation : 2.2737367544323206e-13
```

### Speed Benchmark

This function was measured at a speed of 3,022,432 calls per second.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **GCC** : 13.3.0
- **GNU Octave** : 8.4.0

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in MATLAB** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=22.14&a1=38.2&b1=-46.82&L2=16.24&a2=-43.6&b2=30.39) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Used in 30+ Languages](../../#implementations)

