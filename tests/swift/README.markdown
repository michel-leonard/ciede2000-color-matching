# ΔE2000 — Accurate. Fast. Swift-powered.

ΔE2000 is the global standard for quantifying the difference between two colors as the human eye would.

This canonical implementation in **Swift** offers a simple way of calculating these differences accurately within programs.

## Overview

The developed algorithm enables software to evaluate color similarities (or differences) with scientific rigor.

As a general rule, 🔵 navy blue and 🟡 yellow, which are very different colors, have a ΔE\*<sub>00</sub> of around 115.

Values [such as 5](https://michel-leonard.github.io/ciede2000-color-matching/de2000-rgb-pairs.html?seq=50&delta-e=5) indicate greater closeness, making this both a simple and advanced method of color comparison.

## Implementation Details

The full source code released on March 1, 2025, is available [here](../../ciede-2000.swift#L8) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.swift).

Objective-C can seamlessly integrate this classic source code.

## Example usage in Swift

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```swift
// Compute the Delta E (CIEDE2000) color difference between two Lab colors in Swift

let l1 = 19.3166, a1 = 73.5, b1 = 122.428
let l2 = 19.0, a2 = 76.2, b2 = 91.372

let delta_e = ciede_2000(l_1: l1, a_1: a1, b_1: b1, l_2: l2, a_2: a2, b_2: b2)
print(delta_e)

// This shows a ΔE2000 of 9.60876174564
```

**Note** : L\* is nominally between 0 and 100, a\* and b\* usually between -128 and +127.

For color inputs in **hexadecimal** (e.g., `#FFF`) or **RGB** formats, see examples for other languages :

[AWK](../awk#-flexibility), [C](../c#δe2000--accurate-fast-c-powered), [Dart](../dart#δe2000--accurate-fast-dart-powered), [Java](../java#δe2000--accurate-fast-java-powered), [JavaScript](../js#-flexibility), [Kotlin](../kt#δe2000--accurate-fast-kotlin-powered), [Lua](../lua#-flexibility), [PHP](../php#δe2000--accurate-fast-php-powered), [Python](../py#δe2000--accurate-fast-python-powered), [Ruby](../rb#δe2000--accurate-fast-ruby-powered), [Rust](../rs#δe2000--accurate-fast-rust-powered).

## Verification

[![Swift CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-swift.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-swift.yml)

<details>
<summary>What is the testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by Swift**, like this :
1. `swiftc -Ounchecked tests/swift/ciede-2000-driver.swift -o ciede-2000-tests`
2. `gcc -std=c99 -Wall -pedantic -Ofast -ffast-math -g tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
3. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
4. `./ciede-2000-tests test-cases.csv | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.swift](ciede-2000-driver.swift#L79) for calculations and [test-swift.yml](../../.github/workflows/test-swift.yml) for automation.
</details>

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
 CIEDE2000 Verification Summary :
  First Verified Line : 5,50.66,-34,47.8,1.8,2,41.336597284307338
             Duration : 41.23 s
            Successes : 10000000
               Errors : 0
      Average Delta E : 62.9542
    Average Deviation : 6.6143187649192467e-15
    Maximum Deviation : 2.2737367544323206e-13
```

> This formula, "small" in size, is an essential pillar of color management, deserving of this rigorous, tested and reliable industrial treatment.

### Speed Benchmark

This function was measured at a speed of 2,643,774 calls per second.

### Software Versions

- **MacOS** : 14.7.6
- **Clang** : 15.0.0
- **Swift** : 5.10

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in Swift** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=46&a1=-62.8&b1=-10&L2=65&a2=-116.5&b2=-20) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Suitable in 30+ Languages](../../#implementations)
