// This function written in Haxe is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

import Math;

class ColorUtils {

	// Expressly defining pi ensures that the code works on different platforms.
	public static inline var M_PI:Float = 3.14159265358979323846264338328;

	// The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
	// "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
	public static function ciede_2000(l_1:Float, a_1:Float, b_1:Float, l_2:Float, a_2:Float, b_2:Float):Float {
		// Working in Haxe with the CIEDE2000 color-difference formula.
		// k_l, k_c, k_h are parametric factors to be adjusted according to
		// different viewing parameters such as textures, backgrounds...
		var k_l = 1.0;
		var k_c = 1.0;
		var k_h = 1.0;
		var n = (Math.sqrt(a_1 * a_1 + b_1 * b_1) + Math.sqrt(a_2 * a_2 + b_2 * b_2)) * 0.5;
		n = n * n * n * n * n * n * n;
		// A factor involving chroma raised to the power of 7 designed to make
		// the influence of chroma on the total color difference more accurate.
		n = 1.0 + 0.5 * (1.0 - Math.sqrt(n / (n + 6103515625.0)));
		// Application of the chroma correction factor.
		var c_1 = Math.sqrt(a_1 * a_1 * n * n + b_1 * b_1);
		var c_2 = Math.sqrt(a_2 * a_2 * n * n + b_2 * b_2);
		// atan2 is preferred over atan because it accurately computes the angle of
		// a point (x, y) in all quadrants, handling the signs of both coordinates.
		var h_1 = Math.atan2(b_1, a_1 * n);
		var h_2 = Math.atan2(b_2, a_2 * n);
		if (h_1 < 0.0) h_1 += 2.0 * M_PI;
		if (h_2 < 0.0) h_2 += 2.0 * M_PI;
		n = Math.abs(h_2 - h_1);
		// Cross-implementation consistent rounding.
		if (M_PI - 1E-14 < n && n < M_PI + 1E-14) n = M_PI;
		// When the hue angles lie in different quadrants, the straightforward
		// average can produce a mean that incorrectly suggests a hue angle in
		// the wrong quadrant, the next lines handle this issue.
		var h_m = (h_1 + h_2) * 0.5;
		var h_d = (h_2 - h_1) * 0.5;
		if (M_PI < n) {
			h_d += M_PI;
			// 📜 Sharma’s formulation doesn’t use the next line, but the one after it,
			// and these two variants differ by ±0.0003 on the final color differences.
			h_m += M_PI;
			// h_m += h_m < M_PI ? M_PI : -M_PI;
		}
		var p = 36.0 * h_m - 55.0 * M_PI;
		n = (c_1 + c_2) * 0.5;
		n = n * n * n * n * n * n * n;
		// The hue rotation correction term is designed to account for the
		// non-linear behavior of hue differences in the blue region.
		var r_t = -2.0 * Math.sqrt(n / (n + 6103515625.0))
					* Math.sin(M_PI / 3.0 * Math.exp(p * p / (-25.0 * M_PI * M_PI)));
		n = (l_1 + l_2) * 0.5;
		n = (n - 50.0) * (n - 50.0);
		// Lightness.
		var l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / Math.sqrt(20.0 + n)));
		// These coefficients adjust the impact of different harmonic
		// components on the hue difference calculation.
		var t = 1.0	+ 0.24 * Math.sin(2.0 * h_m + M_PI / 2.0)
				+ 0.32 * Math.sin(3.0 * h_m + 8.0 * M_PI / 15.0)
				- 0.17 * Math.sin(h_m + M_PI / 3.0)
				- 0.20 * Math.sin(4.0 * h_m + 3.0 * M_PI / 20.0);
		n = c_1 + c_2;
		// Hue.
		var h = 2.0 * Math.sqrt(c_1 * c_2) * Math.sin(h_d) / (k_h * (1.0 + 0.0075 * n * t));
		// Chroma.
		var c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
		// Returning the square root ensures that dE00 accurately reflects the
		// geometric distance in color space, which can range from 0 to around 185.
		return Math.sqrt(l * l + h * h + c * c + c * h * r_t);
	}

}

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//   Online Tests : https://michel-leonard.github.io/ciede2000-color-matching

// L1 = 58.4   a1 = 37.4   b1 = 3.3
// L2 = 57.0   a2 = 43.3   b2 = -2.6
// CIE ΔE00 = 4.1119950621 (Bruce Lindbloom, Netflix’s VMAF, ...)
// CIE ΔE00 = 4.1119818383 (Gaurav Sharma, OpenJDK, ...)
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

// This Haxe program outputs a CSV file to standard output, with its length determined by the first CLI argument.
// Each line contains seven columns :
// - Three columns for the random standard L*a*b* color
// - Three columns for the random sample L*a*b* color
// - And the seventh column for the precise Delta E 2000 color difference between the standard and sample
// The output will be correct, this can be verified :
// - With the C driver, which provides a dedicated verification feature
// - By using the JavaScript validator at https://michel-leonard.github.io/ciede2000-color-matching

class Main {

	static function myRound(value:Float):Float {
		return Math.random() < 0.5 ? Math.round(value) : Math.round(value * 10) / 10;
	}

	static function main() {
		var args = Sys.args();
		var nIterations = 10000;

		if (args.length > 0) {
			try {
				var parsed = Std.parseInt(args[0]);
				if (parsed > 0)
					nIterations = parsed;
			} catch (e:Dynamic) {}
		}

		for (i in 0...nIterations) {
			var l1 = Math.random() * 100;
			var a1 = Math.random() * 256 - 128;
			var b1 = Math.random() * 256 - 128;
			var l2 = Math.random() * 100;
			var a2 = Math.random() * 256 - 128;
			var b2 = Math.random() * 256 - 128;

			l1 = myRound(l1);
			a1 = myRound(a1);
			b1 = myRound(b1);
			l2 = myRound(l2);
			a2 = myRound(a2);
			b2 = myRound(b2);

			var deltaE = ColorUtils.ciede_2000(l1, a1, b1, l2, a2, b2);
			Sys.println('$l1,$a1,$b1,$l2,$a2,$b2,$deltaE');
		}
	}
}
