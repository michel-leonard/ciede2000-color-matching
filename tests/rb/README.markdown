# ΔE2000 — Accurate. Fast. Ruby-powered.

ΔE2000 is used worldwide as the most accurate standard for evaluating color differences.

This reference **Ruby** implementation provides a simple and accurate way of calculating these differences within programs.

## Overview

The developed algorithm enables software to evaluate color similarities (or differences) with scientific rigor.

As a general rule, 🔵 navy blue and 🟡 yellow, which are very different colors, have a ΔE\*<sub>00</sub> of around 115.

Values [such as 5](https://michel-leonard.github.io/ciede2000-color-matching/de2000-rgb-pairs.html?seq=50&delta-e=5) indicate greater closeness, making this both a simple and advanced method of color comparison.

## Implementation Details

The full source code released on March 1, 2025, is available [here](../../ciede-2000.rb#L6) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.rb).

## Example usage in Ruby

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```ruby
# Compute the Delta E (CIEDE2000) color difference between two Lab colors in Ruby

# L1 = 19.3166        a1 = 73.5           b1 = 122.428
# L2 = 19.0           a2 = 76.2           b2 = 91.372

delta_e = ciede_2000(l1, a1, b1, l2, a2, b2)
puts delta_e

# This shows a ΔE2000 of 9.60876174564
```

**Note** : L\* is nominally between 0 and 100, a\* and b\* typically between -128 and +127.

To compare **hexadecimal** (e.g., "#FFF") or **RGB colors** using the CIEDE2000 function, follow these examples :
- [compare-hex-colors.rb](compare-hex-colors.rb#L187)
- [compare-rgb-colors.rb](compare-rgb-colors.rb#L187)

## Verification

[![Ruby CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-rb.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-rb.yml)

<details>
<summary>What is the testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by Ruby**, like this :

1. `command -v ruby > /dev/null || { sudo apt-get update && sudo apt-get install ruby ; }`
2. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install gcc ; }`
3. `gcc -std=c99 -Wall -pedantic -Ofast -g tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
4. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
5. `ruby --yjit tests/rb/ciede-2000-driver.rb test-cases.csv | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.rb](ciede-2000-driver.rb#L82) for calculations and [test-rb.yml](../../.github/workflows/test-rb.yml) for automation.
</details>

The test confirms full compliance with the standard, showing no errors :

```
CIEDE2000 Verification Summary :
  First Verified Line : 4.54,-122,-35,10,116.6,91.92,86.21001308276066766
             Duration : 45.80 s
            Successes : 10000000
               Errors : 0
      Average Delta E : 62.9465
    Average Deviation : 3.4328080100731738e-15
    Maximum Deviation : 8.5265128291212022e-14
```

### Comparison with the Gem colorscore in Ruby

[![ΔE2000 against colorscore in Ruby](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-colorscore.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-colorscore.yml)

Compared with the well-maintained **colorscore** gem — first released in 2016 and still widely used 9 years later — this implementation of the CIE ΔE*<sub>00</sub> color difference formula, tested on millions of color pairs, shows an absolute deviation of no more than **4 × 10<sup>-13</sup>**. This  neglieable difference argues in favor of the interoperability of this `ciede_2000` function, in Ruby as in other programming languages.

> [!IMPORTANT]
> To correct this Ruby source code to exact match certain third-party ΔE2000 functions, follow the comments in the source code.

> This formula, "small" in size, is an essential pillar of color management, deserving of this rigorous, tested and reliable industrial treatment.

### Speed Benchmark

This function was measured at a speed of 497,425 calls per second.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **GCC** : 13.3
- **Ruby** : 3.3.8

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in Ruby** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=87.29&a1=-113.03&b1=-48.6&L2=19&a2=-51.6&b2=1.82) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Suitable in 40+ Languages](../../#implementations)
