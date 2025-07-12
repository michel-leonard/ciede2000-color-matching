# ΔE2000 — Accurate. Fast. MATLAB-powered.

This reference vectorized implementation of ΔE2000 written in **MATLAB** enables reliable and precise calculation of color differences.

## Overview

The developed algorithm enables software to evaluate color similarities (or differences) with scientific rigor.

As a general rule, 🔵 navy blue and 🟡 yellow, which are very different colors, have a ΔE\*<sub>00</sub> of around 115.

Values [such as 5](https://michel-leonard.github.io/ciede2000-color-matching/de2000-rgb-pairs.html?seq=50&delta-e=5) indicate greater closeness, making this both a simple and advanced method of color comparison.

## Implementation Details

The full source code, last updated on March 1, 2025, can be viewed [here](../../ciede-2000.m#L12) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.m).

<details>
<summary>How do I get precisely the same ΔE2000 results as Gaurav Sharma ?</summary>

This source code adjustment is performed automatically in the [![ΔE2000 against Gaurav Sharma in Matlab](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-sharma.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-sharma.yml) workflow.

By default, without any modification, matching with Sharma's implementation is guaranteed with a tolerance of **3 × 10<sup>-4</sup>** in ΔE\*<sub>00</sub> results. However, to get the same ΔE\*<sub>00</sub> results as [Gaurav Sharma](https://hajim.rochester.edu/ece/sites/gsharma/ciede2000) with a tolerance of **10<sup>-12</sup>**, do what's explained [here](../../ciede-2000.m#L45) in the source code, as follows :

```diff
-	h_m(mask) = h_m(mask) + pi;
+	h_m(mask) = h_m(mask) + ((h_m < pi) - (pi <= h_m)) * pi;
```

> These are the two main variants for implementing the ΔE\*<sub>00</sub> function. The default is simpler, accurate enough, and widely used in practice.

<details>
<summary>How do you switch to the other variant in Gaurav Sharma's source code ?</summary>

Inside Gaurav Sharma's MATLAB source code, applying the following reproduces the variant of ΔE2000 that is widely used.

 ```diff
- hp = hp - ( abs(hpstd-hpsample)  > pi ) *pi;
+ hp = hp + ( abs(hpstd-hpsample)  > pi ) *pi;
- hp = hp+ (hp < 0) *2*pi;
```

> Instruments and eyes have an uncertainty in ΔE<sub>00</sub> of several orders of magnitude greater than the ±0.0003 implied by this simplification.

</details>

</details>

## Example usage in MATLAB

Two methods of calling the ΔE<sub>00</sub> function are provided :
- `ciede_2000_classic` accepts six floating-point scalars representing two individual colors in L\*a\*b\* space.
- `ciede_2000` accepts vectors of color components for batch processing multiple color pairs simultaneously.

A simple **Delta E 2000** calculation between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000_classic` function :

```matlab
% Compute the Delta E (CIEDE2000) color difference between two Lab colors in MATLAB

% Color 1: L1 = 19.3166, a1 = 73.5, b1 = 122.428
% Color 2: L2 = 19.0,    a2 = 76.2, b2 = 91.372

deltaE = ciede_2000_classic(L1, a1, b1, L2, a2, b2);
disp(deltaE);

% Output: ΔE2000 = 9.60876174564
```

**Notes** :
- L\* is nominally between 0 and 100, a\* and b\* typically between -128 and +127.
- The `ciede_2000` function is vectorized, requiring 128 bytes of RAM for each pair of colors contained in the vectors.

For color inputs in **hexadecimal** (e.g., `#FFF`) or **RGB** formats, see examples for other languages :

[AWK](../awk#-flexibility), [C](../c#δe2000--accurate-fast-c-powered), [Dart](../dart#δe2000--accurate-fast-dart-powered), [Java](../java#δe2000--accurate-fast-java-powered), [JavaScript](../js#-flexibility), [Kotlin](../kt#δe2000--accurate-fast-kotlin-powered), [Lua](../lua#-flexibility), [PHP](../php#δe2000--accurate-fast-php-powered), [Python](../py#δe2000--accurate-fast-python-powered), [Ruby](../rb#δe2000--accurate-fast-ruby-powered), [Rust](../rs#δe2000--accurate-fast-rust-powered).

## Verification

[![Matlab CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-m.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-m.yml)

<details>
<summary>What is the testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by Matlab**, like this :

1. `command -v octave > /dev/null || { sudo apt-get update && sudo apt-get install octave ; }`
2. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install gcc ; }`
3. `cp -p tests/m/ciede-2000-driver.m main.m`
4. `gcc -std=c99 -Wall -pedantic -Ofast -g tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
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

### Comparison with WagenaarLab

[![ΔE2000 against Caltech in Matlab](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-caltech.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-caltech.yml)

Compared to the well-maintained **WagenaarLab** implementation — first released in 2017 — this ΔE\*<sub>00</sub> function, tested on millions of random L\*a\*b\* color pairs, has an absolute deviation of no more than **3 × 10<sup>-13</sup>**. As before in [C99](../c#comparison-with-the-vmaf-c99-library), [Java](../java#comparison-with-the-openimaj), [JavaScript](../js#comparison-with-the-npmchroma-js-library), [Python](../py#comparison-with-the-python-colormath-library) and  [Rust](../rs#comparison-with-the-palette-library), this confirms the **production-ready** status of the `ciede_2000` function, which is interoperable with the California Institute of Technology function in Matlab.

> [!IMPORTANT]
> To correct this MATLAB source code to exact match certain third-party ΔE2000 functions, follow the comments in the source code.

> This formula, "small" in size, is an essential pillar of color management, deserving of this rigorous, tested and reliable industrial treatment.

### Speed Benchmark

This function was measured at a speed of 3,022,432 calls per second.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **GNU Octave** : 8.4
- **GCC** : 13.3

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in MATLAB** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=22.14&a1=38.2&b1=-46.82&L2=16.24&a2=-43.6&b2=30.39) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Suitable in 40+ Languages](../../#implementations)
