# ΔE2000 — Accurate. Fast. Java-powered.

ΔE2000 is the current standard for quantifying color differences in a way that best matches human vision.

This reference **Java** implementation offers an easy way to calculate these differences accurately within programs.

## Overview

The developed algorithm enables software to evaluate color similarities (or differences) with scientific rigor.

As a general rule, 🔵 navy blue and 🟡 yellow, which are very different colors, have a ΔE\*<sub>00</sub> of around 115.

Values [such as 5](https://michel-leonard.github.io/ciede2000-color-matching/de2000-rgb-pairs.html?seq=50&delta-e=5) indicate greater closeness, making this both a simple and advanced method of color comparison.

## Implementation Details

The full source code (Java, released March 1, 2025) is available [here](../../ciede-2000.java#L6) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.java).

This classic source code can easily be integrated into a Processing sketch.

<details>
<summary>What two options are available for matching ΔE2000 calculations with existing calculations ?</summary>

#### Option 1 (default)
 This often-used option consists of a coding simplification that is a historical legacy of early implementations :
```java
h_m += Math.PI;
// h_m += h_m < Math.PI ? Math.PI : -Math.PI;
```

#### Option 2 (compatible with Gaurav Sharma’s precise calculations)
There’s no room for ambiguity, this inversion of the commented line in the source code ensures compliance with the official :
```java
// h_m += Math.PI;
h_m += h_m < Math.PI ? Math.PI : -Math.PI;
```

**Note** : the difference between the two options is minimal (±0.0003 on the calculated color difference) and usually overlooked.
</details>

## Example usage in Java

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```java
// Compute the Delta E (CIEDE2000) color difference between two L*a*b* colors in Java

// Color 1: l1 = 6.3    a1 = 39.4   b1 = 3.6
// Color 2: l2 = 6.5    a2 = 33.4   b2 = -2.0

double deltaE = ciede_2000(l1, a1, b1, l2, a2, b2);
System.out.println(deltaE);

// .................................................. This shows a ΔE2000 of 3.9368581959
// As explained in the comments, compliance with Gaurav Sharma would display 3.9368724643
```

**Note** : L\* is generally between 0 and 100, a\* and b\* typically between -128 and +127.

To compare **hexadecimal** (e.g., "#FFF") or **RGB colors** using the CIEDE2000 function, follow these examples :
- [compare-hex-colors.java](compare-hex-colors.java#L192)
- [compare-rgb-colors.java](compare-rgb-colors.java#L192)

## Verification

[![Java CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-java.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-java.yml)

<details>
<summary>What is the testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by Java**, like this :

1. `command -v javac > /dev/null || { sudo apt-get update && sudo apt-get install default-jdk ; }`
2. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install gcc ; }`
3. `cp -p tests/java/ciede-2000-driver.java Main.java`
4. `javac Main.java`
5. `gcc -std=c99 -Wall -pedantic -O2 -g tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
6. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
7. `java Main test-cases.csv | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.java](ciede-2000-driver.java#L91) for calculations and [test-java.yml](../../.github/workflows/test-java.yml) for automation.
</details>

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
 CIEDE2000 Verification Summary :
  First Verified Line : 93.6,-78,-117.9,12,-93,-7.72,86.22963867911595000
             Duration : 59.55 s
            Successes : 10000000
               Errors : 0
      Average Delta E : 62.9317
    Average Deviation : 5.3488200396634159e-15
    Maximum Deviation : 2.8421709430404007e-13
```

### Comparison with The OpenIMAJ

[![ΔE2000 against OpenIMAJ in Java](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-openimaj.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-openimaj.yml)

Compared to the well-established **OpenIMAJ** library — first released in 2011 and still widely used 14 years later — this ΔE\*<sub>00</sub> function, checked on billions of random L\*a\*b\* color pairs, has an absolute deviation of no more than **3 × 10<sup>-13</sup>**. As before in [C99](../c#comparison-with-the-vmaf-c99-library), [JavaScript](../js#comparison-with-the-npmchroma-js-library), [Python](../py#comparison-with-the-python-colormath-library) and  [Rust](../rs#comparison-with-the-palette-library), this confirms the interoperability of this colorimetry algorithm in Java, including with the award-winning one from the University of Southampton.

```text
====================================
       CIEDE2000 Comparison
====================================
Total duration        : 5841.37 seconds
Iterations run        : 10000000000
Successful matches    : 10000000000
Discrepancies found   : 0
Avg Delta E deviation : 8.65e-15
Max Delta E deviation : 2.42e-13
====================================
```

### Comparison with OpenJDK

[![ΔE2000 against OpenJDK in Java](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-openjdk.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-openjdk.yml)

Compared to the most widely redistributed implementation of this algorithm in Java, **OpenJDK**’s, this public domain ΔE\*<sub>00</sub> function, checked on billions of random L\*a\*b\* color pairs, has an absolute deviation of no more than **3 × 10<sup>-13</sup>**. By default, without any modification, matching with this well-considered implementation is guaranteed with a tolerance of **3 × 10<sup>-4</sup>** in ΔE2000 results. However, to get the same ΔE\*<sub>00</sub> results as OpenJDK given a tolerance of less than **10<sup>-12</sup>**, do what’s explained [here](../../ciede-2000.java#L34) in the source code, as follows :

```diff
-	h_m += Math.PI;
+	h_m += h_m < Math.PI ? Math.PI : -Math.PI;
```

> These are the two main variants for implementing the ΔE\*<sub>00</sub> function. The default is simpler, accurate enough, and widely used in practice. This formula, "small" in size, is an essential pillar of color management, deserving of this rigorous, tested and reliable industrial treatment.

### Speed Benchmark

This function was measured at a speed of 4,264,445 calls per second.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **GCC** : 13.3
- **JDK** : 17.0.15

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in Java** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=44.3&a1=9.3&b1=-6.1&L2=43.2&a2=46.9&b2=31.3) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Suitable in 40+ Languages](../../#implementations)
