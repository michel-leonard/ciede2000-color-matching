# ΔE2000 — Accurate. Fast. Pascal-powered.

ΔE2000 is the current standard for quantifying color differences in a way that best matches human vision.

This reference implementation in **Pascal** makes it possible to set up precise, programmatic color comparison right now.

## Overview

The developed algorithm enables software to evaluate color similarities (or differences) with scientific rigor.

As a general rule, 🔵 navy blue and 🟡 yellow, which are very different colors, have a ΔE\*<sub>00</sub> of around 115.

Values [such as 5](https://michel-leonard.github.io/ciede2000-color-matching/de2000-rgb-pairs.html?seq=50&delta-e=5) indicate greater closeness, making this both a simple and advanced method of color comparison.

## Implementation Details

The full source code released on March 1, 2025, is available [here](../../ciede-2000.pas#L9) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.pas).

Object Pascal (Delphi) can seamlessly integrate this classic source code.

<details>
<summary>What two options are available for matching ΔE2000 calculations with existing calculations ?</summary>

#### Option 1 (default)
 This often-used option consists of a coding simplification that is a historical legacy of early implementations :
```pas
h_m := h_m + Pi;
// if h_m < Pi then h_m := h_m + Pi else h_m := h_m - Pi;
```

#### Option 2 (compatible with Gaurav Sharma’s precise calculations)
There’s no room for ambiguity, this inversion of the commented line in the source code ensures compliance with the official :
```pas
// h_m := h_m + Pi;
if h_m < Pi then h_m := h_m + Pi else h_m := h_m - Pi;
```

**Note** : the difference between the two options is minimal (±0.0003 on the calculated color difference) and usually overlooked.
</details>

## Example usage in Pascal

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```pas
// Calculate ΔE*00 between two colors in L*a*b* space
var
  l1, a1, b1, l2, a2, b2, deltaE: Double;
begin
  l1 := 31.8; a1 := 22.9; b1 := 4.8;
  l2 := 30.2; a2 := 18.7; b2 := -3.7;

  deltaE := ciede_2000(l1, a1, b1, l2, a2, b2);
  writeln('CIEDE2000 = ', deltaE:0:10);
end.

// .................................................. This shows a ΔE2000 of 6.1884550095
// As explained in the comments, compliance with Gaurav Sharma would display 6.1884708040
```

**Note** : L\* is nominally between 0 and 100, a\* and b\* usually between -128 and +127.

For color inputs in **hexadecimal** (e.g., `#FFF`) or **RGB** formats, see examples for other languages :

[AWK](../awk#-flexibility), [C](../c#δe2000--accurate-fast-c-powered), [Dart](../dart#δe2000--accurate-fast-dart-powered), [Java](../java#δe2000--accurate-fast-java-powered), [JavaScript](../js#-flexibility), [Kotlin](../kt#δe2000--accurate-fast-kotlin-powered), [Lua](../lua#-flexibility), [PHP](../php#δe2000--accurate-fast-php-powered), [Python](../py#δe2000--accurate-fast-python-powered), [Ruby](../rb#δe2000--accurate-fast-ruby-powered), [Rust](../rs#δe2000--accurate-fast-rust-powered).

## Verification

[![Pascal CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-pas.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-pas.yml)

<details>
<summary>What is the testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by Pascal**, like this :

1. `command -v fp-compiler > /dev/null || { sudo apt-get update && sudo apt-get install fp-compiler ; }`
2. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install gcc ; }`
3. `fpc -O2 -oCIEDE2000Test tests/pas/ciede-2000-driver.pas`
4. `gcc -std=c99 -Wall -pedantic -O2 -g tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
5. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
6. `tests/pas/CIEDE2000Test test-cases.csv | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.pas](ciede-2000-driver.pas#L99) for calculations and [test-pas.yml](../../.github/workflows/test-pas.yml) for automation.
</details>

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
CIEDE2000 Verification Summary :
  First Verified Line : 89.9,44,33,7,-75.04,-57,120.27117304507197559
             Duration : 33.38 s
            Successes : 10000000
               Errors : 0
      Average Delta E : 62.9452
    Average Deviation : 1.4059798381094168e-14
    Maximum Deviation : 3.4106051316484809e-13
```

> [!IMPORTANT]
> To correct this Pascal source code to exact match certain third-party ΔE2000 functions, follow the comments in the source code.

> This formula, "small" in size, is an essential pillar of color management, deserving of this rigorous, tested and reliable industrial treatment.

### Speed Benchmark

This function was measured at a speed of 2,048,922 calls per second.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **Free Pascal Compiler** : 3.2.2
- **GCC** : 13.3

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in Pascal** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=66.7&a1=34.4&b1=-34.2&L2=77.7&a2=8.8&b2=8.9) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Suitable in 40+ Languages](../../#implementations)
