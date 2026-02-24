# ΔE2000 — Accurate. Fast. C++-powered.

ΔE2000 is the current standard for quantifying color differences in a way that best matches human vision.

This reference implementation in **C++** provides a fast, accurate and generic function for calculating the correct distances between colors.

## Overview

This algorithm enables software to compare colors with scientific precision.

For reference :
- ΔE<sub>00</sub> > 12 → colors are visually very distinct.
- Lower values indicate greater similarity.

This is the most advanced method today for assessing color difference.

## Implementation Details

The full source code, released on March 1, 2025, is available [here](../../ciede-2000.cpp#L14) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.cpp) for long-term reference.

This classic **templated** implementation of ΔE<sub>00</sub> supports both **32-bit** single-precision and **64-bit** double-precision computations.

For simpler integration or legacy systems, [C-style](../c#δe2000--accurate-fast-c-powered) versions are also provided.

<details>
<summary>What two options are available for matching ΔE2000 calculations with existing calculations ?</summary>

#### Option 1 (default)
 This often-used option consists of a coding simplification that is a historical legacy of early implementations :
```cpp
h_m += (T(M_PI) < n) * T(M_PI);
// h_m += (T(M_PI) < n) * ((h_m < T(M_PI)) - (T(M_PI) <= h_m)) * T(M_PI);
```

#### Option 2 (compatible with Gaurav Sharma’s precise calculations)
There’s no room for ambiguity, this inversion of the commented line in the source code ensures compliance with the official :
```cpp
// h_m += (T(M_PI) < n) * T(M_PI);
h_m += (T(M_PI) < n) * ((h_m < T(M_PI)) - (T(M_PI) <= h_m)) * T(M_PI);
```

**Note** : the difference between the two options is minimal (±0.0003 on the calculated color difference) and usually overlooked.
</details>

## Example usage in C++

A typical **Delta E 2000** calculation between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```cpp
// Compute the Delta E (CIEDE2000) color difference between two L*a*b* colors in C++
// L1 = 75.5        a1 = 22.5        b1 = -2.5
// L2 = 76.5        a2 = 16.5        b2 = 2.25

const auto delta_e_32_bits = ciede_2000<float>(L1, a1, b1, L2, a2, b2);
const auto delta_e_64_bits = ciede_2000<double>(L1, a1, b1, L2, a2, b2);

std::printf("DeltaE 2000 (float):  %.8g\n", delta_e_32_bits);
std::printf("DeltaE 2000 (double): %.8g\n", delta_e_64_bits);

// .................................................. This shows a ΔE2000 of 4.8786078559
// As explained in the comments, compliance with Gaurav Sharma would display 4.8785929856
```

**Note** : L\* is nominally between 0 and 100, a\* and b\* typically between -128 and +127.

For color inputs in **hexadecimal** (e.g., `#FFF`) or **RGB** formats, see examples for other languages :

[AWK](../awk#-flexibility), [C](../c#δe2000--accurate-fast-c-powered), [Dart](../dart#δe2000--accurate-fast-dart-powered), [Java](../java#δe2000--accurate-fast-java-powered), [JavaScript](../js#-flexibility), [Kotlin](../kt#δe2000--accurate-fast-kotlin-powered), [Lua](../lua#-flexibility), [PHP](../php#δe2000--accurate-fast-php-powered), [Python](../py#δe2000--accurate-fast-python-powered), [Ruby](../rb#δe2000--accurate-fast-ruby-powered), [Rust](../rs#δe2000--accurate-fast-rust-powered).

## Verification

[![C++ CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-cpp.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-cpp.yml)

<details>
<summary>What is the testing procedure ?</summary>

We generate 10 million color pairs using the [C version](../c/ciede-2000-driver.c), and verify the ΔE2000 values computed by C++ :

1. `command -v g++ > /dev/null || { sudo apt-get update && sudo apt-get install g++ ; }`
2. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install gcc ; }`
3. `g++ -std=c++14 -Wall -Wextra -Wpedantic -Ofast -o ciede-2000-test tests/cpp/ciede-2000-driver.cpp`
4. `gcc -std=c99 -Wall -pedantic -O2 -g tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
5. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
6. `./ciede-2000-test test-cases.csv | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.cpp](ciede-2000-driver.cpp#L95) for calculations and [test-cpp.yml](../../.github/workflows/test-cpp.yml) for automation.
</details>

The test confirms full compliance with the standard, with no observed errors :

```
CIEDE2000 Verification Summary :
  First Verified Line : 45,65.26,-37.27,78.78,-80,-108,102.75551666659558236
             Duration : 13.66 s
            Successes : 10000000
               Errors : 0
      Average Delta E : 62.9626
    Average Deviation : 0
    Maximum Deviation : 0
```

### Comparison with dvisvgm

[![ΔE2000 against dvisvgm in C++](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-dvisvgm.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-dvisvgm.yml)

Compared to the well-maintained **dvisvgm** library  — first released in 2007 and still widely used 18 years later — this ΔE\*<sub>00</sub> function, checked on billions of random L\*a\*b\* color pairs, has an absolute deviation of no more than **5 × 10<sup>-13</sup>**. As before in [C99](../c#comparison-with-the-vmaf-c99-library), [JavaScript](../js#comparison-with-the-npmchroma-js-library), [Python](../py#comparison-with-the-python-colormath-library) and  [Rust](../rs#comparison-with-the-palette-library), this confirms the production-ready status of the `ciede_2000` function in C++, as well as its general interoperability.


> [!IMPORTANT]
> To correct this C++ source code to exact match certain third-party ΔE2000 functions, follow the comments in the source code.

> This formula, "small" in size, is an essential pillar of color management, deserving of this rigorous, tested and reliable industrial treatment.

## Performance

* Speed: **4,097,101 comparisons/sec**
* Compiler: **G++ 13.3**, **GCC 13.3**
* OS: **Ubuntu 24.04.2 LTS**

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in C++** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=13.4&a1=35.6&b1=-43.1&L2=32.4&a2=10.1&b2=12.6) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Suitable in 40+ Languages](../../#implementations)
