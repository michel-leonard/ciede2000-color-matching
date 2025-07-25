// Limited Use License – March 1, 2025

// This source code is provided for public use under the following conditions :
// It may be downloaded, compiled, and executed, including in publicly accessible environments.
// Modification is strictly prohibited without the express written permission of the author.

// © Michel Leonard 2025

import 'dart:math';
import 'dart:io';

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
	// Returns the square root so that the DeltaE 2000 reflects the actual geometric
	// distance within the color space, which ranges from 0 to approximately 185.
	return sqrt(l * l + h * h + c * c + c * h * r_t);
}

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//   Online Tests : https://michel-leonard.github.io/ciede2000-color-matching

// L1 = 2.6    a1 = 37.6   b1 = -3.0
// L2 = 3.4    a2 = 33.2   b2 = 3.1
// CIE ΔE00 = 3.9792483954 (Bruce Lindbloom, Netflix’s VMAF, ...)
// CIE ΔE00 = 3.9792351681 (Gaurav Sharma, OpenJDK, ...)
// Deviation between implementations ≈ 1.3e-5

// See the source code comments for easy switching between these two widely used ΔE*00 implementation variants.

/////////////////////////////////////////////////
/////////////////////////////////////////////////
////////////                         ////////////
////////////    CIEDE2000 Driver     ////////////
////////////                         ////////////
/////////////////////////////////////////////////
/////////////////////////////////////////////////

// Reads a CSV file specified as the first command-line argument. For each line, this program
// in Dart displays the original line with the computed Delta E 2000 color difference appended.
// The C driver can offer CSV files to process and programmatically check the calculations performed there.

//  Example of a CSV input line : 67.24,-14.22,70,65,8,46
//    Corresponding output line : 67.24,-14.22,70,65,8,46,15.46723547943141064

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln('Usage: dart ciede-2000-driver.dart <filename>');
    exit(1);
  }
  final filename = args[0];
  final lines = File(filename).readAsLinesSync();
  for (var line in lines) {
    final v = line.split(',').map(double.parse).toList();
    final deltaE = ciede_2000(v[0], v[1],v[2], v[3], v[4], v[5]);
    print('${line},${deltaE}');
  }
}
