# ΔE2000 — Accurate. Fast. Nim-powered.

ΔE2000 is the preferred standard for measuring color differences in a way that aligns closely with human perception.

This canonical **Nim** implementation offers an easy way to calculate these differences accurately and programmatically.

**Commonly** : ΔE\*00 is used in industries where precise color matching is crucial, such as printing, textiles, and digital imaging.

## Overview

The algorithm enables your software to measure color similarity and difference with scientific rigor and perceptual accuracy.

For reference, two very distinct colors typically have a ΔE2000 value greater than 12.

Lower values indicate greater closeness, making it a **state-of-the-art method** for comparing colors.

## Implementation Details

The full source code released on March 1, 2025, is available [here](../../ciede-2000.nim#L10) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.nim).

## Example usage in Nim

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```nim
let l1 = 19.3166
let a1 = 73.5
let b1 = 122.428

let l2 = 19.0
let a2 = 76.2
let b2 = 91.372

let delta_e = ciede_2000(l1, a1, b1, l2, a2, b2)
echo delta_e  # Output: 9.60876174564
```

**Note**: L\* is usually between 0 and 100, a\* and b\* between -128 and +127.

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
 wget -qO- https://nim-lang.org/choosenim/init.sh | sh -s -- -y
 export PATH="$HOME/.nimble/bin:$PATH"
fi
```
2. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install gcc ; }`
3. `mv tests/nim/ciede-2000-driver.nim tests/nim/ciede_2000_driver.nim`
4. `gcc -std=c99 -Wall -pedantic -Ofast -ffast-math -g tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
5. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
6. `nim c --opt:speed -r tests/nim/ciede_2000_driver.nim  test-cases.csv | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.nim](ciede-2000-driver.nim#L87) for calculations and [test-nim.yml](../../.github/workflows/test-nim.yml) for automation.
</details>

The test confirms full compliance with the standard, with no observed errors :
```
 CIEDE2000 Verification Summary :
  First Verified Line : 68.19,79.9,-87.3,81,-113,49.9,62.20868534108853
             Duration : 46.65 s
            Successes : 10000000
               Errors : 0
      Average Delta E : 62.9434
    Average Deviation : 3.4354866007557662e-15
    Maximum Deviation : 1.1368683772161603e-13
```

### Speed Benchmark

This function was measured at a speed of 5,605,584 calls per second.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **GCC** : 13.3.0
- **Nim Compiler** : 2.2.4

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in Nim** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=72&a1=61&b1=69.7&L2=59&a2=-2&b2=57.1) — [32-bit vs 64-bit](https://github.com/michel-leonard/ciede2000-color-matching#numerical-precision-32-bit-vs-64-bit) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Used in 30+ Languages](../../#implementations)

