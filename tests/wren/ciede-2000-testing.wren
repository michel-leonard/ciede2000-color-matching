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

// L1 = 11.0           a1 = -5.0           b1 = -76.85
// L2 = 11.0           a2 = -5.0           b2 = -76.8086
// CIE ΔE2000 = ΔE00 = 0.00820473922

// L1 = 10.0           a1 = -81.0          b1 = 63.9
// L2 = 10.7           a2 = -79.903        b2 = 62.8965
// CIE ΔE2000 = ΔE00 = 0.51446078161

// L1 = 12.0           a1 = 93.0           b1 = -103.0
// L2 = 12.6099        a2 = 88.1008        b2 = -103.0
// CIE ΔE2000 = ΔE00 = 1.53015823659

// L1 = 81.8863        a1 = 83.11          b1 = 69.6
// L2 = 81.8863        a2 = 83.11          b2 = 63.375
// CIE ΔE2000 = ΔE00 = 2.35735611778

// L1 = 82.0           a1 = 102.65         b1 = 49.06
// L2 = 86.0           a2 = 93.13          b2 = 49.06
// CIE ΔE2000 = ΔE00 = 3.50509387626

// L1 = 7.2531         a1 = 72.399         b1 = 103.0
// L2 = 13.0           a2 = 59.13          b2 = 87.1448
// CIE ΔE2000 = ΔE00 = 4.98342348626

// L1 = 83.0           a1 = 4.99           b1 = 118.98
// L2 = 76.69          a2 = -8.01          b2 = 108.5772
// CIE ΔE2000 = ΔE00 = 7.89806915656

// L1 = 45.0           a1 = 117.5          b1 = 41.2
// L2 = 40.296         a2 = 113.3          b2 = 61.7
// CIE ΔE2000 = ΔE00 = 8.74420404387

// L1 = 12.9236        a1 = -31.66         b1 = 72.0
// L2 = 12.914         a2 = -4.3           b2 = 57.24
// CIE ΔE2000 = ΔE00 = 13.67136565266

// L1 = 56.403         a1 = -9.0           b1 = 21.9332
// L2 = 73.8           a2 = -62.985        b2 = 83.781
// CIE ΔE2000 = ΔE00 = 26.02453477122

///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
/////////////////                         /////////////////////
/////////////////         TESTING         /////////////////////
/////////////////                         /////////////////////
///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////

// The output is intended to be checked by the Large-Scale validator
// at https://michel-leonard.github.io/ciede2000-color-matching

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

var count = 10000

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
