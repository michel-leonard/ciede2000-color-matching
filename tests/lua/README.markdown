# ΔE2000 — Accurate. Fast. Lua-powered.

ΔE2000 is the globally recognized standard for quantifying color differences according to human vision.

This reference implementation in **Lua** offers a simple way of calculating these differences accurately and within programs.

## Overview

The developed algorithm enables software to evaluate color similarities (or differences) with scientific rigor.

As a general rule, 🔵 navy blue and 🟡 yellow, which are very different colors, have a ΔE\*<sub>00</sub> of around 115.

Values [such as 5](https://michel-leonard.github.io/ciede2000-color-matching/de2000-rgb-pairs.html?seq=50&delta-e=5) indicate greater closeness, making this both a simple and advanced method of color comparison.

## Implementation Details

The full source code (released March 1, 2025) is available [here](../../ciede-2000.lua#L6) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.lua).

Compatible with Lua 5.1 to 5.4 and LuaJIT, this implementation integrates easily into projects.

<details>
<summary>What two options are available for matching ΔE2000 calculations with existing calculations ?</summary>

#### Option 1 (default)
 This often-used option consists of a coding simplification that is a historical legacy of early implementations :
```lua
h_m = h_m + math.pi;
-- h_m = h_m + (h_m < math.pi and math.pi or -math.pi)
```

#### Option 2 (compatible with Gaurav Sharma’s precise calculations)
There’s no room for ambiguity, this inversion of the commented line in the source code ensures compliance with the official :
```lua
-- h_m = h_m + math.pi;
h_m = h_m + (h_m < math.pi and math.pi or -math.pi)
```

**Note** : the difference between the two options is minimal (±0.0003 on the calculated color difference) and usually overlooked.
</details>

## Example usage in Lua / LuaJIT

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```lua
-- Compute the Delta E (CIEDE2000) color difference between two L*a*b* colors in Lua

-- Color 1
local L1, a1, b1 = 75.1, 61.9, -3.2

-- Color 2
local L2, a2, b2 = 75.6, 55.9, 3.1

local deltaE = ciede_2000(L1, a1, b1, L2, a2, b2)
print(deltaE)

-- .................................................. This shows a ΔE2000 of 3.3591979531
-- As explained in the comments, compliance with Gaurav Sharma would display 3.3591841825

```

**Note** : L\* is nominally between 0 and 100, a\* and b\* usually between -128 and +127.

### 🎨 Flexibility

An [all-in-one](compare-rgb-hex-colors.lua) function accepts RGB and hexadecimal formats and calculates ΔE2000 using illuminant D65.

## Verification

[![LuaJIT CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-lua.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-lua.yml)

<details>
<summary>What is the testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by Lua**, like this :

1. `command -v luajit > /dev/null || { sudo apt-get update && sudo apt-get install luajit ; }`
2. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install gcc ; }`
3. `gcc -std=c99 -Wall -pedantic -O2 -g tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
4. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
5. `luajit tests/lua/ciede-2000-driver.lua test-cases.csv | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.lua](ciede-2000-driver.lua#L86) for calculations and [test-lua.yml](../../.github/workflows/test-lua.yml) for automation.
</details>

Verification confirms perfect compliance with negligible floating-point deviations: :

```
 CIEDE2000 Verification Summary :
  First Verified Line : 25.3,0.28,53.78,65.8,-101.21,-86,67.92949263023695
             Duration : 19.28 s
            Successes : 10000000
               Errors : 0
      Average Delta E : 62.9474
    Average Deviation : 4.2586916049192067e-15
    Maximum Deviation : 1.1368683772161603e-13
```
### Comparison with Lua’s tiny-devicons-auto-colors.nvim

[![ΔE2000 against tiny-devicons in Lua](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-tiny-devicons.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-tiny-devicons.yml)

Tested on 100 million random L\*a\*b\* color pairs against the official **tiny-devicons-auto-colors** implementation, this function showed a perfect match with zero error and a maximum difference of **4 × 10<sup>-13</sup>** in ΔE\*<sub>00</sub> values, [confirming](../#dynamic-tests-with-established-libraries) its interoperability and production-ready status in Lua.

> [!IMPORTANT]
> To correct this Lua source code to exact match certain third-party ΔE2000 functions, follow the comments in the source code.

> This formula, "small" in size, is an essential pillar of color management, deserving of this rigorous, tested and reliable industrial treatment.

### Speed Benchmark

Measured performance : **6,519,178 calls per second**.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **GCC** : 13.3
- **LuaJIT** : 2.1.1703358377

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in Lua** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=75.2&a1=9&b1=11.3&L2=59.1&a2=33.4&b2=-40.6) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Suitable in 40+ Languages](../../#implementations)
