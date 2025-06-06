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
		// Since hypot is not available, sqrt is used here to calculate the
		// Euclidean distance, without avoiding overflow/underflow.
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
			if (0.0 < h_d)
				h_d -= M_PI;
			else
				h_d += M_PI;
			h_m += M_PI;
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
		// Returns the square root so that the Delta E 2000 reflects the actual geometric
		// distance within the color space, which ranges from 0 to approximately 185.
		return Math.sqrt(l * l + h * h + c * c + c * h * r_t);
	}

}

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

// L1 = 89.0           a1 = -31.3309       b1 = 79.22
// L2 = 89.0           a2 = -31.2755       b2 = 79.22
// CIE ΔE2000 = ΔE00 = 0.02408210379

// L1 = 97.49          a1 = -46.101        b1 = -52.4115
// L2 = 97.49          a2 = -47.2          b2 = -55.57
// CIE ΔE2000 = ΔE00 = 0.85746388299

// L1 = 29.05          a1 = 94.2217        b1 = -29.0
// L2 = 31.192         a2 = 94.2217        b2 = -29.0
// CIE ΔE2000 = ΔE00 = 1.65928921045

// L1 = 17.7           a1 = -71.0          b1 = -30.0
// L2 = 23.2           a2 = -71.0          b2 = -30.0
// CIE ΔE2000 = ΔE00 = 3.82406671893

// L1 = 7.8001         a1 = 19.6           b1 = -66.8881
// L2 = 0.0            a2 = 25.5           b2 = -81.0
// CIE ΔE2000 = ΔE00 = 5.35188576635

// L1 = 45.38          a1 = -104.0         b1 = 17.1871
// L2 = 50.25          a2 = -87.0          b2 = -9.966
// CIE ΔE2000 = ΔE00 = 12.38918494935

// L1 = 68.4           a1 = -105.945       b1 = 17.96
// L2 = 65.82          a2 = -75.3708       b2 = -14.1707
// CIE ΔE2000 = ΔE00 = 15.02378179698

// L1 = 48.87          a1 = 29.3           b1 = 47.63
// L2 = 39.3488        a2 = 15.0           b2 = 63.141
// CIE ΔE2000 = ΔE00 = 15.47266978598

// L1 = 37.843         a1 = -7.401         b1 = -64.8
// L2 = 28.19          a2 = -40.0          b2 = -120.0
// CIE ΔE2000 = ΔE00 = 18.50848820866

// L1 = 24.658         a1 = -102.5833      b1 = 79.9
// L2 = 8.58           a2 = -58.4          b2 = 12.0
// CIE ΔE2000 = ΔE00 = 22.06629705049

///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
/////////////////                         /////////////////////
/////////////////         TESTING         /////////////////////
/////////////////                         /////////////////////
///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////

// The output is intended to be checked by the Large-Scale validator
// at https://michel-leonard.github.io/ciede2000-color-matching

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
