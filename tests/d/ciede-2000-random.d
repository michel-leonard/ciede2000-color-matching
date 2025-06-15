// This function written in D is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

import std.math;

// The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
// "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
double ciede_2000(double l_1, double a_1, double b_1, double l_2, double a_2, double b_2) {
	// Working in D with the CIEDE2000 color-difference formula.
	// k_l, k_c, k_h are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	enum double k_l = 1.0;
	enum double k_c = 1.0;
	enum double k_h = 1.0;
	double n = (hypot(a_1, b_1) + hypot(a_2, b_2)) * 0.5;
	n = n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - sqrt(n / (n + 6103515625.0)));
	// hypot calculates the Euclidean distance while avoiding overflow/underflow.
	double c_1 = hypot(a_1 * n, b_1);
	double c_2 = hypot(a_2 * n, b_2);
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	double h_1 = atan2(b_1, a_1 * n);
	double h_2 = atan2(b_2, a_2 * n);
	if (h_1 < 0.0)
		h_1 += 2.0 * PI;
	if (h_2 < 0.0)
		h_2 += 2.0 * PI;
	n = fabs(h_2 - h_1);
	// Cross-implementation consistent rounding.
	if (PI - 1E-14 < n && n < PI + 1E-14)
		n = PI;
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	double h_m = (h_1 + h_2) * 0.5;
	double h_d = (h_2 - h_1) * 0.5;
	if (PI < n) {
		if (0.0 < h_d)
			h_d -= PI;
		else
			h_d += PI;
		h_m += PI;
	}
	double p = 36.0 * h_m - 55.0 * PI;
	n = (c_1 + c_2) * 0.5;
	n = n * n * n * n * n * n * n;
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	double r_t = -2.0 * sqrt(n / (n + 6103515625.0))
				* sin(PI / 3.0 * exp(p * p / (-25.0 * PI * PI)));
	n = (l_1 + l_2) * 0.5;
	n = (n - 50.0) * (n - 50.0);
	// Lightness.
	double l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / sqrt(20.0 + n)));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	double t = 1.0 	+ 0.24 * sin(2.0 * h_m + PI / 2.0)
			+ 0.32 * sin(3.0 * h_m + 8.0 * PI / 15.0)
			- 0.17 * sin(h_m + PI / 3.0)
			- 0.20 * sin(4.0 * h_m + 3.0 * PI / 20.0);
	n = c_1 + c_2;
	// Hue.
	double h = 2.0 * sqrt(c_1 * c_2) * sin(h_d) / (k_h * (1.0 + 0.0075 * n * t));
	// Chroma.
	double c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
	// Returns the square root so that the Delta E 2000 reflects the actual geometric
	// distance within the color space, which ranges from 0 to approximately 185.
	return sqrt(l * l + h * h + c * c + c * h * r_t);
}

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

// L1 = 97.1           a1 = -19.8          b1 = -70.208
// L2 = 97.1           a2 = -19.8          b2 = -70.3072
// CIE ΔE2000 = ΔE00 = 0.01927247765

// L1 = 50.0           a1 = -95.6          b1 = 37.96
// L2 = 50.0           a2 = -95.6          b2 = 37.797
// CIE ΔE2000 = ΔE00 = 0.05187004277

// L1 = 21.0           a1 = -87.8088       b1 = -54.2
// L2 = 21.0           a2 = -87.8088       b2 = -62.8494
// CIE ΔE2000 = ΔE00 = 2.50374317852

// L1 = 50.63          a1 = 12.058         b1 = 78.0
// L2 = 52.444         a2 = 15.93          b2 = 78.0
// CIE ΔE2000 = ΔE00 = 2.89030708181

// L1 = 15.72          a1 = 126.1164       b1 = -35.6
// L2 = 21.19          a2 = 126.1164       b2 = -35.6
// CIE ΔE2000 = ΔE00 = 3.72491372595

// L1 = 45.571         a1 = 87.0           b1 = 3.0
// L2 = 49.063         a2 = 94.855         b2 = -2.6632
// CIE ΔE2000 = ΔE00 = 4.2661682019

// L1 = 90.35          a1 = 33.8969        b1 = -57.31
// L2 = 83.593         a2 = 125.815        b2 = -125.7264
// CIE ΔE2000 = ΔE00 = 19.78648529709

// L1 = 32.0           a1 = 45.9239        b1 = -36.5
// L2 = 74.37          a2 = 23.42          b2 = -63.92
// CIE ΔE2000 = ΔE00 = 47.07658711075

// L1 = 3.5146         a1 = 68.9           b1 = -31.34
// L2 = 9.14           a2 = 14.0           b2 = -114.3546
// CIE ΔE2000 = ΔE00 = 51.72447392887

// L1 = 82.0           a1 = -90.5          b1 = -61.3
// L2 = 81.0           a2 = 116.0          b2 = 44.0
// CIE ΔE2000 = ΔE00 = 133.26757040687

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

import std.stdio;
import std.random;
import std.math;
import std.conv;
import std.string;
import std.getopt;

double myRound(double value) {
	if (uniform(0, 2) == 0) {
		// Arrondi à 0 décimale
		return roundTo(value, 0);
	} else {
		// Arrondi à 1 décimale
		return roundTo(value, 1);
	}
}

double roundTo(double value, int decimals) {
	double factor = pow(10.0, decimals);
	return round(value * factor) / factor;
}

void main(string[] args) {
	int nIterations = 10_000;

	// Optionnel : permet de passer un nombre d'itérations en argument
	if (args.length > 1) {
		try {
			int parsed = args[1].to!int;
			if (parsed > 0) {
				nIterations = parsed;
			}
		} catch (Exception e) {
			// Ignore les erreurs de parsing
		}
	}

	auto rnd = Random(unpredictableSeed);

	foreach (i; 0 .. nIterations) {
		double l1 = uniform(0.0, 100.0, rnd);
		double a1 = uniform(-128.0, 128.0, rnd);
		double b1 = uniform(-128.0, 128.0, rnd);
		double l2 = uniform(0.0, 100.0, rnd);
		double a2 = uniform(-128.0, 128.0, rnd);
		double b2 = uniform(-128.0, 128.0, rnd);

		l1 = myRound(l1);
		a1 = myRound(a1);
		b1 = myRound(b1);
		l2 = myRound(l2);
		a2 = myRound(a2);
		b2 = myRound(b2);

		double deltaE = ciede_2000(l1, a1, b1, l2, a2, b2);

		writefln("%.1f,%.1f,%.1f,%.1f,%.1f,%.1f,%.17f", l1, a1, b1, l2, a2, b2, deltaE);
	}
}
