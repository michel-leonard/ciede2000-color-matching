// This function written in Kotlin is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

import kotlin.math.*

///////////////////////////////////////////////////////////////////////////////////////////
//////                                                                               //////
//////          Using 32-bit numbers results in an almost always negligible          //////
//////            difference of ±0.0002 in the calculated Delta E 2000.              //////
//////                                                                               //////
///////////////////////////////////////////////////////////////////////////////////////////

// The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
// "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
fun ciede_2000(l_1: Float, a_1: Float, b_1: Float, l_2: Float, a_2: Float, b_2: Float): Float {
	// Working in Kotlin with the CIEDE2000 color-difference formula.
	// k_l, k_c, k_h are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	val k_l = 1.0f
	val k_c = 1.0f
	val k_h = 1.0f
	var n = (hypot(a_1, b_1) + hypot(a_2, b_2)) * 0.5f
	n = n * n * n * n * n * n * n
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = 1.0f + 0.5f * (1.0f - sqrt(n / (n + 6103515625.0f)))
	// hypot calculates the Euclidean distance while avoiding overflow/underflow.
	val c_1 = hypot(a_1 * n, b_1)
	val c_2 = hypot(a_2 * n, b_2)
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	var h_1 = atan2(b_1, a_1 * n)
	var h_2 = atan2(b_2, a_2 * n)
	if (h_1 < 0.0f)
		h_1 += 2.0f * PI.toFloat()
	if (h_2 < 0.0f)
		h_2 += 2.0f * PI.toFloat()
	n = abs(h_2 - h_1)
	// Cross-implementation consistent rounding.
	if (PI.toFloat() - 1E-6f < n && n < PI.toFloat() + 1E-6f)
		n = PI.toFloat()
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	var h_m = (h_1 + h_2) * 0.5f
	var h_d = (h_2 - h_1) * 0.5f
	if (PI.toFloat() < n) {
		if (0.0f < h_d)
			h_d -= PI.toFloat()
		else
			h_d += PI.toFloat()
		h_m += PI.toFloat()
	}
	val p = 36.0f * h_m - 55.0f * PI.toFloat()
	n = (c_1 + c_2) * 0.5f
	n = n * n * n * n * n * n * n
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	val r_t = -2.0f * sqrt(n / (n + 6103515625.0f)) * sin(PI.toFloat() /
			3.0f * exp((p * p) / (-25.0f * PI.toFloat() * PI.toFloat())))
	n = (l_1 + l_2) * 0.5f
	n = (n - 50.0f) * (n - 50.0f)
	// Lightness.
	val l = (l_2 - l_1) / (k_l * (1.0f + 0.015f * n / sqrt(20.0f + n)))
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	val t = 1.0f + 0.24f * sin(2.0f * h_m + PI.toFloat() * 0.5f) +
			0.32f * sin(3.0f * h_m + 8.0f * PI.toFloat() / 15.0f) -
			0.17f * sin(h_m + PI.toFloat() / 3.0f) -
			0.20f * sin(4.0f * h_m + 3.0f * PI.toFloat() / 20.0f)
	n = c_1 + c_2
	// Hue.
	val h = 2.0f * sqrt(c_1 * c_2) * sin(h_d) / (k_h * (1.0f + 0.0075f * n * t))
	// Chroma.
	val c = (c_2 - c_1) / (k_c * (1.0f + 0.0225f * n))
	// Returns the square root so that the DeltaE 2000 reflects the actual geometric
	// distance within the color space, which ranges from 0 to approximately 185.
	return sqrt(l * l + h * h + c * c + c * h * r_t)
}

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

// L1 = 83.91          a1 = -57.617        b1 = -108.116
// L2 = 77.2362        a2 = -50.0          b2 = -109.0
// CIE ΔE2000 = ΔE00 = 5.03265145101
