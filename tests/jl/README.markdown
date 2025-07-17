# ΔE2000 — Accurate. Fast. Julia-powered.

ΔE2000 is the current standard for quantifying color differences in a way that best matches human vision.

These two reference implementations in **Julia** provide a simple and accurate way of calculating these differences within scripts.

## Overview

The developed algorithm enables software to evaluate color similarities (or differences) with scientific rigor.

As a general rule, 🔵 navy blue and 🟡 yellow, which are very different colors, have a ΔE\*<sub>00</sub> of around 115.

Values [such as 5](https://michel-leonard.github.io/ciede2000-color-matching/de2000-rgb-pairs.html?seq=50&delta-e=5) indicate greater closeness, making this both a simple and advanced method of color comparison.

## Implementation Details

The full source code, released on March 1, 2025, is available in two precision variants :
- **Precision**: A 64-bit double precision version intended for rigorous scientific validation. See the source [here](../../ciede-2000.jl#L9) (archived [here](https://web.archive.org/web/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.jl)).
- **Performance**: A generic 32-bit single precision version optimized for most practical applications. Available [in this file](ciede-2000-generic.jl#L16).

**Benchmark** : The 32-bit version runs roughly 30% faster than the 64-bit version, demonstrating a meaningful performance improvement.

### Arbitrary Precision

For **metrology** and cross-language verification purposes, the generic implementation can perform ΔE<sub>00</sub> calculations with arbitrary precision.

**Example** : `ciede_2000(big.([75.5, 22.5, -2.5, 76.5, 16.5, 2.25])...)` equals `4.8786078558712690398212347704718618414820` with the default settings, or `4.8785929856090079542526937421017710870774` when you need compliance with Gaurav Sharma’s color difference calculations.

A source code containing decimal literals like `0.32` can propagate small but significant binary rounding errors in generic-precision arithmetic. For example `BigFloat(0.32) != BigFloat(8//25)`, so the generic function ΔE<sub>00</sub> in Julia includes constants written as fractions like `8//25`. We also note that `BigFloat(π) + BigFloat(-π)` is equal to `0.0000000000000001`, due to the sign that must come from outside the constructor.

## Example usage in Julia

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```jl
# Compute the Delta E (CIEDE2000) color difference between two Lab colors in Julia

# Color 1 (L1, a1, b1)
l1, a1, b1 = 74.5, 29.6, 3.4

# Color 2 (L2, a2, b2)
l2, a2, b2 = 74.6, 35.1, -3.2

deltaE = ciede_2000(l1, a1, b1, l2, a2, b2)
println(deltaE)

# .................................................. This shows a ΔE2000 of 4.5852748113
# As explained in the comments, compliance with Gaurav Sharma would display 4.5852593642
```

The `ciede_2000` function expects inputs as floating-point values :
- **L\*** nominally ranges from 0 to 100,
- **a\*** and **b\*** values generally fall between -128 and +127.

For color inputs in **hexadecimal** (e.g., `#FFF`) or **RGB** formats, see examples for other languages :

[AWK](../awk#-flexibility), [C](../c#δe2000--accurate-fast-c-powered), [Dart](../dart#δe2000--accurate-fast-dart-powered), [Java](../java#δe2000--accurate-fast-java-powered), [JavaScript](../js#-flexibility), [Kotlin](../kt#δe2000--accurate-fast-kotlin-powered), [Lua](../lua#-flexibility), [PHP](../php#δe2000--accurate-fast-php-powered), [Python](../py#δe2000--accurate-fast-python-powered), [Ruby](../rb#δe2000--accurate-fast-ruby-powered), [Rust](../rs#δe2000--accurate-fast-rust-powered).

## Verification

[![Julia CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-jl.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-jl.yml)

<details>
<summary>What is the testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by Julia**, like this :

1.
```sh
if ! command -v julia > /dev/null; then
	########################################################################################
	####  STEP 1:            Download & Extract the latest version of Julia             ####
	########################################################################################
	URL=$(wget -qO- https://julialang.org/downloads/ | grep 'linux/x64' |
	grep '\.tar\.gz' | grep -o 'https://[^"]*' | head -n 1)
	if [ -z "$URL" ]; then
		URL="https://julialang-s3.julialang.org/bin/linux/x64/1.11/julia-1.11.5-linux-x86_64.tar.gz"
	fi
	rm -rf /opt/julia
	mkdir /opt/julia
	wget -q -T5 -t3 -O- "$URL" | tar -xz --strip-components=1 -C /opt/julia
	########################################################################################
	####  STEP 2:                       Add Julia to System PATH                        ####
	########################################################################################
	sudo ln -sf /opt/julia/bin/julia /usr/local/bin/julia
	########################################################################################
	####  CONCLUSION:                    Julia Installed in Under 15s                   ####
	########################################################################################
fi
julia --version
```
2. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install gcc ; }`
3. `gcc -std=c99 -Wall -pedantic -Ofast -g tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
4. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
5. `julia tests/jl/ciede-2000-driver.jl test-cases.csv | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.jl](ciede-2000-driver.jl#L98) for calculations and [test-jl.yml](../../.github/workflows/test-jl.yml) for automation.
</details>

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
 CIEDE2000 Verification Summary :
  First Verified Line : 25.11,-80,77,2,26.08,-46,59.590330238040835
             Duration : 76.37 s
            Successes : 10000000
               Errors : 0
      Average Delta E : 62.9504
    Average Deviation : 5.0239383043038796e-15
    Maximum Deviation : 2.4158453015843406e-13
```

<details>
<summary>How is the arbitrary-precision of the function tested ?</summary>

The arbitrary-precision Julia implementation of `ciede_2000` inherits the validity of the 64-bit Julia version thanks to a rigorous process.

First, the 64-bit Julia implementation has been validated against the 64-bit C99 version, to ensure compliance with standards.

Next, the Julia implementation, which uses the `AbstractFloat` type to support arbitrary precision, was tested against the `bc` (Basic Calculator) implementation. This validation, detailed [here](../bc#δe2000--accurate-fast-bc-powered) for 30 digits, shows that the difference between `bc` and Julia can be as small as desired.

This agreement confirms that arbitrary precision is correctly implemented in Julia, fast (25× faster than `bc`) and accurate.

> In summary, this generic version of ΔE2000 in Julia combines rigorous validation against those C and `bc` for all the accuracies it supports.
</details>

> [!IMPORTANT]
> To correct this Julia source code to exact match certain third-party ΔE2000 functions, follow the comments in the source code.

> This formula, "small" in size, is an essential pillar of color management, deserving of this rigorous, tested and reliable industrial treatment.

### Performance and Environment

The `ciede_2000` function was benchmarked at 4,137,791 calls per second.

Tested environment :

- **Ubuntu** 24.04.2 LTS
- **GCC** 13.3
- **Julia** 1.11.5
- **bc** 1.07.1

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in Julia** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=53&a1=-96&b1=-45&L2=12.5&a2=-106&b2=-26.1) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Suitable in 40+ Languages](../../#implementations)
