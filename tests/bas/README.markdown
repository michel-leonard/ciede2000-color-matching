# ΔE2000 — Accurate. Fast. VBA-powered.

This reference ΔE2000 implementation written in VBA provides reliable and accurate perceptual **color difference** calculation.

## Source Code

The full source code released on March 1, 2025, is available [here](../../ciede-2000.bas#L9) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.bas).

VB6 can seamlessly integrate this classic **.NET** source code.

## Example usage in VBA

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```vba
' Example usage of the CIEDE2000 function in VBA

' L1 = 19.3166        a1 = 73.5           b1 = 122.428
' L2 = 19.0           a2 = 76.2           b2 = 91.372

Dim deltaE As Double
deltaE = ciede_2000(l1, a1, b1, l2, a2, b2)
Debug.Print deltaE

' This shows a ΔE2000 of 9.60876174564
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

[![VBA CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-bas.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-bas.yml)

<details>
<summary>What files are involved in the tests ?</summary>

 1. [ciede-2000-testing.bas](ciede-2000-testing.bas#L131)
 2. [raw-bas.yml](../../.github/workflows/raw-bas.yml)
</details>

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
CIEDE2000 Verification Summary :
- Last Verified Line :  19,-99.59999999999999,-117.5, 39.4, 108, 37, 124.824695300409
- Duration : 143.80 s
- Successes : 10000000
- Errors : 0
- Maximum Difference : 2.8421709430404007e-13
```

### Computational Speed

This function was measured at a speed of 6,595,813 calls per second.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **FreeBASIC Compiler** : 1.10.1
- **GCC** : 13.3.0

## Conclusion

With over 20 years serving developers, this **trusted color comparison** routine developed in VBA brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=19&a1=-99.6&b1=-117.5&L2=39.4&a2=108&b2=37) — [Workflow Details](../../.github/workflows#workflow-details) — [Across 30+ programming languages](../../#implementations)

