# ΔE2000 — Accurate. Fast. Zig-powered.

ΔE2000 is the current industry standard for quantifying color differences in a way that best matches human vision.

This reference implementation in **Zig** offers a simple and reliable method for efficiently calculating color differences within software.

## Overview

The developed algorithm enables software to evaluate color similarities (or differences) with scientific rigor.

As a general rule, 🔵 navy blue and 🟡 yellow, which are very different colors, have a ΔE\*<sub>00</sub> of around 115.

Values [such as 5](https://michel-leonard.github.io/ciede2000-color-matching/de2000-rgb-pairs.html?seq=50&delta-e=5) indicate greater closeness, making this both a simple and advanced method of color comparison.

## Implementation Details

The full source code released on March 1, 2025, is available [here](../../ciede-2000.zig#L9) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.zig).

This classic source code can be seamlessly integrated in both [C](../c#δe2000--accurate-fast-c-powered) and [C++](../cpp#δe2000--accurate-fast-c-powered) projects.

## Example usage in Zig

Calculate the **Delta E 2000** between two colors in the **L\*a\*b\*** color space using the `ciede_2000` function :

```zig
// Compute the Delta E (CIEDE2000) color difference between two Lab colors in Zig

// Color 1: l1 = 52.9   a1 = 33.7   b1 = -2.0
// Color 2: l2 = 53.5   a2 = 28.5   b2 = 1.9

const delta_e = ciede_2000(l1, a1, b1, l2, a2, b2);
std.debug.print("{}\n", .{delta_e});

// .................................................. This shows a ΔE2000 of 3.2925558212
// As explained in the comments, compliance with Gaurav Sharma would display 3.2925418295
```

**Note** :
- L\* nominally ranges from 0 to 100
- a\* and b\* usually range from -128 to +127

For color inputs in **hexadecimal** (e.g., `#FFF`) or **RGB** formats, see examples for other languages :

[AWK](../awk#-flexibility), [C](../c#δe2000--accurate-fast-c-powered), [Dart](../dart#δe2000--accurate-fast-dart-powered), [Java](../java#δe2000--accurate-fast-java-powered), [JavaScript](../js#-flexibility), [Kotlin](../kt#δe2000--accurate-fast-kotlin-powered), [Lua](../lua#-flexibility), [PHP](../php#δe2000--accurate-fast-php-powered), [Python](../py#δe2000--accurate-fast-python-powered), [Ruby](../rb#δe2000--accurate-fast-ruby-powered), [Rust](../rs#δe2000--accurate-fast-rust-powered).

## Verification

[![Zig CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-zig.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-zig.yml)

<details>
<summary>What is the testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by Zig**, like this :

1.
```sh
if ! command -v zig > /dev/null; then
  # Select the most recent version of Zig
  ZIG_URL=$(wget --quiet --no-check-certificate --timeout=3 --tries=2 'https://ziglang.org/download/index.json' -O- |
    tr ',', '\n' | grep -F 'x86_64-linux' | grep -F 'download' | head -n 1 | sed 's/.*http/http/;s/".*//')
  echo "The most recent URL to download Zig is $ZIG_URL"
  # Instead, use the Zig version for which the ΔE2000 driver has been designed
  ZIG_URL='https://ziglang.org/download/0.14.1/zig-x86_64-linux-0.14.1.tar.xz'
  echo "The URL used to download Zig is $ZIG_URL"
  # Download and extract the Zig archive to an appropriate directory
  sudo rm -rf /opt/zig && mkdir /opt/zig
  wget --quiet --no-check-certificate --timeout=5 --tries=2 "$ZIG_URL" -O- | tar -C /opt/zig --strip-components=1 -xJf -
  #  Add Zig to system PATH
  sudo ln --backup --symbolic --verbose /opt/zig/zig /usr/local/bin/zig
  # Congratulations, Zig was installed in less than 15 seconds !
fi
```
2. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install gcc ; }`
3. `gcc -std=c99 -Wall -pedantic -O2 -g tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
4. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
5. `zig run tests/zig/ciede-2000-driver.zig -O ReleaseFast --  test-cases.csv | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.zig](ciede-2000-driver.zig#L93) for calculations and [test-zig.yml](../../.github/workflows/test-zig.yml) for automation.
</details>


The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
 CIEDE2000 Verification Summary :
  First Verified Line : 49,-4,34.3,66,60,100,34.625313516372486
             Duration : 28.73 s
            Successes : 10000000
               Errors : 0
      Average Delta E : 62.9449
    Average Deviation : 5.9963403339913237e-15
    Maximum Deviation : 2.2737367544323206e-13
```

> [!IMPORTANT]
> To correct this Zig source code to exact match certain third-party ΔE2000 functions, follow the comments in the source code.

> This formula, "small" in size, is an essential pillar of color management, deserving of this rigorous, tested and reliable industrial treatment.

### Performance

This function was measured at a speed of 2,178,649 calls per second.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **GCC** : 13.3
- **Zig** : 0.14.1

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in Zig** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=26&a1=38.2&b1=-47.3&L2=43.1&a2=7.5&b2=9.8) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Suitable in 40+ Languages](../../#implementations)
