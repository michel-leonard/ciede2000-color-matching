# ΔE2000 — Accurate. Fast. Nim-powered.

This reference ΔE2000 implementation written in Nim provides reliable and accurate perceptual **color difference** calculation.

## Source Code

The full source code released on March 1, 2025, is available [here](../../ciede-2000.nim#L10) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.nim).

## Example usage in Nim

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```nim
# Example usage of the CIEDE2000 function in Nim

# L1 = 19.3166        a1 = 73.5           b1 = 122.428
# L2 = 19.0           a2 = 76.2           b2 = 91.372

let delta_e = ciede_2000(l1, a1, b1, l2, a2, b2)
echo delta_e

# This shows a ΔE2000 of 9.60876174564
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

[![Nim CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-nim.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-nim.yml)

<details>
<summary>What is the testing procedure ?</summary>

 1. `mv tests/nim/ciede-2000-testing.nim tests/nim/ciede_2000_testing.nim`
 2. `gcc -O3 tests/c/stdin-verifier.c -o verifier -lm`
 3. `nim c --opt:speed -r tests/nim/ciede_2000_testing.nim 10000000 | ./verifier > test-output.txt`

Where the two main files involved are [ciede-2000-testing.nim](ciede-2000-testing.nim#L119) and [raw-nim.yml](../../.github/workflows/raw-nim.yml).
</details>

The test confirms full compliance with the standard, with no observed errors :

```
CIEDE2000 Verification Summary :
- Last Verified Line : 72.0,61.0,69.7,59.0,-2.0,57.1,34.96186783663614
- Duration : 56.45 s
- Successes : 10000000
- Errors : 0
- Maximum Difference : 0.0000000000000000e+00
```

### Computational Speed

This function was measured at a speed of 5,605,584 calls per second.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **GCC** : 13.3.0
- **Nim Compiler** : 2.2.4

## Conclusion

With over 20 years serving developers, this **trusted color comparison** routine developed in Nim brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=72&a1=61&b1=69.7&L2=59&a2=-2&b2=57.1) — [32-bit vs 64-bit](https://github.com/michel-leonard/ciede2000-color-matching#numerical-precision-32-bit-vs-64-bit) — [Workflow Details](../../.github/workflows#workflow-details) — [Across 30+ programming languages](../../#implementations)

