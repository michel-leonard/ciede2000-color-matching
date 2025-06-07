# ΔE2000 — Accurate. Fast. Haxe-powered.

This reference ΔE2000 implementation written in Haxe provides reliable and accurate perceptual **color difference** calculation.

## Source Code

The full source code released on March 1, 2025, is available [here](../../ciede-2000.hx#L9) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.hx).

JavaScript, Python, Java can all seamlessly integrate this classic source code.

## Example usage in Haxe

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```hx
// Example usage of the CIEDE2000 function in Haxe

// L1 = 19.3166        a1 = 73.5           b1 = 122.428
// L2 = 19.0           a2 = 76.2           b2 = 91.372

var deltaE: Float = ciede_2000(l1, a1, b1, l2, a2, b2);
trace(deltaE);

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

[![Haxe CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-hx.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-hx.yml)

<details>
<summary>What is the testing procedure ?</summary>

 1. `cp -p tests/hx/ciede-2000-testing.hx tests/hx/Main.hx`
 2. `gcc -O3 tests/c/stdin-verifier.c -o verifier -lm`
 3. `haxe -cp tests/hx --run Main 10000000 | ./verifier > test-output.txt`

Where the two main files involved are [ciede-2000-testing.hx](ciede-2000-testing.hx#L126) and [raw-hx.yml](../../.github/workflows/raw-hx.yml).
</details>

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
CIEDE2000 Verification Summary :
- Last Verified Line : 81,-107,-35,66,51,89.2,67.1522966823427794
- Duration : 104.04 s
- Successes : 10000000
- Errors : 0
- Maximum Difference : 1.1368683772161603e-13
```

### Computational Speed

This function was measured at a speed of 5,294,042 calls per second.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **GCC** : 13.3.0
- **Haxe** : 4.3.3

## Conclusion

With over 20 years serving developers, this **trusted color comparison** routine developed in Haxe brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=81&a1=-107&b1=-35&L2=66&a2=51&b2=89.2) — [Workflow Details](../../.github/workflows#workflow-details) — [Across 30+ programming languages](../../#implementations)

