# ΔE2000 — Accurate. Fast. Pascal-powered.

ΔE2000 is the current standard for quantifying color differences in a way that best matches human vision.

This canonical implementation in **Pascal** makes it possible to set up precise, programmatic color comparison right now.

## Overview

The developed algorithm enables software to evaluate color similarities (or differences) with scientific rigor.

As a general rule, navy blue and yellow, which are very different colors, generally have a ΔE<sub>00</sub> of around 115.

Values such as 5 indicate greater closeness, making this both a simple and advanced method of color comparison.

## Implementation Details

The full source code released on March 1, 2025, is available [here](../../ciede-2000.pas#L9) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.pas).

Object Pascal (Delphi) can seamlessly integrate this classic source code.

## Example usage in Pascal

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```pas
// Calculate ΔE*00 between two colors in L*a*b* space
var
  l1, a1, b1, l2, a2, b2, deltaE: Double;
begin
  l1 := 19.3166; a1 := 73.5; b1 := 122.428;
  l2 := 19.0;    a2 := 76.2; b2 := 91.372;

  deltaE := ciede_2000(l1, a1, b1, l2, a2, b2);
  writeln('ΔE₀₀ = ', deltaE:0:10);
end.
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
4. `gcc -std=c99 -Wall -pedantic -Ofast -ffast-math -g tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
5. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
6. `tests/pas/CIEDE2000Test test-cases.csv | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.pas](ciede-2000-driver.pas#L97) for calculations and [test-pas.yml](../../.github/workflows/test-pas.yml) for automation.
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

### Speed Benchmark

This function was measured at a speed of 2,048,922 calls per second.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **Free Pascal Compiler** : 3.2.2
- **GCC** : 13.3

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in Pascal** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=44.4&a1=10&b1=-52.1&L2=23&a2=-25&b2=1) — [32-bit vs 64-bit](https://github.com/michel-leonard/ciede2000-color-matching#numerical-precision-32-bit-vs-64-bit) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Suitable in 30+ Languages](../../#implementations)
