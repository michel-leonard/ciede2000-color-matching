using System;

public class CIE {

	// This function written in C# is not affiliated with the CIE (International Commission on Illumination),
	// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

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
		// Application of the chroma correction factor.
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
			h_d += Math.PI;
			// 📜 Sharma’s formulation doesn’t use the next line, but the one after it,
			// and these two variants differ by ±0.0003 on the final color differences.
			h_m += Math.PI;
			// if (h_m < Math.PI) h_m += Math.PI; else h_m -= Math.PI;
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
		// Returning the square root ensures that dE00 accurately reflects the
		// geometric distance in color space, which can range from 0 to around 185.
		return Math.Sqrt(l * l + h * h + c * c + c * h * r_t);
	}

	// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
	//   Online Tests : https://michel-leonard.github.io/ciede2000-color-matching

	// L1 = 20.0   a1 = 11.8   b1 = 3.5
	// L2 = 18.4   a2 = 17.0   b2 = -4.7
	// CIE ΔE00 = 7.0120052868 (Bruce Lindbloom, Netflix’s VMAF, ...)
	// CIE ΔE00 = 7.0119920316 (Gaurav Sharma, OpenJDK, ...)
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

	// This C# (.NET Core) program outputs a CSV file to standard output, with its length determined by the first CLI argument.
	// Each line contains seven columns :
	// - Three columns for the random standard L*a*b* color
	// - Three columns for the random sample L*a*b* color
	// - And the seventh column for the precise Delta E 2000 color difference between the standard and sample
	// The output will be correct, this can be verified :
	// - With the C driver, which provides a dedicated verification feature
	// - By using the JavaScript validator at https://michel-leonard.github.io/ciede2000-color-matching

	static Random random = new Random();

	static double RandomDouble(double min, double max) {
		return Math.Round(min + (max - min) * random.NextDouble(), random.Next(0, 3));
	}

	public static void Test(int count) {
		for (int i = 0; i < count; ++i) {
			double l1 = RandomDouble(0.0, 100.0);
			double a1 = RandomDouble(-128.0, 128.0);
			double b1 = RandomDouble(-128.0, 128.0);
			double l2 = RandomDouble(0.0, 100.0);
			double a2 = RandomDouble(-128.0, 128.0);
			double b2 = RandomDouble(-128.0, 128.0);
			double deltaE = ciede_2000(l1, a1, b1, l2, a2, b2);
			Console.WriteLine($"{l1},{a1},{b1},{l2},{a2},{b2},{deltaE}");
		}
	}

}

int count = Convert.ToInt32(Args.Count == 0 ? "10000" : Args[0]);
CIE.Test(count);
