# ΔE2000 — Accurate. Fast. Dart-powered.

ΔE2000 is the industry standard for quantifying color differences as perceived by humans.

This canonical **Dart** implementation provides an easy, accurate, and programmatic way to calculate these differences.

## Overview

This algorithm enables your software to measure color similarity and differences with scientific accuracy.

For context, two distinctly different colors usually have a ΔE2000 value above 12, while lower values indicate closer matches.

ΔE2000 is widely recognized as the **state-of-the-art method** for color comparison.

## Implementation Details

The full Dart source code, released on March 1, 2025, is available [here](../../ciede-2000.dart#L8) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.dart).

[JavaScript](../js#δe2000--accurate-fast-javascript-powered), [Java](../java#δe2000--accurate-fast-java-powered) / [Kotlin](../kt#δe2000--accurate-fast-kotlin-powered) (Android), [Swift](../swift#δe2000--accurate-fast-swift-powered) and Objective-C (iOS) can all seamlessly integrate this classic source code.

## Example usage in Dart

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```dart
// Example usage of the ΔE*00 function in Dart

final double l1 = 19.3166, a1 = 73.5, b1 = 122.428;
final double l2 = 19.0, a2 = 76.2, b2 = 91.372;

final double delta_e = ciede_2000(l1, a1, b1, l2, a2, b2);
print(delta_e); // Outputs: 9.60876174564
```

**Note**: L\* is usually between 0 and 100, a\* and b\* between -128 and +127.

To compare **hexadecimal** (e.g., "#FFF") or **RGB colors** using the CIEDE2000 function, follow these examples :
- [compare-hex-colors.dart](compare-hex-colors.dart#L174)
- [compare-rgb-colors.dart](compare-rgb-colors.dart#L174)

## Verification

[![Dart CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-dart.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-dart.yml)

<details>
<summary>What is the testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by Dart**, like this :

1.
```sh
if ! command -v dart > /dev/null; then
  wget --timeout=5 --tries=2 -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub \
  | sudo gpg --dearmor -o /usr/share/keyrings/dart.gpg
  echo "deb [signed-by=/usr/share/keyrings/dart.gpg]" \
  "https://storage.googleapis.com/download.dartlang.org/linux/debian stable main" \
  | sudo tee /etc/apt/sources.list.d/dart_stable.list
  sudo apt-get update
  sudo apt-get install -y dart
  sudo ln -s /usr/lib/dart/bin/dart /usr/local/bin/dart
fi
```
2. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install -y gcc ; }`
3. `gcc -std=c99 -Wall -pedantic -Ofast tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
4. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
5. `dart tests/dart/ciede-2000-driver.dart test-cases.csv | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.dart](ciede-2000-driver.dart#L118) for calculations and [test-dart.yml](../../.github/workflows/test-dart.yml) for automation.
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

## Performance & Environment

- Speed benchmark : ~6.3 million calls per second
- Tested on Ubuntu 24.04.2 LTS, GCC 13.3.0, Dart SDK 3.8.1

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in Dart** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=93&a1=-90&b1=-101&L2=79.6&a2=-104&b2=82.6) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Used in 30+ Languages](../../#implementations)

