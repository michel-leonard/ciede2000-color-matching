# ΔE2000 — Accurate. Fast. Zig-powered.

**ΔE2000** is the current industry standard for quantifying color differences in a way that closely matches human perception.

This canonical **Zig** implementation offers a straightforward, reliable method to calculate color differences efficiently in your software.

## Overview

The developed algorithm enables your software to measure color similarity and difference with scientific rigor.

For reference, two very distinct colors typically have a ΔE2000 value greater than 12.

Lower values indicate greater closeness, making it a **state-of-the-art method** for comparing colors.

## Implementation Details

The full source code released on March 1, 2025, is available [here](../../ciede-2000.zig#L9) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.zig).

This classic source code can be seamlessly integrated in both [C](../c#δe2000--accurate-fast-c-powered) and [C++](../cpp#δe2000--accurate-fast-c-powered) projects.

## Example usage in Zig

Calculate the **Delta E 2000** between two colors in the **L\*a\*b\*** color space using the `ciede_2000` function :

```zig
// Compute the Delta E (CIEDE2000) color difference between two Lab colors in Zig

// L1 = 19.3166        a1 = 73.5           b1 = 122.428
// L2 = 19.0           a2 = 76.2           b2 = 91.372

const delta_e = ciede_2000(l1, a1, b1, l2, a2, b2);
std.debug.print("{}\n", .{delta_e});

// Output: ΔE2000 ≈ 9.60876
```

**Note** :
- L\* ranges from 0 to 100
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
  ZIG_VERSION="0.14.1"
  ZIG_TARGET="x86_64-linux"
  # Zig installation ...
  ZIG_URL="https://ziglang.org/download/${ZIG_VERSION}/zig-${ZIG_TARGET}-${ZIG_VERSION}.tar.xz"
  # Verify if the download URL is reachable
  if ! wget --timeout=5 --tries=2 -q --spider "$ZIG_URL"; then
    command -v perl > /dev/null || { sudo apt-get update && sudo apt-get install perl ; }
    # Dynamically fetch the Zig tarball URL for from the official JSON index
    ZIG_URL=$(wget --timeout=5 --tries=2 -qO- https://ziglang.org/download/index.json | \
      perl -0777 -ne "print \$1 if /\"${ZIG_TARGET}\".*?\"tarball\"\\s*:\\s*\"([^\"]+)\"/s")
  fi
  # Download the Zig archive from the determined URL
  wget -q "$ZIG_URL"
  mkdir zig
  tar -C zig -xf "${ZIG_URL##*/}" --strip 1
  # Add the extracted Zig folder to PATH
  echo "export PATH=\"$PWD/zig:\$PATH\"" | sudo tee /etc/profile.d/zig.sh
  # Restart your shell... Congratulations, you installed Zig in 15 seconds.
fi
```
2. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install gcc ; }`
3. `gcc -std=c99 -Wall -pedantic -Ofast -ffast-math -g tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
4. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
5. `zig run tests/zig/ciede-2000-driver.zig -O ReleaseFast --  test-cases.csv | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.zig](ciede-2000-driver.zig#L86) for calculations and [test-zig.yml](../../.github/workflows/test-zig.yml) for automation.
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

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **GCC** : 13.3.0
- **Zig** : 0.15.0

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in Zig** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=2&a1=79&b1=-25&L2=82&a2=-103.9&b2=-121.7) — [32-bit vs 64-bit](https://github.com/michel-leonard/ciede2000-color-matching#numerical-precision-32-bit-vs-64-bit) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Used in 30+ Languages](../../#implementations)

