// This function written in Haxe is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

// Expressly defining pi ensures that the code works on different platforms.
public static inline var M_PI:Float = 3.14159265358979323846264338328;

// The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
// "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 128.
public static function ciede_2000(l_1:Float, a_1:Float, b_1:Float, l_2:Float, a_2:Float, b_2:Float):Float {
	// Working in Haxe with the CIEDE2000 color-difference formula.
	// k_l, k_c, k_h are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	var k_l = 1.0;
	var k_c = 1.0;
	var k_h = 1.0;
	var n = (Math.sqrt(a_1 * a_1 + b_1 * b_1) + Math.sqrt(a_2 * a_2 + b_2 * b_2)) * 0.5;
	n = n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - Math.sqrt(n / (n + 6103515625.0)));
	// Since hypot is not available, sqrt is used here to calculate the
	// Euclidean distance, without avoiding overflow/underflow.
	var c_1 = Math.sqrt(a_1 * a_1 * n * n + b_1 * b_1);
	var c_2 = Math.sqrt(a_2 * a_2 * n * n + b_2 * b_2);
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	var h_1 = Math.atan2(b_1, a_1 * n);
	var h_2 = Math.atan2(b_2, a_2 * n);
	if (h_1 < 0.0) h_1 += 2.0 * M_PI;
	if (h_2 < 0.0) h_2 += 2.0 * M_PI;
	n = Math.abs(h_2 - h_1);
	// Cross-implementation consistent rounding.
	if (M_PI - 1E-14 < n && n < M_PI + 1E-14) n = M_PI;
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	var h_m = (h_1 + h_2) * 0.5;
	var h_d = (h_2 - h_1) * 0.5;
	if (M_PI < n) {
		if (0.0 < h_d)
			h_d -= M_PI;
		else
			h_d += M_PI;
		h_m += M_PI;
	}
	var p = 36.0 * h_m - 55.0 * M_PI;
	n = (c_1 + c_2) * 0.5;
	n = n * n * n * n * n * n * n;
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	var r_t = -2.0 * Math.sqrt(n / (n + 6103515625.0))
				* Math.sin(M_PI / 3.0 * Math.exp(p * p / (-25.0 * M_PI * M_PI)));
	n = (l_1 + l_2) * 0.5;
	n = (n - 50.0) * (n - 50.0);
	// Lightness.
	var l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / Math.sqrt(20.0 + n)));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	var t = 1.0	+ 0.24 * Math.sin(2.0 * h_m + M_PI / 2.0)
			+ 0.32 * Math.sin(3.0 * h_m + 8.0 * M_PI / 15.0)
			- 0.17 * Math.sin(h_m + M_PI / 3.0)
			- 0.20 * Math.sin(4.0 * h_m + 3.0 * M_PI / 20.0);
	n = c_1 + c_2;
	// Hue.
	var h = 2.0 * Math.sqrt(c_1 * c_2) * Math.sin(h_d) / (k_h * (1.0 + 0.0075 * n * t));
	// Chroma.
	var c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
	// Returning the square root ensures that the result reflects the actual geometric
	// distance within the color space, which ranges from 0 to approximately 185.
	return Math.sqrt(l * l + h * h + c * c + c * h * r_t);
}

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/samples.html

// L1 = 94.0           a1 = -80.0          b1 = -46.3431
// L2 = 94.0           a2 = -80.085        b2 = -46.3431
// CIE ΔE2000 = ΔE00 = 0.02132742787

// L1 = 63.9324        a1 = -49.15         b1 = 61.2174
// L2 = 63.9324        a2 = -49.15         b2 = 61.074
// CIE ΔE2000 = ΔE00 = 0.04390696141

// L1 = 53.65          a1 = 52.6           b1 = 94.6235
// L2 = 53.65          a2 = 52.6           b2 = 85.8
// CIE ΔE2000 = ΔE00 = 2.62977041818

// L1 = 57.58          a1 = 72.0           b1 = -70.764
// L2 = 57.58          a2 = 71.4188        b2 = -61.4574
// CIE ΔE2000 = ΔE00 = 3.08672793115

// L1 = 50.5           a1 = 14.6678        b1 = 13.0
// L2 = 52.0           a2 = 14.6678        b2 = 18.215
// CIE ΔE2000 = ΔE00 = 3.85443386502

// L1 = 7.219          a1 = 81.48          b1 = -45.888
// L2 = 0.2793         a2 = 121.94         b2 = -35.81
// CIE ΔE2000 = ΔE00 = 10.2156559158

// L1 = 19.1436        a1 = -111.4188      b1 = -105.78
// L2 = 0.0            a2 = -38.0          b2 = -107.09
// CIE ΔE2000 = ΔE00 = 20.34606493906

// L1 = 35.7206        a1 = -117.0         b1 = -70.4418
// L2 = 56.26          a2 = -123.0         b2 = -34.0
// CIE ΔE2000 = ΔE00 = 22.835480612

// L1 = 96.99          a1 = 18.52          b1 = 62.62
// L2 = 85.83          a2 = 91.2311        b2 = 110.9384
// CIE ΔE2000 = ΔE00 = 25.02388503505

// L1 = 74.0           a1 = -98.0          b1 = -85.1
// L2 = 48.27          a2 = -26.038        b2 = -55.2474
// CIE ΔE2000 = ΔE00 = 28.46749603341
