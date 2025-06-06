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

// L1 = 98.958         a1 = -122.76        b1 = 8.14
// L2 = 98.958         a2 = -122.73        b2 = 8.14
// CIE ΔE2000 = ΔE00 = 0.00463167173

// L1 = 81.9           a1 = -43.8          b1 = -57.2
// L2 = 81.9           a2 = -43.8          b2 = -57.0
// CIE ΔE2000 = ΔE00 = 0.05697579136

// L1 = 68.4           a1 = -50.98         b1 = 38.5
// L2 = 68.4           a2 = -59.23         b2 = 38.5
// CIE ΔE2000 = ΔE00 = 2.58884653731

// L1 = 14.9249        a1 = -17.624        b1 = -85.1864
// L2 = 16.1           a2 = -10.922        b2 = -79.2
// CIE ΔE2000 = ΔE00 = 3.66254150876

// L1 = 53.0           a1 = 117.9844       b1 = -83.9749
// L2 = 71.7           a2 = 92.727         b2 = -73.07
// CIE ΔE2000 = ΔE00 = 16.50173619011

// L1 = 88.6472        a1 = -117.945       b1 = -70.0
// L2 = 67.446         a2 = -126.67        b2 = -23.1
// CIE ΔE2000 = ΔE00 = 21.44606052136

// L1 = 69.99          a1 = 41.2           b1 = 87.6
// L2 = 50.64          a2 = 79.4           b2 = 83.75
// CIE ΔE2000 = ΔE00 = 24.06322148708

// L1 = 92.6           a1 = 82.0           b1 = -119.868
// L2 = 61.1904        a2 = 81.4           b2 = -87.119
// CIE ΔE2000 = ΔE00 = 24.58582585465

// L1 = 97.3           a1 = 0.67           b1 = -79.3
// L2 = 81.5           a2 = 22.0           b2 = -13.8248
// CIE ΔE2000 = ΔE00 = 42.50341751365

// L1 = 46.5           a1 = 49.0           b1 = 2.0
// L2 = 93.5           a2 = -127.68        b2 = 92.8
// CIE ΔE2000 = ΔE00 = 96.57413461364

//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
///////////////////////                        ///////////////////////////
///////////////////////        TESTING         ///////////////////////////
///////////////////////                        ///////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////

// The output is intended to be checked by the Large-Scale validator
// at https://michel-leonard.github.io/ciede2000-color-matching

const rand_in_range = (min, max) => {
	const n = min + (max - min) * Math.random()
	switch(Math.floor(Math.random() * 3)){
		case 0 : return Math.round(n)
		case 1 : return Math.round(n * 10.0) / 10.0
		default : return Math.round(n * 100.0) / 100.0
	}
}

let arg = 1 < process.argv.length ? parseInt(process.argv[2], 10) : 10000;
const n_iterations = isFinite(arg) && 0 < arg ? arg : 10000

for(let i = 0; i < n_iterations; ++i) {
	const l_1 = rand_in_range(0.0, 100.0)
	const a_1 = rand_in_range(-128.0, 128.0)
	const b_1 = rand_in_range(-128.0, 128.0)
	const l_2 = rand_in_range(0.0, 100.0)
	const a_2 = rand_in_range(-128.0, 128.0)
	const b_2 = rand_in_range(-128.0, 128.0)
	const delta_e = ciede_2000(l_1, a_1, b_1, l_2, a_2, b_2)
	process.stdout.write(`${l_1},${a_1},${b_1},${l_2},${a_2},${b_2},${delta_e}\n`)
}
