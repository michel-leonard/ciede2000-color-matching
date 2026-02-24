# ΔE2000 — Accurate. Fast. Dart-powered.

ΔE2000 is the industry standard for quantifying color differences in accordance with how humans see them.

This reference implementation in **Dart** provides a simple, accurate and programmatic way of calculating these differences.

## Overview

The developed algorithm enables software to evaluate color similarities (or differences) with scientific rigor.

As a general rule, 🔵 navy blue and 🟡 yellow, which are very different colors, have a ΔE\*<sub>00</sub> of around 115.

Values [such as 5](https://michel-leonard.github.io/ciede2000-color-matching/de2000-rgb-pairs.html?seq=50&delta-e=5) indicate greater closeness, making this both a simple and advanced method of color comparison.

## Implementation Details

The full Dart source code, released on March 1, 2025, is available [here](../../ciede-2000.dart#L8) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.dart).

[JavaScript](../js#δe2000--accurate-fast-javascript-powered), [Java](../java#δe2000--accurate-fast-java-powered) / [Kotlin](../kt#δe2000--accurate-fast-kotlin-powered) (Android), [Swift](../swift#δe2000--accurate-fast-swift-powered) and Objective-C (iOS) can all seamlessly integrate this classic source code.

<details>
<summary>What two options are available for matching ΔE2000 calculations with existing calculations ?</summary>

#### Option 1 (default)
 This often-used option consists of a coding simplification that is a historical legacy of early implementations :
```dart
h_m += pi;
// if (h_m < pi) h_m += pi; else h_m -= pi;
```

#### Option 2 (compatible with Gaurav Sharma’s precise calculations)
There’s no room for ambiguity, this inversion of the commented line in the source code ensures compliance with the official :
```dart
// h_m += pi;
if (h_m < pi) h_m += pi; else h_m -= pi;
```

**Note** : the difference between the two options is minimal (±0.0003 on the calculated color difference) and usually overlooked.
</details>

## Example usage in Dart

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```dart
// Compute the Delta E (CIEDE2000) color difference between two L*a*b* colors in Dart

final double l1 = 63.6, a1 = 47.3, b1 = 3.5;
final double l2 = 62.4, a2 = 41.1, b2 = -2.0;

final double delta_e = ciede_2000(l1, a1, b1, l2, a2, b2);
print(delta_e);

// .................................................. This shows a ΔE2000 of 3.7114473219
// As explained in the comments, compliance with Gaurav Sharma would display 3.7114606185
```

**Note** : L\* is nominally between 0 and 100, a\* and b\* generally between -128 and +127.

To compare **hexadecimal** (e.g., "#FFF") or **RGB colors** using the CIEDE2000 function, follow these examples :
- [compare-hex-colors.dart](compare-hex-colors.dart#L186)
- [compare-rgb-colors.dart](compare-rgb-colors.dart#L186)

## Verification

[![Dart CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-dart.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-dart.yml)

<details>
<summary>What is the testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by Dart**, like this :

1.
```sh
if ! command -v dart > /dev/null; then
  wget --quiet --no-check-certificate --timeout=5 --tries=2 https://dl-ssl.google.com/linux/linux_signing_key.pub -O- |
  sudo gpg --dearmor -o /usr/share/keyrings/dart.gpg
  echo "deb [signed-by=/usr/share/keyrings/dart.gpg]" \
  "https://storage.googleapis.com/download.dartlang.org/linux/debian stable main" \
  | sudo tee /etc/apt/sources.list.d/dart_stable.list
  sudo apt-get update
  sudo apt-get install dart
  sudo ln -s /usr/lib/dart/bin/dart /usr/local/bin/dart
fi
```
2. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install gcc ; }`
3. `gcc -std=c99 -Wall -pedantic -O2 -g tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
4. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
5. `dart tests/dart/ciede-2000-driver.dart test-cases.csv | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.dart](ciede-2000-driver.dart#L87) for calculations and [test-dart.yml](../../.github/workflows/test-dart.yml) for automation.
</details>

This function has been rigorously tested for compliance with the standard, achieving zero errors and negligible floating-point deviations :

```
CIEDE2000 Verification Summary :
  First Verified Line : 50,53.33,83.5,4,64,119,35.088382900096214
             Duration : 22.05 s
            Successes : 10000000
               Errors : 0
      Average Delta E : 62.9435
    Average Deviation : 4.2583500392545661e-15
    Maximum Deviation : 8.5265128291212022e-14
```

### Comparison with the delta_e Package

[![ΔE2000 against delta_e in Dart](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-ragepeanut.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-ragepeanut.yml)

Compared to the official **delta_e** Dart package — first published in 2019  — this implementation of the ΔE2000 color difference formula, validated on billions of random L\*a\*b\* color pairs, has an absolute deviation of no more than **5 × 10<sup>-13</sup>**. This test confirms the general interoperability of the `ciede_2000` function in Dart, as well as its **production-ready** status.

> [!IMPORTANT]
> To correct this Dart source code to exact match certain third-party ΔE2000 functions, follow the comments in the source code.

> This formula, "small" in size, is an essential pillar of color management, deserving of this rigorous, tested and reliable industrial treatment.

## Performance & Environment

- Speed benchmark : ~6.3 million calls per second
- Tested on Ubuntu 24.04.2 LTS, GCC 13.3, Dart SDK 3.8.1

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in Dart** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=52.1&a1=13&b1=8.1&L2=49.1&a2=50.6&b2=-31) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Suitable in 40+ Languages](../../#implementations)

