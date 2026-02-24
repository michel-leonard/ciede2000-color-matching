# ΔE2000 — Accurate. Fast. Nim-powered.

ΔE2000 is today’s preferred standard for measuring color differences in a way that best aligns with human vision.

This reference implementation in **Nim** offers an easy way to calculate these differences accurately and programmatically.

**Commonly** : ΔE<sub>00</sub> is used in industries where accurate color matching is crucial, such as printing, textiles and digital imaging.

## Overview

The developed algorithm enables software to evaluate color similarities (or differences) with scientific rigor.

As a general rule, 🔵 navy blue and 🟡 yellow, which are very different colors, have a ΔE\*<sub>00</sub> of around 115.

Values [such as 5](https://michel-leonard.github.io/ciede2000-color-matching/de2000-rgb-pairs.html?seq=50&delta-e=5) indicate greater closeness, making this both a simple and advanced method of color comparison.

## Implementation Details

The full source code, released on March 1, 2025, is available in two precision variants :

- **Precision**: A 64-bit double precision version intended for rigorous scientific validation. See the source [here](../../ciede-2000.nim#L10) (archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.nim)).
- **Performance**: A generic 32-bit single precision version optimized for most practical applications. Available [in this file](ciede-2000-generic.nim#L20).

**Benchmark** : Using the 32-bit function results in [negligible ΔE<sub>00</sub> deviations](../../#use-the-ciede_2000-function-in-32-bit-rather-than-64-bit) for an increase in execution speed of up to 60%.

<details>
<summary>What two options are available for matching ΔE2000 calculations with existing calculations ?</summary>

#### Option 1 (default)
 This often-used option consists of a coding simplification that is a historical legacy of early implementations :
```nim
h_m += M_PI;
# h_m += (if h_m < M_PI : M_PI else : -M_PI);
```

#### Option 2 (compatible with Gaurav Sharma’s precise calculations)
There’s no room for ambiguity, this inversion of the commented line in the source code ensures compliance with the official :
```nim
# h_m += M_PI;
h_m += (if h_m < M_PI : M_PI else : -M_PI);
```

**Note** : the difference between the two options is minimal (±0.0003 on the calculated color difference) and usually overlooked.
</details>

## Example usage in Nim

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```nim
# Compute the Delta E (CIEDE2000) color difference between two L*a*b* colors in Nim

let (l1, a1, b1) = (96.8, 44.9, -2.0)
let (l2, a2, b2) = (96.6, 50.4, 2.7)

let delta_e = ciede_2000(l1, a1, b1, l2, a2, b2)
echo delta_e

# .................................................. This shows a ΔE2000 of 2.9776421152
# As explained in the comments, compliance with Gaurav Sharma would display 2.9776552456
```

**Note** : L\* is nominally between 0 and 100, a\* and b\* generally between -128 and +127.

For color inputs in **hexadecimal** (e.g., `#FFF`) or **RGB** formats, see examples for other languages :

[AWK](../awk#-flexibility), [C](../c#δe2000--accurate-fast-c-powered), [Dart](../dart#δe2000--accurate-fast-dart-powered), [Java](../java#δe2000--accurate-fast-java-powered), [JavaScript](../js#-flexibility), [Kotlin](../kt#δe2000--accurate-fast-kotlin-powered), [Lua](../lua#-flexibility), [PHP](../php#δe2000--accurate-fast-php-powered), [Python](../py#δe2000--accurate-fast-python-powered), [Ruby](../rb#δe2000--accurate-fast-ruby-powered), [Rust](../rs#δe2000--accurate-fast-rust-powered).

## Verification

[![Nim CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-nim.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-nim.yml)

<details>
<summary>What is the testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by Nim**, like this :

1.
```sh
if ! command -v nim > /dev/null; then
 wget --quiet --no-check-certificate --timeout=5 --tries=3 https://nim-lang.org/choosenim/init.sh -O- | sh -s
 export PATH="$HOME/.nimble/bin:$PATH"
fi
```
2. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install gcc ; }`
3. `mv tests/nim/ciede-2000-driver.nim tests/nim/ciede_2000_driver.nim`
4. `gcc -std=c99 -Wall -pedantic -O2 -g tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
5. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
6. `nim c --opt:speed -r tests/nim/ciede_2000_driver.nim  test-cases.csv | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.nim](ciede-2000-driver.nim#L94) for calculations and [test-nim.yml](../../.github/workflows/test-nim.yml) for automation.
</details>

The test confirms full compliance with the standard, with no observed errors :
```
CIEDE2000 Verification Summary :
  First Verified Line : 27,-123,101,44,-30,122,29.989372817453113
             Duration : 44.51 s
            Successes : 10000000
               Errors : 0
      Average Delta E : 63.2072
    Average Deviation : 4.3e-15
    Maximum Deviation : 1.1e-13
```

> [!IMPORTANT]
> To correct this Nim source code to exact match certain third-party ΔE2000 functions, follow the comments in the source code.

> This formula, "small" in size, is an essential pillar of color management, deserving of this rigorous, tested and reliable industrial treatment.

### Speed Benchmark

This function was measured at a speed of 5,605,584 calls per second.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **GCC** : 13.3
- **Nim Compiler** : 2.2.4

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in Nim** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=51&a1=3.6&b1=6.2&L2=35.1&a2=26.8&b2=-46.1) — [32-bit vs 64-bit](https://github.com/michel-leonard/ciede2000-color-matching#numerical-precision-32-bit-vs-64-bit) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Suitable in 40+ Languages](../../#implementations)
