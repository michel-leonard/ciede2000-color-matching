# ΔE2000 — Accurate. Fast. Ada-powered.

ΔE2000 is the industry standard for quantifying color differences in accordance with how humans see them.

This reference implementation in **Ada** provides a simple, accurate and programmatic way of calculating these differences.

## Overview

The developed algorithm enables software to evaluate color similarities (or differences) with scientific rigor.

As a general rule, 🔵 navy blue and 🟡 yellow, which are very different colors, have a ΔE\*<sub>00</sub> of around 115.

Values [such as 5](https://michel-leonard.github.io/ciede2000-color-matching/de2000-rgb-pairs.html?seq=50&delta-e=5) indicate greater closeness, making this both a simple and advanced method of color comparison.

## Implementation Details

The full Ada 2005 source code, released on March 1, 2025, is available [here](../../ciede-2000.adb#L8) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.adb).

<details>
<summary>What two options are available for matching ΔE2000 calculations with existing calculations ?</summary>

#### Option 1 (default)
 This often-used option consists of a coding simplification that is a historical legacy of early implementations :
```ada
h_m := h_m + m_pi;
-- if h_m < m_pi then h_m := h_m + m_pi; else h_m := h_m - m_pi; end if;
```

#### Option 2 (compatible with Gaurav Sharma’s precise calculations)
There’s no room for ambiguity, this inversion of the commented line in the source code ensures compliance with the official :
```ada
-- h_m := h_m + m_pi;
if h_m < m_pi then h_m := h_m + m_pi; else h_m := h_m - m_pi; end if;
```

**Note** : the difference between the two options is minimal (±0.0003 on the calculated color difference) and usually overlooked.
</details>

## Example usage in Ada

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```ada
-- Compute the Delta E (CIEDE2000) color difference between two L*a*b* colors in Ada

-- Color 1: l1 = 28.9, a1 = 47.5, b1 = 2.0
-- Color 2: l2 = 28.8, a2 = 41.6, b2 = -1.7

deltaE := ciede_2000(l1, a1, b1, l2, a2, b2);
Put(deltaE, Fore => 1, Aft => 15, Exp => 0);
New_Line;

-- .................................................. This shows a ΔE2000 of 2.7749016764
-- As explained in the comments, compliance with Gaurav Sharma would display 2.7749152801
```

**Note** : L\* is nominally between 0 and 100, a\* and b\* generally between -128 and +127.

For color inputs in **hexadecimal** (e.g., `#FFF`) or **RGB** formats, see examples for other languages :

[AWK](../awk#-flexibility), [C](../c#δe2000--accurate-fast-c-powered), [Dart](../dart#δe2000--accurate-fast-dart-powered), [Java](../java#δe2000--accurate-fast-java-powered), [JavaScript](../js#-flexibility), [Kotlin](../kt#δe2000--accurate-fast-kotlin-powered), [Lua](../lua#-flexibility), [PHP](../php#δe2000--accurate-fast-php-powered), [Python](../py#δe2000--accurate-fast-python-powered), [Ruby](../rb#δe2000--accurate-fast-ruby-powered), [Rust](../rs#δe2000--accurate-fast-rust-powered).

## Verification

[![Ada CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-adb.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-adb.yml)

<details>
<summary>What is the testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by Ada**, like this :

1. `command -v gnatmake > /dev/null || { sudo apt-get update && sudo apt-get install gnat ; }`
2. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install gcc ; }`
3. `cp -p tests/adb/ciede-2000-driver.adb main.adb`
4. `gnatmake main.adb -gnat05 -O3 -gnatwa -gnatf -gnatwd -gnatwe -gnatws -f -o driver-ada`
5. `gcc -std=c99 -Wall -pedantic -O2 -g tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
6. `./ciede-2000-driver --generate 10000000 | sed -E 's/(,|^)([0-9+-]+)e([0-9+-]+)/\1\2.0e\3/gi' > test-cases.csv`
7. `./driver-ada test-cases.csv | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.adb](ciede-2000-driver.adb#L108) for calculations and [test-adb.yml](../../.github/workflows/test-adb.yml) for automation.
</details>

This function has been rigorously tested for compliance with the standard, achieving zero errors and negligible floating-point deviations :

```
 CIEDE2000 Verification Summary :
  First Verified Line : 27,-123,101,44,42.0000098,-99,70.204734814936884
             Duration : 37.68 s
            Successes : 10000000
               Errors : 0
      Average Delta E : 63.0868
    Average Deviation : 7.2e-15
    Maximum Deviation : 2.7e-13
```

> [!IMPORTANT]
> To correct this Ada source code to exact match certain third-party ΔE2000 functions, follow the comments in the source code.

> This formula, "small" in size, is an essential pillar of color management, deserving of this rigorous, tested and reliable industrial treatment.

## Performance & Environment

- Speed benchmark : ~5.1 million calls per second
- Tested on Ubuntu 24.04.2 LTS, GNATMAKE 13.3, GCC 13.3

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in Ada** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=65.3&a1=3.7&b1=4.9&L2=48.9&a2=41.8&b2=-54.2) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Suitable in 40+ Languages](../../#implementations)

