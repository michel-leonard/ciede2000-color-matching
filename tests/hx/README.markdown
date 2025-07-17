# ΔE2000 — Accurate. Fast. Haxe-powered.

ΔE2000 is the globally adopted standard for reliably measuring perceptual color differences.

This reference implementation in **Haxe** makes it easy to calculate these differences accurately in code.

## Overview

The developed algorithm enables software to evaluate color similarities (or differences) with scientific rigor.

As a general rule, 🔵 navy blue and 🟡 yellow, which are very different colors, have a ΔE\*<sub>00</sub> of around 115.

Values [such as 5](https://michel-leonard.github.io/ciede2000-color-matching/de2000-rgb-pairs.html?seq=50&delta-e=5) indicate greater closeness, making this both a simple and advanced method of color comparison.

## Implementation Details

The full source code (released March 1, 2025) is available in the [main Haxe implementation](../../ciede-2000.hx#L9) and archived for reference [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.hx).

[JavaScript](../js#δe2000--accurate-fast-javascript-powered), [Python](../py#δe2000--accurate-fast-python-powered), [Java](../java#δe2000--accurate-fast-java-powered) can all seamlessly integrate this classic source code.

## Example usage in Haxe

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```hx
// Compute the Delta E (CIEDE2000) color difference between two Lab colors in Haxe

// Color 1: l1 = 64.9   a1 = 12.6   b1 = 3.0
// Color 2: l2 = 66.8   a2 = 18.3   b2 = -4.3

var deltaE: Float = ciede_2000(l1, a1, b1, l2, a2, b2);
trace(deltaE);

// .................................................. This shows a ΔE2000 of 6.6360262302
// As explained in the comments, compliance with Gaurav Sharma would display 6.6360100975
```

**Note** : L\* is nominally between 0 and 100, a\* and b\* usually between -128 and +127.

For color inputs in **hexadecimal** (e.g., `#FFF`) or **RGB** formats, see examples for other languages :

[AWK](../awk#-flexibility), [C](../c#δe2000--accurate-fast-c-powered), [Dart](../dart#δe2000--accurate-fast-dart-powered), [Java](../java#δe2000--accurate-fast-java-powered), [JavaScript](../js#-flexibility), [Kotlin](../kt#δe2000--accurate-fast-kotlin-powered), [Lua](../lua#-flexibility), [PHP](../php#δe2000--accurate-fast-php-powered), [Python](../py#δe2000--accurate-fast-python-powered), [Ruby](../rb#δe2000--accurate-fast-ruby-powered), [Rust](../rs#δe2000--accurate-fast-rust-powered).

## Verification

[![Haxe CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-hx.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-hx.yml)

<details>
<summary>What is the testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by Haxe**, like this :

1. `command -v haxe > /dev/null || { sudo apt-get update && sudo apt-get install haxe ; }`
2. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install gcc ; }`
3. `cp -p tests/hx/ciede-2000-driver.hx tests/hx/Main.hx`
4. `gcc -std=c99 -Wall -pedantic -Ofast -g tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
5. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
6. `haxe -cp tests/hx --run Main test-cases.csv | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.hx](ciede-2000-driver.hx#L93) for calculations and [test-hx.yml](../../.github/workflows/test-hx.yml) for automation.
</details>

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
 CIEDE2000 Verification Summary :
  First Verified Line : 11,-68.86,59.9,1,-69.38,-117.7,66.5323051729542101
             Duration : 136.05 s
            Successes : 10000000
               Errors : 0
      Average Delta E : 62.9504
    Average Deviation : 4.2509125594558664e-15
    Maximum Deviation : 1.1368683772161603e-13
```

> [!IMPORTANT]
> To correct this Haxe source code to exact match certain third-party ΔE2000 functions, follow the comments in the source code.

> This formula, "small" in size, is an essential pillar of color management, deserving of this rigorous, tested and reliable industrial treatment.

## Performance & Environment

- Speed : 5,294,042 calls per second
- Ubuntu : 24.04.2 LTS
- GCC : 13.3
- Haxe : 5.0.0-alpha

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in Haxe** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=81&a1=-107&b1=-35&L2=66&a2=51&b2=89.2) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Suitable in 40+ Languages](../../#implementations)
