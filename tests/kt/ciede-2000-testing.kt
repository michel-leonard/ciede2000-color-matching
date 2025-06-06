// This function written in Kotlin is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

import kotlin.math.*
import kotlin.random.Random

// The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
// "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
fun ciede_2000(l_1: Double, a_1: Double, b_1: Double, l_2: Double, a_2: Double, b_2: Double): Double {
	// Working in Kotlin with the CIEDE2000 color-difference formula.
	// k_l, k_c, k_h are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	val k_l = 1.0;
	val k_c = 1.0;
	val k_h = 1.0;
	var n = (hypot(a_1, b_1) + hypot(a_2, b_2)) * 0.5;
	n = n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - sqrt(n / (n + 6103515625.0)));
	// hypot calculates the Euclidean distance while avoiding overflow/underflow.
	val c_1 = hypot(a_1 * n, b_1);
	val c_2 = hypot(a_2 * n, b_2);
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	var h_1 = atan2(b_1, a_1 * n);
	var h_2 = atan2(b_2, a_2 * n);
	if (h_1 < 0.0)
		h_1 += 2.0 * PI;
	if (h_2 < 0.0)
		h_2 += 2.0 * PI;
	n = abs(h_2 - h_1);
	// Cross-implementation consistent rounding.
	if (PI - 1E-14 < n && n < PI + 1E-14)
		n = PI;
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	var h_m = (h_1 + h_2) * 0.5;
	var h_d = (h_2 - h_1) * 0.5;
	if (PI < n) {
		if (0.0 < h_d)
			h_d -= PI;
		else
			h_d += PI;
		h_m += PI;
	}
	val p = 36.0 * h_m - 55.0 * PI;
	n = (c_1 + c_2) * 0.5;
	n = n * n * n * n * n * n * n;
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	val r_t = -2.0 * sqrt(n / (n + 6103515625.0)) * sin(PI / 3.0 * exp((p * p) / (-25.0 * PI * PI)));
	n = (l_1 + l_2) * 0.5;
	n = (n - 50.0) * (n - 50.0);
	// Lightness.
	val l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / sqrt(20.0 + n)));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	val t = 1.0 +	0.24 * sin(2.0 * h_m + PI * 0.5) +
			0.32 * sin(3.0 * h_m + 8.0 * PI / 15.0) -
			0.17 * sin(h_m + PI / 3.0) -
			0.20 * sin(4.0 * h_m + 3.0 * PI / 20.0);
	n = c_1 + c_2;
	// Hue.
	val h = 2.0 * sqrt(c_1 * c_2) * sin(h_d) / (k_h * (1.0 + 0.0075 * n * t));
	// Chroma.
	val c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
	// Returns the square root so that the Delta E 2000 reflects the actual geometric
	// distance within the color space, which ranges from 0 to approximately 185.
	return sqrt(l * l + h * h + c * c + c * h * r_t);
}

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

// L1 = 75.1873        a1 = -61.05         b1 = 24.3781
// L2 = 75.1873        a2 = -61.0518       b2 = 24.3781
// CIE ΔE2000 = ΔE00 = 0.0005145631

// L1 = 5.8868         a1 = 126.06         b1 = -97.7
// L2 = 8.3            a2 = 126.06         b2 = -99.7393
// CIE ΔE2000 = ΔE00 = 1.54866661477

// L1 = 11.921         a1 = 107.107        b1 = -96.0566
// L2 = 11.921         a2 = 107.107        b2 = -86.5
// CIE ΔE2000 = ΔE00 = 2.53949782342

// L1 = 51.652         a1 = 100.2          b1 = 67.281
// L2 = 54.0           a2 = 100.2          b2 = 58.5823
// CIE ΔE2000 = ΔE00 = 3.91195809452

// L1 = 4.7862         a1 = -2.7           b1 = -110.1
// L2 = 18.0           a2 = 10.78          b2 = -115.846
// CIE ΔE2000 = ΔE00 = 9.9789351357

// L1 = 96.2413        a1 = 97.6           b1 = -33.1259
// L2 = 83.9           a2 = 57.2           b2 = -19.0
// CIE ΔE2000 = ΔE00 = 11.98010487614

// L1 = 65.0           a1 = 125.143        b1 = 91.966
// L2 = 81.0           a2 = 81.07          b2 = 91.0
// CIE ΔE2000 = ΔE00 = 17.39340010982

// L1 = 4.7099         a1 = 60.375         b1 = 17.87
// L2 = 7.0            a2 = 22.321         b2 = -10.4086
// CIE ΔE2000 = ΔE00 = 19.55185314971

// L1 = 15.505         a1 = 33.0           b1 = -24.2
// L2 = 8.1            a2 = 116.5253       b2 = -98.0
// CIE ΔE2000 = ΔE00 = 21.51545882794

// L1 = 25.558         a1 = -117.9251      b1 = -127.0
// L2 = 45.0           a2 = -45.73         b2 = -56.274
// CIE ΔE2000 = ΔE00 = 22.39641274089

//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
///////////////////////                        ///////////////////////////
///////////////////////        TESTING         ///////////////////////////
///////////////////////                        ///////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////

// The output is intended to be checked by the Large-Scale validator
// at https://michel-leonard.github.io/ciede2000-color-matching

fun main(args: Array<String>) {
	var nIterations = 10000
	if (args.isNotEmpty()) {
		val i = args[0].toIntOrNull()
		if (i != null && i > 0) {
			nIterations = i
		}
	}

	repeat(nIterations) {
		val l1 = round(Random.nextDouble(0.0, 100.0) * 100) / 100.0
		val a1 = round(Random.nextDouble(-128.0, 128.0) * 100) / 100.0
		val b1 = round(Random.nextDouble(-128.0, 128.0) * 100) / 100.0
		val l2 = round(Random.nextDouble(0.0, 100.0) * 100) / 100.0
		val a2 = round(Random.nextDouble(-128.0, 128.0) * 100) / 100.0
		val b2 = round(Random.nextDouble(-128.0, 128.0) * 100) / 100.0

		val deltaE = ciede_2000(l1, a1, b1, l2, a2, b2)
		println(String.format("%g,%g,%g,%g,%g,%g,%.15g", l1, a1, b1, l2, a2, b2, deltaE))
	}
}
