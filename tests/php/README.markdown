# ΔE2000 — Accurate. Fast. PHP-powered.

ΔE2000 is the current industry standard algorithm to quantify color differences in a way that aligns closely with human perception.

This canonical **PHP** implementation provides a reliable and efficient way to compute ΔE2000 color differences programmatically.

## Overview

The developed algorithm enables your software to measure color similarity and difference with scientific rigor.

As a guideline, two colors with a ΔE\*00 value above 12 are typically perceived as very different by the human eye.

Lower values indicate greater closeness, making it a **state-of-the-art method** for comparing colors.

## Implementation Details

The complete source code of this PHP implementation, as released on March 1, 2025, can be viewed [here](../../ciede-2000.php#L8) and is archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.php).

## Example usage in PHP

A standard **Delta E 2000** computation between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```php
// Define color 1 in L*a*b* space
$l1 = 19.3166;
$a1 = 73.5;
$b1 = 122.428;

// Define color 2 in L*a*b* space
$l2 = 19.0;
$a2 = 76.2;
$b2 = 91.372;

// Calculate the ΔE*00 color difference
$deltaE = ciede_2000($l1, $a1, $b1, $l2, $a2, $b2);
echo $deltaE;  // Outputs: 9.60876174564
```

**Note**: L\* is usually between 0 and 100, a\* and b\* between -128 and +127.

To compare **hexadecimal** (e.g., "#FFF") or **RGB colors** using the CIEDE2000 function, follow these examples :
- [compare-hex-colors.php](compare-hex-colors.php#L177)
- [compare-rgb-colors.php](compare-rgb-colors.php#L177)

## Verification

[![PHP CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-php.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-php.yml)

<details>
<summary>What is the testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by PHP**, like this :

1. `command -v php > /dev/null || { sudo apt-get update && sudo apt-get install php-cli ; }`
2. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install gcc ; }`
3. `gcc -std=c99 -Wall -pedantic -Ofast -ffast-math -g tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
4. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
5.
```sh
# This custom-php.ini ensures PHP runs in an optimized configuration suitable computational tasks.
printf "%s\n" \
"zend_extension=opcache.so" \
"opcache.enable=1" \
"opcache.enable_cli=1" \
"opcache.jit=1235" \
"opcache.jit_buffer_size=32M" \
"memory_limit=64M" > custom-php.ini
```
6. `php -c custom-php.ini tests/php/ciede-2000-driver.php test-cases.csv | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.php](ciede-2000-driver.php#L85) for calculations and [test-php.yml](../../.github/workflows/test-php.yml) for automation.
</details>

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :
```
CIEDE2000 Verification Summary :
  First Verified Line : 34,30,-17,69.8,60,-33,36.861058302008
             Duration : 48.97 s
            Successes : 10000000
               Errors : 0
      Average Delta E : 62.9515
    Average Deviation : 4.5546872117219198e-13
    Maximum Deviation : 5.0590642786119133e-12
```

### Speed Benchmark

The `ciede_2000` function was benchmarked to perform **2,261,484 calls per second**.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **GCC** : 13.3.0
- **PHP** : 8.4.7 with JIT enabled

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in PHP** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=3.46&a1=126.39&b1=-67.46&L2=25.29&a2=-81.88&b2=122.51) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Used in 30+ Languages](../../#implementations)

