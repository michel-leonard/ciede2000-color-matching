# ΔE2000 — Accurate. Fast. PHP-powered.

ΔE2000 is the current standard algorithm that industries use to quantify color differences in a way that best aligns with human vision.

This reference **PHP** implementation is used to evaluate these distances between colors in my favorite programming language.

## Overview

The developed algorithm enables software to measure color similarities (or differences) with scientific rigor.

As a general rule, 🔵 navy blue and 🟡 yellow, which are very different colors, have a ΔE\*<sub>00</sub> of around 115.

Values [such as 5](https://michel-leonard.github.io/ciede2000-color-matching/de2000-rgb-pairs.html?seq=50&delta-e=5) indicate greater closeness, making this both a simple and advanced method of color comparison.

## Implementation Details

The complete source code of this PHP implementation, as released on March 1, 2025, can be viewed [here](../../ciede-2000.php#L8) and is archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.php).

<details>
<summary>What two options are available for matching ΔE2000 calculations with existing calculations ?</summary>

#### Option 1 (default)
 This often-used option consists of a coding simplification that is a historical legacy of early implementations :
```php
$h_m += M_PI;
// $h_m += $h_m < M_PI ? M_PI : -M_PI;
```

#### Option 2 (compatible with Gaurav Sharma’s precise calculations)
There’s no room for ambiguity, this inversion of the commented line in the source code ensures compliance with the official :
```php
// $h_m += M_PI;
$h_m += $h_m < M_PI ? M_PI : -M_PI;
```

**Note** : the difference between the two options is minimal (±0.0003 on the calculated color difference) and usually overlooked.
</details>

## Example usage in PHP

A standard **Delta E 2000** computation between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```php
// Define color 1 in L*a*b* space
$l1 = 57.0;
$a1 = 17.0;
$b1 = -3.6;

// Define color 2 in L*a*b* space
$l2 = 56.6;
$a2 = 21.0;
$b2 = 4.6;

// Calculate the ΔE*00 color difference
$deltaE = ciede_2000($l1, $a1, $b1, $l2, $a2, $b2);
echo $deltaE;

// .................................................. This shows a ΔE2000 of 5.9908949846
// As explained in the comments, compliance with Gaurav Sharma would display 5.9909105284
```

**Note** : L\* is nominally between 0 and 100, a\* and b\* generally between -128 and +127.

To compare **hexadecimal** (e.g., "#FFF") or **RGB colors** using the CIEDE2000 function, follow these examples :
- [compare-hex-colors.php](compare-hex-colors.php#L188)
- [compare-rgb-colors.php](compare-rgb-colors.php#L188)

## Verification

[![PHP CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-php.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-php.yml)

<details>
<summary>What is the testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by PHP**, like this :

1. `command -v php > /dev/null || { sudo apt-get update && sudo apt-get install php-cli ; }`
2. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install gcc ; }`
3. `gcc -std=c99 -Wall -pedantic -O2 -g tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
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
6. `php -n -c custom-php.ini tests/php/ciede-2000-driver.php test-cases.csv | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.php](ciede-2000-driver.php#L89) for calculations and [test-php.yml](../../.github/workflows/test-php.yml) for automation.
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

### Comparison with the color-difference calculations

[![ΔE2000 against color-difference in PHP](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-php-color-difference.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-php-color-difference.yml)

Compared to **renasboy/php-color-difference** — this implementation of the ΔE2000 color difference formula, verified over 100 million color pair comparisons, exhibits a deviation of no more than **5 × 10<sup>-13</sup>**. This confirms that the `ciede_2000` function is suitable for general use in PHP.

### Comparison with the color Library

[![ΔE2000 against color in PHP](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-php-color.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-php-color.yml)

Compared to the PHP **spatie/color** implementation — first released in 2016 — this implementation of the ΔE2000 color difference formula, verified over 100 million color pair comparisons, exhibits an absolute deviation of no more than **5 × 10<sup>-13</sup>**. This confirms, in the same way as for the [C99](../c#comparison-with-the-vmaf-c99-library), [Java](../java#comparison-with-the-openimaj), [JavaScript](../js#comparison-with-the-npmchroma-js-library), [Python](../py#comparison-with-the-python-colormath-library) and [Rust](../rs#comparison-with-the-palette-library) versions, the interoperability and production-ready status of the `ciede_2000` function in PHP.

> [!IMPORTANT]
> To correct this PHP source code to exact match certain third-party ΔE2000 functions, follow the comments in the source code.

> This formula, "small" in size, is an essential pillar of color management, deserving of this rigorous, tested and reliable industrial treatment.

### Speed Benchmark

The `ciede_2000` function was benchmarked to perform **2,261,484 calls per second**.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **GCC** : 13.3
- **PHP** : 8.4 with JIT enabled

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in PHP** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=41.1&a1=11.2&b1=-6&L2=37.3&a2=53.9&b2=29.3) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Suitable in 40+ Languages](../../#implementations)
