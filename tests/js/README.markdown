# ΔE2000 — Accurate. Fast. JavaScript-powered.

CIE 2000 is the current industry standard for quantifying color differences that align closely with human visual perception.

This canonical **JavaScript** implementation offers an easy way to calculate these differences accurately and programmatically.

## Overview

The developed algorithm enables your software to measure color similarity and difference with scientific rigor.

Typically, a ΔE2000 value above 12 indicates two very distinct colors.

Lower values mean the colors are perceptually closer, making ΔE2000 a **state-of-the-art method** for accurate color comparison.

## Implementation Details

The complete source code, released on March 1, 2025, is available [here](../../ciede-2000.js#L6) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.js).

This reference implementation integrates seamlessly with [TypeScript](../ts#δe2000--accurate-fast-typescript-powered), Node.js, and Deno environments.

## Example usage in JavaScript

To calculate the **Delta E 2000** difference between two colors expressed in the **L\*a\*b\* color space**, use the `ciede_2000` function :

```javascript
// Define color 1 in L*a*b* space
const l1 = 19.3166, a1 = 73.5, b1 = 122.428;

// Define color 2 in L*a*b* space
const l2 = 19.0, a2 = 76.2, b2 = 91.372;

// Calculate ΔE2000 color difference
const deltaE = ciede_2000(l1, a1, b1, l2, a2, b2);
console.log(deltaE); // Outputs: 9.60876174564
```

**Note**: L\* is usually between 0 and 100, a\* and b\* between -128 and +127.

### 🎨 Flexibility

To compare **hexadecimal** (e.g., `#FFF`) or **RGB colors** using the CIEDE2000 function, see these example scripts :
- [compare-hex-colors.js](compare-hex-colors.js#L169)
- [compare-rgb-colors.js](compare-rgb-colors.js#L169)

The [all-in-one](../../#rgb-and-hexadecimal-color-comparison-for-the-web-in-javascript) function supports both RGB and hexadecimal formats, allowing quick color difference calculations using the D65 illuminant.

## Browser Tools

See this JavaScript CIEDE2000 color difference formula in action here :
- **Generators** :
  - A [discovery generator](https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html) for quick, small-scale testing and exploration.
  - A [large-scale generator](https://michel-leonard.github.io/ciede2000-color-matching) and validator used to test new implementations.
- **Calculators**:
  - A [simple calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html) for computing ΔE2000 between two **L\*a\*b\*** colors.
  - A [pickers-based calculator](https://michel-leonard.github.io/ciede2000-color-matching/rgb-hex-color-calculator.html) for computing ΔE2000 between two **RGB** or **Hex** colors.
- **Other** :
  - A [tool](https://michel-leonard.github.io/ciede2000-color-matching/color-name-from-image.html) that identify the name of the selected color based on a picture.

## Verification

[![JavaScript CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-js.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-js.yml)

<details>
<summary>What is the testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by JavaScript**, like this :

1. `command -v node > /dev/null || { sudo apt-get update && sudo apt-get install -y nodejs ; }`
1. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install -y gcc ; }`
1. `gcc -std=c99 -Wall -pedantic -Ofast tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
2. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
3. `node tests/js/ciede-2000-driver.js test-cases.csv | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.js](ciede-2000-driver.js#L117) for calculations and [test-js.yml](../../.github/workflows/test-js.yml) for automation.
</details>

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :
```
 CIEDE2000 Verification Summary :
  First Verified Line : 19.8,86.4,126,87,48.32,-70.5,86.66139766452334
             Duration : 36.48 s
            Successes : 10000000
               Errors : 0
      Average Delta E : 62.9463
    Average Deviation : 6.0717893379802488e-15
    Maximum Deviation : 2.2737367544323206e-13
```

### Comparison with the npm/delta-e Library

[![ΔE2000 against npm/delta-e](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-npm-delta-e.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-npm-delta-e.yml)

Compared to the well-established npm library **delta-e** — first released in 2014 and still widely used 11 years later — this implementation of the ΔE2000 color difference formula, validated over billions color pair comparisons, exhibits an absolute deviation of no more than 5 × 10⁻¹³. As first in [C99](../c#comparison-with-the-vmaf-c99-library) and [Python](../py#comparison-with-the-python-colormath-library), this once again confirms the correctness and numerical stability of this algorithm.

### Speed Benchmark

Measured at 3,265,306 calls per second.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **GCC** : 13.3.0
- **Node.js** : 20.19.2

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in JavaScript** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=74.87&a1=-74.4&b1=-66.71&L2=92.27&a2=114.6&b2=122.7) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Used in 30+ Languages](../../#implementations)

