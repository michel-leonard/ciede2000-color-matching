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
	var n = (sqrt(a_1 * a_1 + b_1 * b_1) + sqrt(a_2 * a_2 + b_2 * b_2)) * 0.5;
	n = n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - sqrt(n / (n + 6103515625.0)));
	// Application of the chroma correction factor.
	let c_1 = sqrt(a_1 * a_1 * n * n + b_1 * b_1);
	let c_2 = sqrt(a_2 * a_2 * n * n + b_2 * b_2);
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
		h_d += .pi;
		// 📜 Sharma’s formulation doesn’t use the next line, but the one after it,
		// and these two variants differ by ±0.0003 on the final color differences.
		h_m += .pi;
		// if h_m < .pi { h_m += .pi; } else { h_m -= .pi; }
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
	// Returning the square root ensures that dE00 accurately reflects the
	// geometric distance in color space, which can range from 0 to around 185.
	return sqrt(l * l + h * h + c * c + c * h * r_t);
}

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//   Online Tests : https://michel-leonard.github.io/ciede2000-color-matching

// L1 = 68.6   a1 = 41.4   b1 = -2.0
// L2 = 67.7   a2 = 36.1   b2 = 1.8
// CIE ΔE00 = 2.9718076238 (Bruce Lindbloom, Netflix’s VMAF, ...)
// CIE ΔE00 = 2.9717941461 (Gaurav Sharma, OpenJDK, ...)
// Deviation between implementations ≈ 1.3e-5

// See the source code comments for easy switching between these two widely used ΔE*00 implementation variants.

/////////////////////////////////////////////////
/////////////////////////////////////////////////
////////////                         ////////////
////////////    CIEDE2000 Driver     ////////////
////////////                         ////////////
/////////////////////////////////////////////////
/////////////////////////////////////////////////

// Reads a CSV file specified as the first command-line argument. For each line, this program
// in Swift displays the original line with the computed Delta E 2000 color difference appended.
// The C driver can offer CSV files to process and programmatically check the calculations performed there.

//  Example of a CSV input line : 3.1,5.9,118,30,-6,107
//    Corresponding output line : 3.1,5.9,118,30,-6,107,18.972937614749456554969032391992

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
	let deltaEStr = String(format: "%.17f", deltaE)
	print("\(line),\(deltaEStr)")
}

main()
