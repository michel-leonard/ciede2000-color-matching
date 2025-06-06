# ΔE2000 — Accurate. Fast. C-powered.

This reference ΔE2000 implementation written in C provides reliable and accurate perceptual **color difference** calculation.

## Source Code

The full source code is available [here](../../ciede-2000.c#L13), and is archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.c).

Swift, Objective-C, Julia, D, and C++ can all seamlessly integrate this classic source code.

Starting with GCC supporting C++14, the `ciede_2000` function can be used in constant expressions in C++.

## Example usage in  C - C++

For these programming languages, see the original [full example](../../#source-code-in-c).

To compare **hexadecimal** (e.g., "#FFF") or **RGB colors** using the CIEDE2000 function, follow these examples :
- [compare-hex-colors.c](compare-hex-colors.c#L208)
- [compare-rgb-colors.c](compare-rgb-colors.c#L208)

## Verification

[![C99 CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-c.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-c.yml)

<details>
<summary>What is the testing procedure ?</summary>

 1. `gcc -O3 tests/c/ciede-2000-testing.c -o ciede-2000-test -lm`
 2. `./ciede-2000-test 10000000 | node tests/js/stdin-verifier.js > test-output.txt`
</details>

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
 CIEDE2000 Verification Summary :
- Last Verified Line : 61.3,109.1,2.76,40.1,29,123.3,66.8271373643388
- Duration  : 20.27 s
- Successes : 10000000
- Errors : 0
- Maximum Difference : 6.821210263296962e-13
```

### Computational Speed

This function was measured at a speed of 7,351,040 calls per second.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **GCC** : 13.3.0
- **NodeJS** : 20.19.2

## Conclusion

With over 20 years serving developers, this **trusted color comparison** routine developed in C brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=61.3&a1=109.1&b1=2.76&L2=40.1&a2=29&b2=123.3) — [32-bit vs 64-bit](https://github.com/michel-leonard/ciede2000-color-matching#numerical-precision-32-bit-vs-64-bit) — [Workflow Details](../../.github/workflows#workflow-details) — [Across 30+ programming languages](../../#implementations)

