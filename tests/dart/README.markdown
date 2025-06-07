# ΔE2000 — Accurate. Fast. Dart-powered.

This reference ΔE2000 implementation written in Dart provides reliable and accurate perceptual **color difference** calculation.

## Source Code

The full source code released on March 1, 2025, is available [here](../../ciede-2000.dart#L8) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.dart).

JavaScript, Java / Kotlin (Android), Swift / Objective-C (iOS) can all seamlessly integrate this classic source code.

## Example usage in Dart

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```dart
// Example usage of the CIEDE2000 function in Dart

// L1 = 19.3166        a1 = 73.5           b1 = 122.428
// L2 = 19.0           a2 = 76.2           b2 = 91.372

final double delta_e = ciede_2000(l1, a1, b1, l2, a2, b2);
print(delta_e)

// This shows a ΔE2000 of 9.60876174564
```

**Note**: L\* is usually between 0 and 100, a\* and b\* between -128 and +127.

To compare **hexadecimal** (e.g., "#FFF") or **RGB colors** using the CIEDE2000 function, follow these examples :
- [compare-hex-colors.dart](compare-hex-colors.dart#L174)
- [compare-rgb-colors.dart](compare-rgb-colors.dart#L174)

## Verification

[![Dart CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-dart.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-dart.yml)

<details>
<summary>What is the testing procedure ?</summary>

 1. `gcc -O3 tests/c/stdin-verifier.c -o verifier -lm`
 2. `dart tests/dart/ciede-2000-testing.dart 10000000 | ./verifier > test-output.txt`

Where the two main files involved are [ciede-2000-testing.dart](ciede-2000-testing.dart#L122) and [raw-dart.yml](../../.github/workflows/raw-dart.yml).
</details>

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
CIEDE2000 Verification Summary :
- Last Verified Line : 93.0,-90.0,-101.0,79.6,-104.0,82.6,64.04915875144532
- Duration : 45.77 s
- Successes : 10000000
- Errors : 0
- Maximum Difference : 8.5265128291212022e-14
```

### Computational Speed

This function was measured at a speed of 6,278,356 calls per second.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **GCC** : 13.3.0
- **Dart SDK** : 3.8.1

## Conclusion

With over 20 years serving developers, this **trusted color comparison** routine developed in Dart brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=93&a1=-90&b1=-101&L2=79.6&a2=-104&b2=82.6) — [Workflow Details](../../.github/workflows#workflow-details) — [Across 30+ programming languages](../../#implementations)

