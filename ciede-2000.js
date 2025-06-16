// This function written in JavaScript is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

// The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
// "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
function ciede_2000(l_1, a_1, b_1, l_2, a_2, b_2) {
	"use strict"
	// Working in JavaScript with the CIEDE2000 color-difference formula.
	// k_l, k_c, k_h are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	var k_l = 1.0, k_c = 1.0, k_h = 1.0;
	var n = (Math.hypot(a_1, b_1) + Math.hypot(a_2, b_2)) * 0.5;
	n = n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - Math.sqrt(n / (n + 6103515625.0)));
	// hypot calculates the Euclidean distance while avoiding overflow/underflow.
	var c_1 = Math.hypot(a_1 * n, b_1), c_2 = Math.hypot(a_2 * n, b_2);
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	var h_1 = Math.atan2(b_1, a_1 * n), h_2 = Math.atan2(b_2, a_2 * n);
	h_1 += 2.0 * Math.PI * (h_1 < 0.0);
	h_2 += 2.0 * Math.PI * (h_2 < 0.0);
	n = Math.abs(h_2 - h_1);
	// Cross-implementation consistent rounding.
	if (Math.PI - 1E-14 < n && n < Math.PI + 1E-14)
		n = Math.PI;
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	var h_m = (h_1 + h_2) * 0.5, h_d = (h_2 - h_1) * 0.5;
	if (Math.PI < n) {
		if (0.0 < h_d)
			h_d -= Math.PI;
		else
			h_d += Math.PI;
		h_m += Math.PI;
	}
	var p = 36.0 * h_m - 55.0 * Math.PI;
	n = (c_1 + c_2) * 0.5;
	n = n * n * n * n * n * n * n;
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	var r_t = -2.0 * Math.sqrt(n / (n + 6103515625.0))
		* Math.sin(Math.PI / 3.0 * Math.exp(p * p / (-25.0 * Math.PI * Math.PI)));
	n = (l_1 + l_2) * 0.5;
	n = (n - 50.0) * (n - 50.0);
	// Lightness.
	var l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / Math.sqrt(20.0 + n)));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	var t = 1.0	+ 0.24 * Math.sin(2.0 * h_m + Math.PI * 0.5)
			+ 0.32 * Math.sin(3.0 * h_m + 8.0 * Math.PI / 15.0)
			- 0.17 * Math.sin(h_m + Math.PI / 3.0)
			- 0.20 * Math.sin(4.0 * h_m + 3.0 * Math.PI / 20.0);
	n = c_1 + c_2;
	// Hue.
	var h = 2.0 * Math.sqrt(c_1 * c_2) * Math.sin(h_d) / (k_h * (1.0 + 0.0075 * n * t));
	// Chroma.
	var c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
	// Returns the square root so that the Delta E 2000 reflects the actual geometric
	// distance within the color space, which ranges from 0 to approximately 185.
	return Math.sqrt(l * l + h * h + c * c + c * h * r_t);
}

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

// L1 = 74.0           a1 = 15.1545        b1 = 63.87
// L2 = 74.0           a2 = 15.1545        b2 = 63.8772
// CIE ΔE2000 = ΔE00 = 0.00206409

// L1 = 24.33          a1 = 49.42          b1 = -4.9
// L2 = 24.33          a2 = 50.9987        b2 = -4.9
// CIE ΔE2000 = ΔE00 = 0.4864982581

// L1 = 16.2104        a1 = 43.0           b1 = 61.4
// L2 = 16.2104        a2 = 43.0           b2 = 63.8
// CIE ΔE2000 = ΔE00 = 0.90911815911

// L1 = 64.4           a1 = 103.3          b1 = -100.7
// L2 = 64.4           a2 = 105.44         b2 = -107.2
// CIE ΔE2000 = ΔE00 = 1.39103667692

// L1 = 28.907         a1 = 5.946          b1 = -128.0
// L2 = 28.907         a2 = 1.0            b2 = -128.0
// CIE ΔE2000 = ΔE00 = 2.14014345026

// L1 = 83.441         a1 = 34.056         b1 = -50.4651
// L2 = 89.7539        a2 = 34.056         b2 = -50.4651
// CIE ΔE2000 = ΔE00 = 4.08626157332

// L1 = 83.0           a1 = 111.83         b1 = -105.0
// L2 = 89.9094        a2 = 113.0          b2 = -105.0
// CIE ΔE2000 = ΔE00 = 4.48697896497

// L1 = 77.5           a1 = -91.0          b1 = -122.1
// L2 = 84.0           a2 = -93.0          b2 = -103.0
// CIE ΔE2000 = ΔE00 = 5.67619224426

// L1 = 59.3434        a1 = -123.47        b1 = 72.269
// L2 = 51.0           a2 = -106.5         b2 = 21.244
// CIE ΔE2000 = ΔE00 = 15.34543502396

// L1 = 9.363          a1 = -104.93        b1 = -10.85
// L2 = 7.0            a2 = -48.0          b2 = -45.0
// CIE ΔE2000 = ΔE00 = 23.5118071479
