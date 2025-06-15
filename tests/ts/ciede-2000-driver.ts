// Limited Use License – March 1, 2025

// This source code is provided for public use under the following conditions :
// It may be downloaded, compiled, and executed, including in publicly accessible environments.
// Modification is strictly prohibited without the express written permission of the author.

// © Michel Leonard 2025

// The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
// "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
function ciede_2000(l_1: number, a_1: number, b_1: number, l_2: number, a_2: number, b_2: number): number {
	// Working in TypeScript with the CIEDE2000 color-difference formula.
	// k_l, k_c, k_h are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	const k_l = 1.0, k_c = 1.0, k_h = 1.0;
	let n = (Math.hypot(a_1, b_1) + Math.hypot(a_2, b_2)) * 0.5;
	n = n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - Math.sqrt(n / (n + 6103515625.0)));
	// hypot calculates the Euclidean distance while avoiding overflow/underflow.
	const c_1 = Math.hypot(a_1 * n, b_1), c_2 = Math.hypot(a_2 * n, b_2);
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	let h_1 = Math.atan2(b_1, a_1 * n), h_2 = Math.atan2(b_2, a_2 * n);
	if (h_1 < 0.0)
		h_1 += 2.0 * Math.PI;
	if (h_2 < 0.0)
		h_2 += 2.0 * Math.PI;
	n = Math.abs(h_2 - h_1);
	// Cross-implementation consistent rounding.
	if (Math.PI - 1E-14 < n && n < Math.PI + 1E-14)
		n = Math.PI;
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	let h_m = (h_1 + h_2) * 0.5, h_d = (h_2 - h_1) * 0.5;
	if (Math.PI < n) {
		if (0.0 < h_d)
			h_d -= Math.PI;
		else
			h_d += Math.PI;
		h_m += Math.PI;
	}
	const p = 36.0 * h_m - 55.0 * Math.PI;
	n = (c_1 + c_2) * 0.5;
	n = n * n * n * n * n * n * n;
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	const r_t = -2.0 * Math.sqrt(n / (n + 6103515625.0))
		* Math.sin(Math.PI / 3.0 * Math.exp(p * p / (-25.0 * Math.PI * Math.PI)));
	n = (l_1 + l_2) * 0.5;
	n = (n - 50.0) * (n - 50.0);
	// Lightness.
	const l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / Math.sqrt(20.0 + n)));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	const t = 1.0	+ 0.24 * Math.sin(2.0 * h_m + Math.PI * 0.5)
			+ 0.32 * Math.sin(3.0 * h_m + 8.0 * Math.PI / 15.0)
			- 0.17 * Math.sin(h_m + Math.PI / 3.0)
			- 0.20 * Math.sin(4.0 * h_m + 3.0 * Math.PI / 20.0);
	n = c_1 + c_2;
	// Hue.
	const h = 2.0 * Math.sqrt(c_1 * c_2) * Math.sin(h_d) / (k_h * (1.0 + 0.0075 * n * t));
	// Chroma.
	const c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
	// Returns the square root so that the Delta E 2000 reflects the actual geometric
	// distance within the color space, which ranges from 0 to approximately 185.
	return Math.sqrt(l * l + h * h + c * c + c * h * r_t);
}

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

// L1 = 81.0           a1 = -62.2          b1 = -100.428
// L2 = 81.0           a2 = -62.2          b2 = -100.341
// CIE ΔE2000 = ΔE00 = 0.01585129132

// L1 = 5.9            a1 = -75.0          b1 = -102.8079
// L2 = 8.4369         a2 = -75.0          b2 = -100.739
// CIE ΔE2000 = ΔE00 = 1.5945145677

// L1 = 57.2           a1 = 27.2309        b1 = -47.5
// L2 = 58.8723        a2 = 30.3           b2 = -47.5
// CIE ΔE2000 = ΔE00 = 2.33514815551

// L1 = 55.3           a1 = 83.839         b1 = -0.5
// L2 = 59.0           a2 = 83.839         b2 = -4.237
// CIE ΔE2000 = ΔE00 = 3.66452495185

// L1 = 59.73          a1 = -16.9191       b1 = -98.0
// L2 = 64.3217        a2 = -16.9191       b2 = -98.0
// CIE ΔE2000 = ΔE00 = 3.92763415405

// L1 = 43.5983        a1 = 57.0196        b1 = -34.452
// L2 = 41.3           a2 = 43.7           b2 = -35.0
// CIE ΔE2000 = ΔE00 = 5.22469945928

// L1 = 37.0066        a1 = 50.71          b1 = 88.23
// L2 = 28.0           a2 = 67.9659        b2 = 119.0
// CIE ΔE2000 = ΔE00 = 9.06779612766

// L1 = 66.2731        a1 = 11.6941        b1 = -104.6561
// L2 = 77.0           a2 = 11.28          b2 = -66.7583
// CIE ΔE2000 = ΔE00 = 13.09229578171

// L1 = 54.5329        a1 = 71.5079        b1 = 1.9
// L2 = 69.2068        a2 = 30.1672        b2 = -17.02
// CIE ΔE2000 = ΔE00 = 20.71710293422

// L1 = 93.5           a1 = 59.3832        b1 = -8.53
// L2 = 7.0            a2 = -72.0          b2 = -106.0
// CIE ΔE2000 = ΔE00 = 136.10218811693

/////////////////////////////////////////////////
/////////////////////////////////////////////////
////////////                         ////////////
////////////    CIEDE2000 Driver     ////////////
////////////                         ////////////
/////////////////////////////////////////////////
/////////////////////////////////////////////////

// Reads a CSV file specified as the first command-line argument. For each line, the program
// outputs the original line with the computed Delta E 2000 color difference appended.

//  Example of a CSV input line : 67.24,-14.22,70,65,8,46
//    Corresponding output line : 67.24,-14.22,70,65,8,46,15.46723547943141064

import * as fs from 'fs';
import * as readline from 'readline';

if (process.argv.length < 3) {
	console.error("Usage: ts-node ciede-2000-driver.ts <filename>");
	process.exit(1);
}

const filename: string = process.argv[2];

const lineReader = readline.createInterface({
	input: fs.createReadStream(filename)
});

lineReader.on('line', (line: string) => {
	const [l1, a1, b1, l2, a2, b2] = line.split(',').map(parseFloat);
	const result = ciede_2000(l1, a1, b1, l2, a2, b2);
	process.stdout.write(`${line},${result}\n`);
});

lineReader.on('close', () => {
	// Nothing to do here
});
