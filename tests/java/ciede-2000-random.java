// This function written in Java is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

public class Main {

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

	// L1 = 69.4   a1 = 52.1   b1 = -1.9
	// L2 = 69.2   a2 = 45.9   b2 = 1.7
	// CIE ΔE00 = 2.6629650295 (Bruce Lindbloom, Netflix’s VMAF, ...)
	// CIE ΔE00 = 2.6629519135 (Gaurav Sharma, OpenJDK, ...)
	// Deviation between implementations ≈ 1.3e-5

	// See the source code comments for easy switching between these two widely used ΔE*00 implementation variants.

	///////////////////////////////////////////////
	///////////////////////////////////////////////
	///////                                 ///////
	///////           CIEDE 2000            ///////
	///////      Testing Random Colors      ///////
	///////                                 ///////
	///////////////////////////////////////////////
	///////////////////////////////////////////////

	// This Java program outputs a CSV file to standard output, with its length determined by the first CLI argument.
	// Each line contains seven columns :
	// - Three columns for the random standard L*a*b* color
	// - Three columns for the random sample L*a*b* color
	// - And the seventh column for the precise Delta E 2000 color difference between the standard and sample
	// The output will be correct, this can be verified :
	// - With the C driver, which provides a dedicated verification feature
	// - By using the JavaScript validator at https://michel-leonard.github.io/ciede2000-color-matching

	public static void main(String[] args) {
		int n_iterations = 10000;
		if (0 < args.length)
			try {
				final int i = Integer.parseInt(args[0], 10);
				if (0 < i)
					n_iterations = i;
			} catch (NumberFormatException ignored) { }
		for (int i = 0; i < n_iterations; ++i) {
			final double l_1 = Math.round(Math.random() * 10000.0) / 100.0;
			final double a_1 = Math.round(Math.random() * 25600.0) / 100.0 - 128.0;
			final double b_1 = Math.round(Math.random() * 25600.0) / 100.0 - 128.0;
			final double l_2 = Math.round(Math.random() * 10000.0) / 100.0;
			final double a_2 = Math.round(Math.random() * 25600.0) / 100.0 - 128.0;
			final double b_2 = Math.round(Math.random() * 25600.0) / 100.0 - 128.0;
			final double delta_e = ciede_2000(l_1, a_1, b_1, l_2, a_2, b_2);
			System.out.printf("%g,%g,%g,%g,%g,%g,%.17g\n", l_1, a_1, b_1, l_2, a_2, b_2, delta_e);
		}
	}
	// javac 22 was used to compile this java source.
}
