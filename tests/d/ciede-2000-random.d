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
	double n = (sqrt(a_1 * a_1 + b_1 * b_1) + sqrt(a_2 * a_2 + b_2 * b_2)) * 0.5;
	n = n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - sqrt(n / (n + 6103515625.0)));
	// Application of the chroma correction factor.
	const double c_1 = sqrt(a_1 * a_1 * n * n + b_1 * b_1);
	const double c_2 = sqrt(a_2 * a_2 * n * n + b_2 * b_2);
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	double h_1 = atan2(b_1, a_1 * n);
	double h_2 = atan2(b_2, a_2 * n);
	if (h_1 < 0.0) h_1 += 2.0 * PI;
	if (h_2 < 0.0) h_2 += 2.0 * PI;
	n = fabs(h_2 - h_1);
	// Cross-implementation consistent rounding.
	if (PI - 1E-14 < n && n < PI + 1E-14) n = PI;
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	double h_m = (h_1 + h_2) * 0.5;
	double h_d = (h_2 - h_1) * 0.5;
	if (PI < n) {
		h_d += PI;
		// 📜 Sharma’s formulation doesn’t use the next line, but the one after it,
		// and these two variants differ by ±0.0003 on the final color differences.
		h_m += PI;
		// if (h_m < PI) h_m += PI; else h_m -= PI;
	}
	const double p = 36.0 * h_m - 55.0 * PI;
	n = (c_1 + c_2) * 0.5;
	n = n * n * n * n * n * n * n;
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	const double r_t = -2.0 * sqrt(n / (n + 6103515625.0))
				* sin(PI / 3.0 * exp(p * p / (-25.0 * PI * PI)));
	n = (l_1 + l_2) * 0.5;
	n = (n - 50.0) * (n - 50.0);
	// Lightness.
	const double l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / sqrt(20.0 + n)));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	const double t = 1.0 	+ 0.24 * sin(2.0 * h_m + PI / 2.0)
			+ 0.32 * sin(3.0 * h_m + 8.0 * PI / 15.0)
			- 0.17 * sin(h_m + PI / 3.0)
			- 0.20 * sin(4.0 * h_m + 3.0 * PI / 20.0);
	n = c_1 + c_2;
	// Hue.
	const double h = 2.0 * sqrt(c_1 * c_2) * sin(h_d) / (k_h * (1.0 + 0.0075 * n * t));
	// Chroma.
	const double c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
	// Returning the square root ensures that dE00 accurately reflects the
	// geometric distance in color space, which can range from 0 to around 185.
	return sqrt(l * l + h * h + c * c + c * h * r_t);
}

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//   Online Tests : https://michel-leonard.github.io/ciede2000-color-matching

// L1 = 22.3   a1 = 36.9   b1 = -3.5
// L2 = 23.0   a2 = 30.7   b2 = 3.1
// CIE ΔE00 = 4.6513729720 (Bruce Lindbloom, Netflix’s VMAF, ...)
// CIE ΔE00 = 4.6513540097 (Gaurav Sharma, OpenJDK, ...)
// Deviation between implementations ≈ 1.9e-5

// See the source code comments for easy switching between these two widely used ΔE*00 implementation variants.

///////////////////////////////////////////////
///////////////////////////////////////////////
///////                                 ///////
///////           CIEDE 2000            ///////
///////      Testing Random Colors      ///////
///////                                 ///////
///////////////////////////////////////////////
///////////////////////////////////////////////

// This D program outputs a CSV file to standard output, with its length determined by the first CLI argument.
// Each line contains seven columns :
// - Three columns for the random standard L*a*b* color
// - Three columns for the random sample L*a*b* color
// - And the seventh column for the precise Delta E 2000 color difference between the standard and sample
// The output will be correct, this can be verified :
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
		return roundTo(value, 0);
	} else {
		return roundTo(value, 1);
	}
}

double roundTo(double value, int decimals) {
	double factor = pow(10.0, decimals);
	return round(value * factor) / factor;
}

void main(string[] args) {
	int nIterations = 10000;
	if (args.length > 1) {
		try {
			int parsed = args[1].to!int;
			if (parsed > 0) {
				nIterations = parsed;
			}
		} catch (Exception e) { }
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
