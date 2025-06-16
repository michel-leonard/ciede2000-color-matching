# ΔE2000 — Accurate. Fast. Haskell-powered.

Delta E 2000 is an international standard for quantifying perceptual color differences, widely used in industries like printing and textiles. 

This **Haskell** implementation provides an accurate and easy-to-use function for calculating CIE ΔE2000 color differences programmatically.

## Overview

The developed algorithm enables your software to measure color similarity and difference with scientific rigor.

For reference, two very distinct colors typically have a ΔE2000 value greater than 12.

Lower values indicate greater closeness, making it a **state-of-the-art method** for comparing colors.

## Implementation Details

The full source code, last updated March 1, 2025, is available [here](../../ciede-2000.hs#L6) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.hs).

## Example usage in Haskell

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```hs
-- Compute the Delta E (CIEDE2000) color difference between two Lab colors in Haskell

let l1 = 19.3166; a1 = 73.5; b1 = 122.428
let l2 = 19.0; a2 = 76.2; b2 = 91.372
let deltaE = ciede_2000 l1 a1 b1 l2 a2 b2
print deltaE

-- Output: 9.60876174564
```

**Note**: L\* is usually between 0 and 100, a\* and b\* between -128 and +127.

For color inputs in **hexadecimal** (e.g., `#FFF`) or **RGB** formats, see examples for other languages :

[AWK](../awk#-flexibility), [C](../c#δe2000--accurate-fast-c-powered), [Dart](../dart#δe2000--accurate-fast-dart-powered), [Java](../java#δe2000--accurate-fast-java-powered), [JavaScript](../js#-flexibility), [Kotlin](../kt#δe2000--accurate-fast-kotlin-powered), [Lua](../lua#-flexibility), [PHP](../php#δe2000--accurate-fast-php-powered), [Python](../py#δe2000--accurate-fast-python-powered), [Ruby](../rb#δe2000--accurate-fast-ruby-powered), [Rust](../rs#δe2000--accurate-fast-rust-powered).

## Verification

[![Haskell CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-hs.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-hs.yml)

<details>
<summary>What is the testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by Haskell**, like this :

1. `command -v ghc > /dev/null || { sudo apt-get update && sudo apt-get install -y ghc cabal-install ; }`
2. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install -y gcc ; }`
3. `cabal update && cabal install --lib split`
4. `ghc -Wall -Werror -package $hs_packages -O2 -threaded -rtsopts -o test-ciede-2000 tests/hs/ciede-2000-driver.hs`
5. `gcc -std=c99 -Wall -pedantic -Ofast tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
6. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
7. `./test-ciede-2000 test-cases.csv +RTS -N | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.hs](ciede-2000-driver.hs#L125) for calculations and [test-hs.yml](../../.github/workflows/test-hs.yml) for automation.
</details>

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
 CIEDE2000 Verification Summary :
  First Verified Line : 12.4,99.83,118.99,89,-20.83,-36,98.92538006135425000
             Duration : 193.11 s
            Successes : 10000000
               Errors : 0
      Average Delta E : 62.9407
    Average Deviation : 6.5393301024174734e-15
    Maximum Deviation : 2.7000623958883807e-13

```

### Speed Benchmark

1,477,110 calls per second on :
- Ubuntu 24.04.2 LTS
- Cabal 3.14.2.0
- GHC 9.12.2
- GCC 13.3.0

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in Haskell** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=7&a1=-52.1&b1=-58.8&L2=30.7&a2=-29&b2=18) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Used in 30+ Languages](../../#implementations)

