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
- **Calculators**:
  - A [simple calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html) for computing ΔE2000 between two **L\*a\*b\*** colors.
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

In healthcare, color can give us important information about a person's health. Delta E 2000 helps doctors and medical devices measure those color changes more accurately.

In **dermatology**, it's used to track changes in skin spots or rashes, which can help detect diseases like skin cancer. It also helps doctors see if a treatment is working by watching how skin color changes over time.

In **eye care (ophthalmology)**, it’s used to test how well people see colors and to check the color quality of devices like artificial lenses. It also helps in designing tools for people with color blindness.

In **microscopy and tissue analysis**, Delta E 2000 is used to detect small color changes in stained tissue samples — very helpful for diagnosis. Computers can even use it to automatically find unusual regions in medical images.

It's also helpful in **monitoring wound healing**, like with burns or chronic wounds, by tracking how the skin color changes. In **brain science**, researchers use color-coded images from brain scans, and ΔE 2000 helps analyze these color changes more accurately. It’s even used in **medical prosthetics**, to match artificial skin color to real skin as closely as possible.

### 🖨️ In Printing and Color Management

In printing, keeping color consistent is critical. ΔE 2000 is used to check whether printed colors match what was expected. It helps decide if small color changes are acceptable or not.

This metric is also used to **calibrate printers and screens**, making sure colors stay accurate across different devices. It’s used when creating and testing color profiles for different types of paper, ink, or machines.

ΔE 2000 also helps when **comparing printing methods** (like offset vs. digital), checking which produces better or more accurate colors. In modern printing, AI and cameras can measure color in real time using ΔE 2000, catching problems right away.

Some systems even use this data remotely — **connected printers** can send color data to the cloud for predictive maintenance. And in **augmented reality** or **3D simulations**, this metric helps match virtual colors with real-world lighting, so colors look natural on screen.

### 🏭 In Manufacturing and Industry

Many industries use color as a quality check. With ΔE 2000, manufacturers can verify that the color of a product — like paint, fabric, plastic, or packaging — is correct. Machines can detect even small color mistakes automatically.

In **robotics and automation**, color can be used to guide robots or check products on a production line. In **camera and sensor calibration**, the metric helps tune devices to see and show colors correctly, which is especially important in high-tech imaging systems.

Even **AI and computer vision systems** can benefit — adding human-like color perception helps computers tell similar colors apart more easily. In the **food industry**, this metric is used to tell if fruits are ripe or to spot spoilage just by color.

### 🚀 In New Technologies and Specialized Fields

Delta E 2000 is becoming more useful in high-tech areas. In **augmented reality**, it helps blend virtual and real objects so they look like they belong together. In **environmental monitoring**, it's used to measure color changes in nature, like water pollution or plant health.

In **cosmetics and fashion**, it helps match skin tones for makeup or check fabric colors before products go to market. In the **automotive world**, it ensures the paint job is perfect and that all materials inside the car match visually. It even helps monitor how colors fade in the sun.

In **agriculture**, farmers can track ripeness or plant health by analyzing color. In **pharmaceutical labs**, it helps make sure pills are the right color and helps monitor chemical reactions.

In **art and museum work**, it’s used to check how colors in paintings have changed over time and helps restore artworks to their original look. It also ensures color accuracy when scanning or printing fine art.

For **displays like TVs and smartphones**, Delta E 2000 helps calibrate screens to show colors correctly and reduce eye strain. In **3D printing**, it ensures materials stay color-consistent, even when printing with multiple materials.

Finally, in **forensic science and security**, it’s used to check colors in evidence, documents, or even detect fakes. And in **facial recognition**, fine color detection helps improve skin tone matching and emotion analysis.

![ΔE2000 — Some say it never needed an update…](assets/images/logo.jpg)

## Philosophy

- The pleasure was all mine.
- Be careful out there.
- Keep it real!
