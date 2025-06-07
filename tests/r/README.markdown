# ΔE2000 — Accurate. Fast. R-powered.

This reference vectorized ΔE2000 implementation written in R provides reliable and accurate perceptual **color difference** calculation.

## Source Code

The full source code released on March 1, 2025, is available [here](../../ciede-2000.r#L12) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.r).

## Example usage in R

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```r
# Example usage of the CIEDE2000 function in R

# L1 = 19.3166        a1 = 73.5           b1 = 122.428
# L2 = 19.0           a2 = 76.2           b2 = 91.372

delta_e <- ciede_2000_classic(l1, a1, b1, l2, a2, b2)
print(delta_e)

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

[![R CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-r.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-r.yml)

<details>
<summary>What is the testing procedure ?</summary>

 1. `Rscript -e "install.packages('renv', repos='https://cran.r-project.org')"`
 2. `Rscript -e "if (file.exists('renv.lock')) renv::restore()"`
 3. `gcc -O3 tests/c/stdin-verifier.c -o verifier -lm`
 4. `Rscript tests/r/ciede-2000-testing.r 10000000 | ./verifier > test-output.txt`

Where the two main files involved are [ciede-2000-testing.r](ciede-2000-testing.r#L120) and [raw-r.yml](../../.github/workflows/raw-r.yml).
</details>

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
CIEDE2000 Verification Summary :
- Last Verified Line : 6.0,-102.0,105.0,88.2,-123.0,50.0,81.650329714203579
- Duration : 115.89 s
- Successes : 10000000
- Errors : 0
- Maximum Difference : 9.9475983006414026e-14
```

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **R** : 4.5.0
- **GCC** : 13.3.0

## Conclusion

With over 20 years serving developers, this **trusted color comparison** routine developed in R brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=6&a1=-102&b1=105&L2=88.2&a2=-123&b2=50) — [Workflow Details](../../.github/workflows#workflow-details) — [Across 30+ programming languages](../../#implementations)

