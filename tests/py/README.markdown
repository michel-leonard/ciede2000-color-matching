# ΔE2000 — Accurate. Fast. Python-powered.

This reference ΔE2000 implementation written in Python provides reliable and accurate perceptual **color difference** calculation.

## Source Code

The full source code released on March 1, 2025, is available [here](../../ciede-2000.py#L6) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.py).

## Example usage in Python

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```python
# Example usage of the CIEDE2000 function in Python

# L1 = 19.3166        a1 = 73.5           b1 = 122.428
# L2 = 19.0           a2 = 76.2           b2 = 91.372

delta_e = ciede_2000(l1, a1, b1, l2, a2, b2)
print(delta_e)

# This shows a ΔE2000 of 9.60876174564
```

**Note**: L\* is usually between 0 and 100, a\* and b\* between -128 and +127.

To compare **hexadecimal** (e.g., "#FFF") or **RGB colors** using the CIEDE2000 function, follow these examples :
- [compare-hex-colors.py](compare-hex-colors.py#L166)
- [compare-rgb-colors.py](compare-rgb-colors.py#L166)

## Verification

[![Python CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-py.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-py.yml)

<details>
<summary>What is the testing procedure ?</summary>

 1. `gcc -O3 tests/c/stdin-verifier.c -o verifier -lm`
 2. `python3 tests/py/ciede-2000-testing.py 10000000 | ./verifier > test-output.txt`

Where the two main files involved are [ciede-2000-testing.py](ciede-2000-testing.py#L114) and [raw-py.yml](../../.github/workflows/raw-py.yml).
</details>

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
CIEDE2000 Verification Summary :
- Last Verified Line : 60.28,-13.4,-97.3,67.0,36.66,70.0,60.02649500651052
- Duration : 119.55 s
- Successes : 10000000
- Errors : 0
- Maximum Difference : 5.6843418860808015e-14
```

### Comparison with the Python colormath Library

[![ΔE2000 against Python colormath](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-colormath.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-colormath.yml)

Compared to the well-established Python library **colormath** — first released in 2008 and still widely used 17 years later — this implementation of the ΔE2000 color difference formula, tested on millions of color pairs, shows an absolute deviation of no more than 10⁻¹². This confirms both the correctness and numerical stability of the algorithm.

### Computational Speed

This function was measured at a speed of 417,903 calls per second.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **GCC** : 13.3.0
- **Python** : 3.13.3

## Conclusion

With over 20 years serving developers, this **trusted color comparison** routine developed in Python brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=60.28&a1=-13.4&b1=-97.3&L2=67&a2=36.66&b2=70) — [Workflow Details](../../.github/workflows#workflow-details) — [Across 30+ programming languages](../../#implementations)


