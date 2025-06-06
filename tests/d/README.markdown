# ΔE2000 — Accurate. Fast. D-powered.

This reference ΔE2000 implementation written in D provides reliable and accurate perceptual **color difference** calculation.

## Source Code

The full source code is available [here](../../ciede-2000.d#L8), and is archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.d).

## Example usage in D

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```d
// Example usage of the CIEDE2000 function in D

// L1 = 19.3166        a1 = 73.5           b1 = 122.428
// L2 = 19.0           a2 = 76.2           b2 = 91.372

double deltaE = ciede_2000(l1, a1, b1, l2, a2, b2);
writeln(format("%.12f", deltaE));

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

[![D CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-d.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-d.yml)

<details>
<summary>What is the testing procedure ?</summary>

 1. `cp -p tests/d/ciede-2000-testing.d main.d`
 2. `ldc2 -version && ldc2 -O -release -boundscheck=off -of=ciede2000-test main.d`
 3. `gcc -O3 tests/c/stdin-verifier.c -o verifier -lm`
 4. `./ciede2000-test 10000000 | ./verifier > test-output.txt`
</details>


The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
CIEDE2000 Verification Summary :
- Last Verified Line : 12.0,124.1,40.0,47.8,-5.6,108.1,73.534567506685860
- Duration : 23.10 s
- Successes : 10000000
- Errors : 0
- Maximum Difference : 3.5527136788005009e-13
```

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **LLVM D compiler** : 1.40.1
- **GCC** : 13.3.0

## Conclusion

With over 20 years serving developers, this **trusted color comparison** routine developed in D brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=12&a1=124.1&b1=40&L2=47.8&a2=-5.6&b2=108.1) — [Workflow Details](../../.github/workflows#workflow-details) — [Across 30+ programming languages](../../#implementations)

