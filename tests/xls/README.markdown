# ΔE2000 — Accurate. Fast. Excel-powered.

This reference ΔE2000 implementation written in Excel provides reliable and accurate perceptual **color difference** calculation.

## Source Code

The Excel spreadsheet is available [here](../../ciede-2000.xls) and, being based purely on formulas (without macros or custom functions), it remains highly portable and compatible with various office or scientific environments, including [Google Sheets](https://docs.google.com/spreadsheets).

![Overview of the Excel spreadsheet used to calculate ΔE2000](ms-excel.jpg)

## Usage in Excel

In **Microsoft Excel**, we update the six columns containing the color values (L\*, a\*, b\*) and extend the formula downward to calculate the required number of ΔE 2000 values.

**Note**: L\* is usually between 0 and 100, a\* and b\* between -128 and +127.

## Verification

The spreadsheet was successfully tested with the [large-scale generator](https://michel-leonard.github.io/ciede2000-color-matching), and number precision was increased to prevent rounding that might appear erroneous.

## Conclusion

With over 20 years serving developers, this **trusted color comparison** routine developed in Excel brings accuracy into your applications.

[Across 30+ programming languages](../../#implementations)
