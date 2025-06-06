# ΔE2000 — Accurate. Fast. Racket-powered.

This reference ΔE2000 implementation written in Racket provides reliable and accurate perceptual **color difference** calculation.

## Source Code

The full source code is available [here](../../ciede-2000.rkt#L8), and is archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.rkt).

## Example usage in Racket

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```racket
; Example usage of the CIEDE2000 function in Racket

; L1 = 19.3166        a1 = 73.5           b1 = 122.428
; L2 = 19.0           a2 = 76.2           b2 = 91.372

(define delta-e (ciede_2000 l1 a1 b1 l2 a2 b2))
(displayln delta-e)

; This shows a ΔE2000 of 9.60876174564
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

[![Racket CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-rkt.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-rkt.yml)

<details>
<summary>What is the testing procedure ?</summary>

 1. `gcc -O3 tests/c/stdin-verifier.c -o verifier -lm`
 2. `racket tests/rkt/ciede-2000-testing.rkt 10000000 | ./verifier > test-output.txt`
</details>


The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
CIEDE2000 Verification Summary :
- Last Verified Line : 67.2,111.7,-81.0,97.4,108.6,5.0,30.387652005578015
- Duration : 82.23 s
- Successes : 10000000
- Errors : 0
- Maximum Difference : 2.5579538487363607e-13
```

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **GCC** : 13.3.0
- **Racket** : 8.10

## Conclusion

With over 20 years serving developers, this **trusted color comparison** routine developed in Racket brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=67.2&a1=111.7&b1=-81&L2=97.4&a2=108.6&b2=5) — [Workflow Details](../../.github/workflows#workflow-details) — [Across 30+ programming languages](../../#implementations)

