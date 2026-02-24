# ΔE2000 — Accurate. Fast. F#-powered.

ΔE2000 is the current standard for quantifying color differences in a way that best matches human vision.

This reference implementation in **F#** provides a simple method for calculating these color differences within programs.

## Overview

The developed algorithm enables software to evaluate color similarities (or differences) with scientific rigor.

As a general rule, 🔵 navy blue and 🟡 yellow, which are very different colors, have a ΔE\*<sub>00</sub> of around 115.

Values [such as 5](https://michel-leonard.github.io/ciede2000-color-matching/de2000-rgb-pairs.html?seq=50&delta-e=5) indicate greater closeness, making this both a simple and advanced method of color comparison.

## Implementation Details

The full F# source code (released March 1, 2025) is available [here](../../ciede-2000.fs#L8) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.fs).

This classic source code can be seamlessly integrated into [C#](../cs#δe2000--accurate-fast-c-powered), VB.NET, and PowerShell projects.

<details>
<summary>What two options are available for matching ΔE2000 calculations with existing calculations ?</summary>

#### Option 1 (default)
 This often-used option consists of a coding simplification that is a historical legacy of early implementations :
```fs
h_m <- h_m + Math.PI
// h_m <- h_m + (if h_m < Math.PI then Math.PI else -Math.PI)
```

#### Option 2 (compatible with Gaurav Sharma’s precise calculations)
There’s no room for ambiguity, this inversion of the commented line in the source code ensures compliance with the official :
```fs
// h_m <- h_m + Math.PI
h_m <- h_m + (if h_m < Math.PI then Math.PI else -Math.PI)
```

**Note** : the difference between the two options is minimal (±0.0003 on the calculated color difference) and usually overlooked.
</details>

## Example usage in F#

To calculate the **Delta E 2000** difference between two colors specified in the **L\*a\*b\*** color space, use the `ciede_2000` function :
```fs
// Compute the Delta E (CIEDE2000) color difference between two L*a*b* colors in F#

let l1, a1, b1 = 3.9, 16.9, -4.9
let l2, a2, b2 = 3.1, 11.8, 3.6

let deltaE = ciede_2000 l1 a1 b1 l2 a2 b2
printfn "%f" deltaE

// .................................................. This shows a ΔE2000 of 7.0799401968
// As explained in the comments, compliance with Gaurav Sharma would display 7.0799265161
```

**Note** : L\* is nominally between 0 and 100, a\* and b\* usually between -128 and +127.

For color inputs in **hexadecimal** (e.g., `#FFF`) or **RGB** formats, see examples for other languages :

[AWK](../awk#-flexibility), [C](../c#δe2000--accurate-fast-c-powered), [Dart](../dart#δe2000--accurate-fast-dart-powered), [Java](../java#δe2000--accurate-fast-java-powered), [JavaScript](../js#-flexibility), [Kotlin](../kt#δe2000--accurate-fast-kotlin-powered), [Lua](../lua#-flexibility), [PHP](../php#δe2000--accurate-fast-php-powered), [Python](../py#δe2000--accurate-fast-python-powered), [Ruby](../rb#δe2000--accurate-fast-ruby-powered), [Rust](../rs#δe2000--accurate-fast-rust-powered).

## Verification

[![F# CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-fs.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-fs.yml)

<details>
<summary>What is the testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by F#**, like this :

1. `command -v dotnet > /dev/null || { sudo apt-get update && sudo apt-get install dotnet-sdk-8.0 ; }`
2. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install gcc ; }`
3. `mkdir -p ciede-2000-tests/Exec`
4. `dotnet new console -lang "F#" -n Exec -o ciede-2000-tests/Exec`
5. `cp -p tests/fs/ciede-2000-driver.fs ciede-2000-tests/Exec/Program.fs`
6.
 ```sh
printf '%s\n' '<Project Sdk="Microsoft.NET.Sdk">' \
'  <PropertyGroup>' \
'    <OutputType>Exe</OutputType>' \
'    <TargetFramework>net8.0</TargetFramework>' \
'    <LangVersion>latest</LangVersion>' \
'  </PropertyGroup>' \
'  <ItemGroup>' \
'    <Compile Include="Program.fs" />' \
'  </ItemGroup>' \
'</Project>' > ciede-2000-tests/Exec/Exec.fsproj
```
7. `dotnet build --configuration Release ciede-2000-tests/Exec`
8. `gcc -std=c99 -Wall -pedantic -O2 -g tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
9. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
10. `dotnet run --configuration Release --project ciede-2000-tests/Exec -- test-cases.csv | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.fs](ciede-2000-driver.fs#L89) for calculations and [test-fs.yml](../../.github/workflows/test-fs.yml) for automation.
</details>

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :
```
 CIEDE2000 Verification Summary :
  First Verified Line : 73.2,-34,-46,97.09,38.44,-65,39.669742389892633
             Duration : 51.98 s
            Successes : 10000000
               Errors : 0
      Average Delta E : 62.9404
    Average Deviation : 4.2576547981676426e-15
    Maximum Deviation : 1.1368683772161603e-13
```

> [!IMPORTANT]
> To correct this F# source code to exact match certain third-party ΔE2000 functions, follow the comments in the source code.

> This formula, "small" in size, is an essential pillar of color management, deserving of this rigorous, tested and reliable industrial treatment.

### Speed Benchmark

This function was measured at a speed of 5,293,357 calls per second.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **Dotnet** : 8.0.410
- **GCC** : 13.3

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in F#** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=9.4&a1=27.2&b1=-41.7&L2=20.8&a2=9.9&b2=15.2) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Suitable in 40+ Languages](../../#implementations)
