# ΔE2000 — Accurate. Fast. PowerShell-powered.

ΔE2000 is the best method for accurately quantifying color differences as perceived by the human eye.

This reference implementation in **PowerShell** offers a simple way of calculating these differences accurately within scripts.

## Overview

The developed algorithm enables software to evaluate color similarities (or differences) on Windows with scientific rigor.

As a general rule, navy blue and yellow, which are very different colors, generally have a ΔE<sub>00</sub> of around 115.

Values such as 5 indicate greater closeness, making this both a simple and advanced method of color comparison.

## Implementation Details

The full PowerShell source code, released on March 1, 2025, is available [here](../../ciede-2000.ps1#L6) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.ps1).

## Example usage in PowerShell

The calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done in console using the `ciede_2000` function :

```ps1
# Compute the Delta E (CIEDE2000) color difference between two Lab colors in Microsoft PowerShell

. .\ciede-2000.ps1

$dE = ciede_2000 73.5 122.428 19.0 76.2 91.372
Write-Output $dE

# Outputs: 9.60876174563898
```

**Note** : L\* is nominally between 0 and 100, a\* and b\* generally between -128 and +127.

For color inputs in **hexadecimal** (e.g., `#FFF`) or **RGB** formats, see examples for other languages :

[AWK](../awk#-flexibility), [C](../c#δe2000--accurate-fast-c-powered), [Dart](../dart#δe2000--accurate-fast-dart-powered), [Java](../java#δe2000--accurate-fast-java-powered), [JavaScript](../js#-flexibility), [Kotlin](../kt#δe2000--accurate-fast-kotlin-powered), [Lua](../lua#-flexibility), [PHP](../php#δe2000--accurate-fast-php-powered), [Python](../py#δe2000--accurate-fast-python-powered), [Ruby](../rb#δe2000--accurate-fast-ruby-powered), [Rust](../rs#δe2000--accurate-fast-rust-powered).

<details>
<summary>How to fully process a CSV file ?</summary>
  
To process a CSV file, assume the file `input.csv` contains lines with two L\*a\*b\* colors :

```
75.8,92.832,36.81,8.8,98.12,114.708
24.11,-83.9,9.5,45.132,-57.037,110.297
7.49,101.869,45.326,13,104.64,120.244
```

Then we append the following to the file `ciede-2000.ps1` :

```ps1
if (-not (Test-Path $args[0] -PathType Leaf)) {
	Write-Output "CIEDE2000: Please specify the path of a CSV file containing L*a*b* colors."
	return
}

$culture = [System.Globalization.CultureInfo]::CreateSpecificCulture("en-US")
$culture.NumberFormat.NumberDecimalSeparator = "."
$culture.NumberFormat.NumberGroupSeparator = ""
[System.Threading.Thread]::CurrentThread.CurrentCulture = $culture

Get-Content $args[0] | ForEach-Object {
	$v = $_ -split ','
	$dE = ciede_2000 ([double]$v[0]) ([double]$v[1]) ([double]$v[2]) ([double]$v[3]) ([double]$v[4]) ([double]$v[5])
	Write-Output ("{0},{1}" -f $_.TrimEnd(), $dE)
}
```

And we call `. .\ciede-2000.ps1 input.csv > input-solved.csv` to fill the file `input-solved.csv` with the ΔE2000 color differences :

```
75.8,92.832,36.81,8.8,98.12,114.708,66.1189449398858
24.11,-83.9,9.5,45.132,-57.037,110.297,35.6359956718132
7.49,101.869,45.326,13,104.64,120.244,24.2649165163284
```
</details>

## Verification

[![PowerShell CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-ps1.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-ps1.yml)

<details>
<summary>What is the testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by PowerShell**, like this :

1. `gcc -std=c99 -Wall -pedantic -Ofast -ffast-math -g tests/c/ciede-2000-driver.c -o ciede-2000-driver.exe -lm`
2. `/ciede-2000-driver.exe --generate 1000000 > test-cases.csv`
3. `./tests/ps1/ciede-2000-driver.ps1 test-cases.csv | ./ciede-2000-driver.exe`

Where the main files involved are [ciede-2000-driver.ps](ciede-2000-driver.ps1#L91) for calculations and [test-ps1.yml](../../.github/workflows/test-ps1.yml) for automation.
</details>

This function has been rigorously tested for compliance with the standard, achieving zero errors and negligible floating-point deviations :

```
CIEDE2000 Verification Summary :
  First Verified Line : 22,-120,28,87.18,-87,-33.18,67.02466305752021
             Duration : 1221.15 s
            Successes : 10000000
               Errors : 0
      Average Delta E : 63.0540
    Average Deviation : 4.1e-15
    Maximum Deviation : 1.6e-13
```

## Performance & Environment

- Speed benchmark : 16,385 calls per second
- Tested on Windows Server 2022, GCC 12.2, PowerShell 7.4.10

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in PowerShell** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=22&a1=-120&b1=28&L2=87.18&a2=-87&b2=-33.18) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Suitable in 30+ Languages](../../#implementations)

