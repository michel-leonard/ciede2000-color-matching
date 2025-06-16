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

// L1 = 66.14          a1 = -116.03        b1 = 90.2391
// L2 = 66.14          a2 = -115.931       b2 = 90.2391
// CIE ΔE2000 = ΔE00 = 0.0181767535

// L1 = 74.3           a1 = -109.0         b1 = 24.6
// L2 = 74.3           a2 = -109.0         b2 = 25.0
// CIE ΔE2000 = ΔE00 = 0.1337570419

// L1 = 37.0           a1 = -86.71         b1 = -65.5
// L2 = 37.0           a2 = -90.5          b2 = -65.5
// CIE ΔE2000 = ΔE00 = 0.86593849746

// L1 = 73.51          a1 = 48.316         b1 = 96.86
// L2 = 73.51          a2 = 49.0           b2 = 103.0
// CIE ΔE2000 = ΔE00 = 1.41834622139

// L1 = 1.7            a1 = -113.0         b1 = -38.5806
// L2 = 4.7            a2 = -115.39        b2 = -38.5806
// CIE ΔE2000 = ΔE00 = 1.82096449832

// L1 = 78.7           a1 = 106.0          b1 = -12.67
// L2 = 78.7           a2 = 106.0          b2 = -19.8
// CIE ΔE2000 = ΔE00 = 2.14905669149

// L1 = 70.5192        a1 = -81.4          b1 = 23.2378
// L2 = 76.3101        a2 = -87.4          b2 = 23.2378
// CIE ΔE2000 = ΔE00 = 4.50488763865

// L1 = 70.0           a1 = -6.1235        b1 = -75.0
// L2 = 72.452         a2 = -8.0           b2 = -117.987
// CIE ΔE2000 = ΔE00 = 7.81193431265

// L1 = 49.59          a1 = 74.8           b1 = 13.0
// L2 = 54.7           a2 = 116.0          b2 = 45.8669
// CIE ΔE2000 = ΔE00 = 12.81739300082

// L1 = 7.0            a1 = -19.6181       b1 = -68.0
// L2 = 33.82          a2 = -0.9           b2 = -108.737
// CIE ΔE2000 = ΔE00 = 19.96821736128

double my_round(double valeur) {
  Random random = Random();
  if (random.nextBool()) {
    return double.parse(valeur.toStringAsFixed(0));
  } else {
    return double.parse(valeur.toStringAsFixed(1));
  }
}

///////////////////////////////////////////////
///////////////////////////////////////////////
///////                                 ///////
///////           CIEDE 2000            ///////
///////      Testing Random Colors      ///////
///////                                 ///////
///////////////////////////////////////////////
///////////////////////////////////////////////

// This program outputs a CSV file to standard output, with its length determined by the first CLI argument.
// Each line contains seven columns:
// - Three columns for the standard L*a*b* color
// - Three columns for the sample L*a*b* color
// - One column for the Delta E 2000 color difference between the standard and sample
// The output can be verified in two ways:
// - With the C driver, which provides a dedicated verification feature
// - By using the JavaScript validator at https://michel-leonard.github.io/ciede2000-color-matching

void main(List<String> arguments) {

	int n_iterations = 10000;
	if (arguments.isNotEmpty) {
		try {
			int parsed = int.parse(arguments[0]);
			if (parsed > 0) {
				n_iterations = parsed;
			}
		} catch (e) { }
	}

	Random random = Random();

	for (int i = 0; i < n_iterations; i++) {
	double l1 = random.nextDouble() * 100;
	double a1 = random.nextDouble() * 256 - 128;
	double b1 = random.nextDouble() * 256 - 128;
	double l2 = random.nextDouble() * 100;
	double a2 = random.nextDouble() * 256 - 128;
	double b2 = random.nextDouble() * 256 - 128;

	l1 = my_round(l1);
	a1 = my_round(a1);
	b1 = my_round(b1);
	l2 = my_round(l2);
	a2 = my_round(a2);
	b2 = my_round(b2);

	double deltaE = ciede_2000(l1, a1, b1, l2, a2, b2);

	print('$l1,$a1,$b1,$l2,$a2,$b2,$deltaE');
  }
}
