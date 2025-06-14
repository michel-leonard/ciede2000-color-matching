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

// L1 = 16.958         a1 = -120.9         b1 = -76.15
// L2 = 16.958         a2 = -121.0         b2 = -76.15
// CIE ΔE2000 = ΔE00 = 0.01836279085

// L1 = 24.932         a1 = -125.3         b1 = 50.9549
// L2 = 24.932         a2 = -125.3         b2 = 50.7834
// CIE ΔE2000 = ΔE00 = 0.04478515922

// L1 = 75.4           a1 = -116.68        b1 = -49.215
// L2 = 75.4           a2 = -117.0         b2 = -49.215
// CIE ΔE2000 = ΔE00 = 0.06000200419

// L1 = 55.0           a1 = -122.47        b1 = -2.9
// L2 = 55.2           a2 = -121.4         b2 = -2.9
// CIE ΔE2000 = ΔE00 = 0.25105689307

// L1 = 47.3007        a1 = -106.36        b1 = -76.002
// L2 = 47.3007        a2 = -101.321       b2 = -81.5
// CIE ΔE2000 = ΔE00 = 2.02511393368

// L1 = 75.84          a1 = -100.8717      b1 = 73.114
// L2 = 81.63          a2 = -100.8717      b2 = 68.341
// CIE ΔE2000 = ΔE00 = 4.22673347388

// L1 = 71.42          a1 = -23.72         b1 = 86.0
// L2 = 77.56          a2 = -27.618        b2 = 86.0
// CIE ΔE2000 = ΔE00 = 4.84991421275

// L1 = 20.5316        a1 = 55.0           b1 = 77.0
// L2 = 20.1           a2 = 45.0           b2 = 78.45
// CIE ΔE2000 = ΔE00 = 5.00573516624

// L1 = 17.2321        a1 = -107.6817      b1 = -101.3181
// L2 = 23.4           a2 = -15.1          b2 = -90.467
// CIE ΔE2000 = ΔE00 = 23.55771843602

// L1 = 20.684         a1 = -119.01        b1 = 114.4
// L2 = 80.496         a2 = -100.3199      b2 = 81.0
// CIE ΔE2000 = ΔE00 = 60.01311266186
