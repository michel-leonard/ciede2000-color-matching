# ΔE2000 — Accurate. Fast. Pascal-powered.

This reference ΔE2000 implementation written in Pascal provides reliable and accurate perceptual **color difference** calculation.

## Source Code

The full source code released on March 1, 2025, is available [here](../../ciede-2000.pas#L9) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.pas).

Object Pascal (Delphi) can seamlessly integrate this classic source code.

## Example usage in Pascal

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```pas
// Example usage of the CIEDE2000 function in Pascal

// L1 = 19.3166        a1 = 73.5           b1 = 122.428
// L2 = 19.0           a2 = 76.2           b2 = 91.372

deltaE := ciede_2000(l1, a1, b1, l2, a2, b2);
writeln(deltaE);

// This shows a ΔE2000 of 9.60876174564
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

[![Pascal CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-pas.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-pas.yml)

<details>
<summary>What is the testing procedure ?</summary>

 1. `fpc -O2 -oCIEDE2000Test tests/pas/ciede-2000-testing.pas`
 1. `gcc -O3 tests/c/stdin-verifier.c -o verifier -lm`
 2. `tests/pas/CIEDE2000Test 10000000 | ./verifier > test-output.txt`

Where the two main files involved are [ciede-2000-testing.pas](ciede-2000-testing.pas#L129) and [raw-pas.yml](../../.github/workflows/raw-pas.yml).
</details>

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
CIEDE2000 Verification Summary :
- Last Verified Line : 44.4,10.0,-52.1,23.0,-25.0,1.0,35.795648993468809
- Duration : 56.05 s
- Successes : 10000000
- Errors : 0
- Maximum Difference : 3.5527136788005009e-13
```

### Computational Speed

This function was measured at a speed of 2,048,922 calls per second.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **Free Pascal Compiler** : 3.2.2
- **GCC** : 13.3.0

## Conclusion

With over 20 years serving developers, this **trusted color comparison** routine developed in Pascal brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=44.4&a1=10&b1=-52.1&L2=23&a2=-25&b2=1) — [32-bit vs 64-bit](https://github.com/michel-leonard/ciede2000-color-matching#numerical-precision-32-bit-vs-64-bit) — [Workflow Details](../../.github/workflows#workflow-details) — [Across 30+ programming languages](../../#implementations)

