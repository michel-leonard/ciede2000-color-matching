// This function written in Dart is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

import 'dart:math';

// The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
// "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
double ciede_2000(double l_1, double a_1, double b_1, double l_2, double a_2, double b_2) {
	// Working in Dart/Flutter with the CIEDE2000 color-difference formula.
	// k_l, k_c, k_h are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	const double k_l = 1.0, k_c = 1.0, k_h = 1.0;
	double n = (sqrt(a_1 * a_1 + b_1 * b_1) + sqrt(a_2 * a_2 + b_2 * b_2)) * 0.5;
	n = n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - sqrt(n / (n + 6103515625.0)));
	// Application of the chroma correction factor.
	final double c_1 = sqrt(a_1 * a_1 * n * n + b_1 * b_1);
	final double c_2 = sqrt(a_2 * a_2 * n * n + b_2 * b_2);
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	double h_1 = atan2(b_1, a_1 * n), h_2 = atan2(b_2, a_2 * n);
	if (h_1 < 0.0) h_1 += 2.0 * pi;
	if (h_2 < 0.0) h_2 += 2.0 * pi;
	n = (h_2 - h_1).abs();
	// Cross-implementation consistent rounding.
	if (pi - 1E-14 < n && n < pi + 1E-14) n = pi;
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	double h_m = (h_1 + h_2) * 0.5, h_d = (h_2 - h_1) * 0.5;
	if (pi < n) {
		h_d += pi;
		// 📜 Sharma’s formulation doesn’t use the next line, but the one after it,
		// and these two variants differ by ±0.0003 on the final color differences.
		h_m += pi;
		// if (h_m < pi) h_m += pi; else h_m -= pi;
	}
	final double p = 36.0 * h_m - 55.0 * pi;
	n = (c_1 + c_2) * 0.5;
	n = n * n * n * n * n * n * n;
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	final double r_t = -2.0 * sqrt(n / (n + 6103515625.0))
				* sin(pi / 3.0 * exp(p * p / (-25.0 * pi * pi)));
	n = (l_1 + l_2) * 0.5;
	n = (n - 50.0) * (n - 50.0);
	// Lightness.
	final double l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / sqrt(20.0 + n)));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	final double t = 1.0 	+ 0.24 * sin(2.0 * h_m + pi * 0.5)
				+ 0.32 * sin(3.0 * h_m + 8.0 * pi / 15.0)
				- 0.17 * sin(h_m + pi / 3.0)
				- 0.20 * sin(4.0 * h_m + 3.0 * pi / 20.0);
	n = c_1 + c_2;
	// Hue.
	final double h = 2.0 * sqrt(c_1 * c_2) * sin(h_d) / (k_h * (1.0 + 0.0075 * n * t));
	// Chroma.
	final double c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
	// Returning the square root ensures that dE00 accurately reflects the
	// geometric distance in color space, which can range from 0 to around 185.
	return sqrt(l * l + h * h + c * c + c * h * r_t);
}

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//   Online Tests : https://michel-leonard.github.io/ciede2000-color-matching

// L1 = 33.9   a1 = 24.6   b1 = 4.9
// L2 = 35.9   a2 = 19.5   b2 = -2.9
// CIE ΔE00 = 5.9896524086 (Bruce Lindbloom, Netflix’s VMAF, ...)
// CIE ΔE00 = 5.9896664145 (Gaurav Sharma, OpenJDK, ...)
// Deviation between implementations ≈ 1.4e-5

// See the source code comments for easy switching between these two widely used ΔE*00 implementation variants.

// These color conversion functions written in Dart are released into the public domain.
// They are provided "as is" without any warranty, express or implied.

// rgb in 0..1
List<double> rgb_to_xyz(double r,double g,double b) {
	// Apply a gamma correction to each channel.
	r = r < 0.040448236277105097 ? r / 12.92 : pow((r + 0.055) / 1.055, 2.4);
	g = g < 0.040448236277105097 ? g / 12.92 : pow((g + 0.055) / 1.055, 2.4);
	b = b < 0.040448236277105097 ? b / 12.92 : pow((b + 0.055) / 1.055, 2.4);

	// Applying linear transformation using RGB to XYZ transformation matrix.
	final double x = r * 41.24564390896921145 + g * 35.75760776439090507 + b * 18.04374830853290341;
	final double y = r * 21.26728514056222474 + g * 71.51521552878181013 + b * 7.21749933075596513;
	final double z = r * 1.93338955823293176 + g * 11.91919550818385936 + b * 95.03040770337479886;

	return [x, y, z];
}

List<double> xyz_to_lab(double x, double y, double z) {
	// Reference white point : D65 2° Standard observer
	final double refX = 95.047;
	final double refY = 100.000;
	final double refZ = 108.883;

	x /= refX;
	y /= refY;
	z /= refZ;

	// Applying the CIE standard transformation.
	x = x < 216.0 / 24389.0 ? ((841.0 / 108.0) * x) + (4.0 / 29.0) : pow(x, 1.0 / 3.0);
	y = y < 216.0 / 24389.0 ? ((841.0 / 108.0) * y) + (4.0 / 29.0) : pow(y, 1.0 / 3.0);
	z = z < 216.0 / 24389.0 ? ((841.0 / 108.0) * z) + (4.0 / 29.0) : pow(z, 1.0 / 3.0);

	final double l = (116.0 * y) - 16.0;
	final double a = 500.0 * (x - y);
	final double b = 200.0 * (y - z);

	return [l, a, b];
}

// rgb in 0..1
List<double> rgb_to_lab(double r, double g, double b) {
	final List<double> xyz = rgb_to_xyz(r, g, b);
	return xyz_to_lab(xyz[0], xyz[1], xyz[2]);
}

List<double> lab_to_xyz(double l, double a, double b) {
	// Reference white point : D65 2° Standard observer
	final double refX = 95.047;
	final double refY = 100.000;
	final double refZ = 108.883;

	double y = (l + 16.0) / 116.0;
	double x = a / 500.0 + y;
	double z = y - b / 200.0;

	final double x3 = x * x * x;
	final double z3 = z * z * z;

	x = x3 < 216.0 / 24389.0 ? (x - 4.0 / 29.0) / (841.0 / 108.0) : x3;
	y = l < 8.0 ? l / (24389.0 / 27.0) : y * y * y;
	z = z3 < 216.0 / 24389.0 ? (z - 4.0 / 29.0) / (841.0 / 108.0) : z3;

	return [x * refX, y * refY, z * refZ];
}

// rgb in 0..1
List<double> xyz_to_rgb(double x, double y, double z) {
	// Applying linear transformation using the XYZ to RGB transformation matrix.
	double r = x * 0.032404541621141049051 + y * -0.015371385127977165753 + z * -0.004985314095560160079;
	double g = x * -0.009692660305051867686 + y * 0.018760108454466942288 + z * 0.00041556017530349983;
	double b = x * 0.000556434309591145522 + y * -0.002040259135167538416 + z * 0.010572251882231790398;

	// Apply gamma correction.
	r = r < 0.003130668442500634 ? 12.92 * r : 1.055 * pow(r, 1.0 / 2.4) - 0.055;
	g = g < 0.003130668442500634 ? 12.92 * g : 1.055 * pow(g, 1.0 / 2.4) - 0.055;
	b = b < 0.003130668442500634 ? 12.92 * b : 1.055 * pow(b, 1.0 / 2.4) - 0.055;

	return [r, g, b];
}

// rgb in 0..1
List<double> lab_to_rgb(double l, double a, double b) {
	final List<double> xyz = lab_to_xyz(l, a, b);
	return xyz_to_rgb(xyz[0], xyz[1], xyz[2]);
}

// rgb in 0..255
List<int> hex_to_rgb(String s) {
	// Also support the short syntax (ie "#FFF") as input.
	final n = int.parse((s.length == 4 ? s[0] + s[1] + s[1] + s[2] + s[2] + s[3] + s[3] : s).substring(1), radix: 16);
	return [n >> 16 & 0xff, n >> 8 & 0xff, n & 0xff];
}

// rgb in 0..255
String rgb_to_hex(int r, int g, int b) {
	// Also provide the short syntax (ie "#FFF") as output.
	final String s = '#' + r.toRadixString(16).padLeft(2, '0') + g.toRadixString(16).padLeft(2, '0') + b.toRadixString(16).padLeft(2, '0');
	return s[1] == s[2] && s[3] == s[4] && s[5] == s[6] ? '#' + s[1] + s[3] + s[5] : s;
}

List<double> hex_to_lab(String hex) {
	List<int> rgb = hex_to_rgb(hex);
	return rgb_to_lab(rgb[0] / 255.0, rgb[1] / 255.0, rgb[2] / 255.0);
}

//////////////////////////////////////////////////
///////////                      /////////////////
///////////   CIE ΔE2000 Demo    /////////////////
///////////                      /////////////////
//////////////////////////////////////////////////

// The goal of this demo in Dart/Flutter is to use the CIEDE2000 function to compare two RGB colors.

void main() {
	final List<int> rgb1 = [0, 0, 139]; // darkblue
	final List<int> rgb2 = [0, 0, 128]; // navy

	// 1. RGB -> LAB
	final lab1 = rgb_to_lab(rgb1[0] / 255.0, rgb1[1] / 255.0, rgb1[2] / 255.0);
	final lab2 = rgb_to_lab(rgb2[0] / 255.0, rgb2[1] / 255.0, rgb2[2] / 255.0);

	print('RGB(${rgb1[0]}, ${rgb1[1]}, ${rgb1[2]}) -> LAB(L: ${lab1[0].toStringAsFixed(4)}, a: ${lab1[1].toStringAsFixed(4)}, b: ${lab1[2].toStringAsFixed(4)})');
	print('RGB(${rgb2[0]}, ${rgb2[1]}, ${rgb2[2]}) -> LAB(L: ${lab2[0].toStringAsFixed(4)}, a: ${lab2[1].toStringAsFixed(4)}, b: ${lab2[2].toStringAsFixed(4)})');

	// 2. Delta E 2000
	final deltaE = ciede_2000(lab1[0], lab1[1], lab1[2], lab2[0], lab2[1], lab2[2]);
	print('ΔE2000 : ${deltaE.toStringAsFixed(4)}');

	// This shows a ΔE2000 of 1.56
}
