// Limited Use License – March 1, 2025

// This source code is provided for public use under the following conditions :
// It may be downloaded, compiled, and executed, including in publicly accessible environments.
// Modification is strictly prohibited without the express written permission of the author.

// © Michel Leonard 2025

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import static java.lang.Math.PI;
import static java.lang.Math.sqrt;
import static java.lang.Math.hypot;
import static java.lang.Math.atan2;
import static java.lang.Math.abs;
import static java.lang.Math.sin;
import static java.lang.Math.exp;

public class Main {

	// The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
	// "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
	static double ciede_2000(final double l_1, final double a_1, final double b_1, final double l_2, final double a_2, final double b_2) {
		// Working in Java with the CIEDE2000 color-difference formula.
		// k_l, k_c, k_h are parametric factors to be adjusted according to
		// different viewing parameters such as textures, backgrounds...
		final double k_l = 1.0, k_c = 1.0, k_h = 1.0;
		double n = (hypot(a_1, b_1) + hypot(a_2, b_2)) * 0.5;
		n = n * n * n * n * n * n * n;
		// A factor involving chroma raised to the power of 7 designed to make
		// the influence of chroma on the total color difference more accurate.
		n = 1.0 + 0.5 * (1.0 - sqrt(n / (n + 6103515625.0)));
		// hypot calculates the Euclidean distance while avoiding overflow/underflow.
		final double c_1 = hypot(a_1 * n, b_1), c_2 = hypot(a_2 * n, b_2);
		// atan2 is preferred over atan because it accurately computes the angle of
		// a point (x, y) in all quadrants, handling the signs of both coordinates.
		double h_1 = atan2(b_1, a_1 * n), h_2 = atan2(b_2, a_2 * n);
		h_1 += 2.0 * PI * Boolean.compare(h_1 < 0.0, false);
		h_2 += 2.0 * PI * Boolean.compare(h_2 < 0.0, false);
		n = abs(h_2 - h_1);
		// Cross-implementation consistent rounding.
		if (PI - 1E-14 < n && n < PI + 1E-14)
			n = PI;
		// When the hue angles lie in different quadrants, the straightforward
		// average can produce a mean that incorrectly suggests a hue angle in
		// the wrong quadrant, the next lines handle this issue.
		double h_m = (h_1 + h_2) * 0.5, h_d = (h_2 - h_1) * 0.5;
		if (PI < n) {
			if (0.0 < h_d)
				h_d -= PI;
			else
				h_d += PI;
			h_m += PI;
		}
		final double p = 36.0 * h_m - 55.0 * PI;
		n = (c_1 + c_2) * 0.5;
		n = n * n * n * n * n * n * n;
		// The hue rotation correction term is designed to account for the
		// non-linear behavior of hue differences in the blue region.
		final double r_t = -2.0 * sqrt(n / (n + 6103515625.0))
				* sin(PI / 3.0 * exp(p * p / (-25.0 * PI * PI)));
		n = (l_1 + l_2) * 0.5;
		n = (n - 50.0) * (n - 50.0);
		// Lightness.
		final double l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / sqrt(20.0 + n)));
		// These coefficients adjust the impact of different harmonic
		// components on the hue difference calculation.
		final double t = 1.0 + 0.24 * sin(2.0 * h_m + PI * 0.5)
				+ 0.32 * sin(3.0 * h_m + 8.0 * PI / 15.0)
				- 0.17 * sin(h_m + PI / 3.0)
				- 0.20 * sin(4.0 * h_m + 3.0 * PI / 20.0);
		n = c_1 + c_2;
		// Hue.
		final double h = 2.0 * sqrt(c_1 * c_2) * sin(h_d) / (k_h * (1.0 + 0.0075 * n * t));
		// Chroma.
		final double c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
		// Returns the square root so that the Delta E 2000 reflects the actual geometric
		// distance within the color space, which ranges from 0 to approximately 185.
		return sqrt(l * l + h * h + c * c + c * h * r_t);
	}

	// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
	//  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

	// L1 = 56.14          a1 = 100.0          b1 = 90.138
	// L2 = 56.14          a2 = 99.9958        b2 = 90.138
	// CIE ΔE2000 = ΔE00 = 0.00124956215

	// L1 = 70.177         a1 = -116.2         b1 = 126.4921
	// L2 = 70.177         a2 = -116.2         b2 = 126.9162
	// CIE ΔE2000 = ΔE00 = 0.07471787005

	// L1 = 55.55          a1 = 1.4944         b1 = -82.962
	// L2 = 55.55          a2 = 1.4944         b2 = -84.108
	// CIE ΔE2000 = ΔE00 = 0.25018087743

	// L1 = 69.92          a1 = -121.0         b1 = 110.8
	// L2 = 70.5           a2 = -120.516       b2 = 112.2
	// CIE ΔE2000 = ΔE00 = 0.55018594939

	// L1 = 54.0           a1 = 69.724         b1 = -91.0
	// L2 = 54.0           a2 = 69.724         b2 = -92.805
	// CIE ΔE2000 = ΔE00 = 0.61777814858

	// L1 = 29.0           a1 = -26.1          b1 = -109.2598
	// L2 = 31.76          a2 = -20.0          b2 = -109.2598
	// CIE ΔE2000 = ΔE00 = 3.07664814125

	// L1 = 39.1           a1 = 33.4           b1 = 3.26
	// L2 = 23.0           a2 = 24.9636        b2 = 9.1089
	// CIE ΔE2000 = ΔE00 = 13.90123315286

	// L1 = 64.2           a1 = -19.0          b1 = -56.8
	// L2 = 50.3265        a2 = -50.7          b2 = -57.27
	// CIE ΔE2000 = ΔE00 = 17.31948687871

	// L1 = 68.3           a1 = -78.2271       b1 = 60.63
	// L2 = 64.13          a2 = -20.0          b2 = 76.3172
	// CIE ΔE2000 = ΔE00 = 22.95932386969

	// L1 = 63.0           a1 = 83.0           b1 = -18.0
	// L2 = 89.591         a2 = 60.19          b2 = 84.53
	// CIE ΔE2000 = ΔE00 = 48.53605841885

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

	public static void main(String[] args) {
		if (args.length < 1) {
			System.err.println("Filename argument missing.");
			System.exit(1);
		}
		String filename = args[0];
		try (BufferedReader reader = new BufferedReader(new FileReader(filename))) {
			String line;
			while ((line = reader.readLine()) != null) {
				final String[] parts = line.split(",");
				final double L1 = Double.parseDouble(parts[0]);
				final double a1 = Double.parseDouble(parts[1]);
				final double b1 = Double.parseDouble(parts[2]);
				final double L2 = Double.parseDouble(parts[3]);
				final double a2 = Double.parseDouble(parts[4]);
				final double b2 = Double.parseDouble(parts[5]);
				final double deltaE = ciede_2000(L1, a1, b1, L2, a2, b2);
				System.out.printf("%s,%.17f%n", line, deltaE);
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
}
