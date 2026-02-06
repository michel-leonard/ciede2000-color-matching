# ΔE2000 — Accurate. Fast. TCL-powered.

ΔE2000 is the globally recognized standard for quantifying color differences according to human vision.

This reference implementation in **Tool Command Language** offers a simple way of calculating these differences accurately within scripts.

## Overview

The developed algorithm enables software to evaluate color similarities (or differences) with scientific rigor.

As a general rule, 🔵 navy blue and 🟡 yellow, which are very different colors, have a ΔE\*<sub>00</sub> of around 115.

Values [such as 5](https://michel-leonard.github.io/ciede2000-color-matching/de2000-rgb-pairs.html?seq=50&delta-e=5) indicate greater closeness, making this both a simple and advanced method of color comparison.

## Implementation Details

The full source code (released March 1, 2025) is available [here](../../ciede-2000.tcl#L6) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.tcl).

<details>
<summary>What two options are available for matching ΔE2000 calculations with existing calculations ?</summary>

#### Option 1 (default)
 This often-used option consists of a coding simplification that is a historical legacy of early implementations :
```tcl
set h_m [expr { $h_m + $pi }]
# set h_m [expr {$h_m + ($h_m < $pi ? $pi : -$pi)}]
```

#### Option 2 (compatible with Gaurav Sharma’s precise calculations)
There’s no room for ambiguity, this inversion of the commented line in the source code ensures compliance with the official :
```tcl
# set h_m [expr { $h_m + $pi }]
set h_m [expr {$h_m + ($h_m < $pi ? $pi : -$pi)}]
```

**Note** : the difference between the two options is minimal (±0.0003 on the calculated color difference) and usually overlooked.
</details>

## Example usage in TCL

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```tcl
# Compute the Delta E (CIEDE2000) color difference between two L*a*b* colors in TCL

set color_1 { 77.6 32.2 2.3 }
set color_2 { 79.6 37.6 -2.2 }

lassign $color_1 l1 a1 b1
lassign $color_2 l2 a2 b2

set deltaE [ciede_2000  $l1 $a1 $b1 $l2 $a2 $b2]

puts "Delta E 2000 = $deltaE"

# .................................................. This shows a ΔE2000 of 3.6681680203
# As explained in the comments, compliance with Gaurav Sharma would display 3.6681547431
```

**Note** : L\* varies nominally between 0 and 100, a\* and b\* most often between -128 and +127.

For color inputs in **hexadecimal** (e.g., `#FFF`) or **RGB** formats, see examples for other languages :

[AWK](../awk#-flexibility), [C](../c#δe2000--accurate-fast-c-powered), [Dart](../dart#δe2000--accurate-fast-dart-powered), [Java](../java#δe2000--accurate-fast-java-powered), [JavaScript](../js#-flexibility), [Kotlin](../kt#δe2000--accurate-fast-kotlin-powered), [Lua](../lua#-flexibility), [PHP](../php#δe2000--accurate-fast-php-powered), [Python](../py#δe2000--accurate-fast-python-powered), [Ruby](../rb#δe2000--accurate-fast-ruby-powered), [Rust](../rs#δe2000--accurate-fast-rust-powered).

## Verification

[![TCL CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-tcl.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-tcl.yml)

<details>
<summary>What is the testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by TCL**, like this :

1. `command -v tclsh > /dev/null || { sudo apt-get update && sudo apt-get install tcl ; }`
2. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install gcc ; }`
3. `gcc -std=c99 -Wall -pedantic -O2 -g tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
4. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
5. `tclsh tests/tcl/ciede-2000-driver.tcl test-cases.csv | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.tcl](ciede-2000-driver.tcl#L91) for calculations and [test-tcl.yml](../../.github/workflows/test-tcl.yml) for automation.
</details>

Verification confirms perfect compliance with negligible floating-point deviations :

```
CIEDE2000 Verification Summary :
  First Verified Line : 13,-16,-37,56,-39,6,45.232649568328206
             Duration : 128.97 s
            Successes : 10000000
               Errors : 0
      Average Delta E : 63.2442
    Average Deviation : 4.6e-15
    Maximum Deviation : 1.1e-13
```

> [!IMPORTANT]
> To correct this TCL source code to exact match certain third-party ΔE2000 functions, follow the comments in the source code.

> This formula, "small" in size, is an essential pillar of color management, deserving of this rigorous, tested and reliable industrial treatment.

### Speed Benchmark

Measured performance : **137,438 calls per second**.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **GCC** : 13.3
- **tclsh** : 8.6.14

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in TCL** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=26.7&a1=8.9&b1=-7&L2=28.4&a2=45.9&b2=36.6) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Suitable in 40+ Languages](../../#implementations)
