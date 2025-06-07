# ΔE2000 — Accurate. Fast. Ruby-powered.

This reference ΔE2000 implementation written in Ruby provides reliable and accurate perceptual **color difference** calculation.

## Source Code

The full source code released on March 1, 2025, is available [here](../../ciede-2000.rb#L6) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.rb).

## Example usage in Ruby

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```ruby
# Example usage of the CIEDE2000 function in Ruby

# L1 = 19.3166        a1 = 73.5           b1 = 122.428
# L2 = 19.0           a2 = 76.2           b2 = 91.372

delta_e = ciede_2000(l1, a1, b1, l2, a2, b2)
puts delta_e

# This shows a ΔE2000 of 9.60876174564
```

**Note**: L\* is usually between 0 and 100, a\* and b\* between -128 and +127.

To compare **hexadecimal** (e.g., "#FFF") or **RGB colors** using the CIEDE2000 function, follow these examples :
- [compare-hex-colors.rb](compare-hex-colors.rb#L224)
- [compare-rgb-colors.rb](compare-rgb-colors.rb#L224)

## Verification

[![Ruby CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-rb.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-rb.yml)

<details>
<summary>What is the testing procedure ?</summary>

 1. `gcc -O3 tests/c/stdin-verifier.c -o verifier -lm`
 2. `ruby --yjit tests/rb/ciede-2000-testing.rb 10000000 | ./verifier > test-output.txt`

Where the two main files involved are [ciede-2000-testing.rb](ciede-2000-testing.rb#L115) and [raw-rb.yml](../../.github/workflows/raw-rb.yml).
</details>

The test confirms full compliance with the standard, with no observed errors :

```
CIEDE2000 Verification Summary :
- Last Verified Line : 87.29,-113.03,-48.6,19,-51.6,1.82,69.80993443074732
- Duration : 72.72 s
- Successes : 10000000
- Errors : 0
- Maximum Difference : 0.0000000000000000e+00
```

### Computational Speed

This function was measured at a speed of 497,425 calls per second.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **GCC** : 13.3.0
- **Ruby** : 3.3.8

## Conclusion

With over 20 years serving developers, this **trusted color comparison** routine developed in Ruby brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=87.29&a1=-113.03&b1=-48.6&L2=19&a2=-51.6&b2=1.82) — [Workflow Details](../../.github/workflows#workflow-details) — [Across 30+ programming languages](../../#implementations)

