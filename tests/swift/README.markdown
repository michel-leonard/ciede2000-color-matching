# ΔE2000 — Accurate. Fast. Swift-powered.

ΔE2000 is the global standard for quantifying the difference between two colors as the human eye would.

This reference implementation in **Swift** offers a simple way of calculating these differences accurately within programs.

## Overview

The developed algorithm enables software to evaluate color similarities (or differences) with scientific rigor.

As a general rule, 🔵 navy blue and 🟡 yellow, which are very different colors, have a ΔE\*<sub>00</sub> of around 115.

Values [such as 5](https://michel-leonard.github.io/ciede2000-color-matching/de2000-rgb-pairs.html?seq=50&delta-e=5) indicate greater closeness, making this both a simple and advanced method of color comparison.

## Implementation Details

The full source code released on March 1, 2025, is available [here](../../ciede-2000.swift#L8) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.swift).

Objective-C can seamlessly integrate this classic source code.

<details>
<summary>What two options are available for matching ΔE2000 calculations with existing calculations ?</summary>

#### Option 1 (default)
 This often-used option consists of a coding simplification that is a historical legacy of early implementations :
```swift
h_m += .pi;
// if h_m < .pi { h_m += .pi; } else { h_m -= .pi; }
```

#### Option 2 (compatible with Gaurav Sharma’s precise calculations)
There’s no room for ambiguity, this inversion of the commented line in the source code ensures compliance with the official :
```swift
// h_m += .pi;
if h_m < .pi { h_m += .pi; } else { h_m -= .pi; }
```

**Note** : the difference between the two options is minimal (±0.0003 on the calculated color difference) and usually overlooked.
</details>

## Example usage in Swift

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```swift
// Compute the Delta E (CIEDE2000) color difference between two L*a*b* colors in Swift

let (l1, a1, b1) = (30.0, 28.0, -3.7)
let (l2, a2, b2) = (32.5, 21.8, 3.6)

let delta_e = ciede_2000(l_1: l1, a_1: a1, b_1: b1, l_2: l2, a_2: a2, b_2: b2)
print(delta_e)

// .................................................. This shows a ΔE2000 of 5.9485905742
// As explained in the comments, compliance with Gaurav Sharma would display 5.9485740608
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
2. `gcc -std=c99 -Wall -pedantic -O2 -g tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
3. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
4. `./ciede-2000-tests test-cases.csv | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.swift](ciede-2000-driver.swift#L86) for calculations and [test-swift.yml](../../.github/workflows/test-swift.yml) for automation.
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
### Comparison with the pretty Library

[![ΔE2000 against pretty in Swift](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-pretty.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-pretty.yml)

Compared to the Swift **octree/pretty** implementation — first released in 2017 — this implementation of the ΔE2000 color difference formula, verified over 100 million color pair comparisons, exhibits an absolute deviation of no more than **5 × 10<sup>-13</sup>**. This confirms, in the same way as for the [C99](../c#comparison-with-the-vmaf-c99-library), [Java](../java#comparison-with-the-openimaj), [JavaScript](../js#comparison-with-the-npmchroma-js-library), [Python](../py#comparison-with-the-python-colormath-library) and [Rust](../rs#comparison-with-the-palette-library) versions, the interoperability and production-ready status of the `ciede_2000` function in Swift.

> [!IMPORTANT]
> To correct this Swift source code to exact match certain third-party ΔE2000 functions, follow the comments in the source code.

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

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=33.5&a1=55.2&b1=30.6&L2=33.2&a2=19.7&b2=-10.6) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Suitable in 40+ Languages](../../#implementations)
