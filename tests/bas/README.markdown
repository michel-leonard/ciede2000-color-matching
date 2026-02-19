# ΔE2000 — Accurate. Fast. VBA-powered.

ΔE2000 is the current standard for comparing colors in a way that best matches human perception.

This reference **VBA** implementation offers a simple and accurate way of calculating these color differences programmatically.

## Overview

The algorithm developed measures color similarity (or difference) with the scientific rigor at the heart of Microsoft Office.

As a general rule, 🔵 navy blue and 🟡 yellow, which are very different colors, have a ΔE\*<sub>00</sub> of around 115.

Values [such as 5](https://michel-leonard.github.io/ciede2000-color-matching/de2000-rgb-pairs.html?seq=50&delta-e=5) indicate greater closeness, making this both a simple and advanced method of color comparison.

## Implementation Details

The full source code released on March 1, 2025, is available [here](../../ciede-2000.bas#L9) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.bas).

VB6 can seamlessly integrate this classic **.NET** source code.

<details>
<summary>What two options are available for matching ΔE2000 calculations with existing calculations ?</summary>

#### Option 1 (default)
 This often-used option consists of a coding simplification that is a historical legacy of early implementations :
```vba
h_m = h_m + M_PI
' If h_m < M_PI Then h_m = h_m + M_PI Else h_m = h_m - M_PI
```

#### Option 2 (compatible with Gaurav Sharma’s precise calculations)
There’s no room for ambiguity, this inversion of the commented line in the source code ensures compliance with the official :
```vba
' h_m = h_m + M_PI
If h_m < M_PI Then h_m = h_m + M_PI Else h_m = h_m - M_PI
```

**Note** : the difference between the two options is minimal (±0.0003 on the calculated color difference) and usually overlooked.
</details>

## Example usage in VBA

A typical **Delta E 2000** computation between two colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```vba
' Compute the Delta E (CIEDE2000) color difference between two L*a*b* colors in VBA

' Color 1: L1 = 96.4   a1 = 45.4   b1 = -3.0
' Color 2: L2 = 95.9   a2 = 50.4   b2 = 3.7

Dim deltaE As Double
deltaE = ciede_2000(l1, a1, b1, l2, a2, b2)
Debug.Print deltaE

' .................................................. This shows a ΔE2000 of 3.7852068385
' As explained in the comments, compliance with Gaurav Sharma would display 3.7852203702
```

**Note** : L\* usually ranges from 0 to 100, while a\* and b\* typically range from –128 to +127.

For color inputs in **hexadecimal** (e.g., `#FFF`) or **RGB** formats, see examples for other languages :

[AWK](../awk#-flexibility), [C](../c#δe2000--accurate-fast-c-powered), [Dart](../dart#δe2000--accurate-fast-dart-powered), [Java](../java#δe2000--accurate-fast-java-powered), [JavaScript](../js#-flexibility), [Kotlin](../kt#δe2000--accurate-fast-kotlin-powered), [Lua](../lua#-flexibility), [PHP](../php#δe2000--accurate-fast-php-powered), [Python](../py#δe2000--accurate-fast-python-powered), [Ruby](../rb#δe2000--accurate-fast-ruby-powered), [Rust](../rs#δe2000--accurate-fast-rust-powered).

### Support Questions

<details>
<summary>How do I run ΔE2000 as a user function in Microsoft Excel ?</summary>

1. Open Excel on an empty spreadsheet.
2. Press `Alt + F11` to open the VBA editor.
3. Navigate, via the top menu, to `Insert` and then `Module`.
4. Paste the VBA source code for function `ciede_2000` (take a look at the comments).
5. Press `CTRL + S` to save.

Installation complete !

6. Copy `1	2	3	4	5	6` in the top left-hand corner of your spreadsheet.
7. Calculate the ΔE<sub>00</sub> between these two colors in **L\*a\*b\* format** using your new function : `=@ciede_2000(A1;B1;C1;D1;E1;F1)`.

Excel will automatically use the `ciede_2000` function to evaluate the color difference and display the result : `4.493496891760024`.
</details>

## Verification

[![VBA CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-bas.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-bas.yml)

<details>
<summary>What is the testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by VBA**, like this :

1.
```sh
params="--no-verbose --no-check-certificate --timeout=5 --tries=1"
dep_uri="ubuntu/pool/universe/n/ncurses/libtinfo5_6.3-2ubuntu0.1_amd64.deb"
########################################################################################
####  STEP 1:                          Install Dependencies                         ####
########################################################################################
wget $params http://archive.ubuntu.com/$dep_uri                                    -O X.deb ||
wget $params http://security.ubuntu.com/$dep_uri                                   -O X.deb ||
wget $params http://ftp.lip6.fr/pub/linux/distributions/Ubuntu/archive/$dep_uri    -O X.deb
sudo apt-get update && sudo apt-get install ./X.deb
########################################################################################
####  STEP 2:                     Download & Extract FreeBASIC                      ####
########################################################################################
wget $params https://users.freebasic-portal.de/freebasicru/user-files/FreeBASIC-1.10.0-linux-x86_64.tar.gz  -O X.tar.gz ||
wget $params https://local.doublebyte.ru/static/FreeBASIC-1.10.1-linux-x86_64.tar.gz                        -O X.tar.gz ||
wget $params http://downloads.sourceforge.net/fbc/FreeBASIC-1.10.1-linux-x86_64.tar.gz?download             -O X.tar.gz ||
wget $params https://github.com/engineer-man/piston/releases/download/pkgs/freebasic-1.9.0.pkg.tar.gz       -O X.tar.gz ||
wget $params http://mirror.motherhamster.org/dependencies/FreeBASIC-1.08.1-linux-x86_64.tar.gz              -O X.tar.gz
sudo rm -rf /opt/FreeBASIC && mkdir /opt/FreeBASIC
tar -xzf X.tar.gz --strip-components=1 -C /opt/FreeBASIC
########################################################################################
####  STEP 3:                     Add FreeBASIC to System PATH                      ####
########################################################################################
sudo ln --backup --symbolic --verbose /opt/FreeBASIC/bin/fbc /usr/local/bin/fbc
########################################################################################
####  CONCLUSION:               FreeBASIC Installed in Under 15s                    ####
########################################################################################
sudo rm -rf X* && printf '...\n...\n...\n' && fbc --version
```
2. `cp -p tests/bas/ciede-2000-driver.bas ciede-2000-tests.bas`
3. `fbc -O 2 ciede-2000-tests.bas`
4. `gcc -std=c99 -Wall -pedantic -O2 -g tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
5. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
6. `./ciede-2000-tests test-cases.csv | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.bas](ciede-2000-driver.bas#L99) for calculations and [test-bas.yml](../../.github/workflows/test-bas.yml) for automation.
</details>

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
CIEDE2000 Verification Summary :
  First Verified Line : 31.8,56.39,27.1,61,85,111.57,37.83481076432601
             Duration : 43.31 s
            Successes : 10000000
               Errors : 0
      Average Delta E : 62.9544
    Average Deviation : 8.8259009656255217e-15
    Maximum Deviation : 2.9842794901924208e-13
```

### Comparison with My FreeBasic Framework

[![ΔE2000 against My FreeBasic Framework in VBA](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-my-freebasic-framework.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-my-freebasic-framework.yml)

Compared to **My FreeBasic Framework** — this implementation of the ΔE2000 color difference formula, verified over 100 million color pair comparisons, exhibits a deviation of no more than **5 × 10<sup>-13</sup>**. This confirms that the `ciede_2000` function is suitable for general use in VBA.

> [!IMPORTANT]
> To correct this VBA source code to exact match certain third-party ΔE2000 functions, follow the comments in the source code.

> This formula, "small" in size, is an essential pillar of color management, deserving of this rigorous, tested and reliable industrial treatment.

### Speed Benchmark

This function was measured at a speed of 6,595,813 calls per second.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **FreeBASIC Compiler** : 1.10.1
- **GCC** : 13.3

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in VBA** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=72.7&a1=9.4&b1=8.7&L2=60.2&a2=48&b2=-42.7) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Suitable in 40+ Languages](../../#implementations)
