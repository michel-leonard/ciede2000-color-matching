# ΔE2000 — Accurate. Fast. Java-powered.

ΔE2000 is the current standard for quantifying color differences in a way that best matches human vision.

This canonical **Java** implementation offers an easy way to calculate these differences accurately within programs.

## Overview

The developed algorithm enables software to evaluate color similarities (or differences) with scientific rigor.

As a general rule, navy blue and yellow, which are very different colors, generally have a ΔE<sub>00</sub> of around 115.

Values such as 5 indicate greater closeness, making this both a simple and advanced method of color comparison.

## Implementation Details

The full source code (Java, released March 1, 2025) is available [here](../../ciede-2000.java#L14) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.java).

[Kotlin](../kt#δe2000--accurate-fast-kotlin-powered), Groovy, Scala, Clojure and JRuby can all seamlessly integrate this classic source code.

## Example usage in Java

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```java
// Compute the Delta E (CIEDE2000) color difference between two Lab colors in Java

// L1 = 19.3166        a1 = 73.5           b1 = 122.428
// L2 = 19.0           a2 = 76.2           b2 = 91.372

double deltaE = ciede_2000(l1, a1, b1, l2, a2, b2);
System.out.println(deltaE);

// This shows a ΔE2000 of 9.60876174564
```

**Note** : L\* is generally between 0 and 100, a\* and b\* typically between -128 and +127.

To compare **hexadecimal** (e.g., "#FFF") or **RGB colors** using the CIEDE2000 function, follow these examples :
- [compare-hex-colors.java](compare-hex-colors.java#L188)
- [compare-rgb-colors.java](compare-rgb-colors.java#L188)

## Verification

[![Java CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-java.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-java.yml)

<details>
<summary>What is the testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by Java**, like this :

1. `command -v javac > /dev/null || { sudo apt-get update && sudo apt-get install default-jdk ; }`
2. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install gcc ; }`
3. `cp -p tests/java/ciede-2000-driver.java Main.java`
4. `javac Main.java`
5. `gcc -std=c99 -Wall -pedantic -Ofast -ffast-math -g tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
6. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
7. `java Main test-cases.csv | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.java](ciede-2000-driver.java#L93) for calculations and [test-java.yml](../../.github/workflows/test-java.yml) for automation.
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

### Speed Benchmark

This function was measured at a speed of 4,264,445 calls per second.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **GCC** : 13.3
- **JDK** : 17.0.15

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in Java** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=78.03&a1=-115.16&b1=-53.16&L2=96.25&a2=-8.91&b2=20.18) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Suitable in 30+ Languages](../../#implementations)
