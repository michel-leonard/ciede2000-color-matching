# ΔE2000 — Accurate. Fast. Kotlin-powered.

ΔE2000 is the current global standard for quantifying color differences in a way that best matches human vision.

This reference implementation in **Kotlin** offers a simple way of calculating these differences accurately and programmatically.

## Overview

The developed algorithm enables software to evaluate color similarities (or differences) with scientific rigor.

As a general rule, 🔵 navy blue and 🟡 yellow, which are very different colors, have a ΔE\*<sub>00</sub> of around 115.

Values [such as 5](https://michel-leonard.github.io/ciede2000-color-matching/de2000-rgb-pairs.html?seq=50&delta-e=5) indicate greater closeness, making this both a simple and advanced method of color comparison.

## Implementation Details

The full source code, released on March 1, 2025, is available in two precision variants :
- **64-bit double precision** version (suitable for most practical applications) : [Source code](../../ciede-2000.kt#L8) — [Archive](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.kt)
- **32-bit single precision** version : [Source code](ciede-2000-single-precision.kt#L15)

Compatible with [Java](../java#δe2000--accurate-fast-java-powered), Scala, and Groovy for seamless integration.

<details>
<summary>What two options are available for matching ΔE2000 calculations with existing calculations ?</summary>

#### Option 1 (default)
 This often-used option consists of a coding simplification that is a historical legacy of early implementations :
```kt
h_m += PI;
// if (h_m < PI) h_m += PI; else h_m -= PI;
```

#### Option 2 (compatible with Gaurav Sharma’s precise calculations)
There’s no room for ambiguity, this inversion of the commented line in the source code ensures compliance with the official :
```kt
// h_m += PI;
if (h_m < PI) h_m += PI; else h_m -= PI;
```

**Note** : the difference between the two options is minimal (±0.0003 on the calculated color difference) and usually overlooked.
</details>

## Example usage in Kotlin

Here’s how to calculate the **Delta E 2000** between two colors in Kotlin using the `ciede_2000` function :
```kt
// Compute the Delta E (CIEDE2000) color difference between two L*a*b* colors in Kotlin

// Color 1: l1 = 11.5   a1 = 17.3   b1 = 5.0
// Color 2: l2 = 13.4   a2 = 11.5   b2 = -3.0

val deltaE = ciede_2000(l1, a1, b1, l2, a2, b2)
println(deltaE)

// .................................................. This shows a ΔE2000 of 7.1298347818
// As explained in the comments, compliance with Gaurav Sharma would display 7.1298482937
```

**Note** : L\* is nominally between 0 and 100, a\* and b\* typically between -128 and +127.

To compare **hexadecimal** (e.g., "#FFF") or **RGB colors** using the CIEDE2000 function, follow these examples :
- [compare-hex-colors.kt](compare-hex-colors.kt#L205)
- [compare-rgb-colors.kt](compare-rgb-colors.kt#L205)

## Verification

[![Kotlin CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-kt.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-kt.yml)

<details>
<summary>What is the testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by Kotlin**, like this :

1.
```sh
if ! command -v kotlinc > /dev/null; then
 wget --quiet --no-check-certificate --timeout=5 --tries=3 https://get.sdkman.io -O- | bash
 printf '%s\n' \
  "sdkman_auto_answer=true" \
  "sdkman_auto_selfupdate=true" > "$HOME/.sdkman/etc/config"
 source "$HOME/.sdkman/bin/sdkman-init.sh"
 sdk install kotlin
fi
```
2. `command -v java > /dev/null || { sudo apt-get update && sudo apt-get install default-jdk; }`
3. `cp tests/kt/ciede-2000-driver.kt exec.kt`
4. `kotlinc exec.kt -include-runtime -d exec.jar`
5. `gcc -std=c99 -Wall -pedantic -O2 -g tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
6. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
7. `java -jar exec.jar test-cases.csv | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.kt](ciede-2000-driver.kt#L89) for calculations and [test-kt.yml](../../.github/workflows/test-kt.yml) for automation.
</details>
The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
 CIEDE2000 Verification Summary :
  First Verified Line : 36,-56,-63.5,36.06,-4,108,63.13840748980284
             Duration : 20.19 s
            Successes : 10000000
               Errors : 0
      Average Delta E : 62.9269
    Average Deviation : 5.3503654673381358e-15
    Maximum Deviation : 2.4158453015843406e-13
```

### Comparison with ndtp/android-testify

[![ΔE2000 against Shopify in Kotlin](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-shopify.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-shopify.yml)

Compared to the well-established **android-testify** library from Shopify — first released in 2019 — this ΔE\*<sub>00</sub> function, checked on billions of random L\*a\*b\* color pairs, has an absolute deviation of no more than **3 × 10<sup>-13</sup>**. As before in [C99](../c#comparison-with-the-vmaf-c99-library), [Java](../java#comparison-with-the-openimaj), [JavaScript](../js#comparison-with-the-npmchroma-js-library), [Python](../py#comparison-with-the-python-colormath-library) and  [Rust](../rs#comparison-with-the-palette-library), this confirms the interoperability and production-ready status of the `ciede_2000` function within the JetBrains Kotlin ecosystem.

> [!IMPORTANT]
> To correct this Kotlin source code to exact match certain third-party ΔE2000 functions, follow the comments in the source code.

> This formula, "small" in size, is an essential pillar of color management, deserving of this rigorous, tested and reliable industrial treatment.

### Performance Benchmark

This function was measured at a speed of **6,866,722 calls per second**.

| Software | Version |
|:--:|:--:|
| Ubuntu | 24.04.2 LTS |
| kotlinc | 2.1.10 |
| GCC | 13.3 |
| JDK | 17.0.15 |

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in Kotlin** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=34.9&a1=9.5&b1=14.1&L2=18.9&a2=30.9&b2=-44.5) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Suitable in 40+ Languages](../../#implementations)
