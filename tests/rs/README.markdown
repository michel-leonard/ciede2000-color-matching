# ΔE2000 — Accurate. Fast. Rust-powered.

This reference ΔE2000 implementation written in Rust provides reliable and accurate perceptual **color difference** calculation.

## Source Code

The full source code released on March 1, 2025, is available [here](../../ciede-2000.rs#L8) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.rs).

## Example usage in Rust

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```rs
// Example usage of the CIEDE2000 function in Rust

// L1 = 19.3166        a1 = 73.5           b1 = 122.428
// L2 = 19.0           a2 = 76.2           b2 = 91.372

let delta_e = ciede_2000(l1, a1, b1, l2, a2, b2);
println!("{}", delta_e);

// This shows a ΔE2000 of 9.60876174564
```

**Note**: L\* is usually between 0 and 100, a\* and b\* between -128 and +127.

To compare **hexadecimal** (e.g., "#FFF") or **RGB colors** using the CIEDE2000 function, follow these examples :
- [compare-hex-colors.rs](compare-hex-colors.rs#L229)
- [compare-rgb-colors.rs](compare-rgb-colors.rs#L229)

## Verification

[![Rust CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-rs.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-rs.yml)

<details>
<summary>What is the testing procedure ?</summary>

 1. `cargo new demo`
 2. `cp -p tests/rs/ciede-2000-testing.rs demo/src/main.rs`
 3. `echo 'rand = "0.8"' >> demo/Cargo.toml`
 4. `echo 'libc = "0.2"' >> demo/Cargo.toml`
 5. `gcc -O3 tests/c/stdin-verifier.c -o verifier -lm`
 6. `cargo run --manifest-path=demo/Cargo.toml --release -- 10000000 | ./verifier > test-output.txt`

Where the two main files involved are [ciede-2000-testing.rs](ciede-2000-testing.rs#L116) and [raw-rs.yml](../../.github/workflows/raw-rs.yml).
</details>


Executed through **Cargo**, the test confirms full compliance with the standard, with no observed errors :

```
CIEDE2000 Verification Summary :
- Last Verified Line : 40.52,111.94,25.57,0.85,58.07,100.65,49.03671542129836
- Duration : 23.48 s
- Successes : 10000000
- Errors : 0
- Maximum Difference : 0.0000000000000000e+00
```

### Comparison with the palette Library

[![ΔE2000 against Rust palette](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-palette.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-palette.yml)

Compared to the widely used Rust crate **palette** — first released in 2015 and still actively maintained 10 years later — this implementation of the ΔE2000 color difference formula has been validated against billions of color pairs. The observed absolute deviation never exceeds 5 × 10⁻¹³, confirming the algorithm's accuracy, as previously demonstrated in [JavaScript](../js/README.markdown#comparison-with-the-npmdelta-e-library) and [Python](../py#comparison-with-the-python-colormath-library).

### Computational Speed

This function was measured at a speed of 5,851,428 calls per second.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **rustc** : 1.87.0
- **cargo** : 1.87.0
- **GCC** : 13.3.0

## Conclusion

With over 20 years serving developers, this **trusted color comparison** routine developed in Rust brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=40.52&a1=111.94&b1=25.57&L2=0.85&a2=58.07&b2=100.65) — [32-bit vs 64-bit](https://github.com/michel-leonard/ciede2000-color-matching#numerical-precision-32-bit-vs-64-bit) — [Workflow Details](../../.github/workflows#workflow-details) — [Across 30+ programming languages](../../#implementations)

