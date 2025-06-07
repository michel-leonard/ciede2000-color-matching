# ΔE2000 — Accurate. Fast. PHP-powered.

This reference ΔE2000 implementation written in PHP provides reliable and accurate perceptual **color difference** calculation.

## Source Code

The full source code released on March 1, 2025, is available [here](../../ciede-2000.php#L8) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.php).

## Example usage in PHP

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```php
// Example usage of the CIEDE2000 function in PHP

// L1 = 19.3166        a1 = 73.5           b1 = 122.428
// L2 = 19.0           a2 = 76.2           b2 = 91.372

$deltaE = ciede_2000($l1, $a1, $b1, $l2, $a2, $b2);
echo $deltaE;

// This shows a ΔE2000 of 9.60876174564
```

**Note**: L\* is usually between 0 and 100, a\* and b\* between -128 and +127.

To compare **hexadecimal** (e.g., "#FFF") or **RGB colors** using the CIEDE2000 function, follow these examples :
- [compare-hex-colors.php](compare-hex-colors.php#L177)
- [compare-rgb-colors.php](compare-rgb-colors.php#L177)

## Verification

[![PHP CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-php.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-php.yml)

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

<details>
<summary>What is the testing procedure ?</summary>

 1. `gcc -O3 tests/c/stdin-verifier.c -o verifier -lm`
 2. `php tests/php/ciede-2000-testing.php 10000000 | ./verifier > test-output.txt`

Where the two main files involved are [ciede-2000-testing.php](ciede-2000-testing.php#L116) and [raw-php.yml](../../.github/workflows/raw-php.yml).
</details>

```
CIEDE2000 Verification Summary :
- Last Verified Line : 3.46,126.39,-67.46,25.29,-81.88,122.51,116.17876479257
- Duration : 119.00 s
- Successes : 10000000
- Errors : 0
- Maximum Difference : 5.0022208597511053e-12
```

### Computational Speed

This function was measured at a speed of 2,261,484 calls per second.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **GCC** : 13.3.0
- **PHP** : 8.4.7 with JIT enabled

## Conclusion

With over 20 years serving developers, this **trusted color comparison** routine developed in PHP brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=3.46&a1=126.39&b1=-67.46&L2=25.29&a2=-81.88&b2=122.51) — [Workflow Details](../../.github/workflows#workflow-details) — [Across 30+ programming languages](../../#implementations)

