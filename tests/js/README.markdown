# ΔE2000 — Accurate. Fast. JavaScript-powered.

This reference ΔE2000 implementation written in JavaScript provides reliable and accurate perceptual **color difference** calculation.

## Source Code

The full source code is available [here](../../ciede-2000.js#L6), and is archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.js).

TypeScript, Node.js and Deno can all seamlessly integrate this classic source code.

## Example usage in JavaScript

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```javascript
// Example usage of the CIEDE2000 function in JavaScript

// L1 = 19.3166        a1 = 73.5           b1 = 122.428
// L2 = 19.0           a2 = 76.2           b2 = 91.372

const deltaE = ciede_2000(l1, a1, b1, l2, a2, b2);
console.log(deltaE);

// This shows a ΔE2000 of 9.60876174564
```

**Note**: L\* is usually between 0 and 100, a\* and b\* between -128 and +127.

### 🎨 Flexibility

To compare **hexadecimal** (e.g., "#FFF") or **RGB colors** using the CIEDE2000 function, follow these examples :
- [compare-hex-colors.js](compare-hex-colors.js#L169)
- [compare-rgb-colors.js](compare-rgb-colors.js#L169)

The [all-in-one](../../#rgb-and-hexadecimal-color-comparison-for-the-web-in-javascript) function accepts RGB and hexadecimal color formats to calculate ΔE2000 **color differences**.

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

[![JavaScript CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-js.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-js.yml)

<details>
<summary>What is the testing procedure ?</summary>

 1. `gcc -O3 tests/c/stdin-verifier.c -o verifier -lm`
 2. `node tests/js/ciede-2000-testing.js 10000000 | ./verifier > test-output.txt`
</details>

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
CIEDE2000 Verification Summary :
- Last Verified Line : 74.87,-74.4,-66.71,92.27,114.6,122.7,72.09723914114998
- Duration : 34.09 s
- Successes : 10000000
- Errors : 0
- Maximum Difference : 2.5579538487363607e-13
```

### Computational Speed

This function was measured at a speed of 3,265,306 calls per second.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **GCC** : 13.3.0
- **NodeJS** : 20.19.2

## Conclusion

With over 20 years serving developers, this **trusted color comparison** routine developed in JavaScript brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=74.87&a1=-74.4&b1=-66.71&L2=92.27&a2=114.6&b2=122.7) — [Workflow Details](../../.github/workflows#workflow-details) — [Across 30+ programming languages](../../#implementations)

