// This function written in TypeScript is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

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

// L1 = 82.0002        a1 = -72.47         b1 = 87.773
// L2 = 46.7           a2 = 99.2           b2 = 43.392
// CIE ΔE2000 = ΔE00 = 94.87911465017

///////////////////////////////////////////////
///////////////////////////////////////////////
///////                                 ///////
///////           CIEDE 2000            ///////
///////      Testing Random Colors      ///////
///////                                 ///////
///////////////////////////////////////////////
///////////////////////////////////////////////

// This program outputs a CSV file to standard output, with its length determined by the first CLI argument.
// Each line contains seven columns:
// - Three columns for the standard L*a*b* color
// - Three columns for the sample L*a*b* color
// - One column for the Delta E 2000 color difference between the standard and sample
// The output can be verified in two ways:
// - With the C driver, which provides a dedicated verification feature
// - By using the JavaScript validator at https://michel-leonard.github.io/ciede2000-color-matching

function randInRange(min: number, max: number): number {
	const n = min + (max - min) * Math.random();
	switch (Math.floor(Math.random() * 3)) {
		case 0: return Math.round(n);
		case 1: return Math.round(n * 10) / 10;
		default: return Math.round(n * 100) / 100;
	}
}

const arg = process.argv.length > 2 ? parseInt(process.argv[2], 10) : 10000;
const nIterations = isFinite(arg) && arg > 0 ? arg : 10000;

for (let i = 0; i < nIterations; ++i) {
	const l1 = randInRange(0.0, 100.0);
	const a1 = randInRange(-128.0, 128.0);
	const b1 = randInRange(-128.0, 128.0);
	const l2 = randInRange(0.0, 100.0);
	const a2 = randInRange(-128.0, 128.0);
	const b2 = randInRange(-128.0, 128.0);

	const deltaE = ciede_2000(l1, a1, b1, l2, a2, b2);

	process.stdout.write(`${l1},${a1},${b1},${l2},${a2},${b2},${deltaE}\n`);
}
