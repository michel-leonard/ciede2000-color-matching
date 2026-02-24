# ΔE2000 — Accurate. Fast. R-powered.

This reference vectorized implementation of ΔE2000 written in **R** enables reliable and precise calculation of color differences.

## Overview

The developed algorithm enables software to evaluate color similarities (or differences) with scientific rigor.

As a general rule, 🔵 navy blue and 🟡 yellow, which are very different colors, have a ΔE\*<sub>00</sub> of around 115.

Values [such as 5](https://michel-leonard.github.io/ciede2000-color-matching/de2000-rgb-pairs.html?seq=50&delta-e=5) indicate greater closeness, making this both a simple and advanced method of color comparison.

## Implementation Details

The full source code released on March 1, 2025, is available [here](../../ciede-2000.r#L12) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.r).

<details>
<summary>What two options are available for matching ΔE2000 calculations with existing calculations ?</summary>

#### Option 1 (default)
 This often-used option consists of a coding simplification that is a historical legacy of early implementations :
```r
h_m[mask] <- h_m[mask] + pi;
# h_m[mask] <- h_m[mask] + ifelse(h_m[mask] < pi, pi, -pi);
```

#### Option 2 (compatible with Gaurav Sharma’s precise calculations)
There’s no room for ambiguity, this inversion of the commented line in the source code ensures compliance with the official :
```r
# h_m[mask] <- h_m[mask] + pi;
h_m[mask] <- h_m[mask] + ifelse(h_m[mask] < pi, pi, -pi);
```

**Note** : the difference between the two options is minimal (±0.0003 on the calculated color difference) and usually overlooked.
</details>

## Example usage in R

A basic **Delta E 2000** calculation between 2 colors in the **L\*a\*b\* color space** can be performed with  the `ciede_2000_classic` function :

```r
# Define the L*a*b* components for two colors
l1 <- 64.1; a1 <- 51.6; b1 <- 2.1
l2 <- 64.9; a2 <- 57.8; b2 <- -2.3

# Compute Delta E 2000 difference
delta_e <- ciede_2000_classic(l1, a1, b1, l2, a2, b2)
print(delta_e)

# .................................................. This shows a ΔE2000 of 2.8449009301
# As explained in the comments, compliance with Gaurav Sharma would display 2.8448877859
```

**Note** : L\* is nominally between 0 and 100, a\* and b\* generally between -128 and +127.

For color inputs in **hexadecimal** (e.g., `#FFF`) or **RGB** formats, see examples for other languages :

[AWK](../awk#-flexibility), [C](../c#δe2000--accurate-fast-c-powered), [Dart](../dart#δe2000--accurate-fast-dart-powered), [Java](../java#δe2000--accurate-fast-java-powered), [JavaScript](../js#-flexibility), [Kotlin](../kt#δe2000--accurate-fast-kotlin-powered), [Lua](../lua#-flexibility), [PHP](../php#δe2000--accurate-fast-php-powered), [Python](../py#δe2000--accurate-fast-python-powered), [Ruby](../rb#δe2000--accurate-fast-ruby-powered), [Rust](../rs#δe2000--accurate-fast-rust-powered).

## Verification

[![R CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-r.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-r.yml)

<details>
<summary>What is the testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by R**, like this :

1.

```sh
command -v Rscript > /dev/null || {
  command -v dirmngr > /dev/null && command -v apt-add-repository > /dev/null ||
  { sudo apt-get update && sudo apt-get install --no-install-recommends software-properties-common dirmngr ; }
  . /etc/os-release && wget --quiet --no-check-certificate --timeout=5 --tries=2 https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc -O- |
  sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/cran.gpg
  echo "deb [signed-by=/etc/apt/trusted.gpg.d/cran.gpg] \
  https://cloud.r-project.org/bin/linux/ubuntu ${VERSION_CODENAME}-cran40/" |
  sudo tee /etc/apt/sources.list.d/cran.list
  sudo apt-get update && sudo apt-get install r-base
}
```

2. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install gcc ; }`
3. `gcc -std=c99 -Wall -pedantic -O2 -g tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
4. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
5. `Rscript tests/r/ciede-2000-driver.r test-cases.csv | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.r](ciede-2000-driver.r#L87) for calculations and [test-r.yml](../../.github/workflows/test-r.yml) for automation.
</details>

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
 CIEDE2000 Verification Summary :
  First Verified Line : 21.6,57.07,52.05,71.79,-57.38,106,80.753645227437261
             Duration : 144.46 s
            Successes : 10000000
               Errors : 0
      Average Delta E : 62.9342
    Average Deviation : 4.0356553931975016e-15
    Maximum Deviation : 1.1368683772161603e-13
```

### Comparison with the CRAN shades Library

[![ΔE2000 against shades in R](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-shades.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-shades.yml)

The implementation is compared with that provided by the `shades` package, which is available on CRAN (The Comprehensive R Archive Network). The test worlflow looks for deviations in the ΔE2000 calculated in a vectorized way for about three minutes, then displays :

```
The largest deviation measured after 100000000 calculations is 1.705303e-13 so this test is PASSED.
```

This shows that this R implementation of the CIEDE2000 function is consistent with that of a well-maintained library.

> [!IMPORTANT]
> To correct this R source code to exact match certain third-party ΔE2000 functions, follow the comments in the source code.

> This formula, "small" in size, is an essential pillar of color management, deserving of this rigorous, tested and reliable industrial treatment.

### Performance

This function was measured at a speed of 1,956,947 calls per second.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **R** : 4.5.0
- **GCC** : 13.3

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in R** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=62.1&a1=56.5&b1=-36.7&L2=73.3&a2=12.2&b2=8) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Suitable in 40+ Languages](../../#implementations)
