# ΔE2000 — Accurate. Fast. C#-powered.

ΔE2000 is currently the most accurate standard for quantifying color differences in a way that best matches human vision.

This reference implementation in **C#** offers a simple way to calculate these differences accurately and programmatically.

## Overview

This implementation enables **.NET** software to evaluate color similarities and differences with scientific precision.

As a general rule, 🔵 navy blue and 🟡 yellow, which are very different colors, have a ΔE\*<sub>00</sub> of around 115.

Values [such as 5](https://michel-leonard.github.io/ciede2000-color-matching/de2000-rgb-pairs.html?seq=50&delta-e=5) indicate greater closeness, making this both a simple and advanced method of color comparison.

## Implementation Details

The full source code, released on March 1, 2025, is available in two precision variants :
- <ins>Precision</ins> : for rigorous scientific validations, a **64-bit double precision** version, which can be found [here](../../ciede-2000.cs#L6) and is archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.cs).
- <ins>Performance</ins> : for most practical applications, a version supporting **32-bit single precision** is available [in this file](ciede-2000-single-precision.cs#L13).

**In short** : 32-bit floating-point numbers offer speed gains of around 30%, and [negligible deviations](../../#use-the-ciede_2000-function-in-32-bit-rather-than-64-bit) with a better memory footprint.

VB.NET and [F#](../fs#δe2000--accurate-fast-f-powered) can both seamlessly integrate this classic source code.

<details>
<summary>What two options are available for matching ΔE2000 calculations with existing calculations ?</summary>

#### Option 1 (default)
 This often-used option consists of a coding simplification that is a historical legacy of early implementations :
```csharp
h_m += Math.PI;
// if (h_m < Math.PI) h_m += Math.PI; else h_m -= Math.PI;
```

#### Option 2 (compatible with Gaurav Sharma’s precise calculations)
There’s no room for ambiguity, this inversion of the commented line in the source code ensures compliance with the official :
```csharp
// h_m += Math.PI;
if (h_m < Math.PI) h_m += Math.PI; else h_m -= Math.PI;
```

**Note** : the difference between the two options is minimal (±0.0003 on the calculated color difference) and usually overlooked.
</details>

## Example Usage in C#

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```csharp
// Compute the Delta E (CIEDE2000) color difference between two L*a*b* colors in C# (.NET Core)

double l1 = 95.3,  a1 = 39.2,  b1 = -1.7;
double l2 = 94.8,  a2 = 45.0,  b2 = 2.1;

double deltaE = ciede_2000(l1, a1, b1, l2, a2, b2);
Console.WriteLine(deltaE);

// .................................................. This shows a ΔE2000 of 2.8916930349
// As explained in the comments, compliance with Gaurav Sharma would display 2.8917067928
```

**Note** : L\* is nominally between 0 and 100, a\* and b\* generally between -128 and +127.

For color inputs in **hexadecimal** (e.g., `#FFF`) or **RGB** formats, see examples for other languages :

[AWK](../awk#-flexibility), [C](../c#δe2000--accurate-fast-c-powered), [Dart](../dart#δe2000--accurate-fast-dart-powered), [Java](../java#δe2000--accurate-fast-java-powered), [JavaScript](../js#-flexibility), [Kotlin](../kt#δe2000--accurate-fast-kotlin-powered), [Lua](../lua#-flexibility), [PHP](../php#δe2000--accurate-fast-php-powered), [Python](../py#δe2000--accurate-fast-python-powered), [Ruby](../rb#δe2000--accurate-fast-ruby-powered), [Rust](../rs#δe2000--accurate-fast-rust-powered).

## Verification

[![C# CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-cs.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-cs.yml)

<details>
<summary>What is the testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by C#**, like this :

1. `command -v dotnet > /dev/null || { sudo apt-get update && sudo apt-get install dotnet-sdk-8.0 ; }`
2. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install gcc ; }`
3. `dotnet tool install -g dotnet-script`
4. `gcc -std=c99 -Wall -pedantic -O2 -g tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
5. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
6. `dotnet script tests/cs/ciede-2000-driver.cs test-cases.csv | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.cs](ciede-2000-driver.cs#L90) for calculations and [test-cs.yml](../../.github/workflows/test-cs.yml) for automation.
</details>

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
CIEDE2000 Verification Summary :
  First Verified Line : 65,44.1,69,8.3,-46.8,-22.9,72.86971426109767
             Duration : 32.12 s
            Successes : 10000000
               Errors : 0
      Average Delta E : 62.9416
    Average Deviation : 4.2567882330146744e-15
    Maximum Deviation : 1.1368683772161603e-13
```

### Comparison with the Masuit.Tools Library

[![ΔE2000 against Masuit.Tools in C#](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-masuit-tools.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-masuit-tools.yml)

Compared to one of the most widely recognized implementations of this algorithm in C#, **Masuit.Tools**’s, this public domain ΔE\*<sub>00</sub> function, checked on billions of random L\*a\*b\* color pairs, has an absolute deviation of no more than **5 × 10<sup>-13</sup>**. By default, without any modification, matching with this well-established implementation is guaranteed with a tolerance of **3 × 10<sup>-4</sup>** in ΔE2000 results. However, to get the same ΔE\*<sub>00</sub> results as Masuit.Tools given a tolerance of less than **10<sup>-12</sup>**, do what’s explained [here](../../ciede-2000.cs#L34) in the source code, as follows :

```diff
- h_m += Math.PI;
+ if (h_m < Math.PI) h_m += Math.PI; else h_m -= Math.PI;
```

> These are the two main variants for implementing the ΔE\*<sub>00</sub> function. The default is simpler, accurate enough, and widely used in practice. This formula, "small" in size, is an essential pillar of color management, deserving of this rigorous, tested and reliable industrial treatment.

### Speed Benchmark

This function was measured at a speed of 3,168,561 calls per second.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **Dotnet** : 8.0.410
- **GCC** : 13.3

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in C#** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=69.5&a1=43.8&b1=-37.9&L2=83.6&a2=10.8&b2=9.6) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Suitable in 40+ Languages](../../#implementations)

