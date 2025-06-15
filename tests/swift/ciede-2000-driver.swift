// Limited Use License – March 1, 2025

// This source code is provided for public use under the following conditions :
// It may be downloaded, compiled, and executed, including in publicly accessible environments.
// Modification is strictly prohibited without the express written permission of the author.

// © Michel Leonard 2025

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

// L1 = 73.7           a1 = -69.8          b1 = -50.0
// L2 = 73.7           a2 = -69.828        b2 = -50.0
// CIE ΔE2000 = ΔE00 = 0.00762132883

// L1 = 99.299         a1 = 45.941         b1 = 81.76
// L2 = 99.299         a2 = 45.941         b2 = 84.53
// CIE ΔE2000 = ΔE00 = 0.85110967366

// L1 = 35.231         a1 = 76.347         b1 = 29.4
// L2 = 35.231         a2 = 76.347         b2 = 35.0
// CIE ΔE2000 = ΔE00 = 2.46638538597

// L1 = 57.703         a1 = -51.76         b1 = 69.67
// L2 = 57.703         a2 = -51.76         b2 = 60.0769
// CIE ΔE2000 = ΔE00 = 2.82596982305

// L1 = 46.033         a1 = 89.1665        b1 = 41.64
// L2 = 43.63          a2 = 117.3          b2 = 46.0
// CIE ΔE2000 = ΔE00 = 5.80916492828

// L1 = 27.3           a1 = -17.067        b1 = -69.2643
// L2 = 34.0           a2 = -5.0           b2 = -126.08
// CIE ΔE2000 = ΔE00 = 8.7815617801

// L1 = 67.54          a1 = -61.0          b1 = -46.2
// L2 = 58.0           a2 = -97.0          b2 = -73.1672
// CIE ΔE2000 = ΔE00 = 11.54399543005

// L1 = 73.86          a1 = 48.815         b1 = 36.158
// L2 = 88.7           a2 = 103.53         b2 = 115.27
// CIE ΔE2000 = ΔE00 = 21.12126227618

// L1 = 77.0           a1 = 17.4           b1 = -15.0
// L2 = 70.236         a2 = 57.0           b2 = 71.2
// CIE ΔE2000 = ΔE00 = 37.69268444246

// L1 = 40.0           a1 = 62.0           b1 = -61.446
// L2 = 93.0           a2 = 31.36          b2 = 89.8
// CIE ΔE2000 = ΔE00 = 75.42811008575

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

func main() {
	let arguments = CommandLine.arguments
	guard arguments.count > 1 else {
		fputs("Usage: \(arguments[0]) <filename>\n", stderr)
		exit(1)
	}
	let filename = arguments[1]
	guard let fileHandle = FileHandle(forReadingAtPath: filename) else {
		fputs("Cannot open file: \(filename)\n", stderr)
		exit(1)
	}
	let buffer = NSMutableData()
	let delim = UInt8(ascii: "\n")
	while true {
		let chunk = fileHandle.readData(ofLength: 4096)
		if chunk.count == 0 {
			if buffer.length > 0 {
				if let line = String(data: buffer as Data, encoding: .utf8) {
					processLine(line)
				}
			}
			break
		}
		for byte in chunk {
			if byte == delim {
				if let line = String(data: buffer as Data, encoding: .utf8) {
					processLine(line)
				}
				buffer.length = 0
			} else {
				buffer.append([byte], length: 1)
			}
		}
	}
	fileHandle.closeFile()
}

func processLine(_ line: String) {
	let parts = line.split(separator: ",", omittingEmptySubsequences: false)
	guard parts.count == 6 else { return }
	let L1 = Double(parts[0])!
	let a1 = Double(parts[1])!
	let b1 = Double(parts[2])!
	let L2 = Double(parts[3])!
	let a2 = Double(parts[4])!
	let b2 = Double(parts[5])!
	let deltaE = ciede_2000(l_1:L1, a_1:a1, b_1:b1, l_2:L2, a_2:a2, b_2:b2)
	let deltaEStr = String(format: "%.17g", deltaE)
	print("\(line),\(deltaEStr)")
}

main()
