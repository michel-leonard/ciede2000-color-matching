# ΔE2000 — Accurate. Fast. Excel-powered.

ΔE2000 is the current industry standard for quantifying color differences in a way that best matches human vision.

This reference implementation in pure **Microsoft Excel** is the portable solution for calculating these differences without programming.

## Overview

This Excel setup makes it easy to measure color similarities and differences with scientific rigor.

As a general rule, 🔵 navy blue and 🟡 yellow, which are very different colors, have a ΔE\*<sub>00</sub> of around 115.

Values [such as 5](https://michel-leonard.github.io/ciede2000-color-matching/de2000-rgb-pairs.html?seq=50&delta-e=5) indicate greater closeness, making this both a simple and advanced method of color comparison.

## Implementation Details

The Excel spreadsheet is available [here](../../ciede-2000.xls).

This Excel spreadsheet calculates the CIEDE2000 color difference (ΔE00) using a native Excel formula on a single line, without the need for macros or VBA. The implementation is scientifically validated and includes test pairs for formulations by [Gaurav Sharma](https://hajim.rochester.edu/ece/sites/gsharma/ciede2000/) and [Bruce Lindbloom](http://www.brucelindbloom.com/ColorDifferenceCalc.html). A total of 18 ΔE00 values are calculated on separate lines in two tables (9 for Sharma and 9 for Lindbloom).

The formula handles special cases such as `atan2(0, 0)` to ensure consistent mathematical behavior. Parametric factors `kL`, `kC` and `kH` are adjustable on a per-line basis, each line being independent of the others. The algorithm is robustly transcribed, and the final CIEDE2000 result is accurate to at least 10 decimal places, validated by MATLAB (Sharma) and JavaScript (Lindbloom) implementations on 10,000 color pairs behind the scenes.

The complete formula is stored in hidden columns (`I` to `AN`), while the visible ΔE2000 result appears in column `H`. The `AO` column is grayed out for easy expansion. Each line can be copied, pasted or moved down to extend calculations, while retaining its autonomy.

The file is developed in the classic **Excel 97-2003** XLS format, using ASCII characters only for maximum compatibility. On environments that accept native Excel files, such as [Google Sheets](https://docs.google.com/spreadsheets), this spreadsheet is recognized.

### Algorithm

This Excel sheet allows you to choose between the two main ΔE2000 implementation variants, the original formulation by Gaurav Sharma and its widely used simplified version by Bruce Lindbloom. Here’s a table showing the only difference between the two algorithms, which can lead to discrepancies of up to **3 × 10<sup>-4</sup>** in ΔE\*<sub>00</sub> results :

| Reference Implementation | Java Source Code | Excel Formula in Column `AC` |
|:--:|:--:|:--:|
**Bruce Lindbloom** | `h_m += Math.PI;` | `=IF(PI()<Y9,Z9+PI(),Z9)` |
**Gaurav Sharma** | `h_m += h_m < Math.PI ? Math.PI : -Math.PI;` | `=IF(PI()<Y20,IF(Z20<PI(),Z20+PI(),Z20-PI()),Z20)` |

### Alternate Setup

If you prefer to centralize the ΔE<sub>00</sub> logic in a user function, refer to the algorithm’s [VBA](../bas#δe2000--accurate-fast-vba-powered) documentation, which details this procedure.

## Usage in Excel

In the Excel sheet, update the six columns containing the color values (L\*, a\*, b\*) in each row, and drag the formula down to calculate ΔE\*00s.

![Overview of the Excel spreadsheet used to calculate ΔE2000](https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/docs/assets/images/ms-excel.jpg)

**Note** :
- L\* nominally ranges from 0 to 100
- a`\* and b\* usually range from -128 to +127

This file is intended for professional use by organizations such as Fogra and X-Rite, requiring accurate and portable ΔE00 calculations.

## Verification

The spreadsheet was successfully tested with the [large-scale generator](https://michel-leonard.github.io/ciede2000-color-matching).

**Note** : Number precision was increased to prevent rounding that might appear erroneous.

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in Excel** brings accuracy into your applications.

🌐 [Suitable in 40+ Languages](../../#implementations)
