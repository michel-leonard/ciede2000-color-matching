// This function written in Java is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.IOException;

class Verifier {

	// The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
	// "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
	static double ciede_2000(final double l_1, final double a_1, final double b_1, final double l_2, final double a_2, final double b_2) {
		// Working in Java with the CIEDE2000 color-difference formula.
		// k_l, k_c, k_h are parametric factors to be adjusted according to
		// different viewing parameters such as textures, backgrounds...
		final double k_l = 1.0, k_c = 1.0, k_h = 1.0;
		double n = (Math.sqrt(a_1 * a_1 + b_1 * b_1) + Math.sqrt(a_2 * a_2 + b_2 * b_2)) * 0.5;
		n = n * n * n * n * n * n * n;
		// A factor involving chroma raised to the power of 7 designed to make
		// the influence of chroma on the total color difference more accurate.
		n = 1.0 + 0.5 * (1.0 - Math.sqrt(n / (n + 6103515625.0)));
		// Application of the chroma correction factor.
		final double c_1 = Math.sqrt(a_1 * a_1 * n * n + b_1 * b_1);
		final double c_2 = Math.sqrt(a_2 * a_2 * n * n + b_2 * b_2);
		// atan2 is preferred over atan because it accurately computes the angle of
		// a point (x, y) in all quadrants, handling the signs of both coordinates.
		double h_1 = Math.atan2(b_1, a_1 * n), h_2 = Math.atan2(b_2, a_2 * n);
		h_1 += 2.0 * Math.PI * Boolean.compare(h_1 < 0.0, false);
		h_2 += 2.0 * Math.PI * Boolean.compare(h_2 < 0.0, false);
		n = Math.abs(h_2 - h_1);
		// Cross-implementation consistent rounding.
		if (Math.PI - 1E-14 < n && n < Math.PI + 1E-14)
			n = Math.PI;
		// When the hue angles lie in different quadrants, the straightforward
		// average can produce a mean that incorrectly suggests a hue angle in
		// the wrong quadrant, the next lines handle this issue.
		double h_m = (h_1 + h_2) * 0.5, h_d = (h_2 - h_1) * 0.5;
		if (Math.PI < n) {
			h_d += Math.PI;
			// 📜 Sharma’s formulation doesn’t use the next line, but the one after it,
			// and these two variants differ by ±0.0003 on the final color differences.
			h_m += Math.PI;
			// h_m += h_m < Math.PI ? Math.PI : -Math.PI;
		}
		final double p = 36.0 * h_m - 55.0 * Math.PI;
		n = (c_1 + c_2) * 0.5;
		n = n * n * n * n * n * n * n;
		// The hue rotation correction term is designed to account for the
		// non-linear behavior of hue differences in the blue region.
		final double r_t = -2.0 * Math.sqrt(n / (n + 6103515625.0))
				* Math.sin(Math.PI / 3.0 * Math.exp(p * p / (-25.0 * Math.PI * Math.PI)));
		n = (l_1 + l_2) * 0.5;
		n = (n - 50.0) * (n - 50.0);
		// Lightness.
		final double l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / Math.sqrt(20.0 + n)));
		// These coefficients adjust the impact of different harmonic
		// components on the hue difference calculation.
		final double t = 1.0 + 0.24 * Math.sin(2.0 * h_m + Math.PI * 0.5)
				+ 0.32 * Math.sin(3.0 * h_m + 8.0 * Math.PI / 15.0)
				- 0.17 * Math.sin(h_m + Math.PI / 3.0)
				- 0.20 * Math.sin(4.0 * h_m + 3.0 * Math.PI / 20.0);
		n = c_1 + c_2;
		// Hue.
		final double h = 2.0 * Math.sqrt(c_1 * c_2) * Math.sin(h_d) / (k_h * (1.0 + 0.0075 * n * t));
		// Chroma.
		final double c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
		// Returning the square root ensures that dE00 accurately reflects the
		// geometric distance in color space, which can range from 0 to around 185.
		return Math.sqrt(l * l + h * h + c * c + c * h * r_t);
	}

	// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
	//   Online Tests : https://michel-leonard.github.io/ciede2000-color-matching

	// L1 = 50.3   a1 = 12.0   b1 = 3.5
	// L2 = 52.6   a2 = 17.9   b2 = -5.2
	// CIE ΔE00 = 7.7217093369 (Bruce Lindbloom, Netflix’s VMAF, ...)
	// CIE ΔE00 = 7.7216925478 (Gaurav Sharma, OpenJDK, ...)
	// Deviation between implementations ≈ 1.7e-5

	// See the source code comments for easy switching between these two widely used ΔE*00 implementation variants.

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
