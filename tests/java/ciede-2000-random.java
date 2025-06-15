// This function written in Java is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

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

	// L1 = 77.645         a1 = 127.712        b1 = 116.2
	// L2 = 77.645         a2 = 127.712        b2 = 116.19
	// CIE ΔE2000 = ΔE00 = 0.0027521213

	// L1 = 51.01          a1 = -100.167       b1 = -27.08
	// L2 = 51.01          a2 = -100.0         b2 = -27.08
	// CIE ΔE2000 = ΔE00 = 0.03333286203

	// L1 = 75.6875        a1 = -11.4873       b1 = -90.1
	// L2 = 75.6875        a2 = -11.4873       b2 = -89.6178
	// CIE ΔE2000 = ΔE00 = 0.07697101975

	// L1 = 76.9           a1 = -106.5         b1 = -11.5
	// L2 = 76.9           a2 = -106.5         b2 = -9.962
	// CIE ΔE2000 = ΔE00 = 0.60925855311

	// L1 = 89.441         a1 = -117.1285      b1 = -18.218
	// L2 = 89.441         a2 = -107.369       b2 = -18.218
	// CIE ΔE2000 = ΔE00 = 1.68544899352

	// L1 = 56.0           a1 = -95.5          b1 = -12.74
	// L2 = 56.0           a2 = -104.0         b2 = -19.0
	// CIE ΔE2000 = ΔE00 = 2.61912967123

	// L1 = 78.445         a1 = -13.6546       b1 = -127.0
	// L2 = 78.445         a2 = -5.4           b2 = -119.5194
	// CIE ΔE2000 = ΔE00 = 3.98513802138

	// L1 = 70.0           a1 = -68.2          b1 = -126.3
	// L2 = 79.951         a2 = -71.7          b2 = -87.0
	// CIE ΔE2000 = ΔE00 = 10.29943955718

	// L1 = 51.4           a1 = -103.2         b1 = -13.1477
	// L2 = 55.37          a2 = -93.32         b2 = -51.0
	// CIE ΔE2000 = ΔE00 = 15.61468550097

	// L1 = 58.0           a1 = -46.542        b1 = 113.4
	// L2 = 79.877         a2 = -41.76         b2 = 109.0
	// CIE ΔE2000 = ΔE00 = 17.19611385157

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
