# ΔE2000 — Accurate. Fast. AWK-powered.

ΔE2000 is the modern standard for quantifying perceptual differences between colors with high accuracy.

This canonical **AWK** implementation offers an easy way to calculate these differences accurately and programmatically.

## Overview

The developed algorithm allows software to measure color similarity and difference with scientific rigor.

For reference, two very distinct colors typically have a ΔE2000 value greater than 12.

Lower values indicate greater similarity between colors, making ΔE2000 a **state-of-the-art method** for perceptual color comparison.

## Implementation Details

The full source code released on March 1, 2025, is available [here](../../ciede-2000.awk#L20) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.awk).

This AWK script can be used in shell environments such as **Bash** on Linux and macOS.

## Example usage in AWK

Each line in `samples.csv` contains two colors in L\*a\*b\* format (L\*, a\*, b\*), separated by commas: :
```txt
47.3,33.0,73.0,47.3,29.2,73.0
69.122,120.821,85.9,74.0,125.7,85.9
58.0,-101.1,-81.4,57.0,-65.44,-84.729
```

The command to calculate the **Delta E 2000** color difference :
```sh
awk -f ciede-2000.awk < samples.csv
```

The result on standard output :
```txt
47.3,33.0,73.0,47.3,29.2,73.0,2.07402875906584
69.122,120.821,85.9,74.0,125.7,85.9,3.88062401552627
58.0,-101.1,-81.4,57.0,-65.44,-84.729,8.44139030696944
```

**Note**: L\* is usually between 0 and 100, a\* and b\* between -128 and +127.

### 🎨 Flexibility

This [all-in-one](compare-rgb-hex-colors.awk#L4) AWK script accepts RGB and hexadecimal color formats to calculate ΔE2000 **color differences**.

<details>
 <summary>Show example !</summary>

The  `samples.csv` file contains colors to be processed :
```text
238,170,17,170,17,238
238,170,17,#a1e
238,170,17,#aa11ee
#ea1,170,17,238
#eeaa11,170,17,238
#ea1,#a1e
#ea1,#AA11EE
#eeaa11,#a1e
#eeaa11,#aa11ee
```

The command to calculate the **Delta E 2000** color difference :
```sh
awk -f ciede-2000-rgb-hex.awk < samples.csv
```

The result on standard output :
```text
238,170,17,170,17,238,72.4646795182437
238,170,17,#a1e,72.4646795182437
238,170,17,#aa11ee,72.4646795182437
#ea1,170,17,238,72.4646795182437
#eeaa11,170,17,238,72.4646795182437
#ea1,#a1e,72.4646795182437
#ea1,#AA11EE,72.4646795182437
#eeaa11,#a1e,72.4646795182437
#eeaa11,#aa11ee,72.4646795182437
```
</details>

<details>
<summary>Want to make the AWK script directly executable ?</summary>

1. Add a shebang `#!/usr/bin/awk -f` or `#!/usr/bin/env awk -f` at the top of your `ciede-2000.awk` file.
2. Make it executable using `chmod 755 ciede-2000.awk`.
3. Move it to a folder in your `$PATH` using `mv ciede-2000.awk /usr/local/bin/ciede_2000`.

Now you can run `ciede_2000 < samples.csv` as in the [test workflow](../../.github/workflows/test-awk.yml#L20), just like a native command !
</details>

### Precision of Results

Output precision can be customized by modifying the `printf` format string — e.g., change `%.17g` to `%.2f` for two decimal places.

## Verification

[![AWK CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-awk.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-awk.yml)

<details>
<summary>What is the testing procedure ?</summary>

 The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates random color pairs, and checks the Delta E 2000 color differences produced in AWK, like this :
1. `gcc -std=c99 -Wall -pedantic -Ofast -ffast-math -g tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
2. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
3. `awk -f ciede-2000.awk < test-cases.csv | ./ciede-2000-driver`

Where the main files involved are [ciede-2000.awk](../../ciede-2000.awk#L-16) for calculations and [test-awk.yml](../../.github/workflows/test-awk.yml) for automation.
</details>

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
CIEDE2000 Verification Summary :
  First Verified Line : 69.47,-24,-36,20,-36.8,-94.1,48.6133314128157
             Duration : 56.73 s
            Successes : 10000000
               Errors : 0
      Average Delta E : 62.9396
    Average Deviation : 4.5856684738332374e-14
    Maximum Deviation : 5.6843418860808015e-13
```

### Speed Benchmark

This function was measured at a speed of 228,571 calls per second.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **GCC** : 13.3.0
- **AWK** : 5.2.1
  - API : 3.2
  - GNU MPFR : 4.2.1
  - GNU MP : 6.3.0

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **written in AWK** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=19.16&a1=-80&b1=-31&L2=36&a2=75&b2=-66.72) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Used in 30+ Languages](../../#implementations)

