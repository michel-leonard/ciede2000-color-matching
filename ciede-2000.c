// This function written in C is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

#include <math.h>

// Expressly defining pi ensures that the code works on different platforms.
#ifndef M_PI
#define M_PI 3.14159265358979323846264338328
#endif

// The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
static double ciede_2000_1(const double l_1, const double a_1, const double b_1, const double l_2, const double a_2, const double b_2) {
	// Working in C with the CIEDE2000 color-difference formula.
	// k_l, k_c, k_h are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	const double k_l = 1.0;
	const double k_c = 1.0;
	const double k_h = 1.0;
	double n = (hypot(a_1, b_1) + hypot(a_2, b_2)) * 0.5;
	n = n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - sqrt(n / (n + 6103515625.0)));
	// hypot calculates the Euclidean distance while avoiding overflow/underflow.
	const double c_1 = hypot(a_1 * n, b_1);
	const double c_2 = hypot(a_2 * n, b_2);
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	double h_1 = atan2(b_1, a_1 * n);
	double h_2 = atan2(b_2, a_2 * n);
	if (h_1 < 0.0)
		h_1 += 2.0 * M_PI;
	if (h_2 < 0.0)
		h_2 += 2.0 * M_PI;
	n = fabs(h_2 - h_1);
	// Cross-implementation consistent rounding.
	if (M_PI - 1E-14 < n && n < M_PI + 1E-14)
		n = M_PI;
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	double h_m = (h_1 + h_2) * 0.5;
	double h_d = (h_2 - h_1) * 0.5;
	if (M_PI < n) {
		if (0.0 < h_d)
			h_d -= M_PI;
		else
			h_d += M_PI;
		h_m += M_PI;
	}
	const double p = 36.0 * h_m - 55.0 * M_PI;
	n = (c_1 + c_2) * 0.5;
	n = n * n * n * n * n * n * n;
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	const double r_t = -2.0 * sqrt(n / (n + 6103515625.0))
				* sin(M_PI / 3.0 * exp(p * p / (-25.0 * M_PI * M_PI)));
	n = (l_1 + l_2) * 0.5;
	n = (n - 50.0) * (n - 50.0);
	// Lightness.
	const double l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / sqrt(20.0 + n)));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	const double t = 1.0 	+ 0.24 * sin(2.0 * h_m + M_PI / 2.0)
				+ 0.32 * sin(3.0 * h_m + 8.0 * M_PI / 15.0)
				- 0.17 * sin(h_m + M_PI / 3.0)
				- 0.20 * sin(4.0 * h_m + 3.0 * M_PI / 20.0);
	n = c_1 + c_2;
	// Hue.
	const double h = 2.0 * sqrt(c_1 * c_2) * sin(h_d) / (k_h * (1.0 + 0.0075 * n * t));
	// Chroma.
	const double c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
	// Returning the square root ensures that the result represents
	// the "true" geometric distance in the color space.
	return sqrt(l * l + h * h + c * c + c * h * r_t);
}

// Compilation is done using GCC or CLang :
// - gcc -std=c99 -Wall -Wextra -pedantic -Ofast -o ciede-2000-compiled ciede-2000.c -lm
// - clang -std=c99 -Wall -Wextra -pedantic -Ofast -o ciede-2000-compiled ciede-2000.c -lm

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/samples.html

// L1 = 78.95          a1 = -18.0          b1 = -117.0
// L2 = 78.95          a2 = -17.96         b2 = -117.0
// CIE ΔE2000 = ΔE00 = 0.01479037399

// L1 = 39.9           a1 = 87.6           b1 = -83.93
// L2 = 39.9           a2 = 84.2           b2 = -83.93
// CIE ΔE2000 = ΔE00 = 0.97646920972

// L1 = 48.3           a1 = -109.49        b1 = 27.538
// L2 = 48.3           a2 = -111.4814      b2 = 19.0
// CIE ΔE2000 = ΔE00 = 2.99209651754

// L1 = 55.5           a1 = -19.9          b1 = 82.1914
// L2 = 58.0           a2 = -23.6          b2 = 91.64
// CIE ΔE2000 = ΔE00 = 3.11702919445

// L1 = 56.34          a1 = -17.544        b1 = -82.8
// L2 = 57.0           a2 = -26.0          b2 = -86.093
// CIE ΔE2000 = ΔE00 = 3.61280667544

// L1 = 53.0           a1 = 93.01          b1 = -96.4
// L2 = 53.0           a2 = 88.6347        b2 = -105.7879
// CIE ΔE2000 = ΔE00 = 3.86787284311

// L1 = 11.0744        a1 = 25.0           b1 = -4.7
// L2 = 11.0744        a2 = 17.0           b2 = -4.7
// CIE ΔE2000 = ΔE00 = 4.60427021225

// L1 = 52.81          a1 = -66.34         b1 = 89.748
// L2 = 61.537         a2 = -65.591        b2 = 108.83
// CIE ΔE2000 = ΔE00 = 9.11354412918

// L1 = 51.258         a1 = 82.682         b1 = -11.04
// L2 = 65.0           a2 = 54.252         b2 = 21.3
// CIE ΔE2000 = ΔE00 = 20.64997515838

// L1 = 18.0           a1 = -58.0          b1 = 104.0
// L2 = 45.745         a2 = -66.03         b2 = 97.1248
// CIE ΔE2000 = ΔE00 = 22.22753974253
