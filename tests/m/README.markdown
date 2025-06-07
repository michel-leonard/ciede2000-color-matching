# ΔE2000 — Accurate. Fast. MATLAB-powered.

This reference vectorized ΔE2000 implementation written in MATLAB provides reliable and accurate perceptual **color difference** calculation.

## Source Code

The full source code released on March 1, 2025, is available [here](../../ciede-2000.m#L12) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.m).

## Example usage in MATLAB

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```matlab
% Example usage of the CIEDE2000 function in MATLAB

% L1 = 19.3166        a1 = 73.5           b1 = 122.428
% L2 = 19.0           a2 = 76.2           b2 = 91.372

deltaE = ciede_2000_classic(l1, a1, b1, l2, a2, b2);
disp(deltaE);

% This shows a ΔE2000 of 9.60876174564
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

[![Matlab CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-m.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-m.yml)

<details>
<summary>What is the testing procedure ?</summary>

 1. `cp -p tests/m/ciede-2000-testing.m run_ciede2000_random.m`
 2. `gcc -O3 tests/c/stdin-verifier.c -o verifier -lm`
 3. `octave --quiet --eval "run_ciede2000_random(10000000)" | ./verifier > test-output.txt`

Where the two main files involved are [ciede-2000-testing.m](ciede-2000-testing.m#L4) and [raw-m.yml](../../.github/workflows/raw-m.yml).
</details>

Executed through **GNU Octave**, the test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
CIEDE2000 Verification Summary :
- Last Verified Line : 22.14,38.20,-46.82,16.24,-43.60,30.39,48.881073843641083
- Duration : 185.55 s
- Successes : 10000000
- Errors : 0
- Maximum Difference : 8.8817841970012523e-16
```

### Computational Speed

This function was measured at a speed of 3,022,432 calls per second.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **GCC** : 13.3.0
- **GNU Octave** : 8.4.0

## Conclusion

With over 20 years serving developers, this **trusted color comparison** routine developed in MATLAB brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=22.14&a1=38.2&b1=-46.82&L2=16.24&a2=-43.6&b2=30.39) — [Workflow Details](../../.github/workflows#workflow-details) — [Across 30+ programming languages](../../#implementations)

