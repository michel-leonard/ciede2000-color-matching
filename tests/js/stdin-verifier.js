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

// L1 = 71.33          a1 = -94.6522       b1 = -46.7
// L2 = 71.33          a2 = -94.749        b2 = -46.7
// CIE ΔE2000 = ΔE00 = 0.0214835367

// L1 = 57.0           a1 = -118.11        b1 = 30.5089
// L2 = 57.1           a2 = -125.99        b2 = 30.5089
// CIE ΔE2000 = ΔE00 = 1.2958802405

// L1 = 42.313         a1 = 79.6735        b1 = -68.903
// L2 = 45.1           a2 = 87.2           b2 = -68.417
// CIE ΔE2000 = ΔE00 = 3.35266071365

// L1 = 78.29          a1 = -29.1          b1 = -88.3
// L2 = 72.77          a2 = -23.032        b2 = -78.668
// CIE ΔE2000 = ΔE00 = 4.94172895737

// L1 = 17.39          a1 = -71.0          b1 = 9.354
// L2 = 19.0           a2 = -47.392        b2 = 1.571
// CIE ΔE2000 = ΔE00 = 7.29942181144

// L1 = 27.72          a1 = 35.0           b1 = 35.0
// L2 = 24.1           a2 = 106.7293       b2 = 64.3595
// CIE ΔE2000 = ΔE00 = 18.32747446091

// L1 = 65.47          a1 = 77.09          b1 = -94.66
// L2 = 81.089         a2 = 28.3           b2 = -68.7567
// CIE ΔE2000 = ΔE00 = 19.53490666593

// L1 = 34.732         a1 = 43.4258        b1 = 100.0
// L2 = 32.698         a2 = 92.08          b2 = 96.0
// CIE ΔE2000 = ΔE00 = 20.2971426994

// L1 = 21.0           a1 = -94.196        b1 = -26.392
// L2 = 48.4           a2 = -102.0         b2 = -40.0
// CIE ΔE2000 = ΔE00 = 22.90963038136

// L1 = 1.36           a1 = -125.041       b1 = 47.0
// L2 = 23.0           a2 = 125.0          b2 = 89.89
// CIE ΔE2000 = ΔE00 = 102.71357914652

//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
///////////////////////                        ///////////////////////////
///////////////////////        TESTING         ///////////////////////////
///////////////////////                        ///////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////

// The verification is performed here in JavaScript/NodeJS.
// It reads the CSV data from STDIN and prints a completion message.

const readline = require('readline')

const rl = readline.createInterface({
	input: process.stdin,
	output: process.stdout,
	terminal: false
})

const t_1 = Date.now()
let n_success = 0
let n_bad_lines = 0, n_errors = 0
let max_err = 0
const errors = [ ]
let last_line = null

rl.on('line', (curr_line) => {
	line = curr_line.split(',').map(Number)
	if (line.length == 7 && line.every(isFinite)) {
		last_line = curr_line
		const res = ciede_2000(line[0], line[1], line[2], line[3], line[4], line[5])
		const err = Math.abs(line[6] - res)
		if (max_err < err)
			max_err = err
		if (err < 1e-10) {
			++n_success
		} else if(n_errors < 10)
			++n_errors, line.push(res), errors.push(line)
	} else if(n_bad_lines < 10)
		++n_bad_lines, console.error('Bad line in CSV input:', curr_line)
})

rl.once('close', () => {
	if (errors.length) {
		for(const [l_1, a_1, b_1, l_2, a_2, b_2, delta_e, expects] of errors)
			console.log(`Error: ciede_2000(${l_1}, ${a_1}, ${b_1}, ${l_2}, ${a_2}, ${b_2}) !== ${expects} ... got ${delta_e}`)
	}
	const t_2 = Date.now(), duration_ms = t_2 - t_1
	console.log('CIEDE2000 Verification Summary :')
	console.log('- Last Verified Line :', last_line)
	console.log('- Duration  :', (duration_ms / 1000.0).toFixed(2), 's')
	console.log('- Successes :', n_success)
	console.log('- Errors :', n_errors)
	console.log('- Maximum Difference :', max_err)
	process.exit(0)
})
