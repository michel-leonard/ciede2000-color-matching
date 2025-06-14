// Limited Use License – March 1, 2025

// This source code is provided for public use under the following conditions :
// It may be downloaded, compiled, and executed, including in publicly accessible environments.
// Modification is strictly prohibited without the express written permission of the author.

// © Michel Leonard 2025

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

// L1 = 20.0           a1 = -127.0         b1 = 76.0
// L2 = 20.0           a2 = -127.121       b2 = 76.0
// CIE ΔE2000 = ΔE00 = 0.02044771817

// L1 = 6.5519         a1 = 73.779         b1 = -97.41
// L2 = 6.5519         a2 = 75.972         b2 = -97.362
// CIE ΔE2000 = ΔE00 = 0.8072722617

// L1 = 3.0            a1 = -82.2          b1 = -56.673
// L2 = 3.0            a2 = -89.2          b2 = -55.983
// CIE ΔE2000 = ΔE00 = 1.77768646248

// L1 = 23.802         a1 = -54.0          b1 = 18.82
// L2 = 28.7236        a2 = -54.0          b2 = 14.506
// CIE ΔE2000 = ΔE00 = 4.18535283319

// L1 = 6.73           a1 = -69.0          b1 = 25.842
// L2 = 7.4751         a2 = -95.0          b2 = 33.468
// CIE ΔE2000 = ΔE00 = 5.54742844261

// L1 = 80.5           a1 = -25.0          b1 = -48.82
// L2 = 84.29          a2 = -45.7735       b2 = -79.55
// CIE ΔE2000 = ΔE00 = 9.26532669223

// L1 = 43.0           a1 = 48.0           b1 = -90.01
// L2 = 31.0           a2 = 63.1           b2 = -55.9676
// CIE ΔE2000 = ΔE00 = 20.79771782161

// L1 = 59.089         a1 = -17.0          b1 = -111.94
// L2 = 68.96          a2 = -90.6239       b2 = -106.22
// CIE ΔE2000 = ΔE00 = 21.27628070638

// L1 = 75.0           a1 = 61.1511        b1 = -72.168
// L2 = 44.7886        a2 = 70.9           b2 = -93.18
// CIE ΔE2000 = ΔE00 = 27.0977052546

// L1 = 14.564         a1 = -76.0          b1 = -112.0689
// L2 = 79.158         a2 = 31.5           b2 = -74.771
// CIE ΔE2000 = ΔE00 = 79.0183238319

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

import std.stdio;
import std.file;
import std.conv;
import std.range;
import std.algorithm;

void main(string[] args) {
	if (args.length < 2) {
		writeln("Usage: ", args[0], " <filename>");
		return;
	}
	auto file = File(args[1]);
	auto range = file.byLine();
	foreach (line; range) {
		const auto a = line.split(',');
		const auto v = a.map!(to!double).array;
		double deltaE = ciede_2000(v[0], v[1], v[2], v[3], v[4], v[5]);
		writefln("%s,%s,%s,%s,%s,%s,%.17g", a[0], a[1], a[2], a[3], a[4], a[5], deltaE);
	}
}
