# ΔE2000 — Accurate. Fast. Wren-powered.

ΔE2000 has become the global difference metric for color comparison in professional and industrial applications.

This reference implementation in **Wren** offers an easy way to calculate these differences accurately within programs.

## Overview

The developed algorithm enables software to evaluate color similarities (or differences) with scientific rigor.

As a general rule, 🔵 navy blue and 🟡 yellow, which are very different colors, have a ΔE\*<sub>00</sub> of around 115.

Values [such as 5](https://michel-leonard.github.io/ciede2000-color-matching/de2000-rgb-pairs.html?seq=50&delta-e=5) indicate greater closeness, making this both a simple and advanced method of color comparison.

## Implementation Details

The full source code released on March 1, 2025, is available [here](../../ciede-2000.wren#L6) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.wren).

<details>
<summary>What two options are available for matching ΔE2000 calculations with existing calculations ?</summary>

#### Option 1 (default)
 This often-used option consists of a coding simplification that is a historical legacy of early implementations :
```wren
h_m = h_m + Num.pi
// h_m = h_m + (h_m < Math.PI ? Math.PI : -Math.PI)
```

#### Option 2 (compatible with Gaurav Sharma’s precise calculations)
There’s no room for ambiguity, this inversion of the commented line in the source code ensures compliance with the official :
```wren
// h_m = h_m + Num.pi
h_m = h_m + (h_m < Math.PI ? Math.PI : -Math.PI)
```

**Note** : the difference between the two options is minimal (±0.0003 on the calculated color difference) and usually overlooked.
</details>

## Example usage in Wren

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```wren
// Example usage of the ΔE*00 function in Wren

var l1 = 91.0, a1 = 40.7, b1 = 4.0
var l2 = 93.0, a2 = 34.5, b2 = -2.2

var delta_e = ciede_2000(l1, a1, b1, l2, a2, b2)
System.print(delta_e)

// .................................................. This shows a ΔE2000 of 4.3724700322
// As explained in the comments, compliance with Gaurav Sharma would display 4.3724840146
```

**Note** : L\* is nominally between 0 and 100, a\* and b\* generally between -128 and +127.

For color inputs in **hexadecimal** (e.g., `#FFF`) or **RGB** formats, see examples for other languages :

[AWK](../awk#-flexibility), [C](../c#δe2000--accurate-fast-c-powered), [Dart](../dart#δe2000--accurate-fast-dart-powered), [Java](../java#δe2000--accurate-fast-java-powered), [JavaScript](../js#-flexibility), [Kotlin](../kt#δe2000--accurate-fast-kotlin-powered), [Lua](../lua#-flexibility), [PHP](../php#δe2000--accurate-fast-php-powered), [Python](../py#δe2000--accurate-fast-python-powered), [Ruby](../rb#δe2000--accurate-fast-ruby-powered), [Rust](../rs#δe2000--accurate-fast-rust-powered).

## Verification

[![Wren CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-wren.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-wren.yml)
<details>
<summary>What is the testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by Wren**, like this :

1.
```sh
command -v wren_cli > /dev/null || {
  command -v make > /dev/null || { sudo apt-get update && sudo apt-get install make ; }
  # Use Wren version 0.4.0 for which the ΔE2000 driver has been designed
  WREN_URL="https://github.com/wren-lang/wren-cli/archive/18553636618a4d33f10af9b5ab92da6431784a8c.tar.gz"
  # Extract the 512KB Wren archive into a temporary directory
  WREN_DIR=$(mktemp --directory)
  wget --no-verbose --no-check-certificate --timeout=5 --tries=2 "$WREN_URL" -O- |
  tar -C $WREN_DIR --strip-components=1 -xzf -
  # Install Wren from the C sources
  make -C $WREN_DIR/projects/make -f wren_cli.make
  # Move wren_cli to a suitable location in the system PATH
  sudo mv --backup --verbose $WREN_DIR/bin/wren_cli /usr/local/bin/wren_cli
  # Clean up everything else
  sudo rm -rf $WREN_DIR
  # Congratulations, Wren was installed in 15 seconds !
}
```
2. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install gcc ; }`
3. `gcc -std=c99 -Wall -pedantic -O2 -g tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
4. `./ciede-2000-driver --generate $n_tests | split -u -l 50000 - X`
5. `wren_cli tests/wren/ciede-2000-driver.wren $(ls X* | tr '\n' ' ') | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.wren](ciede-2000-driver.wren#L88) for calculations and [test-wren.yml](../../.github/workflows/test-wren.yml) for automation.
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

> [!IMPORTANT]
> To correct this Wren source code to exact match certain third-party ΔE2000 functions, follow the comments in the source code.

> This formula, "small" in size, is an essential pillar of color management, deserving of this rigorous, tested and reliable industrial treatment.

### Performance

This function was measured at a speed of 311,915 calls per second.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **GCC** : 13.3
- **wren_cli** : 0.4.0

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in Wren** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=8.1&a1=5&b1=6.2&L2=8.9&a2=29.6&b2=-36.2) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Suitable in 40+ Languages](../../#implementations)
