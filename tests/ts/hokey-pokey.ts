import * as fs from 'fs';
import * as readline from 'readline';

// npm init -y; npm install --save-dev @types/node; tsc --init; tsc hokey-pokey.ts

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

// L1 = 99.0           a1 = 110.19         b1 = -79.32
// L2 = 99.0           a2 = 110.19         b2 = -79.0
// CIE ΔE2000 = ΔE00 = 0.0837805098

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

function compare_values(ext: string): void {
	const path = `./../${ext}/values-${ext}.txt`;
	process.stdout.write(`compare_values('${path}')\n`);

	const rl = readline.createInterface({
		input: fs.createReadStream(path),
		terminal: false,
	});

	let n_err = 0, n = 0;

	rl.on('line', (line: string) => {
		const row: number[] = line.split(',').map(parseFloat);
		const delta_E = row.pop() as number; // 'as number' car on sait que ce n'est pas undefined ici
		const res = ciede_2000(row[0], row[1], row[2], row[3], row[4], row[5]);
		const err = Math.abs(res - delta_E);

		if (!isFinite(res) || !isFinite(delta_E) || 1e-10 < err) {
			process.stdout.write(`Error with ${line} get ${res}`);
			if (++n_err === 10) rl.close();
		} else if (++n % 1000 === 0) {
			process.stdout.write('.');
		}
	});
}

function prepare_values(num: number = 10000): void {
	const path = './values-ts.txt';
	process.stdout.write(`prepare_values('${path}', ${num})\n`);
	const stream = fs.createWriteStream(path, { flags: 'w' });

	stream.once('open', async () => {
		for (let i = 0; i < num; ++i) {
			const row: number[] = [
				parseFloat((Math.random() * 100).toFixed(3 * Math.random())),
				parseFloat((Math.random() * 256 - 128).toFixed(3 * Math.random())),
				parseFloat((Math.random() * 256 - 128).toFixed(3 * Math.random())),
				parseFloat((Math.random() * 100).toFixed(3 * Math.random())),
				parseFloat((Math.random() * 256 - 128).toFixed(3 * Math.random())),
				parseFloat((Math.random() * 256 - 128).toFixed(3 * Math.random())),
			];

			if (i % 1000 === 0) {
				process.stdout.write('.');
			}

			row.push(ciede_2000(row[0], row[1], row[2], row[3], row[4], row[5]));

			if (!stream.write(row.join(',') + '\n')) {
				await new Promise<void>((resolve) => stream.once('drain', resolve));
			}
		}
	});
}

const arg = process.argv.pop()?.toLowerCase();
if (arg && /^[a-z]+$/.test(arg)) {
	compare_values(arg);
} else {
	prepare_values((~~Number(arg)) || 10000);
}
