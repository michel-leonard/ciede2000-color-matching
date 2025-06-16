# ΔE2000 — Accurate. Fast. Kotlin-powered.

ΔE2000 is the current standard for quantifying color differences in a way that matches human perception.

This canonical **Kotlin** implementation offers an easy way to calculate these differences accurately and programmatically.

## Overview

The ΔE2000 algorithm allows software to measure color similarity and difference with scientific rigor.

For reference, two very distinct colors typically have a ΔE2000 value greater than 12, while lower values indicate higher similarity.

Lower values indicate greater similarity between colors, making it a **state-of-the-art method** for perceptual color comparison.

## Implementation Details

The full source code, released on March 1, 2025, is available in two precision variants :
- **64-bit double precision** version (suitable for most practical applications) : [Source code](../../ciede-2000.kt#L8) — [Archive](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.kt)  
- **32-bit single precision** version : [Source code](ciede-2000-single-precision.kt#L15)
  
Compatible with [Java](../java#δe2000--accurate-fast-java-powered), Scala, and Groovy for seamless integration.

## Example usage in Kotlin

Here's how to calculate the **Delta E 2000** between two colors in Kotlin using the `ciede_2000` function :
```kt
// Compute the Delta E (CIEDE2000) color difference between two Lab colors in Kotlin

// L1 = 19.3166        a1 = 73.5           b1 = 122.428
// L2 = 19.0           a2 = 76.2           b2 = 91.372

val deltaE = ciede_2000(l1, a1, b1, l2, a2, b2)
println(deltaE)

// This shows a ΔE2000 of 9.60876174564
```

**Note**: L\* is usually between 0 and 100, a\* and b\* between -128 and +127.

To compare **hexadecimal** (e.g., "#FFF") or **RGB colors** using the CIEDE2000 function, follow these examples :
- [compare-hex-colors.kt](compare-hex-colors.kt#L231)
- [compare-rgb-colors.kt](compare-rgb-colors.kt#L231)

## Verification

[![Kotlin CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-kt.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-kt.yml)

<details>
<summary>What is the testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by Kotlin**, like this :

1.
```sh
if ! command -v kotlinc > /dev/null; then
 wget --timeout=5 --tries=3 -qO- https://get.sdkman.io | bash
 printf '%s\n' \
  "sdkman_auto_answer=true" \
  "sdkman_auto_selfupdate=true" > "$HOME/.sdkman/etc/config"
 source "$HOME/.sdkman/bin/sdkman-init.sh"
 sdk install kotlin
fi
```
2. `command -v java > /dev/null || { sudo apt-get update && sudo apt-get install -y default-jdk; }`
3. `cp tests/kt/ciede-2000-driver.kt exec.kt`
4. `kotlinc exec.kt -include-runtime -d exec.jar`
5. `gcc -std=c99 -Wall -pedantic -Ofast tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
6. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
7. `java -jar exec.jar test-cases.csv | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.kt](ciede-2000-driver.kt#L123) for calculations and [test-kt.yml](../../.github/workflows/test-kt.yml) for automation.
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

### Performance Benchmark

This function was measured at a speed of **6,866,722 calls per second**.

| Software | Version |
|:--:|:--:|
| Ubuntu | 24.04.2 LTS |
| kotlinc | 2.1.10 |
| GCC | 13.3.0 |
| JDK | 17.0.15 |

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in Kotlin** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=22.04&a1=-40.67&b1=123.51&L2=22.6&a2=-115.8&b2=3.92) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Used in 30+ Languages](../../#implementations)

