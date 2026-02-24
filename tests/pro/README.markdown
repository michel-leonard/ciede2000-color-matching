# ΔE2000 — Accurate. Fast. Prolog-powered.

ΔE2000 is the globally recognized standard for quantifying color differences according to human vision.

This reference implementation in **Prolog** offers a simple way of calculating these differences accurately within programs.

## Overview

The developed algorithm enables software to evaluate color similarities (or differences) with scientific rigor.

As a general rule, 🔵 navy blue and 🟡 yellow, which are very different colors, have a ΔE\*<sub>00</sub> of around 115.

Values [such as 5](https://michel-leonard.github.io/ciede2000-color-matching/de2000-rgb-pairs.html?seq=50&delta-e=5) indicate greater closeness, making this both a simple and advanced method of color comparison.

## Implementation Details

The full source code (released March 1, 2025) is available [here](../../ciede-2000.pro#L6) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.pro).

<details>
<summary>What two options are available for matching ΔE2000 calculations with existing calculations ?</summary>

#### Option 1 (default)
 This often-used option consists of a coding simplification that is a historical legacy of early implementations :
```prolog
H_mean is H_mean_raw + Hue_wrap * Pi_1,
% (Hue_wrap =:= 1, H_mean_raw < Pi_1 -> H_mean_hi = Pi_1 ; H_mean_hi = 0.0),
% (Hue_wrap =:= 1, H_mean_hi =:= 0.0 -> H_mean_lo = Pi_1 ; H_mean_lo = 0.0),
% H_mean is H_mean_raw + H_mean_hi - H_mean_lo,
```

#### Option 2 (compatible with Gaurav Sharma’s precise calculations)
There’s no room for ambiguity, this inversion of the commented line in the source code ensures compliance with the official :
```prolog
% H_mean is H_mean_raw + Hue_wrap * Pi_1,
(Hue_wrap =:= 1, H_mean_raw < Pi_1 -> H_mean_hi = Pi_1 ; H_mean_hi = 0.0),
(Hue_wrap =:= 1, H_mean_hi =:= 0.0 -> H_mean_lo = Pi_1 ; H_mean_lo = 0.0),
H_mean is H_mean_raw + H_mean_hi - H_mean_lo,
```

**Note** : the difference between the two options is minimal (±0.0003 on the calculated color difference) and usually overlooked.
</details>

## Example usage in Prolog

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```prolog
% Compute the Delta E (CIEDE2000) color difference between two L*a*b* colors in Prolog

color_1([69.5, 43.6, -1.8]).
color_2([70.2, 37.9, 1.6]).

extract_lab([L, A, B], L, A, B).

compute_delta_e :-
	color_1(C1),
	color_2(C2),
	extract_lab(C1, L1, A1, B1),
	extract_lab(C2, L2, A2, B2),
	ciede_2000(L1, A1, B1, L2, A2, B2, DeltaE),
	format('Delta E 2000 = ~10f~n', [DeltaE]).

% .................................................. This shows a ΔE2000 of 2.8044781137
% As explained in the comments, compliance with Gaurav Sharma would display 2.8044649638
```

**Note** : L\* varies nominally between 0 and 100, a\* and b\* most often between -128 and +127.

For color inputs in **hexadecimal** (e.g., `#FFF`) or **RGB** formats, see examples for other languages :

[AWK](../awk#-flexibility), [C](../c#δe2000--accurate-fast-c-powered), [Dart](../dart#δe2000--accurate-fast-dart-powered), [Java](../java#δe2000--accurate-fast-java-powered), [JavaScript](../js#-flexibility), [Kotlin](../kt#δe2000--accurate-fast-kotlin-powered), [Lua](../lua#-flexibility), [PHP](../php#δe2000--accurate-fast-php-powered), [Python](../py#δe2000--accurate-fast-python-powered), [Ruby](../rb#δe2000--accurate-fast-ruby-powered), [Rust](../rs#δe2000--accurate-fast-rust-powered).

## Verification

[![Prolog CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-pro.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-pro.yml)

<details>
<summary>What is the testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by Prolog**, like this :

1. `command -v swipl > /dev/null || { sudo apt-get update && sudo apt-get install swi-prolog ; }`
2. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install gcc ; }`
3. `gcc -std=c99 -Wall -pedantic -O2 -g tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
4. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
5. `swipl -q -s tests/pro/ciede-2000-driver.pro -- test-cases.csv | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.pro](ciede-2000-driver.pro#L139) for calculations and [test-pro.yml](../../.github/workflows/test-pro.yml) for automation.
</details>

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
 CIEDE2000 Verification Summary :
  First Verified Line : 27,-123,101,44,-30,122,29.98937281745311
             Duration : 254.09 s
            Successes : 10000000
               Errors : 0
      Average Delta E : 63.2072
    Average Deviation : 5.0e-15
    Maximum Deviation : 1.1e-13
```

> [!IMPORTANT]
> To correct this Prolog source code to exact match certain third-party ΔE2000 functions, follow the comments in the source code.

> This formula, "small" in size, is an essential pillar of color management, deserving of this rigorous, tested and reliable industrial treatment.

### Speed Benchmark

This function was measured at a speed of 88,308 calls per second.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **SWI-Prolog** : 9.0.4
- **GCC** : 13.3

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in Prolog** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=69.6&a1=49.9&b1=-34.3&L2=75.7&a2=8.5&b2=6) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Suitable in 40+ Languages](../../#implementations)
