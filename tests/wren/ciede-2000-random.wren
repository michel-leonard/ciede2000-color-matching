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

// L1 = 48.7   a1 = 14.4   b1 = -2.3
// L2 = 49.5   a2 = 20.5   b2 = 4.5
// CIE ΔE00 = 6.0932725537 (Bruce Lindbloom, Netflix’s VMAF, ...)
// CIE ΔE00 = 6.0932863277 (Gaurav Sharma, OpenJDK, ...)
// Deviation between implementations ≈ 1.4e-5

// See the source code comments for easy switching between these two widely used ΔE*00 implementation variants.

///////////////////////////////////////////////
///////////////////////////////////////////////
///////                                 ///////
///////           CIEDE 2000            ///////
///////      Testing Random Colors      ///////
///////                                 ///////
///////////////////////////////////////////////
///////////////////////////////////////////////

// This Wren program outputs a CSV file to standard output, with its length determined by the first CLI argument.
// Each line contains seven columns :
// - Three columns for the random standard L*a*b* color
// - Three columns for the random sample L*a*b* color
// - And the seventh column for the precise Delta E 2000 color difference between the standard and sample
// The output will be correct, this can be verified :
// - With the C driver, which provides a dedicated verification feature
// - By using the JavaScript validator at https://michel-leonard.github.io/ciede2000-color-matching

class XorShift64 {
	construct new(seed) {
		_state = seed
	}

	nextInt() {
	_state = _state ^ (_state << 13)
	_state = _state ^ (_state >> 17)
	_state = _state ^ (_state << 5)
		return _state
	}

	nextFloat(min, max) {
		var rand = nextInt() / 4294967296.0
		return min + (max - min) * rand
	}
}

import "os" for Process

var count = 10000.0

if (Process.arguments.count == 1) {
	var input = Num.fromString(Process.arguments[0])
	if (0 < input) {
		count = input
	}
}

var rng = XorShift64.new(0x2236b69a7d223bd)

 for (i in 1..count) {
	var l_1 = rng.nextInt() & 1 == 0 ? (10.0 * rng.nextFloat(0, 100)).round / 10.0 : rng.nextFloat(0, 100).round
	var a_1 = rng.nextInt() & 1 == 0 ? (10.0 * rng.nextFloat(-128, 128)).round / 10.0 : rng.nextFloat(-128, 128).round
	var b_1 = rng.nextInt() & 1 == 0 ? (10.0 * rng.nextFloat(-128, 128)).round / 10.0 : rng.nextFloat(-128, 128).round
	var l_2 = rng.nextInt() & 1 == 0 ? (10.0 * rng.nextFloat(0, 100)).round / 10.0 : rng.nextFloat(0, 100).round
	var a_2 = rng.nextInt() & 1 == 0 ? (10.0 * rng.nextFloat(-128, 128)).round / 10.0 : rng.nextFloat(-128, 128).round
	var b_2 = rng.nextInt() & 1 == 0 ? (10.0 * rng.nextFloat(-128, 128)).round / 10.0 : rng.nextFloat(-128, 128).round

	var res = ciede_2000.call(l_1, a_1, b_1, l_2, a_2, b_2)

	System.print(l_1.toString + "," + a_1.toString + "," + b_1.toString + "," + l_2.toString + "," + a_2.toString + "," + b_2.toString + "," + res.toString)
}
