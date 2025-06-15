# ΔE2000 — Accurate. Fast. Python-powered.

ΔE2000 is the modern standard for quantifying perceived color differences with high accuracy.

This canonical **Python** implementation provides an easy and reliable method to compute these differences programmatically.

## Overview

The presented algorithm enables your software to measure color similarity and differences with scientific rigor.

For reference, two very distinct colors typically have a ΔE2000 value greater than 12.

Lower values indicate greater closeness, making it a **state-of-the-art method** for comparing colors.

## Implementation Details

The full source code released on March 1, 2025, is available [here](../../ciede-2000.py#L6) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.py).

## Example usage in Python

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```python
# L*a*b* coordinates for first color
L1, a1, b1 = 19.3166, 73.5, 122.428
# L*a*b* coordinates for second color
L2, a2, b2 = 19.0, 76.2, 91.372

delta_e = ciede_2000(L1, a1, b1, L2, a2, b2)
print(delta_e)  # Expected output: 9.60876174564
```

**Note**: The L\* value typically ranges from 0 to 100, while a\* and b\* values range approximately between -128 and +127.

To compare **hexadecimal** (e.g., "#FFF") or **RGB colors** using the CIEDE2000 function, follow these examples :
- [compare-hex-colors.py](compare-hex-colors.py#L166)
- [compare-rgb-colors.py](compare-rgb-colors.py#L166)

## Verification

[![Python CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-py.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-py.yml)

<details>
<summary>What is the testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by Python**, like this :

1. `command -v python3 > /dev/null || { sudo apt-get update && sudo apt-get install -y python3 ; }`
2. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install -y gcc ; }`
3. `gcc -std=c99 -Wall -pedantic -Ofast tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
4. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
5. `python3 tests/py/ciede-2000-driver.py test-cases.csv | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.py](ciede-2000-driver.py#L119) for calculations and [test-py.yml](../../.github/workflows/test-py.yml) for automation.
</details>

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
CIEDE2000 Verification Summary :
  First Verified Line : 73,42,15,53.7,-9.04,-51.3,51.254604281273956
             Duration : 54.14 s
            Successes : 10000000
               Errors : 0
      Average Delta E : 62.9478
    Average Deviation : 3.4565876161352096e-15
    Maximum Deviation : 8.5265128291212022e-14
```

### Comparison with the Python colormath Library

[![ΔE2000 against Python colormath](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-colormath.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-colormath.yml)

Compared to the well-established Python library **colormath** — first released in 2008 and still widely used 17 years later — this implementation of the ΔE2000 color difference formula, tested on millions of color pairs, shows an absolute deviation of no more than 10⁻¹². This confirms both the correctness and numerical stability of the algorithm.

### Performance Benchmark 

This function was measured at a speed of 417,903 calls per second.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **GCC** : 13.3.0
- **Python** : 3.13.3

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in Python** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=60.28&a1=-13.4&b1=-97.3&L2=67&a2=36.66&b2=70) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Used in 30+ Languages](../../#implementations)


