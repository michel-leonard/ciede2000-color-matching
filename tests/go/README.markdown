# ΔE2000 — Accurate. Fast. Go-powered.

ΔE2000 is the current industry standard for quantifying color differences in a manner consistent with human vision.

This reference implementation in **Go** offers a simple, accurate and programmatic way of calculating these differences.

## Overview

The developed algorithm enables software to evaluate color similarities (or differences) with scientific rigor.

As a general rule, 🔵 navy blue and 🟡 yellow, which are very different colors, have a ΔE\*<sub>00</sub> of around 115.

Values [such as 5](https://michel-leonard.github.io/ciede2000-color-matching/de2000-rgb-pairs.html?seq=50&delta-e=5) indicate greater closeness, making this both a simple and advanced method of color comparison.

<details>
<summary>What two options are available for matching ΔE2000 calculations with existing calculations ?</summary>

#### Option 1 (default)
 This often-used option consists of a coding simplification that is a historical legacy of early implementations :
```go
h_m += math.Pi
// if h_m < math.Pi { h_m += math.Pi } else { h_m -= math.Pi }
```

#### Option 2 (compatible with Gaurav Sharma’s precise calculations)
There’s no room for ambiguity, this inversion of the commented line in the source code ensures compliance with the official :
```go
// h_m += math.Pi
if h_m < math.Pi { h_m += math.Pi } else { h_m -= math.Pi }
```

**Note** : the difference between the two options is minimal (±0.0003 on the calculated color difference) and usually overlooked.
</details>

## Implementation Details

The full source code released on March 1, 2025, is available [here](../../ciede-2000.go#L10) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.go).

## Example usage in Go

Here is an example of calculating the ΔE<sub>00</sub> difference between two colors in the L\*a\*b\* color space using the `ciede_2000` function :

```go
// Compute the Delta E (CIEDE2000) color difference between two L*a*b* colors in Go
// Color 1: l1 = 90.3   a1 = 38.2   b1 = -2.1
// Color 2: l2 = 89.9   a2 = 43.9   b2 = 2.6

deltaE := ciede_2000(l1, a1, b1, l2, a2, b2)
fmt.Printf("%f\n", deltaE)

// .................................................. This shows a ΔE2000 of 3.2738672431
// As explained in the comments, compliance with Gaurav Sharma would display 3.2738822974
```

**Note** : The L\* value nominally ranges from 0 to 100, while a\* and b\* values range usually from -128 to +127.

For color inputs in **hexadecimal** (e.g., `#FFF`) or **RGB** formats, see examples for other languages :

[AWK](../awk#-flexibility), [C](../c#δe2000--accurate-fast-c-powered), [Dart](../dart#δe2000--accurate-fast-dart-powered), [Java](../java#δe2000--accurate-fast-java-powered), [JavaScript](../js#-flexibility), [Kotlin](../kt#δe2000--accurate-fast-kotlin-powered), [Lua](../lua#-flexibility), [PHP](../php#δe2000--accurate-fast-php-powered), [Python](../py#δe2000--accurate-fast-python-powered), [Ruby](../rb#δe2000--accurate-fast-ruby-powered), [Rust](../rs#δe2000--accurate-fast-rust-powered).

## Verification

[![Go CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-go.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-go.yml)

<details>
<summary>What is the testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by Go**, like this :

1. `command -v go > /dev/null || { sudo apt-get update && sudo apt-get install go ; }`
2. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install gcc ; }`
3. `gcc -std=c99 -Wall -pedantic -O2 -g tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
4. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
5. `go run tests/go/ciede-2000-driver.go test-cases.csv | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.go](ciede-2000-driver.go#L101) for calculations and [raw-dart.go](../../.github/workflows/test-go.yml) for automation.
</details>

Test results confirm full compliance with the standard, with no errors and negligible floating-point deviation :

```
 CIEDE2000 Verification Summary :
  First Verified Line : 58.05,125.53,-120,93.1,-15.7,60,88.23669570136294737
             Duration : 22.26 s
            Successes : 10000000
               Errors : 0
      Average Delta E : 62.9356
    Average Deviation : 7.947572977506922e-15
    Maximum Deviation : 2.7000623958883807e-13
```

### Comparison with the go-chromath Package

[![ΔE2000 against go-chromath in Go](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-go-chromath.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-go-chromath.yml)

Compared to the Go package **go-chromath** — this implementation of the ΔE2000 color difference formula, verified over 100 million color pair comparisons, exhibits a deviation of no more than **2 × 10<sup>-13</sup>**. This confirms that the `ciede_2000` function is suitable for general use in Go.

### Comparison with the xterm-color-chart Library

[![ΔE2000 against xterm-color-chart in Go](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-xterm-color-chart.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-xterm-color-chart.yml)

Compared to the Go library **kutuluk/xterm-color-chart** — first released in 2015 — this implementation of the ΔE2000 color difference formula, verified over 100 million color pair comparisons, exhibits an absolute deviation of no more than **2 × 10<sup>-13</sup>**. This confirms, in the same way as for the [C99](../c#comparison-with-the-vmaf-c99-library), [Java](../java#comparison-with-the-openimaj), [JavaScript](../js#comparison-with-the-npmchroma-js-library), [Kotlin](../kt#comparison-with-ndtpandroid-testify), [Python](../py#comparison-with-the-python-colormath-library) and [Rust](../rs#comparison-with-the-palette-library) versions, the interoperability and production-ready status of the `ciede_2000` function in Go.

> [!IMPORTANT]
> To correct this Go source code to exact match certain third-party ΔE2000 functions, follow the comments in the source code.

> This formula, "small" in size, is an essential pillar of color management, deserving of this rigorous, tested and reliable industrial treatment.

## Speed Benchmark

Measured at 5,364,064 calls per second.

## Software Environment

* Ubuntu 24.04.2 LTS
* Go 1.23.9
* GCC 13.3

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in Go** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=72.9&a1=2.7&b1=5&L2=56.1&a2=27.8&b2=-51.3) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Suitable in 40+ Languages](../../#implementations)
