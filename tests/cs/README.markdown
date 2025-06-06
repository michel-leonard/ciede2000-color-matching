# ΔE2000 — Accurate. Fast. C#-powered.

This reference ΔE2000 implementation written in C# provides reliable and accurate perceptual **color difference** calculation.

## Source Code

The full source code is available [here](../../ciede-2000.cs#L6), and is archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.cs).

VB.NET and F# can both seamlessly integrate this classic source code.

## Example usage in C#

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```csharp
// Example usage of the CIEDE2000 function in C# (.NET Core)

// L1 = 19.3166        a1 = 73.5           b1 = 122.428
// L2 = 19.0           a2 = 76.2           b2 = 91.372

double deltaE = ciede_2000(l1, a1, b1, l2, a2, b2);
Console.WriteLine(deltaE);

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

[![C# CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-cs.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-cs.yml)

<details>
<summary>What is the testing procedure ?</summary>

 1. `dotnet tool install -g dotnet-script`
 2. `gcc -O3 tests/c/stdin-verifier.c -o verifier -lm`
 3. `dotnet script tests/cs/ciede-2000-testing.cs -- 10000000 | ./verifier > test-output.txt`
</details>

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
CIEDE2000 Verification Summary :
- Last Verified Line : 81,80,-29,31,47.3,124.1,77.29380412017679
- Duration : 29.57 s
- Successes : 10000000
- Errors : 0
- Maximum Difference : 8.5265128291212022e-14
```

### Computational Speed

This function was measured at a speed of 3,168,561 calls per second.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **Dotnet** : 8.0.410
- **GCC** : 13.3.0

## Conclusion

With over 20 years serving developers, this **trusted color comparison** routine developed in C# brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=81&a1=80&b1=-29&L2=31&a2=47.3&b2=124.1) — [Workflow Details](../../.github/workflows#workflow-details) — [Across 30+ programming languages](../../#implementations)

