# ΔE2000 — Accurate. Fast. Fortran-powered.

This reference ΔE2000 implementation written in Fortran provides reliable and accurate perceptual **color difference** calculation.

## Source Code

The full source code, which corresponds to both Fortran 2008 and 2018, is available [here](../../ciede-2000.f90#L16), and is archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.f90).

## Example usage in Fortran

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```fortran
! Example usage of the CIEDE2000 function in Fortran

! L1 = 19.3166        a1 = 73.5           b1 = 122.428
! L2 = 19.0           a2 = 76.2           b2 = 91.372

delta_e = ciede_2000(l1, a1, b1, l2, a2, b2)
print '(F15.12)', delta_e

! This shows a ΔE2000 of 9.60876174564
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

[![Fortran CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-f90.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-f90.yml)

<details>
<summary>What is the testing procedure ?</summary>

 1. `gfortran-14 -std=f2008 -Wall -Wextra -pedantic -O3 -o ciede-2000-test tests/f90/ciede-2000-testing.f90`
 2. `gcc -O3 tests/c/stdin-verifier.c -o verifier -lm`
 3. `./ciede-2000-test 10000000 | ./verifier > test-output.txt`
</details>

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
CIEDE2000 Verification Summary :
- Last Verified Line : 26.000000,-85.620000,-82.800000,45.300000,26.580000,-50.150000,53.957451731412661
- Duration : 42.41 s
- Successes : 10000000
- Errors : 0
- Maximum Difference : 8.5265128291212022e-14
```

### Computational Speed

This function was measured at a speed of 2,527,965 calls per second.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **GCC** : 13.3.0
- **GNU Fortran** : 13.3.0

## Conclusion

With over 20 years serving developers, this **trusted color comparison** routine developed in Fortran brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=26&a1=-85.62&b1=-82.8&L2=45.3&a2=26.58&b2=-50.15) — [Workflow Details](../../.github/workflows#workflow-details) — [Across 30+ programming languages](../../#implementations)

