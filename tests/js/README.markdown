# ΔE2000 — Accurate. Fast. JavaScript-powered.

CIE 2000 is the current industry standard for quantifying color differences in a way that best matches human vision.

This reference **JavaScript** implementation offers an easy way to calculate these differences accurately within scripts.

## Overview

The developed algorithm enables software to evaluate color similarities (or differences) with scientific rigor.

As a general rule, 🔵 navy blue and 🟡 yellow, which are very different colors, have a ΔE\*<sub>00</sub> of around 115.

Values [such as 5](https://michel-leonard.github.io/ciede2000-color-matching/de2000-rgb-pairs.html?seq=50&delta-e=5) indicate greater closeness, making this both a simple and advanced method of color comparison.

## Implementation Details

The complete source code, released on March 1, 2025, is available [here](../../ciede-2000.js#L6) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.js).

This reference implementation integrates seamlessly with [TypeScript](../ts#δe2000--accurate-fast-typescript-powered), Node.js, and Deno environments.

<details>
<summary>What two options are available for matching ΔE2000 calculations with existing calculations ?</summary>

#### Option 1 (default)
 This often-used option consists of a coding simplification that is a historical legacy of early implementations :
```javascript
h_m += Math.PI;
// h_m += h_m < Math.PI ? Math.PI : -Math.PI;
```

#### Option 2 (compatible with Gaurav Sharma’s precise calculations)
There’s no room for ambiguity, this inversion of the commented line in the source code ensures compliance with the official :
```javascript
// h_m += Math.PI;
h_m += h_m < Math.PI ? Math.PI : -Math.PI;
```

**Note** : the difference between the two options is minimal (±0.0003 on the calculated color difference) and usually overlooked.
</details>

<details>
<summary>Do you have an implementation in arbitrary precision ?</summary>

[![JavaScript CIEDE2000 Testing (multiprecision)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-js-multiprecision.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-js-multiprecision.yml)

Of course, it works with `decimal.js` included in the source code, both in the browser and on Node.js, and its source code is [here](ciede-2000-multiprecision.js#L46).
</details>

## Example usage in JavaScript

To calculate the **Delta E 2000** difference between two colors expressed in the **L\*a\*b\* color space**, use the `ciede_2000` function :

```javascript
// Define color 1 in L*a*b* space
const l1 = 43.2, a1 = 31.2, b1 = 4.1;

// Define color 2 in L*a*b* space
const l2 = 43.0, a2 = 35.5, b2 = -4.3;

// Calculate ΔE2000 color difference
const deltaE = ciede_2000(l1, a1, b1, l2, a2, b2);
console.log(deltaE);

// .................................................. This shows a ΔE2000 of 5.2895865658
// As explained in the comments, compliance with Gaurav Sharma would display 5.2895721943
```

**Note** : L\* is nominally between 0 and 100, a\* and b\* generally between -128 and +127.

### 🎨 Flexibility

To compare **hexadecimal** (e.g., `#FFF`) or **RGB colors** using the CIEDE2000 function, see these example scripts :
- [compare-hex-colors.js](compare-hex-colors.js#L181)
- [compare-rgb-colors.js](compare-rgb-colors.js#L181)

The [all-in-one](../../#rgb-and-hexadecimal-color-comparison-for-the-web-in-javascript) function supports both RGB and hexadecimal formats, allowing quick color difference calculations using the D65 illuminant.

## Browser Tools

See this JavaScript CIEDE2000 color difference formula in action here :
- **Generators** :
  - A [discovery generator](https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html) for quick, small-scale testing and exploration.
  - A [large-scale generator](https://michel-leonard.github.io/ciede2000-color-matching) and validator used to test new implementations.
  - A [ΔE-to-RGB pairs generator](https://michel-leonard.github.io/ciede2000-color-matching/de2000-rgb-pairs.html) that shows RGB color pairs sharing a given ΔE2000 value (±0.05).
- **Calculators**:
  - A [simple calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html) that shows in 10 steps how to compute ΔE2000 between two **L\*a\*b\*** colors.
  - A [pickers-based calculator](https://michel-leonard.github.io/ciede2000-color-matching/rgb-hex-color-calculator.html) for computing ΔE2000 between two **RGB** or **Hex** colors.
- **Other** :
  - A [tool](https://michel-leonard.github.io/ciede2000-color-matching/color-name-from-image.html) that identify the name of the selected color based on a picture.

## Verification

[![JavaScript CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-js.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-js.yml)

<details>
<summary>What is the testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by JavaScript**, like this :

1. `command -v node > /dev/null || { sudo apt-get update && sudo apt-get install nodejs ; }`
2. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install gcc ; }`
3. `gcc -std=c99 -Wall -pedantic -O2 -g tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
4. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
5. `node tests/js/ciede-2000-driver.js test-cases.csv | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.js](ciede-2000-driver.js#L86) for calculations and [test-js.yml](../../.github/workflows/test-js.yml) for automation.
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

### Comparison with the npm/chroma-js Library

[![ΔE2000 against chroma in JavaScript](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-chroma.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-chroma.yml)

Compared to the well-established **chroma-js** library on npm — first published in 2011 and still widely used 14 years later — this ΔE\*<sub>00</sub> function, validated on billions of random L\*a\*b\* color pairs, has an absolute deviation of no more than **5 × 10<sup>-13</sup>**. As previously in [C99](../c#comparison-with-the-vmaf-c99-library) and [Python](../py#comparison-with-the-python-colormath-library), this once again confirms the accuracy and numerical stability of this advanced colorimetry algorithm.

### Comparison with the npm/delta-e Library

[![ΔE2000 against npm/delta-e in JavaScript](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-npm-delta-e.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-npm-delta-e.yml)

Compared to the well-maintained **delta-e** library on npm — first published in 2014 and still widely used 11 years later — this implementation of the ΔE2000 color difference formula, validated on billions of random L\*a\*b\* color pairs, has an absolute deviation of no more than **5 × 10<sup>-13</sup>**. This test confirms the general interoperability of the `ciede_2000` function in JavaScript, as well as its **production-ready** status.

> [!IMPORTANT]
> To correct this JavaScript source code to exact match certain third-party ΔE2000 functions, follow the comments in the source code.

> This formula, "small" in size, is an essential pillar of color management, deserving of this rigorous, tested and reliable industrial treatment.

### Speed Benchmark

Measured at 3,265,306 calls per second.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **GCC** : 13.3
- **NPM** : 10.8.2
- **Node.js** : 20.20.0
- **decimal.js** : 10.6.0

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in JavaScript** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=57.9&a1=6.5&b1=6&L2=51.2&a2=38.1&b2=-34.8) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Suitable in 40+ Languages](../../#implementations)
