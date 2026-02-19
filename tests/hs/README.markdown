# ΔE2000 — Accurate. Fast. Haskell-powered.

Delta E 2000 is a worldwide standard for quantifying color differences, widely used in sectors such as printing and textiles.

This **Haskell** implementation provides a precise, easy-to-use function for calculating these CIE ΔE<sub>00</sub> color differences programmatically.

## Overview

The developed algorithm enables software to evaluate color similarities (or differences) with scientific rigor.

As a general rule, 🔵 navy blue and 🟡 yellow, which are very different colors, have a ΔE\*<sub>00</sub> of around 115.

Values [such as 5](https://michel-leonard.github.io/ciede2000-color-matching/de2000-rgb-pairs.html?seq=50&delta-e=5) indicate greater closeness, making this both a simple and advanced method of color comparison.

## Implementation Details

The full source code, last updated March 1, 2025, is available [here](../../ciede-2000.hs#L6) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.hs).

<details>
<summary>What two options are available for matching ΔE2000 calculations with existing calculations ?</summary>

#### Option 1 (default)
 This often-used option consists of a coding simplification that is a historical legacy of early implementations :
```hs
in if pi < n_0 then x + pi else x
-- in if pi < n_0 then if x < pi then x + pi else x - pi else x
```

#### Option 2 (compatible with Gaurav Sharma’s precise calculations)
There’s no room for ambiguity, this inversion of the commented line in the source code ensures compliance with the official :
```hs
-- in if pi < n_0 then x + pi else x
in if pi < n_0 then if x < pi then x + pi else x - pi else x
```

**Note** : the difference between the two options is minimal (±0.0003 on the calculated color difference) and usually overlooked.
</details>

## Example usage in Haskell

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```hs
-- Compute the Delta E (CIEDE2000) color difference between two L*a*b* colors in Haskell

let (l1, a1, b1) = (46.9, 56.7, -2.5)
let (l2, a2, b2) = (46.6, 50.7, 2.3)

let deltaE = ciede_2000 l1 a1 b1 l2 a2 b2
print deltaE

-- .................................................. This shows a ΔE2000 of 2.9263291321
-- As explained in the comments, compliance with Gaurav Sharma would display 2.9263153756
```

**Note** : L\* is nominally between 0 and 100, a\* and b\* generally between -128 and +127.

For color inputs in **hexadecimal** (e.g., `#FFF`) or **RGB** formats, see examples for other languages :

[AWK](../awk#-flexibility), [C](../c#δe2000--accurate-fast-c-powered), [Dart](../dart#δe2000--accurate-fast-dart-powered), [Java](../java#δe2000--accurate-fast-java-powered), [JavaScript](../js#-flexibility), [Kotlin](../kt#δe2000--accurate-fast-kotlin-powered), [Lua](../lua#-flexibility), [PHP](../php#δe2000--accurate-fast-php-powered), [Python](../py#δe2000--accurate-fast-python-powered), [Ruby](../rb#δe2000--accurate-fast-ruby-powered), [Rust](../rs#δe2000--accurate-fast-rust-powered).

## Verification

[![Haskell CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-hs.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-hs.yml)

<details>
<summary>What is the testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by Haskell**, like this :

1. `command -v ghc > /dev/null || { sudo apt-get update && sudo apt-get install ghc cabal-install ; }`
2. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install gcc ; }`
3. `cabal update && cabal install --lib split`
4. `ghc -Wall -Werror -package split -O2 -threaded -rtsopts -o test-ciede-2000 tests/hs/ciede-2000-driver.hs`
5. `gcc -std=c99 -Wall -pedantic -O2 -g tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
6. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
7. `./test-ciede-2000 test-cases.csv +RTS -N | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.hs](ciede-2000-driver.hs#L96) for calculations and [test-hs.yml](../../.github/workflows/test-hs.yml) for automation.
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

> [!IMPORTANT]
> To correct this Haskell source code to exact match certain third-party ΔE2000 functions, follow the comments in the source code.

> This formula, "small" in size, is an essential pillar of color management, deserving of this rigorous, tested and reliable industrial treatment.

### Speed Benchmark

1,477,110 calls per second on :
- Ubuntu 24.04.2 LTS
- Cabal 3.14.2.0
- GHC 9.12.2
- GCC 13.3

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in Haskell** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=67.1&a1=60&b1=-38.2&L2=78.2&a2=15.4&b2=10.4) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Suitable in 40+ Languages](../../#implementations)
