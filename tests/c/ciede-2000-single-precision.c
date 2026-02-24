// This function written in C is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

#include <math.h>

// Expressly defining pi ensures that the code works on different platforms.
#ifndef M_PI
#define M_PI 3.14159265358979323846264338328
#endif

///////////////////////////////////////////////////////////////////////////////////////////
//////                                                                               //////
//////                   Measured at 30,395,327 calls per second.                    //////
//////               💡 This function is up to 60% faster than 64-bit.               //////
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
	float n = (sqrtf(a_1 * a_1 + b_1 * b_1) + sqrtf(a_2 * a_2 + b_2 * b_2)) * 0.5f;
	n = n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = 1.0f + 0.5f * (1.0f - sqrtf(n / (n + 6103515625.0f)));
	// Application of the chroma correction factor.
	const float c_1 = sqrtf(a_1 * a_1 * n * n + b_1 * b_1);
	const float c_2 = sqrtf(a_2 * a_2 * n * n + b_2 * b_2);
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	float h_1 = atan2f(b_1, a_1 * n);
	float h_2 = atan2f(b_2, a_2 * n);
	h_1 += (h_1 < 0.0f) * 2.0f * (float)M_PI;
	h_2 += (h_2 < 0.0f) * 2.0f * (float)M_PI;
	// 32-bit implementations do not have consistent rounding between implementations.
	n = fabsf(h_2 - h_1);
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	float h_m = (h_1 + h_2) * 0.5f;
	float h_d = (h_2 - h_1) * 0.5f;
	h_d += ((float)M_PI < n) * (float)M_PI;
	// 📜 Sharma’s formulation doesn’t use the next line, but the one after it,
	// and these two variants differ by ±0.0003 on the final color differences.
	h_m += ((float)M_PI < n) * (float)M_PI;
	// h_m += ((float)M_PI < n) * ((h_m < (float)M_PI) - ((float)M_PI <= h_m)) * (float)M_PI;
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
	// Returning the square root ensures that dE00 accurately reflects the
	// geometric distance in color space, which can range from 0 to around 185.
	return sqrtf(l * l + h * h + c * c + c * h * r_t);
}

// Compilation is done using GCC or CLang :
// - gcc -std=c99 -Wall -Wextra -pedantic -Ofast -o ciede-2000-compiled ciede-2000.c -lm
// - clang -std=c99 -Wall -Wextra -pedantic -Ofast -o ciede-2000-compiled ciede-2000.c -lm

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//   Online Tests : https://michel-leonard.github.io/ciede2000-color-matching

// L1 = 22.0   a1 = 49.9   b1 = 3.4
// L2 = 20.1   a2 = 44.3   b2 = -2.5
// CIE ΔE00 = 3.7701664560 (Bruce Lindbloom, Netflix’s VMAF, ...)
// CIE ΔE00 = 3.7701796395 (Gaurav Sharma, OpenJDK, ...)
// Deviation between implementations ≈ 1.3e-5

// See the source code comments for easy switching between these two widely used ΔE*00 implementation variants.
