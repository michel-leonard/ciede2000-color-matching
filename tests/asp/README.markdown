# ΔE2000 — Accurate. Fast. ASP-powered.

ΔE2000 is the current standard for comparing colors in a way that best matches human perception.

This reference implementation in **VBScript** offers a simple and accurate way of calculating these color differences in traditional workflows.

## Overview

This algorithm provides scientifically rigorous color similarity (or difference) calculations on IIS servers.

As a general rule, 🔵 navy blue and 🟡 yellow, which are very different colors, have a ΔE\*<sub>00</sub> of around 115.

Values [such as 5](https://michel-leonard.github.io/ciede2000-color-matching/de2000-rgb-pairs.html?seq=50&delta-e=5) indicate greater closeness, making this both a simple and advanced method of color comparison.

## Implementation Details

The full **ASP Classic** source code released on March 1, 2025, is available [here](../../ciede-2000.asp#L10) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.asp).

<details>
<summary>What two options are available for matching ΔE2000 calculations with existing calculations ?</summary>

#### Option 1 (default)
 This often-used option consists of a coding simplification that is a historical legacy of early implementations :
```vbscript
h_m = h_m + M_PI
' If h_m < M_PI Then h_m = h_m + M_PI Else h_m = h_m - M_PI
```

#### Option 2 (compatible with Gaurav Sharma’s precise calculations)
There’s no room for ambiguity, this inversion of the commented line in the source code ensures compliance with the official :
```vbscript
' h_m = h_m + M_PI
If h_m < M_PI Then h_m = h_m + M_PI Else h_m = h_m - M_PI
```

**Note** : the difference between the two options is minimal (±0.0003 on the calculated color difference) and usually overlooked.
</details>

## Example usage in ASP

A typical **Delta E 2000** computation between two colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```vbscript
' Compute the Delta E (CIEDE2000) color difference between two L*a*b* colors in ASP

' Color 1: L1 = 28.9, a1 = 47.5, b1 = 2.0
' Color 2: L2 = 28.8, a2 = 41.6, b2 = -1.7

Dim deltaE
deltaE = ciede_2000(L1, a1, b1, L2, a2, b2)
Response.Write "ΔE2000 = " & deltaE

' .................................................. This shows a ΔE2000 of 2.7749016764
' As explained in the comments, compliance with Gaurav Sharma would display 2.7749152801
```

**Note** : L\* usually ranges from 0 to 100, while a\* and b\* typically range from –128 to +127.

For color inputs in **hexadecimal** (e.g., `#FFF`) or **RGB** formats, see examples for other languages :

[AWK](../awk#-flexibility), [C](../c#δe2000--accurate-fast-c-powered), [Dart](../dart#δe2000--accurate-fast-dart-powered), [Java](../java#δe2000--accurate-fast-java-powered), [JavaScript](../js#-flexibility), [Kotlin](../kt#δe2000--accurate-fast-kotlin-powered), [Lua](../lua#-flexibility), [PHP](../php#δe2000--accurate-fast-php-powered), [Python](../py#δe2000--accurate-fast-python-powered), [Ruby](../rb#δe2000--accurate-fast-ruby-powered), [Rust](../rs#δe2000--accurate-fast-rust-powered).

## Verification

[![ASP CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-asp.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-asp.yml)

ASP Classic, unlike other programming languages, doesn't have its own test driver. The [VBA driver](../bas/ciede-2000-driver.bas) is used for tests, and only the VBScript ΔE2000 function is injected inside, using the steam editor (`sed`), to replace the VBA function. The file [test-asp.yml](../../.github/workflows/test-asp.yml) is used for automation.

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
 CIEDE2000 Verification Summary :
  First Verified Line : 27,-123,101,44,-30,122,29.9893728174531
             Duration : 41.49 s
            Successes : 10000000
               Errors : 0
      Average Delta E : 63.2072
    Average Deviation : 8.8e-15
    Maximum Deviation : 2.8e-13
```

> [!IMPORTANT]
> To correct this VBScript source code to exact match certain third-party ΔE2000 functions, follow the comments in the source code.

> This formula, "small" in size, is an essential pillar of color management, deserving of this rigorous, tested and reliable industrial treatment.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **FreeBASIC Compiler** : 1.10.1
- **GCC** : 13.3

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in VBScript** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=63.6&a1=50.8&b1=-28.2&L2=73&a2=12.5&b2=7) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Suitable in 40+ Languages](../../#implementations)
