# ΔE2000 — Accurate. Fast. Lua-powered.

ΔE2000 is the globally recognized standard for quantifying color differences in line with human perception.

This canonical **Lua** implementation offers an easy way to calculate these differences accurately and programmatically.

## Overview

The developed algorithm enables your software to measure color similarity and difference with scientific rigor.

For reference, two very distinct colors typically have a ΔE2000 value greater than 12.

Lower values indicate greater closeness, making it a **state-of-the-art method** for comparing colors.

## Implementation Details

The full source code (released March 1, 2025) is available [here](../../ciede-2000.lua#L6) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.lua).

Compatible with Lua 5.1 to 5.4 and LuaJIT, this implementation integrates seamlessly into your projects.

## Example usage in Lua / LuaJIT

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```lua
-- Compute the Delta E (CIEDE2000) color difference between two Lab colors in Lua

-- Color 1
local L1, a1, b1 = 19.3166, 73.5, 122.428

-- Color 2
local L2, a2, b2 = 19.0, 76.2, 91.372

local deltaE = ciede_2000(L1, a1, b1, L2, a2, b2)
print(deltaE)  -- Output: 9.60876174564
```

**Note**: L\* is usually between 0 and 100, a\* and b\* between -128 and +127.

### 🎨 Flexibility

An [all-in-one](compare-rgb-hex-colors.lua#L145) function accepts RGB and hexadecimal formats and calculates ΔE2000 using illuminant D65.

## Verification

[![LuaJIT CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-lua.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-lua.yml)

<details>
<summary>What is the testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by Lua**, like this :

1. `command -v luajit > /dev/null || { sudo apt-get update && sudo apt-get install -y luajit ; }`
2. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install -y gcc ; }`
3. `gcc -std=c99 -Wall -pedantic -Ofast tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
4. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
5. `luajit tests/lua/ciede-2000-driver.lua test-cases.csv | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.lua](ciede-2000-driver.lua#L120) for calculations and [test-lua.yml](../../.github/workflows/test-lua.yml) for automation.
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
### Comparison with Lua's tiny‑devicons‑auto‑colors.nvim

[![ΔE2000 against Lua tiny-devicons](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-tiny-devicons.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-tiny-devicons.yml)

Tested on 100 million random cases against the official **tiny‑devicons‑auto‑colors** implementation, this Lua function showed perfect agreement with zero errors and a max difference of 4×10⁻¹³, confirming correctness and reliability.

### Speed Benchmark

Measured performance : **6,519,178 calls per second**.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **GCC** : 13.3.0
- **LuaJIT** : 2.1.1703358377

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in Lua** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=64.38&a1=100.89&b1=-53.17&L2=7.05&a2=-67.98&b2=65.23) — [32-bit vs 64-bit](https://github.com/michel-leonard/ciede2000-color-matching#numerical-precision-32-bit-vs-64-bit) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Used in 30+ Languages](../../#implementations)

