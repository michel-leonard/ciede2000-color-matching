# ΔE2000 — Accurate. Fast. Wren-powered.

ΔE2000 has become the color difference metric of choice in professional and industrial applications.

This canonical **Wren** implementation offers an easy way to calculate these differences accurately and programmatically.

## Overview

The developed algorithm enables your software to measure color similarity and difference with scientific rigor.

For reference, two very distinct colors typically have a ΔE2000 value greater than 12.

Lower values indicate greater closeness, making it a **state-of-the-art method** for comparing colors.

## Implementation Details

The full source code released on March 1, 2025, is available [here](../../ciede-2000.wren#L6) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.wren).

## Example usage in Wren

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```wren
// Example usage of the ΔE*00 function in Wren

var l1 = 19.3166, a1 = 73.5, b1 = 122.428
var l2 = 19.0, a2 = 76.2, b2 = 91.372

var delta_e = ciede_2000(l1, a1, b1, l2, a2, b2)
System.print(delta_e) 

// This shows a ΔE2000 of 9.60876174564
```

**Note**: L\* is usually between 0 and 100, a\* and b\* between -128 and +127.

For color inputs in **hexadecimal** (e.g., `#FFF`) or **RGB** formats, see examples for other languages :

[AWK](../awk#-flexibility), [C](../c#δe2000--accurate-fast-c-powered), [Dart](../dart#δe2000--accurate-fast-dart-powered), [Java](../java#δe2000--accurate-fast-java-powered), [JavaScript](../js#-flexibility), [Kotlin](../kt#δe2000--accurate-fast-kotlin-powered), [Lua](../lua#-flexibility), [PHP](../php#δe2000--accurate-fast-php-powered), [Python](../py#δe2000--accurate-fast-python-powered), [Ruby](../rb#δe2000--accurate-fast-ruby-powered), [Rust](../rs#δe2000--accurate-fast-rust-powered).

## Verification

[![Wren CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-wren.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-wren.yml)
<details>
<summary>What is the testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by Wren**, like this :

1. `command -v make > /dev/null || { sudo apt-get update && sudo apt-get install -y make ; }`
2.
```sh
git clone --depth 1 https://github.com/wren-lang/wren-cli.git
# The cd is scoped into a subshell, so not persistent.
(cd wren-cli/projects/make && make -f wren_cli.make)
ln -s $PWD/wren-cli/bin/wren_cli /usr/local/bin/wren_cli
```
3. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install -y gcc ; }`
4. `gcc -std=c99 -Wall -pedantic -Ofast tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
5. `./ciede-2000-driver --generate $n_tests | split -u -l 50000 - X`
6. `wren_cli tests/wren/ciede-2000-driver.wren $(ls X* | tr '\n' ' ') | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.wren](ciede-2000-driver.wren#L122) for calculations and [test-wren.yml](../../.github/workflows/test-wren.yml) for automation.
</details>

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
CIEDE2000 Verification Summary :
  First Verified Line : 52.11,32.4,35,37,116,55,26.287015265926
             Duration : 72.22 s
            Successes : 10000000
               Errors : 0
      Average Delta E : 62.9356
    Average Deviation : 4.5509643875618626e-13
    Maximum Deviation : 5.0590642786119133e-12
```

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **GCC** : 13.3.0
- **wren_cli** : 0.4.0

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in Wren** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=52&a1=-99.5&b1=52.9&L2=55&a2=26.7&b2=-102) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Used in 30+ Languages](../../#implementations)

