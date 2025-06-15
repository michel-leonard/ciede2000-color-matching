# ΔE2000 — Accurate. Fast. C-powered.

ΔE2000 is the most widely accepted metric for evaluating color differences in line with human visual perception.

This canonical **C** implementation offers an easy way to calculate these differences accurately and programmatically.

## Overview

The presented algorithm enables your software to measure color similarity and difference with scientific rigor.

For reference, two very distinct colors typically have a ΔE2000 value greater than 12.

Lower values indicate greater closeness, making it a **state-of-the-art method** for comparing colors.

## Implementation Details

The full source code, released on March 1, 2025, is available in two precision variants :
- <ins>Precision</ins> : for rigorous scientific validations, a **64-bit double precision** version, which can be found [here](../../ciede-2000.c#L13) and is archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.c).
- <ins>Performance</ins> : for most practical applications, a version supporting **32-bit single precision** is available [in this file](ciede-2000-single-precision.c#L20).

<details>
<summary>Which version should I use ?</summary>

- The 32-bit version is recommended for user interfaces, real-time processing, and embedded systems.
- The 64-bit version is necessary for professional color calibration, extreme cases, or critical analysis.
</details>

[Swift](../swift#δe2000--accurate-fast-swift-powered), Objective-C, [Julia](../jl#δe2000--accurate-fast-julia-powered), [D](../d#δe2000--accurate-fast-d-powered), and [C++](../cpp#δe2000--accurate-fast-c-powered) can all seamlessly integrate this classic source code.

Starting with GCC supporting C++14, the `ciede_2000` function can be used in **constant expressions** in C++.

## Example usage in C

For these programming languages, see the original [full example](../../#source-code-in-c).

To compare **hexadecimal** (e.g., "#FFF") or **RGB colors** using the CIEDE2000 function, follow these examples :
- [compare-hex-colors.c](compare-hex-colors.c#L208)
- [compare-rgb-colors.c](compare-rgb-colors.c#L208)

## Verification

[![C99 CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-c.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-c.yml)

<details>
<summary>What is the testing procedure ?</summary>

The C99 implementation is tested against several external [established sources](../#comparison-with-established-libraries), and internally against JavaScript, like this :

1. `command -v node > /dev/null || { sudo apt-get update && sudo apt-get install -y nodejs ; }`
2. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install -y gcc ; }`
3. `gcc -std=c99 -Wall -pedantic -Ofast tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
4. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
5. `./ciede-2000-driver -s -i test-cases.csv | node tests/js/ciede-2000-driver.js`

Where the two main files involved are [ciede-2000-driver.c](ciede-2000-driver.c) for calculations, and [test-c.yml](../../.github/workflows/test-c.yml) for automation.
</details>

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
 CIEDE2000 Verification Summary :
  First Verified Line : 48,104,115.93,93,27,56.7,40.47788983936747087
             Duration : 18.26 s
            Successes : 10000000
               Errors : 0
      Average Delta E : 62.9586
    Average Deviation : 6.0772934018515914e-15
    Maximum Deviation : 2.4158453015843406e-13
```

### Comparison with the VMAF C99 Library

To ensure top accuracy and reliability, this ΔE2000 implementation was compared to the [Video Multi-Method Assessment Fusion](https://github.com/Netflix/vmaf) (VMAF) reference implementation, developed by **Netflix**, a world’s largest video content distributor. First released in 2016, VMAF is an open-source video quality metric widely adopted by major platforms like **YouTube**, **Meta**, **Amazon**, and **Twitch**, confirming its industry-standard status.

Using 1,000,000,000 randomly generated L\*a\*b\* color pairs, the comparison [workflow](../../.github/workflows/vs-netflix.yml) produced the following results :

```
 -------------------------------
----   CIEDE2000 Summary   ----
-------------------------------
         Duration : 388.91 s
       Iterations : 1000000000
        Successes : 1000000000
           Errors : 0
Average deviation : 9.57e-15
Maximum deviation : 4.69e-13
```

This confirms a near-perfect alignment with VMAF's trusted implementation, strongly validating the quality of this C-based ΔE2000 algorithm.

### Speed Benchmark

This function has been measured at over **7.3 million ΔE2000 computations per second**, on a standard system.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **GCC** : 13.3.0
- **NodeJS** : 20.19.2

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in C** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=61.3&a1=109.1&b1=2.76&L2=40.1&a2=29&b2=123.3) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Used in 30+ Languages](../../#implementations)

