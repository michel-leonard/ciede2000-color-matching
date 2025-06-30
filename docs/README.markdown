## Topic of This Repository

- 颜色差异
- Diferència de color
- Delta E
- Écart de couleur
- اختلاف رنگ
- 色差
- 색차 (색 공간)
- Формула цветового отличия
- Színkülönbség
- Väriero

## List of Pages

Based on our JavaScript [implementation](../ciede-2000.js#L6), you can see the CIEDE2000 color difference formula in action here :
- **Generators** :
  - A [discovery generator](https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html) for quick, small-scale testing and exploration.
  - A [large-scale generator](https://michel-leonard.github.io/ciede2000-color-matching) and validator used to test new implementations.
  - A [ΔE-to-RGB pairs generator](https://michel-leonard.github.io/ciede2000-color-matching/de2000-rgb-pairs.html) that shows RGB color pairs sharing a given ΔE2000 value (±0.05).
- **Calculators**:
  - A [simple calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html) that shows in 10 steps how to compute ΔE2000 between two **L\*a\*b\*** colors.
  - A [pickers-based calculator](https://michel-leonard.github.io/ciede2000-color-matching/rgb-hex-color-calculator.html) for computing ΔE2000 between two **RGB** or **Hex** colors.
- **Other** :
  - A [tool](https://michel-leonard.github.io/ciede2000-color-matching/color-name-from-image.html) that identify the name of the selected color based on a picture.
## External Links

- [Rosetta Code](https://rosettacode.org/wiki/Color_Difference_CIE_ΔE2000) invites you to port our ΔE 2000 function to your favorite programming language.
- **Technical**
  - Learn [more](https://github.com/actions/runner-images/tree/main/images) about the execution context of test workflows.

## Where to Use the CIE ΔE 2000 Metric

These implementations of the **ΔE 2000 metric** provide robust color difference calculations, and can be widely used almost everywhere.

### 🏥 In Medicine

In the field of health, color provides important information about a person's state of health, and Delta E 2000 is in action.

In **dermatology**, this color-difference formula is used to detect disease and track changes in skin color over time.

In the field of **eye care**, ΔE2000 is used, among other things, to design tools for people suffering from color blindness.

In microscopy and tissue analysis, software programs use CIEDE2000 to automatically find unusual regions in medical images.

In the field of **brain science**, researchers analyze images from brain scans, and ΔE 2000 helps identify color variations with greater precision.

### 🖨️ In Printing and Color Management

The ΔE 2000 is standardized by the CIE and included in ISO standards for printing.

In printing, ΔE 2000 is used to validate that printed colors correspond to what is expected.

This color difference formula is also used to **calibrate printers**, and produce color profiles for paper, ink and machines.

In modern printing, an AI measures colors using ΔE 2000, and prevents problems.

In **augmented reality**, this metric helps to match virtual colors with those of the real world.

### 🏭 In Manufacturing and Industry

Manufacturers use ΔE 2000 to check that the color of a product (paint, fabric, plastic) is correct.

For **camera and sensor calibration**, this metric is used to set devices to see and display colors correctly.

CIEDE2000 is also used to determine whether fruit is ripe or to identify spoiled produce.

### 🚀 In New Technologies and Specialized Fields

With regard to the **environment**, ΔE2000 is used to measure color changes (water, plants) in nature.

CIEDE2000 is used to produce better quality make-up, and pharmaceutical laboratories use it to control chemical reactions.

ΔE 2000 is used to check how the colors of have changed over time, **restore works of art**, and guarantee accuracy when digitizing them.

This metric is also used to detect counterfeits.

![ΔE2000 — Some say it never needed an update…](https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/docs/assets/images/logo.jpg)

## Philosophy

- The pleasure was all mine.
- Be careful out there.
- Keep it real!
