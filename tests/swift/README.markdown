# ΔE2000 — Accurate. Fast. Swift-powered.

This reference ΔE2000 implementation written in Swift provides reliable and accurate perceptual **color difference** calculation.

## Source Code

The full source code is available [here](../../ciede-2000.swift#L8), and is archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.swift).

Objective-C can seamlessly integrate this classic source code.

## Example usage in Swift

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```swift
// Example usage of the CIEDE2000 function in Swift

// L1 = 19.3166        a1 = 73.5           b1 = 122.428
// L2 = 19.0           a2 = 76.2           b2 = 91.372

let delta_e = ciede_2000(l_1: l1, a_1: a1, b_1: b1, l_2: l2, a_2: a2, b_2: b2)
print(delta_e)

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

[![Swift CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-swift.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-swift.yml)

<details>
<summary>What is the testing procedure ?</summary>

 1. `gcc -O3 tests/c/stdin-verifier.c -o verifier -lm`
 2. `swift tests/swift/ciede-2000-testing.swift 10000000 | ./verifier > test-output.txt`
</details>

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
 CIEDE2000 Verification Summary :
- Last Verified Line : 46.0,-62.8,-10.0,65.0,-116.5,-20.0,20.83717562908332
- Duration : 71.14 s
- Successes : 10000000
- Errors : 0
- Maximum Difference : 1.7053025658242404e-13
```

### Computational Speed

This function was measured at a speed of 2,643,774 calls per second.

### Software Versions

- **MacOS** : 14.7.6
- **Clang** : 15.0.0
- **Swift** : 5.10

## Conclusion

With over 20 years serving developers, this **trusted color comparison** routine developed in Swift brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=46&a1=-62.8&b1=-10&L2=65&a2=-116.5&b2=-20) — [Workflow Details](../../.github/workflows#workflow-details) — [Across 30+ programming languages](../../#implementations)

