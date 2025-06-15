// This function written in Wren is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

// The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
// "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
var ciede_2000 = Fn.new { |l_1, a_1, b_1, l_2, a_2, b_2|
	// Working in Wren with the CIEDE2000 color-difference formula.
	// k_l, k_c, k_h are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	var k_l = 1.0
	var k_c = 1.0
	var k_h = 1.0
	var n = ((a_1 * a_1 + b_1 * b_1).sqrt + (a_2 * a_2 + b_2 * b_2).sqrt) * 0.5
	n = n * n * n * n * n * n * n
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - (n / (n + 6103515625.0)).sqrt)
	// hypot from "Math", rather than sqrt used here can calculate
	// Euclidean distance while avoiding overflow/underflow.
	var c_1 = (a_1 * a_1 * n * n + b_1 * b_1).sqrt
	var c_2 = (a_2 * a_2 * n * n + b_2 * b_2).sqrt
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	var h_1 = b_1.atan(a_1 * n)
	var h_2 = b_2.atan(a_2 * n)
	if (h_1 < 0.0) h_1 = h_1 + 2.0 * Num.pi
	if (h_2 < 0.0) h_2 = h_2 + 2.0 * Num.pi
	n = (h_2 - h_1).abs
	// Cross-implementation consistent rounding.
	if (Num.pi - 1E-14 < n && n < Num.pi + 1E-14) n = Num.pi
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	var h_m = (h_1 + h_2) * 0.5
	var h_d = (h_2 - h_1) * 0.5
	if (Num.pi < n) {
		if (0.0 < h_d) {
			h_d = h_d - Num.pi
		} else {
			h_d = h_d + Num.pi
		}
		h_m = h_m + Num.pi
	}
	var p = 36.0 * h_m - 55.0 * Num.pi
	n = (c_1 + c_2) * 0.5
	n = n * n * n * n * n * n * n
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	var r_t = -2.0 * (n / (n + 6103515625.0)).sqrt * (Num.pi / 3.0 *
		2.718281828459045235360287471353.pow(p * p / (-25.0 * Num.pi * Num.pi))).sin
	n = (l_1 + l_2) * 0.5
	n = (n - 50.0) * (n - 50.0)
	// Lightness.
	var l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / (20.0 + n).sqrt))
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	var t = 1.0 +	0.24 * (2.0 * h_m + Num.pi * 0.5).sin +
			0.32 * (3.0 * h_m + 8.0 * Num.pi / 15.0).sin -
			0.17 * (h_m + Num.pi / 3.0).sin -
			0.20 * (4.0 * h_m + 3.0 * Num.pi / 20.0).sin
	n = c_1 + c_2
	// Hue.
	var h = 2.0 * (c_1 * c_2).sqrt * h_d.sin / (k_h * (1.0 + 0.0075 * n * t))
	// Chroma.
	var c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n))
	// Returns the square root so that the Delta E 2000 reflects the actual geometric
	// distance within the color space, which ranges from 0 to approximately 185.
	return (l * l + h * h + c * c + c * h * r_t).sqrt
}

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

// L1 = 62.7           a1 = 99.88          b1 = -23.537
// L2 = 62.7           a2 = 100.0          b2 = -23.537
// CIE ΔE2000 = ΔE00 = 0.02246266284

// L1 = 92.0147        a1 = -45.67         b1 = 72.73
// L2 = 92.0147        a2 = -45.67         b2 = 67.895
// CIE ΔE2000 = ΔE00 = 1.37182014068

// L1 = 77.83          a1 = -58.0          b1 = 46.89
// L2 = 81.022         a2 = -58.0          b2 = 46.89
// CIE ΔE2000 = ΔE00 = 2.22225454599

// L1 = 0.6            a1 = -107.1         b1 = 126.6
// L2 = 7.2482         a2 = -115.5         b2 = 126.6
// CIE ΔE2000 = ΔE00 = 4.25691700138

// L1 = 98.2653        a1 = 74.0           b1 = 104.27
// L2 = 91.0           a2 = 64.1595        b2 = 84.685
// CIE ΔE2000 = ΔE00 = 5.8179755092

// L1 = 37.0           a1 = -27.106        b1 = -65.4492
// L2 = 45.43          a2 = -25.9          b2 = -99.92
// CIE ΔE2000 = ΔE00 = 9.75765963422

// L1 = 13.257         a1 = -115.241       b1 = -74.38
// L2 = 8.1491         a2 = -69.981        b2 = -73.368
// CIE ΔE2000 = ΔE00 = 10.21871047111

// L1 = 20.0           a1 = 74.4601        b1 = 77.9
// L2 = 30.546         a2 = 124.0          b2 = 109.057
// CIE ΔE2000 = ΔE00 = 12.13993913559

// L1 = 21.593         a1 = 115.6683       b1 = -16.84
// L2 = 24.0           a2 = 61.2313        b2 = -48.2376
// CIE ΔE2000 = ΔE00 = 17.8914003046

// L1 = 23.6965        a1 = 26.56          b1 = 112.9
// L2 = 35.0           a2 = -9.0           b2 = 63.2
// CIE ΔE2000 = ΔE00 = 22.16448545543

