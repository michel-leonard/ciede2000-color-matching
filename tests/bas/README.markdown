# ΔE2000 — Accurate. Fast. VBA-powered.

ΔE2000 is the current standard for comparing colors in a way that best matches human perception.

This canonical **VBA** implementation offers a simple and accurate way of calculating these color differences programmatically.

## Overview

The algorithm developed measures color similarity (or difference) with the scientific rigor at the heart of Microsoft Office.

As a general rule, navy blue and yellow, which are very different colors, generally have a ΔE<sub>00</sub> of around 115.

Values such as 5 indicate greater closeness, making this both a simple and advanced method of color comparison.

## Implementation Details

The full source code released on March 1, 2025, is available [here](../../ciede-2000.bas#L9) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.bas).

VB6 can seamlessly integrate this classic **.NET** source code.

## Example usage in VBA

A typical **Delta E 2000** computation between two colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```vba
' Compute the Delta E (CIEDE2000) color difference between two Lab colors in VBA

' L1 = 19.3166        a1 = 73.5           b1 = 122.428
' L2 = 19.0           a2 = 76.2           b2 = 91.372

Dim deltaE As Double
deltaE = ciede_2000(l1, a1, b1, l2, a2, b2)
Debug.Print deltaE

' This shows a ΔE2000 of 9.60876174564
```

**Note** : L\* usually ranges from 0 to 100, while a\* and b\* typically range from –128 to +127.

For color inputs in **hexadecimal** (e.g., `#FFF`) or **RGB** formats, see examples for other languages :

[AWK](../awk#-flexibility), [C](../c#δe2000--accurate-fast-c-powered), [Dart](../dart#δe2000--accurate-fast-dart-powered), [Java](../java#δe2000--accurate-fast-java-powered), [JavaScript](../js#-flexibility), [Kotlin](../kt#δe2000--accurate-fast-kotlin-powered), [Lua](../lua#-flexibility), [PHP](../php#δe2000--accurate-fast-php-powered), [Python](../py#δe2000--accurate-fast-python-powered), [Ruby](../rb#δe2000--accurate-fast-ruby-powered), [Rust](../rs#δe2000--accurate-fast-rust-powered).

## Verification

[![VBA CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-bas.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-bas.yml)

<details>
<summary>What is the testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by VBA**, like this :

1.
```sh
params="-q -T5 -t1"
########################################################################################
####  STEP 1:                          Install Dependencies                         ####
########################################################################################
wget $params http://archive.ubuntu.com/ubuntu/pool/universe/n/ncurses/libtinfo5_6.3-2ubuntu0.1_amd64.deb    -O X.deb ||
wget $params http://security.ubuntu.com/ubuntu/pool/universe/n/ncurses/libtinfo5_6.3-2ubuntu0.1_amd64.deb   -O X.deb
sudo apt-get update
sudo apt-get install ./X.deb
########################################################################################
####  STEP 2:                     Download & Extract FreeBASIC                      ####
########################################################################################
wget $params https://users.freebasic-portal.de/freebasicru/user-files/FreeBASIC-1.10.0-linux-x86_64.tar.gz  -O X.tar.gz ||
wget $params https://local.doublebyte.ru/static/FreeBASIC-1.10.1-linux-x86_64.tar.gz                        -O X.tar.gz ||
wget $params http://downloads.sourceforge.net/fbc/FreeBASIC-1.10.1-linux-x86_64.tar.gz?download             -O X.tar.gz ||
wget $params https://github.com/engineer-man/piston/releases/download/pkgs/freebasic-1.9.0.pkg.tar.gz       -O X.tar.gz
tar -xf X.tar.gz
########################################################################################
####  STEP 3:                     Add FreeBASIC to System PATH                      ####
########################################################################################
fbc_dir=$(ls -1d Free* 2>/dev/null | head -n 1)
ln -s $PWD/$fbc_dir/bin/fbc /usr/local/bin/fbc
########################################################################################
####  CONCLUSION:               FreeBASIC Installed in Under 15s                    ####
########################################################################################
rm X* && printf '\n\n\n\n' && fbc --version
```
2. `cp -p tests/bas/ciede-2000-driver.bas ciede-2000-tests.bas`
3. `fbc -O 2 ciede-2000-tests.bas`
4. `gcc -std=c99 -Wall -pedantic -Ofast -ffast-math -g tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
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

### Speed Benchmark

This function was measured at a speed of 6,595,813 calls per second.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **FreeBASIC Compiler** : 1.10.1
- **GCC** : 13.3

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in VBA** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=31.8&a1=56.39&b1=27.1&L2=61&a2=85&b2=111.57) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Suitable in 30+ Languages](../../#implementations)
