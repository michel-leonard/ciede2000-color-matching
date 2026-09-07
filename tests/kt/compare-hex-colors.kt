// This function written in Kotlin is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

import kotlin.math.*

// The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
// "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
fun ciede_2000(l_1: Double, a_1: Double, b_1: Double, l_2: Double, a_2: Double, b_2: Double): Double {
	// Working in Kotlin with the CIEDE2000 color-difference formula.
	// k_l, k_c, k_h are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	val k_l = 1.0;
	val k_c = 1.0;
	val k_h = 1.0;
	var n = (sqrt(a_1 * a_1 + b_1 * b_1) + sqrt(a_2 * a_2 + b_2 * b_2)) * 0.5;
	n = n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - sqrt(n / (n + 6103515625.0)));
	// Application of the chroma correction factor.
	val c_1 = sqrt(a_1 * a_1 * n * n + b_1 * b_1);
	val c_2 = sqrt(a_2 * a_2 * n * n + b_2 * b_2);
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	var h_1 = atan2(b_1, a_1 * n);
	var h_2 = atan2(b_2, a_2 * n);
	if (h_1 < 0.0)
		h_1 += 2.0 * PI;
	if (h_2 < 0.0)
		h_2 += 2.0 * PI;
	n = abs(h_2 - h_1);
	// Cross-implementation consistent rounding.
	if (PI - 1E-14 < n && n < PI + 1E-14)
		n = PI;
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	var h_m = (h_1 + h_2) * 0.5;
	var h_d = (h_2 - h_1) * 0.5;
	if (PI < n) {
		h_d += PI;
		// 📜 Sharma’s formulation doesn’t use the next line, but the one after it,
		// and these two variants differ by ±0.0003 on the final color differences.
		h_m += PI;
		// if (h_m < PI) h_m += PI; else h_m -= PI;
	}
	val p = 36.0 * h_m - 55.0 * PI;
	n = (c_1 + c_2) * 0.5;
	n = n * n * n * n * n * n * n;
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	val r_t = -2.0 * sqrt(n / (n + 6103515625.0)) * sin(PI / 3.0 * exp((p * p) / (-25.0 * PI * PI)));
	n = (l_1 + l_2) * 0.5;
	n = (n - 50.0) * (n - 50.0);
	// Lightness.
	val l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / sqrt(20.0 + n)));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	val t = 1.0 +	0.24 * sin(2.0 * h_m + PI * 0.5) +
			0.32 * sin(3.0 * h_m + 8.0 * PI / 15.0) -
			0.17 * sin(h_m + PI / 3.0) -
			0.20 * sin(4.0 * h_m + 3.0 * PI / 20.0);
	n = c_1 + c_2;
	// Hue.
	val h = 2.0 * sqrt(c_1 * c_2) * sin(h_d) / (k_h * (1.0 + 0.0075 * n * t));
	// Chroma.
	val c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
	// Returning the square root ensures that dE00 accurately reflects the
	// geometric distance in color space, which can range from 0 to around 185.
	return sqrt(l * l + h * h + c * c + c * h * r_t);
}

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//   Online Tests : https://michel-leonard.github.io/ciede2000-color-matching

// L1 = 24.8   a1 = 11.5   b1 = 3.6
// L2 = 25.8   a2 = 17.6   b2 = -5.0
// CIE ΔE00 = 7.5353340235 (Bruce Lindbloom, Netflix’s VMAF, ...)
// CIE ΔE00 = 7.5353193430 (Gaurav Sharma, OpenJDK, ...)
// Deviation between implementations ≈ 1.5e-5

// See the source code comments for easy switching between these two widely used ΔE*00 implementation variants.

// These color conversion functions written in Kotlin are released into the public domain.
// They are provided "as is" without any warranty, express or implied.

// rgb in 0..1
fun rgb_to_xyz(ra: Double, ga: Double, ba: Double): DoubleArray {
	// Apply a gamma correction to each channel.
	val r = if (ra < 0.040448236277105097) ra / 12.92 else Math.pow((ra + 0.055) / 1.055, 2.4)
	val g = if (ga < 0.040448236277105097) ga / 12.92 else Math.pow((ga + 0.055) / 1.055, 2.4)
	val b = if (ba < 0.040448236277105097) ba / 12.92 else Math.pow((ba + 0.055) / 1.055, 2.4)

	// Applying linear transformation using RGB to XYZ transformation matrix.
	val x = r * 41.24564390896921145 + g * 35.75760776439090507 + b * 18.04374830853290341
	val y = r * 21.26728514056222474 + g * 71.51521552878181013 + b * 7.21749933075596513
	val z = r * 1.93338955823293176 + g * 11.91919550818385936 + b * 95.03040770337479886

	return doubleArrayOf(x, y, z)
}

fun xyz_to_lab(xa: Double, ya: Double, za: Double): DoubleArray {
	// Reference white point : D65 2° Standard observer
	val refX = 95.047
	val refY = 100.000
	val refZ = 108.883

	var x = xa / refX
	var y = ya / refY
	var z = za / refZ

	// Applying the CIE standard transformation.
	x = if (x < 216.0 / 24389.0) ((841.0 / 108.0) * x) + (4.0 / 29.0) else Math.cbrt(x)
	y = if (y < 216.0 / 24389.0) ((841.0 / 108.0) * y) + (4.0 / 29.0) else Math.cbrt(y)
	z = if (z < 216.0 / 24389.0) ((841.0 / 108.0) * z) + (4.0 / 29.0) else Math.cbrt(z)

	val l = (116.0 * y) - 16.0
	val a = 500.0 * (x - y)
	val b = 200.0 * (y - z)

	return doubleArrayOf(l, a, b)
}

// rgb in 0..1
fun rgb_to_lab(r: Double, g: Double, b: Double): DoubleArray {
	val xyz = rgb_to_xyz(r, g, b)
	return xyz_to_lab(xyz[0], xyz[1], xyz[2])
}

fun lab_to_xyz(l: Double, a: Double, b: Double): DoubleArray {
	// Reference white point : D65 2° Standard observer
	val refX = 95.047
	val refY = 100.000
	val refZ = 108.883

	var y = (l + 16.0) / 116.0
	var x = a / 500.0 + y
	var z = y - b / 200.0

	val x3 = x * x * x
	val z3 = z * z * z

	x = if (x3 < 216.0 / 24389.0) (x - 4.0 / 29.0) / (841.0 / 108.0) else x3
	y = if (l < 8.0) l / (24389.0 / 27.0) else y * y * y
	z = if (z3 < 216.0 / 24389.0) (z - 4.0 / 29.0) / (841.0 / 108.0) else z3

	return doubleArrayOf(x * refX, y * refY, z * refZ)
}

// rgb in 0..1
fun xyz_to_rgb(x: Double, y: Double, z: Double): DoubleArray {
	// Applying linear transformation using the XYZ to RGB transformation matrix.
	var r = x * 0.032404541621141049051 + y * -0.015371385127977165753 + z * -0.004985314095560160079
	var g = x * -0.009692660305051867686 + y * 0.018760108454466942288 + z * 0.00041556017530349983
	var b = x * 0.000556434309591145522 + y * -0.002040259135167538416 + z * 0.010572251882231790398

	// Apply gamma correction.
	r = if (r < 0.003130668442500634) 12.92 * r else 1.055 * Math.pow(r, 1.0 / 2.4) - 0.055
	g = if (g < 0.003130668442500634) 12.92 * g else 1.055 * Math.pow(g, 1.0 / 2.4) - 0.055
	b = if (b < 0.003130668442500634) 12.92 * b else 1.055 * Math.pow(b, 1.0 / 2.4) - 0.055

	return doubleArrayOf(r, g, b)
}

// rgb in 0..1
fun lab_to_rgb(l: Double, a: Double, b: Double): DoubleArray {
	val xyz = lab_to_xyz(l, a, b)
	return xyz_to_rgb(xyz[0], xyz[1], xyz[2])
}

// rgb in 0..255
fun hex_to_rgb(s: String): IntArray {
	// Also support the short syntax (ie "#FFF") as input.
	val n = (if (s.length == 4) "#" + s[1].toString().repeat(2) + s[2].toString().repeat(2) + s[3].toString()
		.repeat(2) else s).substring(1).toInt(16)
	return intArrayOf((n shr 16) and 0xFF, (n shr 8) and 0xFF, n and 0xFF)
}

// rgb in 0..255
fun rgb_to_hex(r: Int, g: Int, b: Int): String {
	// Also provide the short syntax (ie "#FFF") as output.
	val s = "#%02X%02X%02X".format(r, g, b)
	return if (s[1] == s[2] && s[3] == s[4] && s[5] == s[6]) "#${s[1]}${s[3]}${s[5]}" else s
}

// Constants used in Color Conversion :
// 216.0 / 24389.0 = 0.0088564516790356308171716757554635286399606379925376194185903481077
// 841.0 / 108.0 = 7.78703703703703703703703703703703703703703703703703703703703703703703703703
// 4.0 / 29.0 = 0.13793103448275862068965517241379310344827586206896551724137931034482758620
// 24389.0 / 27.0 = 903.296296296296296296296296296296296296296296296296296296296296296296296296
// 1.0 / 2.4 = 0.41666666666666666666666666666666666666666666666666666666666666666666666666
// To get 0.040448236277105097132567243294938 we perform x/12.92 = ((x+0.055)/1.055)^2.4
// To get 0.00313066844250063403284123841596 we perform 12.92*x = 1.055*x^(1/2.4)-0.055

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
////////////////////                                   ///////////////////////
////////////////////              TESTING              ///////////////////////
////////////////////                                   ///////////////////////
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

// The goal of this demo in Kotlin is to use the CIEDE2000 function to compare two hexadecimal colors.

fun main() {
	// 1. Define two HEX color codes
	val hex_1 = "#00ff00"   // Pure green
	val hex_2 = "#00c800"   // Slightly darker green

	// 2. Convert HEX colors to RGB format
	val rgb_1 = hex_to_rgb(hex_1)
	val rgb_2 = hex_to_rgb(hex_2)

	// 3. Normalize RGB values (0–255 → 0.0–1.0) and convert them to L*a*b* color space
	val lab_1 = rgb_to_lab(rgb_1[0] / 255.0, rgb_1[1] / 255.0, rgb_1[2] / 255.0)
	val lab_2 = rgb_to_lab(rgb_2[0] / 255.0, rgb_2[1] / 255.0, rgb_2[2] / 255.0)

	// 4. Calculate the color difference using the CIEDE2000 ΔE formula
	val delta_e = ciede_2000(lab_1[0], lab_1[1], lab_1[2], lab_2[0], lab_2[1], lab_2[2])

	// 5. Display the original HEX color values
	println("Color 1 HEX: ${hex_1}")
	println("Color 2 HEX: ${hex_2}")

	// 6. Display the converted RGB values
	println("Color 1 RGB: ${rgb_1.joinToString(", ", "(", ")")}")
	println("Color 2 RGB: ${rgb_2.joinToString(", ", "(", ")")}")

	// 7. Display the L*a*b* values with formatting to 2 decimal places
	println("Color 1 Lab: (L=${"%.2f".format(lab_1[0])}, a=${"%.2f".format(lab_1[1])}, b=${"%.2f".format(lab_1[2])})")
	println("Color 2 Lab: (L=${"%.2f".format(lab_2[0])}, a=${"%.2f".format(lab_2[1])}, b=${"%.2f".format(lab_2[2])})")

	// 8. Display the final Delta E value with 4 decimal places
	println("Delta E (CIEDE2000) = ${"%.4f".format(delta_e)}")

	// The result shows a perceptible color difference: ΔE2000 ≈ 12.58
}
