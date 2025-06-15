# ΔE2000 — Accurate. Fast. C++-powered.

ΔE2000 is the current standard for quantifying color differences in a way that matches human perception.

This reference **C++** implementation provides a fast, accurate, and easy-to-integrate function for calculating ΔE2000 distances between colors.

## Overview

This implementation enables your software to compare colors with scientific precision.

For reference :
- ΔE2000 > 12 → colors are visually very distinct
- Lower values indicate increasing similarity

It is the **state-of-the-art method** for assessing perceptual color difference.

## Implementation Details

The full source code, released on March 1, 2025, is available [here](../../ciede-2000.cpp#L14) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.cpp) for long-term reference.

This classic **templated** implementation of ΔE2000 supports both **32-bit** single-precision and **64-bit** double-precision computations.

For simpler integration or legacy systems, [C-style](../c#δe2000--accurate-fast-c-powered) versions are also provided.

## Example usage in C++

A typical **Delta E 2000** calculation between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```cpp
// Example usage of the CIEDE2000 function in C++

// L1 = 19.3166        a1 = 73.5           b1 = 122.428
// L2 = 19.0           a2 = 76.2           b2 = 91.372

const auto delta_e_32_bits = ciede_2000<float>(L1, a1, b1, L2, a2, b2);
const auto delta_e_64_bits = ciede_2000<double>(L1, a1, b1, L2, a2, b2);

std::printf("DeltaE 2000 (float):  %.8g\n", delta_e_32_bits);
std::printf("DeltaE 2000 (double): %.8g\n", delta_e_64_bits);

// This shows a ΔE2000 of 9.60876174564
```

**Note**: L\* is usually between 0 and 100, a\* and b\* between -128 and +127.

For color inputs in **hexadecimal** (e.g., `#FFF`) or **RGB** formats, see examples for other languages :

[AWK](../awk#-flexibility), [C](../c#δe2000--accurate-fast-c-powered), [Dart](../dart#δe2000--accurate-fast-dart-powered), [Java](../java#δe2000--accurate-fast-java-powered), [JavaScript](../js#-flexibility), [Kotlin](../kt#δe2000--accurate-fast-kotlin-powered), [Lua](../lua#-flexibility), [PHP](../php#δe2000--accurate-fast-php-powered), [Python](../py#δe2000--accurate-fast-python-powered), [Ruby](../rb#δe2000--accurate-fast-ruby-powered), [Rust](../rs#δe2000--accurate-fast-rust-powered).

## Verification

[![C++ CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-cpp.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-cpp.yml)

<details>
<summary>What is the testing procedure ?</summary>

We generate 10 million color pairs using the [C version](../c/ciede-2000-driver.c), and verify the ΔE2000 values computed by C++ :

1. `command -v g++ > /dev/null || { sudo apt-get update && sudo apt-get install -y g++ ; }`
2. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install -y gcc ; }`
3. `g++ -std=c++14 -Wall -Wextra -Wpedantic -Ofast -o ciede-2000-test tests/cpp/ciede-2000-driver.cpp`
4. `gcc -std=c99 -Wall -pedantic -Ofast tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
5. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
6. `./ciede-2000-test test-cases.csv | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.cpp](ciede-2000-driver.cpp#L131) for calculations and [test-cpp.yml](../../.github/workflows/test-cpp.yml) for automation.
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

## Performance

* Speed: **4,097,101 comparisons/sec**
* Compiler: **G++ 13.3.0**, **GCC 13.3.0**
* OS: **Ubuntu 24.04.2 LTS**

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in C++** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=90&a1=-113.8&b1=-56&L2=49.4&a2=-107&b2=-4) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Used in 30+ Languages](../../#implementations)

