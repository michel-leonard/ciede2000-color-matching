// Limited Use License – March 1, 2025

// This source code is provided for public use under the following conditions :
// It may be downloaded, compiled, and executed, including in publicly accessible environments.
// Modification is strictly prohibited without the express written permission of the author.

// © Michel Leonard 2025

using System;
using System.IO;

public class CIE {

	// The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
	// "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
	static double ciede_2000(double l_1, double a_1, double b_1, double l_2, double a_2, double b_2) {
		// Working in C# (.NET Core) with the CIEDE2000 color-difference formula.
		// k_l, k_c, k_h are parametric factors to be adjusted according to
		// different viewing parameters such as textures, backgrounds...
		const double k_l = 1.0, k_c = 1.0, k_h = 1.0;
		double n = (Math.Sqrt(a_1 * a_1 + b_1 * b_1) + Math.Sqrt(a_2 * a_2 + b_2 * b_2)) * 0.5;
		n = n * n * n * n * n * n * n;
		// A factor involving chroma raised to the power of 7 designed to make
		// the influence of chroma on the total color difference more accurate.
		n = 1.0 + 0.5 * (1.0 - Math.Sqrt(n / (n + 6103515625.0)));
		// Since hypot is not available, sqrt is used here to calculate the
		// Euclidean distance, without avoiding overflow/underflow.
		double c_1 = Math.Sqrt(a_1 * a_1 * n * n + b_1 * b_1);
		double c_2 = Math.Sqrt(a_2 * a_2 * n * n + b_2 * b_2);
		// atan2 is preferred over atan because it accurately computes the angle of
		// a point (x, y) in all quadrants, handling the signs of both coordinates.
		double h_1 = Math.Atan2(b_1, a_1 * n), h_2 = Math.Atan2(b_2, a_2 * n);
		if (h_1 < 0.0) h_1 += 2.0 * Math.PI;
		if (h_2 < 0.0) h_2 += 2.0 * Math.PI;
		n = Math.Abs(h_2 - h_1);
		// Cross-implementation consistent rounding.
		if (Math.PI - 1E-14 < n && n < Math.PI + 1E-14)
			n = Math.PI;
		// When the hue angles lie in different quadrants, the straightforward
		// average can produce a mean that incorrectly suggests a hue angle in
		// the wrong quadrant, the next lines handle this issue.
		double h_m = (h_1 + h_2) * 0.5, h_d = (h_2 - h_1) * 0.5;
		if (Math.PI < n) {
			if (0.0 < h_d)
				h_d -= Math.PI;
			else
				h_d += Math.PI;
			h_m += Math.PI;
		}
		double p = 36.0 * h_m - 55.0 * Math.PI;
		n = (c_1 + c_2) * 0.5;
		n = n * n * n * n * n * n * n;
		// The hue rotation correction term is designed to account for the
		// non-linear behavior of hue differences in the blue region.
		double r_t = -2.0 * Math.Sqrt(n / (n + 6103515625.0))
				* Math.Sin(Math.PI / 3.0 * Math.Exp(p * p / (-25.0 * Math.PI * Math.PI)));
		n = (l_1 + l_2) * 0.5;
		n = (n - 50.0) * (n - 50.0);
		// Lightness.
		double l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / Math.Sqrt(20.0 + n)));
		// These coefficients adjust the impact of different harmonic
		// components on the hue difference calculation.
		double t = 1.0	+ 0.24 * Math.Sin(2.0 * h_m + Math.PI * 0.5)
					+ 0.32 * Math.Sin(3.0 * h_m + 8.0 * Math.PI / 15.0)
					- 0.17 * Math.Sin(h_m + Math.PI / 3.0)
					- 0.20 * Math.Sin(4.0 * h_m + 3.0 * Math.PI / 20.0);
		n = c_1 + c_2;
		// Hue.
		double h = 2.0 * Math.Sqrt(c_1 * c_2) * Math.Sin(h_d) / (k_h * (1.0 + 0.0075 * n * t));
		// Chroma.
		double c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
		// Returns the square root so that the Delta E 2000 reflects the actual geometric
		// distance within the color space, which ranges from 0 to approximately 185.
		return Math.Sqrt(l * l + h * h + c * c + c * h * r_t);
	}

	// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
	//  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

	// L1 = 57.042         a1 = 26.054         b1 = -65.1
	// L2 = 57.042         a2 = 26.054         b2 = -65.1091
	// CIE ΔE2000 = ΔE00 = 0.00403031776

	// L1 = 99.3342        a1 = -97.604        b1 = -9.1
	// L2 = 99.3342        a2 = -97.604        b2 = -6.6772
	// CIE ΔE2000 = ΔE00 = 1.01065909289

	// L1 = 28.3           a1 = -39.084        b1 = -46.56
	// L2 = 28.3           a2 = -44.532        b2 = -46.56
	// CIE ΔE2000 = ΔE00 = 1.93766642505

	// L1 = 73.5           a1 = 103.12         b1 = 46.0
	// L2 = 77.0           a2 = 97.31          b2 = 46.0
	// CIE ΔE2000 = ΔE00 = 2.87358524579

	// L1 = 4.8            a1 = 49.28          b1 = -28.799
	// L2 = 7.4            a2 = 43.5           b2 = -20.823
	// CIE ΔE2000 = ΔE00 = 3.73282989208

	// L1 = 61.8           a1 = 5.0            b1 = -95.458
	// L2 = 64.99          a2 = -4.7           b2 = -89.091
	// CIE ΔE2000 = ΔE00 = 4.70083644142

	// L1 = 1.526          a1 = 120.0          b1 = 94.13
	// L2 = 12.539         a2 = 70.449         b2 = 111.9726
	// CIE ΔE2000 = ΔE00 = 21.40481944302

	// L1 = 36.676         a1 = -97.08         b1 = -110.53
	// L2 = 52.2           a2 = -24.5031       b2 = -113.651
	// CIE ΔE2000 = ΔE00 = 23.17878866127

	// L1 = 98.0373        a1 = -92.3          b1 = 116.7855
	// L2 = 35.03          a2 = -82.41         b2 = 21.4305
	// CIE ΔE2000 = ΔE00 = 55.89067616391

	// L1 = 3.832          a1 = 83.851         b1 = 55.0
	// L2 = 91.96          a2 = -111.46        b2 = -82.15
	// CIE ΔE2000 = ΔE00 = 148.01934212584

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

	public static void Test(string filename) {
		foreach (var line in File.ReadLines(filename)) {
			var parts = line.Split(',');
			// Parse all six parameters from the line
			double L1 = double.Parse(parts[0]);
			double a1 = double.Parse(parts[1]);
			double b1 = double.Parse(parts[2]);
			double L2 = double.Parse(parts[3]);
			double a2 = double.Parse(parts[4]);
			double b2 = double.Parse(parts[5]);
			double deltaE = ciede_2000(L1, a1, b1, L2, a2, b2);
			Console.WriteLine($"{L1},{a1},{b1},{L2},{a2},{b2},{deltaE:R}");
			}
		}
}

if (Args.Count > 0)
	CIE.Test(Args[0]);
