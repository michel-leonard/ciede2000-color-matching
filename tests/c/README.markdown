# ΔE2000 — Accurate. Fast. C-powered.

ΔE2000 is the most widely accepted metric for evaluating color differences in accordance with human vision.

This reference implementation in pure **C** offers an easy way to calculate these differences accurately and programmatically.

## Overview

The developed algorithm enables us to measure color similarity (or difference) efficiently and with scientific rigor.

As a general rule, 🔵 navy blue and 🟡 yellow, which are very different colors, have a ΔE\*<sub>00</sub> of around 115.

Values [such as 5](https://michel-leonard.github.io/ciede2000-color-matching/de2000-rgb-pairs.html?seq=50&delta-e=5) indicate greater closeness, making this both a simple and advanced method of color comparison.

## Implementation Details

The full source code, released on March 1, 2025, is available in two precision variants. Here’s a simple analysis of one billion measurements :

| Version |  Type | 	Throughput (calls/sec)	 | Speed Gain vs Double | Source code | Archive |
|:--:|:--:|:--:|:--:|:--:|:--:|
| 32-bit | `float` | 30,395,327 | +62.12%  | [View](ciede-2000-single-precision.c#L23) | — |
| 64-bit | `double` | 11,514,840 | — | [View](../../ciede-2000.c#L13) | [Archive](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.c) |

### Recommendation

Using the 32-bit function results in [negligible deviations](../../#use-the-ciede_2000-function-in-32-bit-rather-than-64-bit) in most visual tasks :

- The 32-bit version is recommended for user interfaces, real-time processing, and embedded systems.
- The 64-bit version is necessary for professional color calibration and high-precision batch analysis.

### Compatibility Notes

Starting with GCC supporting C++14, the `ciede_2000` function is usable in **constant expressions** (`constexpr`) in C++.

Other languages like [Swift](../swift#δe2000--accurate-fast-swift-powered), Objective-C, [Julia](../jl#δe2000--accurate-fast-julia-powered), [D](../d#δe2000--accurate-fast-d-powered), and [C++](../cpp#δe2000--accurate-fast-c-powered) can all seamlessly integrate this C source.

<details>
<summary>What two options are available for matching ΔE2000 calculations with existing calculations ?</summary>

#### Option 1 (default)
 This often-used option consists of a coding simplification that is a historical legacy of early implementations :
```c
h_m += (M_PI < n) * M_PI;
// h_m += (M_PI < n) * ((h_m < M_PI) - (M_PI <= h_m)) * M_PI;
```

#### Option 2 (compatible with Gaurav Sharma’s precise calculations)
There’s no room for ambiguity, this inversion of the commented line in the source code ensures compliance with the official :
```c
// h_m += (M_PI < n) * M_PI;
h_m += (M_PI < n) * ((h_m < M_PI) - (M_PI <= h_m)) * M_PI;
```

**Note** : the difference between the two options is minimal (±0.0003 on the calculated color difference) and usually overlooked.
</details>

## Example usage in C

For this programming language, the [original example](../../#source-code-in-c) is available and looks like :

```c
// Compute the Delta E (CIEDE2000) color difference between two L*a*b* colors in C99

const double l_1 = 28.9, a_1 = 47.5, b_1 = 2.0;
const double l_2 = 28.8, a_2 = 41.6, b_2 = -1.7;

const double delta_e = ciede_2000(l_1, a_1, b_1, l_2, a_2, b_2);
printf("%.12f\n", delta_e);

// .................................................. This shows a ΔE2000 of 2.7749016764
// As explained in the comments, compliance with Gaurav Sharma would display 2.7749152801
```

**Note** : L\* nominally varies between 0 and 100, a\* and b\* typically between -128 and +127.

To compare **hexadecimal** (e.g., "#FFF") or **RGB colors** using the CIEDE2000 function, follow these examples :
- [compare-hex-colors.c](compare-hex-colors.c#L215)
- [compare-rgb-colors.c](compare-rgb-colors.c#L215)

## Verification

<details>
<summary>How is the 32-bit version of the function tested ?</summary>

The 32-bit version of `ciede_2000` inherits the validity of the 64-bit version by construction, thanks to a bit-by-bit transitive validation chain.

Firstly, the 64-bit C implementation of the function has been extensively validated against reliable references such as Netflix’s VMAF library and Gaurav Sharma’s (University of Rochester) authoritative ΔE2000 formulation. This ensures that the 64-bit implementation can be used to verify other implementations, as it is compliant with academic and industry standards, and is certainly suitable for production use.

Next, a fully templated C++ version was created to support multiple floating-point precisions. When instantiated with `double`, this C++ version produces bit-for-bit identical results to the validated 64-bit C version, while with float it corresponds exactly to the 32-bit C version.

Therefore, although the 32-bit and 64-bit versions differ in terms of precision, each aligns perfectly with the corresponding modeled C++ version. This confirms that the 32-bit implementation behaves correctly in reflecting the validated model version instantiated with `float`.

This layered validation is reinforced by automated tests (`tests/cpp/ciede-2000-identity.cpp`), which run 80 million random color pairs in both implementations, compiled with aggressive optimizations (`g++ -std=c++14 -Ofast`), applying zero tolerance for output differences.

> In summary, the 32-bit version is often ideal, working up to 60% faster, with a smaller footprint and negligible deviation of ±0.0002.
</details>

[![C99 CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-c.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-c.yml)

<details>
<summary>What is the testing procedure ?</summary>

The C99 implementation is tested against several external [established sources](../#dynamic-tests-with-established-libraries), and internally against JavaScript, like this :

1. `command -v node > /dev/null || { sudo apt-get update && sudo apt-get install nodejs ; }`
2. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install gcc ; }`
3. `gcc -std=c99 -Wall -pedantic -O2 -g tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
4. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
5. `./ciede-2000-driver -s -i test-cases.csv | node tests/js/ciede-2000-driver.js`

Where the two main files involved are [ciede-2000-driver.c](ciede-2000-driver.c) for calculations, and [test-c.yml](../../.github/workflows/test-c.yml) for automation. Note that the test driver must be compiled with the `-O2` option, not `-Ofast`, otherwise it will omit testing for negative zeros, in return for a negligible overall time saving.
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

**Note** : Deviations of less than **10<sup>-12</sup>** in ΔE<sub>00</sub> are due to low-level details and cannot constitute errors for this 64-bit C99 driver.

<details>
<summary>What is the "canonical" driver option ?</summary>

As indicated in the C driver help (when using `--help`), with the `--canonical` option we test implementations such as Gaurav Sharma’s and OpenJDK’s, without this option (default) we test implementations such as Bruce Lindbloom’s and Netflix’s VMAF. These two implementations differ by up to ±0.0003 on ΔE\*<sub>00</sub> results, so to set up accurate tests, expressly in metrology and 64-bit, this command-line option can be key.
</details>

### Comparison with the VMAF C99 Library

[![ΔE2000 against Netflix VMAF in C99](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-netflix.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-netflix.yml)

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

This confirms an almost perfect alignment with Netflix’s search product, asserting the quality of this ΔE2000 algorithm in C language.

> [!IMPORTANT]
> To correct this C source code to exact match certain third-party ΔE2000 functions, follow the comments in the source code.

> This formula, "small" in size, is an essential pillar of color management, deserving of this rigorous, tested and reliable industrial treatment.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **GCC** : 13.3
- **NodeJS** : 20.19.2

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in C** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=27.3&a1=8.3&b1=-11.4&L2=35.4&a2=26.8&b2=37) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Suitable in 40+ Languages](../../#implementations)
