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
	// Since hypot is not available, sqrt is used here to calculate the
	// Euclidean distance, without avoiding overflow/underflow.
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
		if (0.0 < h_d) h_d -= pi;
		else h_d += pi;
		h_m += pi;
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
	// Returns the square root so that the Delta E 2000 reflects the actual geometric
	// distance within the color space, which ranges from 0 to approximately 185.
	return sqrt(l * l + h * h + c * c + c * h * r_t);
}

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

// L1 = 70.8           a1 = -109.041       b1 = 54.0
// L2 = 70.8           a2 = -109.0         b2 = 54.0
// CIE ΔE2000 = ΔE00 = 0.00774787701

// L1 = 11.82          a1 = -49.0          b1 = 82.921
// L2 = 11.82          a2 = -47.0          b2 = 82.921
// CIE ΔE2000 = ΔE00 = 0.7000907747

// L1 = 68.49          a1 = -111.081       b1 = 40.0
// L2 = 69.6643        a2 = -119.8         b2 = 40.0
// CIE ΔE2000 = ΔE00 = 1.78942901572

// L1 = 28.482         a1 = -120.0         b1 = 35.94
// L2 = 28.482         a2 = -112.0         b2 = 27.93
// CIE ΔE2000 = ΔE00 = 2.34646183542

// L1 = 4.776          a1 = -127.6         b1 = -32.1476
// L2 = 8.8533         a2 = -117.73        b2 = -32.1476
// CIE ΔE2000 = ΔE00 = 2.99185335649

// L1 = 61.905         a1 = -14.28         b1 = 57.0
// L2 = 65.6           a2 = -12.0231       b2 = 57.0
// CIE ΔE2000 = ΔE00 = 3.36092754561

// L1 = 94.0           a1 = 94.0           b1 = -102.73
// L2 = 82.593         a2 = 81.6           b2 = -104.5291
// CIE ΔE2000 = ΔE00 = 8.46157223469

// L1 = 32.41          a1 = -53.3451       b1 = 1.32
// L2 = 24.0           a2 = -15.5405       b2 = -4.64
// CIE ΔE2000 = ΔE00 = 17.09175252645

// L1 = 48.844         a1 = -103.4         b1 = 66.0
// L2 = 72.11          a2 = -125.73        b2 = 45.6923
// CIE ΔE2000 = ΔE00 = 21.8488722228

// L1 = 69.918         a1 = 15.255         b1 = 59.7701
// L2 = 88.58          a2 = -16.3          b2 = 81.936
// CIE ΔE2000 = ΔE00 = 23.68701354983

/////////////////////////////////////////////////
/////////////////////////////////////////////////
////////////                         ////////////
////////////    CIEDE2000 Driver     ////////////
////////////                         ////////////
/////////////////////////////////////////////////
/////////////////////////////////////////////////

// Reads a CSV file specified as the first command-line argument. For each line, the program
// outputs the original line with the computed Delta E 2000 color difference appended.

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
