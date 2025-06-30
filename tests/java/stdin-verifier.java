// This function written in Java is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.IOException;

import static java.lang.Math.PI;
import static java.lang.Math.sqrt;
import static java.lang.Math.hypot;
import static java.lang.Math.atan2;
import static java.lang.Math.abs;
import static java.lang.Math.sin;
import static java.lang.Math.exp;

class Verifier {

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
		final double t = 1.0	+ 0.24 * sin(2.0 * h_m + PI * 0.5)
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

	// L1 = 16.23          a1 = -9.4           b1 = 47.465
	// L2 = 17.85          a2 = -20.0          b2 = 56.0
	// CIE ΔE2000 = ΔE00 = 5.8839059333

	//////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////
	///////////////////////                        ///////////////////////////
	///////////////////////        TESTING         ///////////////////////////
	///////////////////////                        ///////////////////////////
	//////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////

	// The verification is performed here in Java.
	// It reads the CSV data from STDIN and prints a completion message.

	public static void main(String[] args) throws IOException {
		final double tolerance = args.length > 0 && "--32-bit".equals(args[0]) ? 1E-2 : 1E-10;
		BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
		String line;
		long display = 10, success = 0, error = 0, start = System.nanoTime();
		double l1, a1, b1, l2, a2, b2, delta_e, maxDiff = 0.0;
		String lastLine = "N/A";

		while ((line = reader.readLine()) != null) {
			if (line.trim().isEmpty()) continue;
			String[] parts = line.trim().split(",");
			if (parts.length != 7)
				continue;
			try {
				l1 = Double.parseDouble(parts[0]);
				a1 = Double.parseDouble(parts[1]);
				b1 = Double.parseDouble(parts[2]);
				l2 = Double.parseDouble(parts[3]);
				a2 = Double.parseDouble(parts[4]);
				b2 = Double.parseDouble(parts[5]);
				delta_e = Double.parseDouble(parts[6]);
			} catch (NumberFormatException e) {
				continue;
			}
			if (!Double.isFinite(l1) || !Double.isFinite(a1) || !Double.isFinite(b1) || !Double.isFinite(l2) || !Double.isFinite(a2) || !Double.isFinite(b2) || !Double.isFinite(delta_e))
				continue;
			final double expected_delta_e = ciede_2000(l1, a1, b1, l2, a2, b2);
			lastLine = line;
			double diff = Math.abs(expected_delta_e - delta_e);

			if (diff > tolerance) {
				if (--display > 0)
					System.out.printf("Error: ciede_2000(%s, %s, %s, %s, %s, %s) !== %.17f ... got %s%n", parts[0], parts[1], parts[2], parts[3], parts[4], parts[5], expected_delta_e, parts[6]);
				++error;
			} else
				++success;
			if (diff > maxDiff)
				maxDiff = diff;
		}

		final double durationSeconds = (System.nanoTime() - start) / 1e9;

		System.out.println("CIEDE2000 Verification Summary :");
		System.out.println("- Last Verified Line :  " + lastLine);
		System.out.printf("- Duration : %.2f s%n", durationSeconds);
		System.out.println("- Successes : " + success);
		System.out.println("- Errors : " + error);
		System.out.println("- Maximum Difference : " + maxDiff);
	}

}
