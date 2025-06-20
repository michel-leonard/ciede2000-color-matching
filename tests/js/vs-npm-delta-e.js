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

// L1 = 96.9           a1 = -75.4179       b1 = 80.0
// L2 = 96.9           a2 = -75.4179       b2 = 79.967
// CIE ΔE2000 = ΔE00 = 0.00820101893

////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
////////////                               /////////////
////////////         Compare with          /////////////
////////////         npm/delta-e           /////////////
////////////                               /////////////
////////////////////////////////////////////////////////
////////////////////////////////////////////////////////

// The goal is to demonstrate that the library produces results identical to npm/delta-e.  
// If the results differ by more than a tolerance of 1E-10, a non-zero value will be returned.
// Explore the workflows to see how this code is executed.

let arg = 1 < process.argv.length ? parseInt(process.argv[2], 10) : 10000;
const n_iterations = isFinite(arg) && 0 < arg ? arg : 10000

// Installed with "npm i delta-e".
const DeltaE = require('delta-e')

let maxDiff = 0
let worstCase = {}

for (let i = 0; i < n_iterations; i++) {
	const l1 = Math.random() * 100
	const a1 = Math.random() * 255 - 128
	const b1 = Math.random() * 255 - 128
	const l2 = Math.random() * 100
	const a2 = Math.random() * 255 - 128
	const b2 = Math.random() * 255 - 128

	const color1 = { L: l1, A: a1, B: b1 }
	const color2 = { L: l2, A: a2, B: b2 }

	const delta1 = DeltaE.getDeltaE00(color1, color2)
	const delta2 = ciede_2000(l1, a1, b1, l2, a2, b2)

	if (!(isFinite(delta1) && isFinite(delta2)))
		process.exit(1)
	
	const diff = Math.abs(delta1 - delta2)
	if (diff > maxDiff) {
		maxDiff = diff
		worstCase = { l1, a1, b1, l2, a2, b2, delta1, delta2, diff }
	}
}
console.log('Total runs :', n_iterations);
console.log('Worst case :', worstCase);
process.exit(+(1e-10 < worstCase.diff))
