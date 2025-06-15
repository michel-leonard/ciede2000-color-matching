# ΔE2000 — Accurate. Fast. Go-powered.

ΔE2000 is the current industry standard for quantifying color differences in a manner consistent with human perception.

This reference implementation in Go provides an easy, accurate, and programmatic way to compute these differences.

## Overview

This algorithm allows your software to measure color similarity and difference with scientific accuracy.

As a guideline, two very distinct colors usually have a ΔE2000 value greater than 12, while lower values indicate higher similarity.

ΔE2000 is thus a **state-of-the-art method** for precise color comparison.

## Implementation Details

The full source code released on March 1, 2025, is available [here](../../ciede-2000.go#L10) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.go).

## Example usage in Go

Here is an example of calculating the ΔE2000 difference between two colors in the L\*a\*b\* color space using the `ciede_2000` function :

```go
// Input colors (L*, a*, b*)
// Color 1: L1 = 19.3166, a1 = 73.5,  b1 = 122.428
// Color 2: L2 = 19.0,    a2 = 76.2,  b2 = 91.372

deltaE := ciede_2000(l1, a1, b1, l2, a2, b2)
fmt.Printf("%f\n", deltaE)

// Output: ΔE2000 = 9.60876174564
```

**Note** : The L\* value typically ranges from 0 to 100, while a\* and b\* values range approximately from -128 to +127.

For color inputs in **hexadecimal** (e.g., `#FFF`) or **RGB** formats, see examples for other languages :

[AWK](../awk#-flexibility), [C](../c#δe2000--accurate-fast-c-powered), [Dart](../dart#δe2000--accurate-fast-dart-powered), [Java](../java#δe2000--accurate-fast-java-powered), [JavaScript](../js#-flexibility), [Kotlin](../kt#δe2000--accurate-fast-kotlin-powered), [Lua](../lua#-flexibility), [PHP](../php#δe2000--accurate-fast-php-powered), [Python](../py#δe2000--accurate-fast-python-powered), [Ruby](../rb#δe2000--accurate-fast-ruby-powered), [Rust](../rs#δe2000--accurate-fast-rust-powered).


## Verification

[![Go CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-go.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-go.yml)

<details>
<summary>What is the testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by Go**, like this :

1. `command -v go > /dev/null || { sudo apt-get update && sudo apt-get install -y go ; }`
2. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install -y gcc ; }`
3. `gcc -std=c99 -Wall -pedantic -Ofast tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
4. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
5. `go run tests/go/ciede-2000-driver.go test-cases.csv | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.go](ciede-2000-driver.go#L130) for calculations and [raw-dart.go](../../.github/workflows/test-go.yml) for automation.
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

### Comparison with the xterm-color-chart Library

[![ΔE2000 against xterm-color-chart](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-xterm-color-chart.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-xterm-color-chart.yml)

Compared to the Go library **kutuluk/xterm-color-chart** — first released in 2015 — this Go version of the ΔE2000 color difference formula, validated over 300 million color pair comparisons, exhibits an absolute deviation no greater than 2 × 10⁻¹³ in the worst case. This confirms, in the same way as for the [JavaScript](../js#comparison-with-the-npmdelta-e-library), [Python](../py#comparison-with-the-python-colormath-library) and [Rust](../rs#comparison-with-the-palette-library) versions, the numerical precision of this algorithm.

## Speed Benchmark

Measured at 5,364,064 calls per second.

## Software Environment

* Ubuntu 24.04.2 LTS
* Go 1.23.9
* GCC 13.3.0

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in Go** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=65&a1=-50&b1=10.5&L2=20.82&a2=71&b2=-34.1) — [32-bit vs 64-bit](https://github.com/michel-leonard/ciede2000-color-matching#numerical-precision-32-bit-vs-64-bit) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Used in 30+ Languages](../../#implementations)

