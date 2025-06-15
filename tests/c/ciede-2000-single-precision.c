// This function written in C is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

#include <math.h>

// Expressly defining pi ensures that the code works on different platforms.
#ifndef M_PI
#define M_PI 3.14159265358979323846264338328
#endif

///////////////////////////////////////////////////////////////////////////////////////////
//////                                                                               //////
//////          Using 32-bit numbers results in an almost always negligible          //////
//////             difference of ±0.0002 in the calculated Delta E 2000.             //////
//////                                                                               //////
///////////////////////////////////////////////////////////////////////////////////////////

// The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
// "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
static float ciede_2000(const float l_1, const float a_1, const float b_1, const float l_2, const float a_2, const float b_2) {
	// Working in C with the CIEDE2000 color-difference formula.
	// k_l, k_c, k_h are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	const float k_l = 1.0f;
	const float k_c = 1.0f;
	const float k_h = 1.0f;
	float n = (hypotf(a_1, b_1) + hypotf(a_2, b_2)) * 0.5f;
	n = n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = 1.0f + 0.5f * (1.0f - sqrtf(n / (n + 6103515625.0f)));
	// hypot calculates the Euclidean distance while avoiding overflow/underflow.
	const float c_1 = hypotf(a_1 * n, b_1);
	const float c_2 = hypotf(a_2 * n, b_2);
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	float h_1 = atan2f(b_1, a_1 * n);
	float h_2 = atan2f(b_2, a_2 * n);
	if (h_1 < 0.0f)
		h_1 += 2.0f * (float)M_PI;
	if (h_2 < 0.0f)
		h_2 += 2.0f * (float)M_PI;
	// 32-bit implementations do not have consistent rounding between implementations.
	n = fabsf(h_2 - h_1);
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	float h_m = (h_1 + h_2) * 0.5f;
	float h_d = (h_2 - h_1) * 0.5f;
	if ((float)M_PI < n) {
		if (0.0f < h_d)
			h_d -= (float)M_PI;
		else
			h_d += (float)M_PI;
		h_m += (float)M_PI;
	}
	const float p = 36.0f * h_m - 55.0f * (float)M_PI;
	n = (c_1 + c_2) * 0.5f;
	n = n * n * n * n * n * n * n;
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	const float r_t = -2.0f * sqrtf(n / (n + 6103515625.0f)) * sinf((float)M_PI / 3.0f
					* expf(p * p / (-25.0f * (float)M_PI * (float)M_PI)));
	n = (l_1 + l_2) * 0.5f;
	n = (n - 50.0f) * (n - 50.0f);
	// Lightness.
	const float l = (l_2 - l_1) / (k_l * (1.0f + 0.015f * n / sqrtf(20.0f + n)));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	const float t = 1.0f	+ 0.24f * sinf(2.0f * h_m + (float)M_PI / 2.0f)
				+ 0.32f * sinf(3.0f * h_m + 8.0f * (float)M_PI / 15.0f)
				- 0.17f * sinf(h_m + (float)M_PI / 3.0f)
				- 0.20f * sinf(4.0f * h_m + 3.0f * (float)M_PI / 20.0f);
	n = c_1 + c_2;
	// Hue.
	const float h = 2.0f * sqrtf(c_1 * c_2) * sinf(h_d) / (k_h * (1.0f + 0.0075f * n * t));
	// Chroma.
	const float c = (c_2 - c_1) / (k_c * (1.0f + 0.0225f * n));
	// Returns the square root so that the Delta E 2000 reflects the actual geometric
	// distance within the color space, which ranges from 0 to approximately 185.
	return sqrtf(l * l + h * h + c * c + c * h * r_t);
}

// Compilation is done using GCC or CLang :
// - gcc -std=c99 -Wall -Wextra -pedantic -Ofast -o ciede-2000-compiled ciede-2000.c -lm
// - clang -std=c99 -Wall -Wextra -pedantic -Ofast -o ciede-2000-compiled ciede-2000.c -lm

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

// L1 = 41.904         a1 = 118.0          b1 = 22.3033
// L2 = 41.904         a2 = 117.9          b2 = 22.3033
// CIE ΔE2000 = ΔE00 = 0.01652875083

// L1 = 13.6207        a1 = 124.0          b1 = -22.75
// L2 = 13.6207        a2 = 124.0          b2 = -22.14
// CIE ΔE2000 = ΔE00 = 0.16257757584

// L1 = 50.19          a1 = 71.0           b1 = 100.8176
// L2 = 50.19          a2 = 69.5203        b2 = 100.8176
// CIE ΔE2000 = ΔE00 = 0.57579678309

// L1 = 66.2877        a1 = -48.6376       b1 = 67.0
// L2 = 66.2877        a2 = -39.8          b2 = 67.0
// CIE ΔE2000 = ΔE00 = 3.25921506438

// L1 = 77.0           a1 = -56.8          b1 = -48.77
// L2 = 82.1378        a2 = -56.8          b2 = -54.41
// CIE ΔE2000 = ΔE00 = 3.9840481272

// L1 = 67.3           a1 = 3.0            b1 = -86.2
// L2 = 63.83          a2 = -10.6803       b2 = -65.7144
// CIE ΔE2000 = ΔE00 = 5.57396004382

// L1 = 6.1            a1 = 63.16          b1 = -102.168
// L2 = 10.6           a2 = 90.0           b2 = -115.0
// CIE ΔE2000 = ΔE00 = 7.52359758531

// L1 = 51.923         a1 = 52.0           b1 = 96.144
// L2 = 57.21          a2 = 79.0           b2 = 104.7
// CIE ΔE2000 = ΔE00 = 10.43707565507

// L1 = 49.693         a1 = 121.0          b1 = -50.4
// L2 = 63.2003        a2 = 91.661         b2 = -73.0
// CIE ΔE2000 = ΔE00 = 16.32284000566

// L1 = 32.56          a1 = -87.13         b1 = -97.0
// L2 = 6.0            a2 = 31.68          b2 = -118.849
// CIE ΔE2000 = ΔE00 = 42.0860739668
