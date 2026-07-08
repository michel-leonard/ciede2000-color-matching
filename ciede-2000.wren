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
	// Application of the chroma correction factor.
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
		h_d = h_d + Num.pi
		// 📜 Sharma’s formulation doesn’t use the next line, but the one after it,
		// and these two variants differ by ±0.0003 on the final color differences.
		h_m = h_m + Num.pi
		// h_m = h_m + (h_m < Math.PI ? Math.PI : -Math.PI)
	}
	var p = 36.0 * h_m - 55.0 * Num.pi
	n = (c_1 + c_2) * 0.5
	n = n * n * n * n * n * n * n
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	var r_t = -2.0 * (n / (n + 6103515625.0)).sqrt * (Num.pi / 3.0 *
		2.71828182845904523536.pow(p * p / (-25.0 * Num.pi * Num.pi))).sin
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
	// Returning the square root ensures that dE00 accurately reflects the
	// geometric distance in color space, which can range from 0 to around 185.
	return (l * l + h * h + c * c + c * h * r_t).sqrt
}

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//   Online Tests : https://michel-leonard.github.io/ciede2000-color-matching

// L1 = 35.0   a1 = 57.0   b1 = -3.3
// L2 = 35.5   a2 = 62.4   b2 = 3.7
// CIE ΔE00 = 3.5439355959 (Bruce Lindbloom, Netflix’s VMAF, ...)
// CIE ΔE00 = 3.5439486703 (Gaurav Sharma, OpenJDK, ...)
// Deviation between implementations ≈ 1.3e-5

// See the source code comments for easy switching between these two widely used ΔE*00 implementation variants.
