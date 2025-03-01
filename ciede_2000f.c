#include <math.h>

#define M_PIF   3.14159265358979323846f
#define M_PI_2F 1.57079632679489661923f

float ciede_2000f(float l_1, float a_1, float b_1, float l_2, float a_2, float b_2) {
	// Working with the CIEDE2000 color-difference formula.
	// k_l, k_c, k_h are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	const float k_l = 1.0f, k_c = 1.0f, k_h = 1.0f;
	float n = (hypotf(a_1, b_1) + hypotf(a_2, b_2)) * 0.5f;
	n = n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = 1.0f + 0.5f * (1.0f - sqrtf(n / (n + 6103515625.0f)));
	// hypot calculates the Euclidean distance while avoiding overflow/underflow.
	const float c_1 = hypotf(a_1 * n, b_1), c_2 = hypotf(a_2 * n, b_2);
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	float h_1 = atan2f(b_1, a_1 * n), h_2 = atan2f(b_2, a_2 * n);
	h_1 += 2.0f * M_PIF * (h_1 < 0.0f);
	h_2 += 2.0f * M_PIF * (h_2 < 0.0f);
	n = fabsf(h_2 - h_1);
	// Cross-implementation consistent rounding.
	if (M_PIF - 1E-14f < n && n < M_PIF + 1E-14f)
		n = M_PIF;
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	float h_m = 0.5f * h_1 + 0.5f * h_2, h_d = (h_2 - h_1) * 0.5f;
	if (M_PIF < n) {
		if (0.0f < h_d)
			h_d -= M_PIF;
		else
			h_d += M_PIF;
		h_m += M_PIF;
	}
	const float p = (36.0f * h_m - 55.0f * M_PIF);
	n = (c_1 + c_2) * 0.5f;
	n = n * n * n * n * n * n * n;
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	const float r_t = -2.0f * sqrtf(n / (n + 6103515625.0f))
				* sinf(M_PIF / 3.0f * expf(p * p / (-25.0f * M_PIF * M_PIF)));
	n = (l_1 + l_2) * 0.5f;
	n = (n - 50.0f) * (n - 50.0f);
	// Lightness.
	const float l = (l_2 - l_1) / (k_l * (1.0f + 0.015f * n / sqrtf(20.0f + n)));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	const float t = 1.0f 	+ 0.24f * sinf(2.0f * h_m + M_PI_2F)
				+ 0.32f * sinf(3.0f * h_m + 8.0f * M_PIF / 15.0f)
				- 0.17f * sinf(h_m +  M_PIF / 3.0f)
				- 0.20f * sinf(4.0f * h_m + 3.0f * M_PI_2F / 10.0f);
	n = c_1 + c_2;
	// Hue.
	const float h = 2.0f * sqrtf(c_1 * c_2) * sinf(h_d) / (k_h * (1.0f + 0.0075f * n * t));
	// Chroma.
	const float c = (c_2 - c_1) / (k_c * (1.0f + 0.0225f * n));
	// Returning the square root ensures that the result represents
	// the "true" geometric distance in the color space.
	return sqrtf(l * l + h * h + c * c + c * h * r_t);
}