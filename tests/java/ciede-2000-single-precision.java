// This function written in Java is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

import static java.lang.Math.PI;
import static java.lang.Math.sqrt;
import static java.lang.Math.hypot;
import static java.lang.Math.atan2;
import static java.lang.Math.abs;
import static java.lang.Math.sin;
import static java.lang.Math.exp;

///////////////////////////////////////////////////////////////////////////////////////////
//////                                                                               //////
//////          Using 32-bit numbers results in an almost always negligible          //////
//////             difference of ±0.002 in the calculated Delta E 2000.              //////
//////                                                                               //////
///////////////////////////////////////////////////////////////////////////////////////////

// The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
// "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
static float ciede_2000(final float l_1, final float a_1, final float b_1, final float l_2, final float a_2, final float b_2) {
	// Working in Java with the CIEDE2000 color-difference formula.
	// k_l, k_c, k_h are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	final float k_l = 1.0f, k_c = 1.0f, k_h = 1.0f;
	float n = (float)(hypot(a_1, b_1) + hypot(a_2, b_2)) * 0.5f;
	n = n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = 1.0f + 0.5f * (1.0f - (float)sqrt(n / (n + 6103515625.0f)));
	// hypot calculates the Euclidean distance while avoiding overflow/underflow.
	final float c_1 = (float)hypot(a_1 * n, b_1), c_2 = (float)hypot(a_2 * n, b_2);
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	float h_1 = (float)atan2(b_1, a_1 * n), h_2 = (float)atan2(b_2, a_2 * n);
	h_1 += 2.0f * (float)PI * Boolean.compare(h_1 < 0.0f, false);
	h_2 += 2.0f * (float)PI * Boolean.compare(h_2 < 0.0f, false);
	// 32-bit implementations do not have consistent rounding between implementations.
	n = (float)abs(h_2 - h_1);
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	float h_m = (h_1 + h_2) * 0.5f, h_d = (h_2 - h_1) * 0.5f;
	if ((float)PI < n) {
		if (0.0f < h_d)
			h_d -= (float)PI;
		else
			h_d += (float)PI;
		h_m += (float)PI;
	}
	final float p = 36.0f * h_m - 55.0f * (float)PI;
	n = (c_1 + c_2) * 0.5f;
	n = n * n * n * n * n * n * n;
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	final float r_t = -2.0f * (float)sqrt(n / (n + 6103515625.0f))
			* (float)sin((float)PI / 3.0f * (float)exp(p * p / (-25.0f * (float)PI * (float)PI)));
	n = (l_1 + l_2) * 0.5f;
	n = (n - 50.0f) * (n - 50.0f);
	// Lightness.
	final float l = (l_2 - l_1) / (k_l * (1.0f + 0.015f * n / (float)sqrt(20.0f + n)));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	final float t = 1.0f
			+ 0.24f * (float)sin(2.0f * h_m + (float)PI * 0.5f)
			+ 0.32f * (float)sin(3.0f * h_m + 8.0f * (float)PI / 15.0f)
			- 0.17f * (float)sin(h_m + (float)PI / 3.0f)
			- 0.20f * (float)sin(4.0f * h_m + 3.0f * (float)PI / 20.0f);
	n = c_1 + c_2;
	// Hue.
	final float h = 2.0f * (float)sqrt(c_1 * c_2) * (float)sin(h_d) / (k_h * (1.0f + 0.0075f * n * t));
	// Chroma.
	final float c = (c_2 - c_1) / (k_c * (1.0f + 0.0225f * n));
	// Returns the square root so that the DeltaE 2000 reflects the actual geometric
	// distance within the color space, which ranges from 0 to approximately 185.
	return (float)sqrt(l * l + h * h + c * c + c * h * r_t);
}

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

// L1 = 58.27          a1 = -124.72        b1 = -82.095
// L2 = 64.077         a2 = -28.5          b2 = -108.224
// CIE ΔE2000 = ΔE00 = 24.20714524206
