# ΔE2000 — Accurate. Fast. F#-powered.

ΔE2000 is the current standard for quantifying color differences in a way that matches human perception.

This canonical **F#** implementation provides an easy-to-use, highly accurate method to compute color differences programmatically.

## Overview

This algorithm allows software to scientifically measure how similar or different two colors are perceived by humans.

For reference, two very distinct colors typically have a ΔE2000 value greater than 12.

Lower values indicate greater closeness, making it a **state-of-the-art method** for comparing colors.

## Implementation Details

The full F# source code (released March 1, 2025) is available [here](../../ciede-2000.fs#L8) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.fs).

This classic source code can be seamlessly integrated into [C#](../cs#δe2000--accurate-fast-c-powered), VB.NET, and PowerShell projects.

## Example usage in F#

To calculate the **Delta E 2000** difference between two colors specified in the **L\*a\*b\*** color space, use the `ciede_2000` function :
```fs
// Example usage of the CIEDE2000 function in F#

let l1, a1, b1 = 19.3166, 73.5, 122.428
let l2, a2, b2 = 19.0, 76.2, 91.372

let deltaE = ciede_2000 l1 a1 b1 l2 a2 b2
printfn "%f" deltaE

// Output: ΔE2000 = 9.60876174564
```

**Note**: L\* is usually between 0 and 100, a\* and b\* between -128 and +127.

To compare **hexadecimal** (e.g., "#FFF") or **RGB colors** using the CIEDE2000 function, examples are available in several languages :
- [AWK](../awk#-flexibility)
- [C](../c#δe2000--accurate-fast-c-powered)
- [Dart](../dart#δe2000--accurate-fast-dart-powered)
- [JavaScript](../js#-flexibility)
- [Java](../java#δe2000--accurate-fast-java-powered)
- [Kotlin](../kt#δe2000--accurate-fast-kotlin-powered)
- [Lua](../lua#-flexibility)
- [PHP](../php#δe2000--accurate-fast-php-powered)
- [Python](../py#δe2000--accurate-fast-python-powered)
- [Ruby](../rb#δe2000--accurate-fast-ruby-powered)
- [Rust](../rs#δe2000--accurate-fast-rust-powered)

## Verification

[![F# CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-fs.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-fs.yml)

<details>
<summary>What is the testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by F#**, like this :

1. `command -v dotnet > /dev/null || { sudo apt-get update && sudo apt-get install -y dotnet-sdk-8.0 ; }`
2. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install -y gcc ; }`
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
8. `gcc -std=c99 -Wall -pedantic -Ofast tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
9. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
10. `dotnet run --configuration Release --project ciede-2000-tests/Exec -- test-cases.csv | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.fs](ciede-2000-driver.fs#L122) for calculations and [test-fs.yml](../../.github/workflows/test-fs.yml) for automation.
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

### Speed Benchmark

This function was measured at a speed of 5,293,357 calls per second.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **Dotnet** : 8.0.410
- **GCC** : 13.3.0

## Conclusion

![ΔE2000 Logo](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in F#** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=4&a1=104.59&b1=-12&L2=78.74&a2=5.87&b2=11) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Used in 30+ Languages](../../#implementations)

