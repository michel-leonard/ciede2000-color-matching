# ΔE2000 — Accurate. Fast. AWK-powered.

ΔE2000 is the modern standard for quantifying color differences with high accuracy.

This reference **AWK** implementation offers a classic way of calculating these differences reliably within scripts.

## Overview

The algorithm developed measures color similarity (or difference) with high portability and scientific rigor.

As a general rule, 🔵 navy blue and 🟡 yellow, which are very different colors, have a ΔE\*<sub>00</sub> of around 115.

Values [such as 5](https://michel-leonard.github.io/ciede2000-color-matching/de2000-rgb-pairs.html?seq=50&delta-e=5) indicate greater closeness, making this both a simple and advanced method of color comparison.

## Implementation Details

The full source code released on March 1, 2025, is available [here](../../ciede-2000.awk#L20) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.awk).

This AWK script can be used in shell environments such as **Bash** on Linux and macOS.

<details>
<summary>What two options are available for matching ΔE2000 calculations with existing calculations ?</summary>

#### Option 1 (default)
 This often-used option consists of a coding simplification that is a historical legacy of early implementations :
```awk
h_m += M_PI
# h_m += ((h_m < M_PI) - (M_PI <= h_m)) * M_PI
```

#### Option 2 (compatible with Gaurav Sharma’s precise calculations)
There’s no room for ambiguity, this inversion of the commented line in the source code ensures compliance with the official :
```awk
# h_m += M_PI
h_m += ((h_m < M_PI) - (M_PI <= h_m)) * M_PI
```

**Note** : the difference between the two options is minimal (±0.0003 on the calculated color difference) and usually overlooked.
</details>

## Example usage in AWK

Each line in `samples.csv` contains two colors in L\*a\*b\* format (L\*, a\*, b\*), separated by commas :

```txt
94.4,28.8,2.0,95.4,34.6,-2.3
83.3,26.7,-3.4,81.9,32.6,5.1
44.4,18.6,-3.5,42.7,23.0,5.1
```

The command to calculate the **Delta E 2000** color difference :

```sh
awk -f ciede-2000.awk < samples.csv
```

The result on standard output :

```txt
94.4,28.8,2.0,95.4,34.6,-2.3,3.60377935046666
83.3,26.7,-3.4,81.9,32.6,5.1,5.87778763807824
44.4,18.6,-3.5,42.7,23.0,5.1,6.35778281622944
```

As explained in the comments, compliance with Gaurav Sharma would display :

```txt
94.4,28.8,2.0,95.4,34.6,-2.3,3.60376335698225
83.3,26.7,-3.4,81.9,32.6,5.1,5.87780485815695
44.4,18.6,-3.5,42.7,23.0,5.1,6.3577972039558
```

**Note** : L\* is nominally between 0 and 100, a\* and b\* usually between -128 and +127.

### 🎨 Flexibility

This [all-in-one](compare-rgb-hex-colors.awk) AWK script accepts RGB and hexadecimal color formats to calculate ΔE2000 **color differences**.

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
1. `gcc -std=c99 -Wall -pedantic -O2 -g tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
2. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
3. `awk -f ciede-2000.awk < test-cases.csv | ./ciede-2000-driver`

Where the main files involved are [ciede-2000.awk](../../ciede-2000.awk#L20) for calculations and [test-awk.yml](../../.github/workflows/test-awk.yml) for automation.
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

> [!IMPORTANT]
> To correct this AWK source code to exact match certain third-party ΔE2000 functions, follow the comments in the source code.

> This formula, "small" in size, is an essential pillar of color management, deserving of this rigorous, tested and reliable industrial treatment.

### Speed Benchmark

This function was measured at a speed of 228,571 calls per second.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **GCC** : 13.3
- **AWK** : 5.2.1
  - API : 3.2
  - GNU MPFR : 4.2.1
  - GNU MP : 6.3.0

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in AWK** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=59.5&a1=12.6&b1=9&L2=49.2&a2=43.7&b2=-30.9) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Suitable in 40+ Languages](../../#implementations)
