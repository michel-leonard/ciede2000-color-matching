// Limited Use License – March 1, 2025

// This source code is provided for public use under the following conditions :
// It may be downloaded, compiled, and executed, including in publicly accessible environments.
// Modification is strictly prohibited without the express written permission of the author.

// © Michel Leonard 2025

// The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
// "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
function ciede_2000(l_1, a_1, b_1, l_2, a_2, b_2) {
	"use strict"
	// Working in JavaScript with the CIEDE2000 color-difference formula.
	// k_l, k_c, k_h are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	var k_l = 1.0, k_c = 1.0, k_h = 1.0;
	var n = (Math.sqrt(a_1 * a_1 + b_1 * b_1) + Math.sqrt(a_2 * a_2 + b_2 * b_2)) * 0.5;
	n = n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - Math.sqrt(n / (n + 6103515625.0)));
	// Application of the chroma correction factor.
	var c_1 = Math.sqrt(a_1 * a_1 * n * n + b_1 * b_1);
	var c_2 = Math.sqrt(a_2 * a_2 * n * n + b_2 * b_2);
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
		h_d += Math.PI;
		// 📜 Sharma’s formulation doesn’t use the next line, but the one after it,
		// and these two variants differ by ±0.0003 on the final color differences.
		h_m += Math.PI;
		// h_m += h_m < Math.PI ? Math.PI : -Math.PI;
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
	// Returning the square root ensures that dE00 accurately reflects the
	// geometric distance in color space, which can range from 0 to around 185.
	return Math.sqrt(l * l + h * h + c * c + c * h * r_t);
}

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//   Online Tests : https://michel-leonard.github.io/ciede2000-color-matching

// L1 = 26.3   a1 = 10.6   b1 = 3.4
// L2 = 27.6   a2 = 16.2   b2 = -5.1
// CIE ΔE00 = 7.4721880778 (Bruce Lindbloom, Netflix’s VMAF, ...)
// CIE ΔE00 = 7.4721746408 (Gaurav Sharma, OpenJDK, ...)
// Deviation between implementations ≈ 1.3e-5

// See the source code comments for easy switching between these two widely used ΔE*00 implementation variants.

/////////////////////////////////////////////////
/////////////////////////////////////////////////
////////////                         ////////////
////////////    CIEDE2000 Driver     ////////////
////////////                         ////////////
/////////////////////////////////////////////////
/////////////////////////////////////////////////

if (process.argv.length < 2) {
	console.error('Usage: node ciede-2000-driver.js <filename>')
	console.error('Usage: node ciede-2000-driver.js < file-to-verify.csv')
	process.exit(1)
}

const fs = require('fs'), path = process.argv[2]

if (fs.existsSync(path)) {
	// Reads a CSV file specified as the first command-line argument. For each line, this program
	// in JavaScript displays the original line with the computed Delta E 2000 color difference appended.
	// The C driver can offer CSV files to process and programmatically check the calculations performed there.

	//  Example of a CSV input line : 53.9,93,-16,64,101.1,7
	//    Corresponding output line : 53.9,93,-16,64,101.1,7,11.984738082022724118652751730625
	const lineReader = require('readline').createInterface({
		input: fs.createReadStream(process.argv[2]),
	})

	lineReader.on('line', line => {
		process.stdout.write(`${line},${ciede_2000(...line.split(',').map(parseFloat))}\n`)
	})

	lineReader.on('close', () => {
		// Nothing to do here
	})
} else {

	const tolerance = process.argv[2] === '--32-bit' ? 1E-2 : 1E-10
	const readline = require('readline')
	const rl = readline.createInterface({
		input: process.stdin,
		output: process.stdout,
		terminal: false,
	})

	let n_lines = 0, sum_delta_e = 0.0, sum_err = 0.0, max_err = 0.0
	let n_success = 0, n_errors = 0, errors_displayed = 0, do_copy = true, time_1, first_line

	rl.on('line', (curr_line) => {
		++n_lines
		const v = curr_line.split(',').map(Number)
		if (v.length === 7 && v.every(isFinite)) {
			const expected_delta_e = ciede_2000(v[0], v[1], v[2], v[3], v[4], v[5])
			const err = Math.abs(v[6] - expected_delta_e)
			sum_delta_e += expected_delta_e
			sum_err += err
			const has_new_error = max_err < err
			if (has_new_error)
				max_err = err
			if (tolerance < err) {
				++n_errors
				if (has_new_error && ++errors_displayed <= 5) {
					console.error(`Line ${n_lines} : L1=${v[0]} a1=${v[1]} b1=${v[2]}`)
					console.error(`                     L2=${v[3]} a2=${v[4]} b2=${v[5]}`)
					console.error(`Expecting : ${expected_delta_e}      Found deviation : ${err}`)
					console.error(`Got       : ${v[6]}\n`)
				}
			} else
				++n_success
			if (do_copy) {
				do_copy = false
				time_1 = Date.now()
				first_line = curr_line
			}
		}
	})

	rl.once('close', () => {
		if (n_success || n_errors) {
			console.log(`CIEDE2000 Verification Summary :`)
			console.log(`  First Verified Line : ${first_line}`)
			console.log(`             Duration : ${((Date.now() - time_1) / 1000.0).toFixed(2)} s`)
			console.log(`            Successes : ${n_success}`)
			console.log(`               Errors : ${n_errors}`)
			console.log(`      Average Delta E : ${(sum_delta_e / (n_success + n_errors)).toFixed(4)}`)
			console.log(`    Average Deviation : ${sum_err / (n_success + n_errors)}`)
			console.log(`    Maximum Deviation : ${max_err}\n`)
		} else
			console.error(`No data to verify.`)
	})

}
