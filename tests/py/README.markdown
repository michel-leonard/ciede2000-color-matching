# ΔE2000 — Accurate. Fast. Python-powered.

ΔE2000 is the global industry standard for quantifying color differences with unrivalled accuracy.

This reference **Python** implementation provides a simple and reliable method for calculating these differences within programs.

## Overview

The developed algorithm enables software to evaluate color similarities (or differences) with scientific rigor.

As a general rule, 🔵 navy blue and 🟡 yellow, which are very different colors, have a ΔE\*<sub>00</sub> of around 115.

Values [such as 5](https://michel-leonard.github.io/ciede2000-color-matching/de2000-rgb-pairs.html?seq=50&delta-e=5) indicate greater closeness, making this both a simple and advanced method of color comparison.

## Implementation Details

The full source code released on March 1, 2025, is available [here](../../ciede-2000.py#L6) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.py).

<details>
<summary>What two options are available for matching ΔE2000 calculations with existing calculations ?</summary>

#### Option 1 (default)
 This often-used option consists of a coding simplification that is a historical legacy of early implementations :
```py
h_m += pi
# h_m += pi if h_m < pi else -pi
```

#### Option 2 (compatible with Gaurav Sharma’s precise calculations)
There’s no room for ambiguity, this inversion of the commented line in the source code ensures compliance with the official :
```py
# h_m += pi
h_m += pi if h_m < pi else -pi
```

**Note** : the difference between the two options is minimal (±0.0003 on the calculated color difference) and usually overlooked.
</details>

<details>
<summary>How can I use Numba to speed up large-scale ΔE2000 calculations ?</summary>

[Numba](https://numba.readthedocs.io/en/stable/reference/jit-compilation.html) must be installed and will compile the `ciede_2000` function for better performance. To do this, update the source code as follows :

```diff
- def ciede_2000(l_1, a_1, b_1, l_2, a_2, b_2):
- 	from math import pi, sqrt, atan2, sin, exp

+ from math import pi, sqrt, atan2, sin, exp
+ from numba import jit, f8
+ @jit([f8(f8, f8, f8, f8, f8, f8)], cache=True, fastmath=True, nogil=True, nopython=True)
+ def ciede_2000(l_1, a_1, b_1, l_2, a_2, b_2):
```

</details>

## Example usage in Python

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```python
# L*a*b* coordinates for first color
l1, a1, b1 = 29.2, 9.8, 3.7
# L*a*b* coordinates for second color
l2, a2, b2 = 31.8, 25.6, -4.6

delta_e = ciede_2000(l1, a1, b1, l2, a2, b2)
print(delta_e)

# .................................................. This shows a ΔE2000 of 6.5165064755
# As explained in the comments, compliance with Gaurav Sharma would display 6.5164865319
```

**Note** : The L\* value nominally ranges from 0 to 100, while a\* and b\* values range usually between -128 and +127.

To compare **hexadecimal** (e.g., "#FFF") or **RGB colors** using the CIEDE2000 function, follow these examples :
- [compare-hex-colors.py](compare-hex-colors.py#L177)
- [compare-rgb-colors.py](compare-rgb-colors.py#L177)

## Verification

[![Python CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-py.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-py.yml)

<details>
<summary>What is the testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by Python**, like this :

1. `command -v python3 > /dev/null || { sudo apt-get update && sudo apt-get install python3 ; }`
2. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install gcc ; }`
3. `gcc -std=c99 -Wall -pedantic -O2 -g tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
4. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
5. `python3 tests/py/ciede-2000-driver.py test-cases.csv | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.py](ciede-2000-driver.py#L87) for calculations and [test-py.yml](../../.github/workflows/test-py.yml) for automation.
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

[![ΔE2000 against colormath in Python](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-colormath.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-colormath.yml)

Compared with the well-established **colormath** library — first published in 2008 and still widely used 17 years later — this implementation of the ΔE2000 color difference formula, tested on millions of color pairs, shows an absolute deviation of no more than **10<sup>-12</sup>**. As first in [C99](../c#comparison-with-the-vmaf-c99-library) and [Rust](../tests/rs#comparison-with-the-palette-library), this once again confirms the accuracy and relatability of this algorithm.

### Comparison with Mathics3 calculations in Python

[![ΔE2000 against Mathics3 in Python](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-mathics.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-mathics.yml)

Compared with the well-maintained **Mathics3** computer algebra system — first published in 2011 and still widely used 14 years later — this implementation of the CIE ΔE*<sub>00</sub> color difference formula, tested on millions of color pairs, shows an absolute deviation of no more than **10<sup>-12</sup>**. This test confirms that the `ciede_2000` function guarantees general interoperability within the Python ecosystem.

### Comparison with Colour Science

[![ΔE2000 against Colour Science in Python](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-colour-science.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-colour-science.yml)

Compared to the implementation of the most normative library in this field in Python, **Colour Science**’s, this public domain ΔE\*<sub>00</sub> function, checked on millions of random L\*a\*b\* color pairs, has an absolute deviation of no more than **4 × 10<sup>-13</sup>**. By default, without any modification, matching with this most scientifically defensible implementation is guaranteed with a tolerance of **3 × 10<sup>-4</sup>** in ΔE2000 results. However, to get the same ΔE\*<sub>00</sub> results as Colour Science given a tolerance of less than **10<sup>-12</sup>**, do what’s explained [here](../../ciede-2000.py#L37) in the source code, as follows :

```diff
- h_m += pi
+ h_m += pi if h_m < pi else -pi
```

> These are the two main variants for implementing the ΔE\*<sub>00</sub> function. The default is simpler, accurate enough, and widely used in practice. This formula, "small" in size, is an essential pillar of color management, deserving of this rigorous, tested and reliable industrial treatment.

### Performance Benchmark

This function was measured at a speed of 417,903 calls per second, and 988,851 calls per second with the optional addition of Numba.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **GCC** : 13.3
- **Python** : 3.13.3
  - **Numba** : 0.61.2

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in Python** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=66.9&a1=21.7&b1=11&L2=57.9&a2=60.9&b2=-30.8) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Suitable in 40+ Languages](../../#implementations)
