// This function written in Swift is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

import Foundation

// The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
// "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
func ciede_2000(l_1: Double, a_1: Double, b_1: Double, l_2: Double, a_2: Double, b_2: Double) -> Double {
	// Working in Swift with the CIEDE2000 color-difference formula.
	// k_l, k_c, k_h are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	let k_l = 1.0, k_c = 1.0, k_h = 1.0;
	var n = (hypot(a_1, b_1) + hypot(a_2, b_2)) * 0.5;
	n = n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - sqrt(n / (n + 6103515625.0)));
	// hypot calculates the Euclidean distance while avoiding overflow/underflow.
	let c_1 = hypot(a_1 * n, b_1), c_2 = hypot(a_2 * n, b_2);
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	var h_1 = atan2(b_1, a_1 * n), h_2 = atan2(b_2, a_2 * n);
	if h_1 < 0.0 { h_1 += 2.0 * .pi; }
	if h_2 < 0.0 { h_2 += 2.0 * .pi; }
	n = abs(h_2 - h_1);
	// Cross-implementation consistent rounding.
	if .pi - 1E-14 < n && n < .pi + 1E-14 { n = .pi; }
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	var h_m = (h_1 + h_2) * 0.5, h_d = (h_2 - h_1) * 0.5;
	if .pi < n {
		if 0.0 < h_d { h_d -= .pi; }
		else { h_d += .pi; }
		h_m += .pi;
	}
	let p = 36.0 * h_m - 55.0 * .pi;
	n = (c_1 + c_2) * 0.5;
	n = n * n * n * n * n * n * n;
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	let r_t = -2.0 * sqrt(n / (n + 6103515625.0))
			* sin(.pi / 3.0 * exp(p * p / (-25.0 * .pi * .pi)));
	n = (l_1 + l_2) * 0.5;
	n = (n - 50.0) * (n - 50.0);
	// Lightness.
	let l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / sqrt(20.0 + n)));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	let t = 1.0 	+ 0.24 * sin(2.0 * h_m + .pi * 0.5)
			+ 0.32 * sin(3.0 * h_m + 8.0 * .pi / 15.0)
			- 0.17 * sin(h_m + .pi / 3.0)
			- 0.20 * sin(4.0 * h_m + 3.0 * .pi / 20.0);
	n = c_1 + c_2;
	// Hue.
	let h = 2.0 * sqrt(c_1 * c_2) * sin(h_d) / (k_h * (1.0 + 0.0075 * n * t));
	// Chroma.
	let c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
	// Returns the square root so that the Delta E 2000 reflects the actual geometric
	// distance within the color space, which ranges from 0 to approximately 185.
	return sqrt(l * l + h * h + c * c + c * h * r_t);
}

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

// L1 = 0.03           a1 = 60.245         b1 = -9.0
// L2 = 0.0            a2 = 60.245         b2 = -9.0
// CIE ΔE2000 = ΔE00 = 0.0171743402

// L1 = 26.324         a1 = -85.4          b1 = -72.736
// L2 = 26.324         a2 = -80.6          b2 = -72.736
// CIE ΔE2000 = ΔE00 = 1.11724043687

// L1 = 3.531          a1 = 67.9709        b1 = 3.8603
// L2 = 3.531          a2 = 67.0372        b2 = -4.66
// CIE ΔE2000 = ΔE00 = 3.64146209714

// L1 = 59.0           a1 = 49.6967        b1 = 83.246
// L2 = 59.0           a2 = 55.83          b2 = 76.0
// CIE ΔE2000 = ΔE00 = 4.82701497664

// L1 = 11.0           a1 = 104.7          b1 = -83.1309
// L2 = 18.07          a2 = 112.9          b2 = -74.0
// CIE ΔE2000 = ΔE00 = 5.95317771633

// L1 = 49.5           a1 = -123.1         b1 = -101.0
// L2 = 50.4862        a2 = -92.3          b2 = -63.0
// CIE ΔE2000 = ΔE00 = 7.43630893488

// L1 = 49.1688        a1 = 67.473         b1 = 12.0766
// L2 = 41.427         a2 = 75.4           b2 = -10.39
// CIE ΔE2000 = ΔE00 = 12.04545144227

// L1 = 64.6198        a1 = 14.57          b1 = 89.5308
// L2 = 60.2635        a2 = 54.568         b2 = 77.52
// CIE ΔE2000 = ΔE00 = 23.10937280626

// L1 = 53.0           a1 = 10.5773        b1 = -109.3622
// L2 = 31.6902        a2 = -38.29         b2 = 56.06
// CIE ΔE2000 = ΔE00 = 73.63756849227

// L1 = 28.2           a1 = 110.3          b1 = -116.982
// L2 = 65.5072        a2 = -57.0          b2 = 90.0
// CIE ΔE2000 = ΔE00 = 112.28691106979

/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
//////////////////                          /////////////////////////
//////////////////                          /////////////////////////
//////////////////         TESTING          /////////////////////////
//////////////////                          /////////////////////////
//////////////////                          /////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////

// The output is intended to be checked by the Large-Scale validator
// at https://michel-leonard.github.io/ciede2000-color-matching

var results: [String] = []

let default_count = 10000
let argument = CommandLine.arguments.dropFirst().first
let count = Int(argument ?? "") ?? default_count
let real_count = count >= 0 ? count : default_count

for _ in 0..<real_count {
	let l1Decimal = pow(10.0, Double(Int.random(in: 0...1)))
	let l1 = round(Double.random(in: 0...100) * l1Decimal) / l1Decimal
	let a1Decimal = pow(10.0, Double(Int.random(in: 0...1)))
	let a1 = round(Double.random(in: -128...128) * a1Decimal) / a1Decimal
	let b1Decimal = pow(10.0, Double(Int.random(in: 0...1)))
	let b1 = round(Double.random(in: -128...128) * b1Decimal) / b1Decimal

	let l2Decimal = pow(10.0, Double(Int.random(in: 0...1)))
	let l2 = round(Double.random(in: 0...100) * l2Decimal) / l2Decimal
	let a2Decimal = pow(10.0, Double(Int.random(in: 0...1)))
	let a2 = round(Double.random(in: -128...128) * a2Decimal) / a2Decimal
	let b2Decimal = pow(10.0, Double(Int.random(in: 0...1)))
	let b2 = round(Double.random(in: -128...128) * b2Decimal) / b2Decimal

	let deltaE = ciede_2000(l_1: l1, a_1: a1, b_1: b1, l_2: l2, a_2: a2, b_2: b2)

	results.append("\(l1),\(a1),\(b1),\(l2),\(a2),\(b2),\(deltaE)")
}

for result in results {
	print(result)
}
