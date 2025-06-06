# ΔE2000 — Accurate. Fast. Julia-powered.

This reference ΔE2000 implementation written in Julia provides reliable and accurate perceptual **color difference** calculation.

## Source Code

The full source code is available [here](../../ciede-2000.jl#L9), and is archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.jl).

## Example usage in Julia

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```jl
# Example usage of the CIEDE2000 function in Julia

# L1 = 19.3166        a1 = 73.5           b1 = 122.428
# L2 = 19.0           a2 = 76.2           b2 = 91.372

deltaE = ciede_2000(l1, a1, b1, l2, a2, b2)
println(deltaE)

# This shows a ΔE2000 of 9.60876174564
```

**Note**: L\* is usually between 0 and 100, a\* and b\* between -128 and +127.

To compare **hexadecimal** (e.g., "#FFF") or **RGB colors** using the CIEDE2000 function, examples are available in several languages :
- [AWK](../awk#-flexibility)
- [C](../c#δe2000--accurate-fast-c-powered)
- [Dart](../dart#δe2000--accurate-fast-dart-powered)
- [JavaScript](../js#-flexibility)
- [Java](../java#δe2000--accurate-fast-java-powered)
- [Kotlin](../kt#δe2000--accurate-fast-kotlin-powered)
- [Lua](../lua#-flexibility)
- [PHP](../php#δe2000--accurate-fast-php-powered)
- [Python](../py#δe2000--accurate-fast-python-powered)
- [Ruby](../rb#δe2000--accurate-fast-ruby-powered)
- [Rust](../rs#δe2000--accurate-fast-rust-powered)

## Verification

[![Julia CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-jl.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-jl.yml)

<details>
<summary>What is the testing procedure ?</summary>

 1. `gcc -O3 tests/c/stdin-verifier.c -o verifier -lm`
 2. `julia tests/jl/ciede-2000-testing.jl 10000000 | ./verifier > test-output.txt`
</details>

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
 CIEDE2000 Verification Summary :
- Last Verified Line : 53.0,-96.0,-45.0,12.5,-106.0,-26.1,33.361091064492946
- Duration : 83.98 s
- Successes : 10000000
- Errors : 0
- Maximum Difference : 2.2737367544323206e-13
```

### Computational Speed

This function was measured at a speed of 4,137,791 calls per second.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **GCC** : 13.3.0
- **julia** : 1.9.4

## Conclusion

With over 20 years serving developers, this **trusted color comparison** routine developed in Julia brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=53&a1=-96&b1=-45&L2=12.5&a2=-106&b2=-26.1) — [Workflow Details](../../.github/workflows#workflow-details) — [Across 30+ programming languages](../../#implementations)

