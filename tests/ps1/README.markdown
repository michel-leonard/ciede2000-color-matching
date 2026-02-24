# ΔE2000 — Accurate. Fast. PowerShell-powered.

ΔE2000 is the best method for accurately quantifying color differences as perceived by the human eye.

This reference implementation in **PowerShell** offers a simple way of calculating these differences accurately within scripts.

## Overview

The developed algorithm enables software to evaluate color similarities (or differences) on Windows with scientific rigor.

As a general rule, 🔵 navy blue and 🟡 yellow, which are very different colors, have a ΔE\*<sub>00</sub> of around 115.

Values [such as 5](https://michel-leonard.github.io/ciede2000-color-matching/de2000-rgb-pairs.html?seq=50&delta-e=5) indicate greater closeness, making this both a simple and advanced method of color comparison.

## Implementation Details

The full PowerShell source code, released on March 1, 2025, is available [here](../../ciede-2000.ps1#L6) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.ps1).

<details>
<summary>What two options are available for matching ΔE2000 calculations with existing calculations ?</summary>

#### Option 1 (default)
 This often-used option consists of a coding simplification that is a historical legacy of early implementations :
```ps1
$h_m += [math]::PI;
# $h_m += if ($h_m -lt [Math]::PI) { [Math]::PI } else { -[Math]::PI }
```

#### Option 2 (compatible with Gaurav Sharma’s precise calculations)
There’s no room for ambiguity, this inversion of the commented line in the source code ensures compliance with the official :
```ps1
# $h_m += [math]::PI;
$h_m += if ($h_m -lt [Math]::PI) { [Math]::PI } else { -[Math]::PI }
```

**Note** : the difference between the two options is minimal (±0.0003 on the calculated color difference) and usually overlooked.
</details>

## Example usage in PowerShell

The calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done in console using the `ciede_2000` function :

```ps1
# Compute the Delta E (CIEDE2000) color difference between two L*a*b* colors in Microsoft PowerShell

. .\ciede-2000.ps1

$dE = ciede_2000 26.2 31.1 4.9 26.1 26.8 -3.7
Write-Output $dE

# .................................................. This shows a ΔE2000 of 5.6403371072
# As explained in the comments, compliance with Gaurav Sharma would display 5.6403515920
```

**Note** : L\* is nominally between 0 and 100, a\* and b\* generally between -128 and +127.

For color inputs in **hexadecimal** (e.g., `#FFF`) or **RGB** formats, see examples for other languages :

[AWK](../awk#-flexibility), [C](../c#δe2000--accurate-fast-c-powered), [Dart](../dart#δe2000--accurate-fast-dart-powered), [Java](../java#δe2000--accurate-fast-java-powered), [JavaScript](../js#-flexibility), [Kotlin](../kt#δe2000--accurate-fast-kotlin-powered), [Lua](../lua#-flexibility), [PHP](../php#δe2000--accurate-fast-php-powered), [Python](../py#δe2000--accurate-fast-python-powered), [Ruby](../rb#δe2000--accurate-fast-ruby-powered), [Rust](../rs#δe2000--accurate-fast-rust-powered).

<details>
<summary>How to fully process a CSV file ?</summary>

To process a CSV file, assume the file `input.csv` contains lines with two L\*a\*b\* colors :

```text
28.5,40.3,2.0,28.7,34.8,-1.5
99.8,48.1,2.8,99.1,42.0,-2.2
55.3,23.7,4.2,53.3,27.9,-4.3
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

```text
28.5,40.3,2.0,28.7,34.8,-1.5,2.86205611293017
99.8,48.1,2.8,99.1,42.0,-2.2,3.33688490822251
55.3,23.7,4.2,53.3,27.9,-4.3,6.08430308518873
```

When you need conformity with Gaurav Sharma’s ΔE*<sub>00</sub> calculations instead, do as indicated in the comments, and you get :

```text
28.5,40.3,2.0,28.7,34.8,-1.5,2.862069321262
99.8,48.1,2.8,99.1,42.0,-2.2,3.33689997781063
55.3,23.7,4.2,53.3,27.9,-4.3,6.08428984670139
```

> This insignificant discrepancy between the two variants is due to the fact that two main implementations of the formula are in circulation.

</details>

## Verification

[![PowerShell CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-ps1.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-ps1.yml)

<details>
<summary>What is the testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by PowerShell**, like this :

1. `gcc -std=c99 -Wall -pedantic -O2 -g tests/c/ciede-2000-driver.c -o ciede-2000-driver.exe -lm`
2. `/ciede-2000-driver.exe --generate 1000000 > test-cases.csv`
3. `./tests/ps1/ciede-2000-driver.ps1 test-cases.csv | ./ciede-2000-driver.exe`

Where the main files involved are [ciede-2000-driver.ps](ciede-2000-driver.ps1#L94) for calculations and [test-ps1.yml](../../.github/workflows/test-ps1.yml) for automation.
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

> [!IMPORTANT]
> To correct this PowerShell source code to exact match certain third-party ΔE2000 functions, follow the comments in the source code.

> This formula, "small" in size, is an essential pillar of color management, deserving of this rigorous, tested and reliable industrial treatment.

## Performance & Environment

- Speed benchmark : 16,385 calls per second
- Tested on Windows Server 2022, GCC 12.2, PowerShell 7.4.10

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in PowerShell** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=82.5&a1=19&b1=12.9&L2=69.8&a2=58.7&b2=-38.2) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Suitable in 40+ Languages](../../#implementations)

