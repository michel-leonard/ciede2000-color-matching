# ΔE2000 — Accurate. Fast. Julia-powered.

ΔE2000 is the current standard for quantifying color differences in a way that matches human perception.

This reference **Julia** implementation provides a straightforward and precise way to compute these differences programmatically.

## Overview

The presented algorithm enables your software to measure color similarity and difference with scientific rigor.

For reference, two very distinct colors typically have a ΔE2000 value greater than 12.

Lower values indicate greater closeness, making it a **state-of-the-art method** for comparing colors.

## Implementation Details

The full source code, released on March 1, 2025, is available in two precision variants :
- **Precision**: A 64-bit double precision version intended for rigorous scientific validation. See the source [here](https://github.com/michel-leonard/ciede2000-color-matching/blob/main/ciede-2000.jl#L9) (archived [here](https://web.archive.org/web/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.jl)).
- **Performance**: A generic 32-bit single precision version optimized for most practical applications. Available [in this file](https://github.com/michel-leonard/ciede2000-color-matching/blob/main/ciede-2000-generic.jl#L16).

## Example usage in Julia

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```jl
# Example usage of the ciede_2000 function in Julia

# Color 1 (L1, a1, b1)
l1, a1, b1 = 19.3166, 73.5, 122.428

# Color 2 (L2, a2, b2)
l2, a2, b2 = 19.0, 76.2, 91.372

deltaE = ciede_2000(l1, a1, b1, l2, a2, b2)
println(deltaE)  # Output: 9.60876174564
```

The `ciede_2000` function expects inputs as floating-point values :
- **L\*** typically ranges from 0 to 100,
- **a\*** and **b\*** values generally fall between -128 and +127.

For color inputs in **hexadecimal** (e.g., `#FFF`) or **RGB** formats, see examples for other languages :

[AWK](../awk#-flexibility), [C](../c#δe2000--accurate-fast-c-powered), [Dart](../dart#δe2000--accurate-fast-dart-powered), [Java](../java#δe2000--accurate-fast-java-powered), [JavaScript](../js#-flexibility), [Kotlin](../kt#δe2000--accurate-fast-kotlin-powered), [Lua](../lua#-flexibility), [PHP](../php#δe2000--accurate-fast-php-powered), [Python](../py#δe2000--accurate-fast-python-powered), [Ruby](../rb#δe2000--accurate-fast-ruby-powered), [Rust](../rs#δe2000--accurate-fast-rust-powered).

## Verification

[![Julia CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-jl.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-jl.yml)

<details>
<summary>What is the testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by Julia**, like this :

1. `command -v julia > /dev/null || { sudo apt-get update && sudo apt-get install -y julia ; }`
2. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install -y gcc ; }`
3. `gcc -std=c99 -Wall -pedantic -Ofast tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
4. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
5. `julia tests/jl/ciede-2000-driver.jl test-cases.csv | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.jl](ciede-2000-driver.jl#L128) for calculations and [test-jl.yml](../../.github/workflows/test-jl.yml) for automation.
</details>

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
 CIEDE2000 Verification Summary :
  First Verified Line : 25.11,-80,77,2,26.08,-46,59.590330238040835
             Duration : 76.37 s
            Successes : 10000000
               Errors : 0
      Average Delta E : 62.9504
    Average Deviation : 5.0239383043038796e-15
    Maximum Deviation : 2.4158453015843406e-13
```

### Performance and Environment

The `ciede_2000` function was benchmarked at 4,137,791 calls per second.

Tested environment :

- **Ubuntu** 24.04.2 LTS
- **GCC** 13.3.0
- **Julia** 1.9.4

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in Julia** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=53&a1=-96&b1=-45&L2=12.5&a2=-106&b2=-26.1) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Used in 30+ Languages](../../#implementations)

