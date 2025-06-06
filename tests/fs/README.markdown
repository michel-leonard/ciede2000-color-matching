# ΔE2000 — Accurate. Fast. F#-powered.

This reference ΔE2000 implementation written in F# provides reliable and accurate perceptual **color difference** calculation.

## Source Code

The full source code is available [here](../../ciede-2000.fs#L8), and is archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.fs).

C#, VB.NET and PowerShell can all seamlessly integrate this classic source code.

## Example usage in F#

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```fs
// Example usage of the CIEDE2000 function in F#

// L1 = 19.3166        a1 = 73.5           b1 = 122.428
// L2 = 19.0           a2 = 76.2           b2 = 91.372

let deltaE = ciede_2000 l1 a1 b1 l2 a2 b2
printfn "%f" deltaE

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

[![F# CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-fs.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-fs.yml)

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
CIEDE2000 Verification Summary :
- Last Verified Line : 4.00,104.59,-12.00,78.74,5.87,11.00,75.430859126624028
- Duration : 154.29 s
- Successes : 10000000
- Errors : 0
- Maximum Difference : 8.5265128291212022e-14
```

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **Dotnet** : 8.0.410
- **GCC** : 13.3.0

## Conclusion

With over 20 years serving developers, this **trusted color comparison** routine developed in F# brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=4&a1=104.59&b1=-12&L2=78.74&a2=5.87&b2=11) — [Workflow Details](../../.github/workflows#workflow-details) — [Across 30+ programming languages](../../#implementations)

