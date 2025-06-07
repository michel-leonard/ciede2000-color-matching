# ΔE2000 — Accurate. Fast. Kotlin-powered.

This reference ΔE2000 implementation written in Kotlin provides reliable and accurate perceptual **color difference** calculation.

## Source Code

The full source code, released on March 1, 2025, is available in two precision variants :
- A **64-bit double precision** version, which can be found [here](../../ciede-2000.kt#L8) and is archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.kt).
- A **32-bit single precision** version, <ins>suitable for most practical applications</ins>, is available [here](ciede-2000-single-precision.kt#L15).

[Java](../java#δe2000--accurate-fast-java-powered), Scala and Groovy can all seamlessly integrate this classic source code.

## Example usage in Kotlin

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```kt
// Example usage of the CIEDE2000 function in Kotlin

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

[![Kotlin CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-kt.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-kt.yml)

<details>
<summary>What is the testing procedure ?</summary>

 1. `cp tests/kt/ciede-2000-testing.kt exec.kt`
 2. `kotlinc exec.kt -include-runtime -d exec.jar`
 3. `gcc -O3 tests/c/stdin-verifier.c -o verifier -lm`
 4. `java -jar exec.jar 10000000 | ./verifier > test-output.txt`

Where the two main files involved are [ciede-2000-testing.kt](ciede-2000-testing.kt#L120) and [raw-kt.yml](../../.github/workflows/raw-kt.yml).
</details>

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
CIEDE2000 Verification Summary :
- Last Verified Line : 22.0400,-40.6700,123.510,22.6000,-115.800,3.92000,39.5539626132356
- Duration : 54.27 s
- Successes : 10000000
- Errors : 0
- Maximum Difference : 6.9633188104489818e-13
```

### Computational Speed

This function was measured at a speed of 6,866,722 calls per second.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **kotlinc** : 2.1.10
- **GCC** : 13.3.0
- **JDK** : 17.0.15

## Conclusion

With over 20 years serving developers, this **trusted color comparison** routine developed in Kotlin brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=22.04&a1=-40.67&b1=123.51&L2=22.6&a2=-115.8&b2=3.92) — [Workflow Details](../../.github/workflows#workflow-details) — [Across 30+ programming languages](../../#implementations)

