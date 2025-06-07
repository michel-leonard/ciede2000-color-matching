# ΔE2000 — Accurate. Fast. Haskell-powered.

This reference ΔE2000 implementation written in Haskell provides reliable and accurate perceptual **color difference** calculation.

## Source Code

The full source code released on March 1, 2025, is available [here](../../ciede-2000.hs#L6) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.hs).

## Example usage in Haskell

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```hs
-- Example usage of the CIEDE2000 function in Haskell

-- L1 = 19.3166        a1 = 73.5           b1 = 122.428
-- L2 = 19.0           a2 = 76.2           b2 = 91.372

let deltaE = ciede_2000 l1 a1 b1 l2 a2 b2
print deltaE

-- This shows a ΔE2000 of 9.60876174564
```

**Note**: L\* is usually between 0 and 100, a\* and b\* between -128 and +127.

To compare **hexadecimal** (e.g., "#FFF") or **RGB colors** using the CIEDE2000 function, examples are available in several languages :
- [AWK](../awk#-flexibility)
- [C](../c#δe2000--accurate-fast-c-powered)
- [Dart](../dart#δe2000--accurate-fast-dart-powered)
- [JavaScript](../js#-flexibility)
- [Java](../java#δe2000--accurate-fast-java-powered)
- [Kotlin](../kt#δe2000--accurate-fast-kotlin-powered)
- [Lua](../lua#-flexibility)
- [PHP](../php#δe2000--accurate-fast-php-powered)
- [Python](../py#δe2000--accurate-fast-python-powered)
- [Ruby](../rb#δe2000--accurate-fast-ruby-powered)
- [Rust](../rs#δe2000--accurate-fast-rust-powered)

## Verification

[![Haskell CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-hs.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-hs.yml)

<details>
<summary>What is the testing procedure ?</summary>

 1. `cabal update && cabal install --lib random`
 2. `ghc -Wall -Werror -package random -O2 -threaded -rtsopts -o test-ciede-2000 tests/hs/ciede-2000-testing.hs`
 3. `gcc -O3 tests/c/stdin-verifier.c -o verifier -lm`
 4. `./test-ciede-2000 10000000 +RTS -N | ./verifier > test-output.txt`

Where the two main files involved are [ciede-2000-testing.hs](ciede-2000-testing.hs#L120) and [raw-hs.yml](../../.github/workflows/raw-hs.yml).
</details>

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
CIEDE2000 Verification Summary :
- Last Verified Line : 7.0,-52.1,-58.8,30.7,-29.0,18.0,42.480229445564540
- Duration : 116.79 s
- Successes : 10000000
- Errors : 0
- Maximum Difference : 2.5579538487363607e-13
```

### Computational Speed

This function was measured at a speed of 1,477,110 calls per second.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **Cabal** : 3.14.2.0
- **GHC** : 9.12.2
- **GCC** : 13.3.0

## Conclusion

With over 20 years serving developers, this **trusted color comparison** routine developed in Haskell brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=7&a1=-52.1&b1=-58.8&L2=30.7&a2=-29&b2=18) — [Workflow Details](../../.github/workflows#workflow-details) — [Across 30+ programming languages](../../#implementations)

