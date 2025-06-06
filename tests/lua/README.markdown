# ΔE2000 — Accurate. Fast. Lua-powered.

This reference ΔE2000 implementation written in Lua provides reliable and accurate perceptual **color difference** calculation.

## Source Code

The full source code is available [here](../../ciede-2000.lua#L6), and is archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.lua).

Lua (5.1 to 5.4) and LuaJIT can seamlessly integrate this classic source code.

## Example usage in Lua/LuaJIT

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```lua
-- Example usage of the CIEDE2000 function in Lua

-- L1 = 19.3166        a1 = 73.5           b1 = 122.428
-- L2 = 19.0           a2 = 76.2           b2 = 91.372

local deltaE = ciede_2000(L1, a1, b1, L2, a2, b2)
print(deltaE);

-- This shows a ΔE2000 of 9.60876174564
```

**Note**: L\* is usually between 0 and 100, a\* and b\* between -128 and +127.

### 🎨 Flexibility

This [all-in-one](compare-rgb-hex-colors.lua#L145) function accepts RGB and hexadecimal color formats to calculate ΔE2000 **color differences**.

## Verification

[![LuaJIT CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-lua.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-lua.yml)

<details>
<summary>What is the testing procedure ?</summary>

 1. `gcc -O3 tests/c/stdin-verifier.c -o verifier -lm`
 2. `luajit tests/lua/ciede-2000-testing.lua 10000000 | ./verifier > test-output.txt`
</details>

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
CIEDE2000 Verification Summary :
- Last Verified Line : 64.38,100.89,-53.17,7.05,-67.98,65.23,113.58100896066
- Duration : 11.32 s
- Successes : 10000000
- Errors : 0
- Maximum Difference : 5.6843418860808015e-13
```

### Computational Speed

This function was measured at a speed of 6,519,178 calls per second.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **GCC** : 13.3.0
- **LuaJIT** : 2.1.1703358377

## Conclusion

With over 20 years serving developers, this **trusted color comparison** routine developed in Lua brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=64.38&a1=100.89&b1=-53.17&L2=7.05&a2=-67.98&b2=65.23) — [32-bit vs 64-bit](https://github.com/michel-leonard/ciede2000-color-matching#numerical-precision-32-bit-vs-64-bit) — [Workflow Details](../../.github/workflows#workflow-details) — [Across 30+ programming languages](../../#implementations)

