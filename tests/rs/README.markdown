# ΔE2000 — Accurate. Fast. Rust-powered.

ΔE2000 is the classic 21st century standard for quantifying color differences in accordance with human vision.

This implementation in **Rust** provides a simple, accurate and efficient way of calculating these differences within programs.

## Overview

The developed algorithm enables software to evaluate color similarities (or differences) with scientific rigor.

As a general rule, 🔵 navy blue and 🟡 yellow, which are very different colors, have a ΔE\*<sub>00</sub> of around 115.

Values [such as 5](https://michel-leonard.github.io/ciede2000-color-matching/de2000-rgb-pairs.html?seq=50&delta-e=5) indicate greater closeness, making this both a simple and advanced method of color comparison.

## Implementation Details

The full source code, released on March 1, 2025, is available in two precision variants :
- <ins>Precision</ins> : for rigorous scientific validations, a **64-bit double precision** version, which can be found [here](../../ciede-2000.rs#L6) and is archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.rs).
- <ins>Performance</ins> : for most practical applications, a generic version supporting **32-bit single precision** using [num-traits](https://crates.io/crates/num-traits) is available [in this file](ciede-2000-generic.rs#L18).

**Benchmark** : Single-precision (`f32`) calculations run approximately 1.5 to 1.7 times faster than double-precision (`f64`).

## Example usage in Rust

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```rust
// Compute the Delta E (CIEDE2000) color difference between two Lab colors in Rust

let l1 = 19.3166;
let a1 = 73.5;
let b1 = 122.428;

let l2 = 19.0;
let a2 = 76.2;
let b2 = 91.372;

let delta_e = ciede_2000(l1, a1, b1, l2, a2, b2);
println!("ΔE2000: {}", delta_e);

// Output: ΔE2000: 9.60876174564
```

**Note** : L\* is nominally between 0 and 100, a\* and b\* usually between -128 and +127.

To compare **hexadecimal** (e.g., "#FFF") or **RGB colors** using the CIEDE2000 function, see these examples :
- [compare-hex-colors.rs](compare-hex-colors.rs#L194)
- [compare-rgb-colors.rs](compare-rgb-colors.rs#L194)

## Verification

[![Rust CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-rs.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-rs.yml)

<details>
<summary>What is the testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by Rust**, like this :

1.
```sh
command -v rustc > /dev/null || {
 wget --timeout=5 --tries=3 -O- https://sh.rustup.rs | sh -s -- --profile minimal
 source $HOME/.cargo/env
}
```
2. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install gcc ; }`
3. `cargo new demo`
4. `cp -p tests/rs/ciede-2000-driver.rs demo/src/main.rs`
5. `gcc -std=c99 -Wall -pedantic -Ofast -g tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
6. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
7. `cargo run --manifest-path=demo/Cargo.toml --release -- test-cases.csv | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.rs](ciede-2000-driver.rs#L88) for calculations and [test-rs.yml](../../.github/workflows/test-rs.yml) for automation.
</details>

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
 CIEDE2000 Verification Summary :
  First Verified Line : 78,-90,-27,2.67,-10,69.4,80.79982533173092918
             Duration : 24.14 s
            Successes : 10000000
               Errors : 0
      Average Delta E : 62.9452
    Average Deviation : 3.4358127010136741e-15
    Maximum Deviation : 1.1368683772161603e-13
```

### Comparison with the palette Library

[![ΔE2000 against palette in Rust](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-palette.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-palette.yml)

Compared to the widely used Rust crate **palette** — first released in 2015 and still actively maintained 10 years later — this generic ΔE<sub>00</sub> formula implementation has been validated on billions of random L\*a\*b\* color pairs. The absolute deviation observed never exceeds **5 × 10<sup>-13</sup>**, which, as earlier in [C99](../c#comparison-with-the-vmaf-c99-library), [Java](../java#comparison-with-the-openimaj), [JavaScript](../js/README.markdown#comparison-with-the-npmchroma-js-library) and [Python](../py#comparison-with-the-python-colormath-library), confirms that the `ciede_2000` function has a **production-ready** status in the Rust ecosystem.

> [!IMPORTANT]
> To correct this Rust source code to exact match certain third-party ΔE2000 functions, follow the comments in the source code.

> This formula, "small" in size, is an essential pillar of color management, deserving of this rigorous, tested and reliable industrial treatment.

### Speed Benchmark

This function was measured at a speed of **5,851,428 calls per second**.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **rustc** : 1.87
- **cargo** : 1.87
- **GCC** : 13.3

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in Rust** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=40.52&a1=111.94&b1=25.57&L2=0.85&a2=58.07&b2=100.65) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Suitable in 40+ Languages](../../#implementations)
