# ΔE2000 — Accurate. Fast. Lua-powered.

This reference ΔE2000 [implementation in Lua](../../ciede-2000.lua#L6) provides reliable and accurate perceptual color difference calculation.

LuaJIT can seamlessly integrate this **Lua CIEDE2000** implementation.

## Verification

[![LuaJIT CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-lua.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-lua.yml)

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
CIEDE2000 Verification Summary :
- Last Verified Line : 64.38,100.89,-53.17,7.05,-67.98,65.23,113.58100896066
- Duration : 11.32 s
- Successes : 10000000
- Errors : 0
- Maximum Difference : 5.6843418860808015e-13
```

[[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/calculator.html?L1=64.38&a1=100.89&b1=-53.17&L2=7.05&a2=-67.98&b2=65.23)] - [[Workflow Details](../../.github/workflows#workflow-details)]
