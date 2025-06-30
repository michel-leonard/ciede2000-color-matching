# ΔE2000 — Accurate. Fast. C-powered.

ΔE2000 is the most widely accepted metric for evaluating color differences in accordance with human vision.

This canonical implementation in pure **C** offers an easy way to calculate these differences accurately and programmatically.

## Overview

The developed algorithm enables us to measure color similarity (or difference) efficiently and with scientific rigor.

As a general rule, navy blue and yellow, which are very different colors, generally have a ΔE<sub>00</sub> of around 115.

Values such as 5 indicate greater closeness, making this both a simple and advanced method of color comparison.

## Implementation Details

The full source code, released on March 1, 2025, is available in two precision variants. Here's a simple analysis of one billion measurements :

| Version |  Type | 	Throughput (calls/sec)	 | Speed Gain vs Double | Source code | Archive |
|:--:|:--:|:--:|:--:|:--:|:--:|
| 32-bit | `float` | 30,395,327 | +62.12%  | [View](ciede-2000-single-precision.c#L23) | — |
| 64-bit | `double` | 11,514,840 | — | [View](../../ciede-2000.c#L13) | [Archive](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.c) |

### Recommendation

Using 32-bit floats results in a typical maximum deviation of ±0.0002 in ΔE<sub>00</sub> — negligible for most visual tasks :

- The 32-bit version is recommended for user interfaces, real-time processing, and embedded systems.
- The 64-bit version is necessary for professional color calibration and high-precision batch analysis.

### Compatibility Notes

Starting with GCC supporting C++14, the `ciede_2000` function is usable in **constant expressions** (`constexpr`) in C++.

Other languages like [Swift](../swift#δe2000--accurate-fast-swift-powered), Objective-C, [Julia](../jl#δe2000--accurate-fast-julia-powered), [D](../d#δe2000--accurate-fast-d-powered), and [C++](../cpp#δe2000--accurate-fast-c-powered) can all seamlessly integrate this C source.


## Example usage in C

For this programming language, the [original example](../../#source-code-in-c) is available and looks like :

```c
// Compute the Delta E (CIEDE2000) color difference between two Lab colors in C99

const double l_1 = 22.7233, a_1 = 20.0904, b_1 = -46.694;
const double l_2 = 23.0331, a_2 = 14.973, b_2 = -42.5619;
const double delta_e = ciede_2000(l_1, a_1, b_1, l_2, a_2, b_2);
printf("%.12f\n", delta_e);

// This shows a ΔE2000 of 2.037258269709
```

**Note** : L\* nominally varies between 0 and 100, a\* and b\* typically between -128 and +127.

To compare **hexadecimal** (e.g., "#FFF") or **RGB colors** using the CIEDE2000 function, follow these examples :
- [compare-hex-colors.c](compare-hex-colors.c#L208)
- [compare-rgb-colors.c](compare-rgb-colors.c#L208)

## Verification

<details>
<summary>How is the 32-bit version of the function tested ?</summary>

The 32-bit version of `ciede_2000` inherits the validity of the 64-bit version by construction, thanks to a bitwise transitive validation chain.

First, the 64-bit C implementation of the function was extensively validated against trusted references such as the Netflix VMAF library and the authoritative ΔE2000 formulation by Gaurav Sharma (University of Rochester). This ensures that the 64-bit implementation is compliant with academic and industry standards, is methodologically sound, and operationally robust.

Next, a fully templated C++ version was created to support multiple floating-point precisions. When instantiated with `double`, this C++ version produces bit-for-bit identical results to the validated 64-bit C version. When instantiated with `float`, it matches the 32-bit C version exactly.

As a result, although the 32-bit and 64-bit versions differ in precision, each aligns perfectly with the corresponding templated C++ version. This confirms that the 32-bit implementation behaves correctly by mirroring the validated templated version instantiated with `float`.

This layered validation is reinforced by automated tests (`tests/cpp/ciede-2000-identity.cpp`), which run 80 million random color pairs through both implementations, compiled with aggressive optimizations (`g++ -std=c++14 -Ofast`), enforcing zero tolerance for output differences.

> Finally, the 32-bit version runs up to 60% faster, with a negligible ±0.0002 error, a tradeoff acceptable for most applications.

</details>

[![C99 CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-c.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-c.yml)

<details>
<summary>What is the testing procedure ?</summary>

The C99 implementation is tested against several external [established sources](../#comparison-with-established-libraries), and internally against JavaScript, like this :

1. `command -v node > /dev/null || { sudo apt-get update && sudo apt-get install nodejs ; }`
2. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install gcc ; }`
3. `gcc -std=c99 -Wall -pedantic -Ofast -ffast-math -g tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
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

[![ΔE2000 against Netflix VMAF](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-netflix.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-netflix.yml)

To guarantee best-in-class reliability, this C99 ΔE2000 implementation was compared to the reference implementation [Video Multi-Method Assessment Fusion](https://github.com/Netflix/vmaf) (VMAF), developed by Netflix, experts in video content delivery. Launched in 2016, VMAF is a video quality measurement library that has become an industry standard and is now widely adopted by **YouTube**, **Meta**, **Amazon** and **Twitch**, among others.

The following results were obtained by comparing 100,000,000,000 randomly generated L\*a\*b\* color pairs :

```
====================================
       CIEDE2000 Comparison
====================================
Total duration        : 38891.15 seconds
Iterations run        : 100000000000
Successful matches    : 100000000000
Discrepancies found   : 0
Avg Delta E deviation : 9.58e-15
Max Delta E deviation : 5.12e-13
====================================
```

This confirms an almost perfect alignment with Netflix's search product, asserting the quality of this ΔE2000 algorithm in C language.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **GCC** : 13.3
- **NodeJS** : 20.19.2

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in C** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=48&a1=104&b1=115.93&L2=93&a2=27&b2=56.7) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Suitable in 30+ Languages](../../#implementations)
