// This function written in C# is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

// The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
// "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 128.
static double ciede_2000(double l_1, double a_1, double b_1, double l_2, double a_2, double b_2) {
	// Working in C# (.NET Core) with the CIEDE2000 color-difference formula.
	// k_l, k_c, k_h are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	const double k_l = 1.0, k_c = 1.0, k_h = 1.0;
	double n = (Math.Sqrt(a_1 * a_1 + b_1 * b_1) + Math.Sqrt(a_2 * a_2 + b_2 * b_2)) * 0.5;
	n = n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - Math.Sqrt(n / (n + 6103515625.0)));
	// Since hypot is not available, sqrt is used here to calculate the
	// Euclidean distance, without avoiding overflow/underflow.
	double c_1 = Math.Sqrt(a_1 * a_1 * n * n + b_1 * b_1);
	double c_2 = Math.Sqrt(a_2 * a_2 * n * n + b_2 * b_2);
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	double h_1 = Math.Atan2(b_1, a_1 * n), h_2 = Math.Atan2(b_2, a_2 * n);
	if (h_1 < 0.0) h_1 += 2.0 * Math.PI;
	if (h_2 < 0.0) h_2 += 2.0 * Math.PI;
	n = Math.Abs(h_2 - h_1);
	// Cross-implementation consistent rounding.
	if (Math.PI - 1E-14 < n && n < Math.PI + 1E-14)
		n = Math.PI;
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	double h_m = (h_1 + h_2) * 0.5, h_d = (h_2 - h_1) * 0.5;
	if (Math.PI < n) {
		if (0.0 < h_d)
			h_d -= Math.PI;
		else
			h_d += Math.PI;
		h_m += Math.PI;
	}
	double p = 36.0 * h_m - 55.0 * Math.PI;
	n = (c_1 + c_2) * 0.5;
	n = n * n * n * n * n * n * n;
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	double r_t = -2.0 * Math.Sqrt(n / (n + 6103515625.0))
			* Math.Sin(Math.PI / 3.0 * Math.Exp(p * p / (-25.0 * Math.PI * Math.PI)));
	n = (l_1 + l_2) * 0.5;
	n = (n - 50.0) * (n - 50.0);
	// Lightness.
	double l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / Math.Sqrt(20.0 + n)));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	double t = 1.0	+ 0.24 * Math.Sin(2.0 * h_m + Math.PI * 0.5)
			+ 0.32 * Math.Sin(3.0 * h_m + 8.0 * Math.PI / 15.0)
			- 0.17 * Math.Sin(h_m + Math.PI / 3.0)
			- 0.20 * Math.Sin(4.0 * h_m + 3.0 * Math.PI / 20.0);
	n = c_1 + c_2;
	// Hue.
	double h = 2.0 * Math.Sqrt(c_1 * c_2) * Math.Sin(h_d) / (k_h * (1.0 + 0.0075 * n * t));
	// Chroma.
	double c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
	// Returning the square root ensures that the result reflects the actual geometric
	// distance within the color space, which ranges from 0 to approximately 185.
	return Math.Sqrt(l * l + h * h + c * c + c * h * r_t);
}

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/samples.html

// L1 = 94.32          a1 = 105.0          b1 = 111.331
// L2 = 94.32          a2 = 105.0          b2 = 111.3
// CIE ΔE2000 = ΔE00 = 0.00886494786

// L1 = 52.0           a1 = 95.747         b1 = 35.9
// L2 = 52.0           a2 = 95.747         b2 = 37.1755
// CIE ΔE2000 = ΔE00 = 0.49398562852

// L1 = 61.28          a1 = -0.7           b1 = -102.8
// L2 = 62.0           a2 = 2.0            b2 = -96.723
// CIE ΔE2000 = ΔE00 = 2.42119050559

// L1 = 28.4           a1 = 42.4           b1 = -9.966
// L2 = 28.4           a2 = 34.7888        b2 = -4.77
// CIE ΔE2000 = ΔE00 = 3.6470240701

// L1 = 22.0           a1 = -87.209        b1 = -72.0
// L2 = 27.1           a2 = -94.194        b2 = -69.7
// CIE ΔE2000 = ΔE00 = 4.17644311383

// L1 = 17.5           a1 = -73.0          b1 = 37.5
// L2 = 11.754         a2 = -73.197        b2 = 50.0
// CIE ΔE2000 = ΔE00 = 5.55356898764

// L1 = 50.1           a1 = -95.3896       b1 = -36.55
// L2 = 50.89          a2 = -70.8232       b2 = -15.71
// CIE ΔE2000 = ΔE00 = 8.20303819622

// L1 = 88.8234        a1 = 68.0           b1 = -45.5771
// L2 = 76.6182        a2 = 100.0          b2 = -86.0
// CIE ΔE2000 = ΔE00 = 12.82461444517

// L1 = 76.8245        a1 = 57.64          b1 = -53.3
// L2 = 89.165         a2 = 102.399        b2 = -98.98
// CIE ΔE2000 = ΔE00 = 13.61389701413

// L1 = 66.55          a1 = 52.0           b1 = 30.084
// L2 = 73.0           a2 = 43.0           b2 = 2.946
// CIE ΔE2000 = ΔE00 = 14.76036528642
