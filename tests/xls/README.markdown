# ΔE2000 — Accurate. Fast. Excel-powered.

ΔE2000 is the current industry standard for quantifying color differences in a way that best matches human vision.

This reference implementation in pure **Microsoft Excel** is the portable solution for calculating these differences without programming.

## Overview

This Excel setup makes it easy to measure color similarities and differences with scientific rigor.

As a general rule, 🔵 navy blue and 🟡 yellow, which are very different colors, have a ΔE\*<sub>00</sub> of around 115.

Values [such as 5](https://michel-leonard.github.io/ciede2000-color-matching/de2000-rgb-pairs.html?seq=50&delta-e=5) indicate greater closeness, making this both a simple and advanced method of color comparison.

## Implementation Details

The Excel spreadsheet is available [here](../../ciede-2000.xls).

Because it’s formula-based (no macros or custom functions), it’s compatible with many environments such as [Google Sheets](https://docs.google.com/spreadsheets).

![Overview of the Excel spreadsheet used to calculate ΔE2000](https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/docs/assets/images/ms-excel.jpg)

### Algorithm

This Excel sheet allows you to choose between the two main ΔE2000 implementation variants, the original formulation by Gaurav Sharma and its widely used simplified version by Bruce Lindbloom. Here's a table showing the only difference between the two algorithms, which can lead to discrepancies of up to **3 × 10<sup>-4</sup>** in ΔE\*<sub>00</sub> results :

| Reference Implementation | Java Source Code | Excel Formula in Column `AC` |
|:--:|:--:|:--:|
**Bruce Lindbloom** | `h_m += Math.PI;` | `=IF(PI()<Y9,Z9+PI(),Z9)` |
**Gaurav Sharma** | `h_m += h_m < Math.PI ? Math.PI : -Math.PI;` | `=IF(PI()<Y20,IF(Z20<PI(),Z20+PI(),Z20-PI()),Z20)` |

### Alternate Setup

If you prefer to centralize the ΔE<sub>00</sub> logic in a user function, refer to the algorithm’s [VBA](../bas#δe2000--accurate-fast-vba-powered) documentation, which details this procedure.

## Usage in Excel

In the Excel sheet, update the six columns containing the color values (L\*, a\*, b\*) in each row, and drag the formula down to calculate ΔE\*00s.

**Note** :
- L\* nominally ranges from 0 to 100
- a`\* and b\* usually range from -128 to +127

## Verification

The spreadsheet was successfully tested with the [large-scale generator](https://michel-leonard.github.io/ciede2000-color-matching).

**Note** : Number precision was increased to prevent rounding that might appear erroneous.

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in Excel** brings accuracy into your applications.

🌐 [Suitable in 40+ Languages](../../#implementations)
