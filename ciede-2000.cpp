// This function written in C++ is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

#include <cmath>

// Expressly defining pi ensures that the code works on different platforms.
#ifndef M_PI
#define M_PI 3.14159265358979323846264338328
#endif

// The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
// "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
template <typename T>
static T ciede_2000(const T l_1, const T a_1, const T b_1, const T l_2, const T a_2, const T b_2) {
	// Working in C++ with the CIEDE2000 color-difference formula.
	// k_l, k_c, k_h are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	const T k_l = T(1.0);
	const T k_c = T(1.0);
	const T k_h = T(1.0);
	T n = (std::hypot(a_1, b_1) + std::hypot(a_2, b_2)) * T(0.5);
	n = n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = T(1.0) + T(0.5) * (T(1.0) - std::sqrt(n / (n + T(6103515625.0))));
	// hypot calculates the Euclidean distance while avoiding overflow/underflow.
	const T c_1 = std::hypot(a_1 * n, b_1);
	const T c_2 = std::hypot(a_2 * n, b_2);
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	T h_1 = std::atan2(b_1, a_1 * n);
	T h_2 = std::atan2(b_2, a_2 * n);
	if (h_1 < T(0.0))
		h_1 += T(2.0) * T(M_PI);
	if (h_2 < T(0.0))
		h_2 += T(2.0) * T(M_PI);
	n = std::fabs(h_2 - h_1);
	// Cross-implementation consistent rounding.
	if (T(M_PI) - T(1E-14) < n && n < T(M_PI) + T(1E-14))
		n = T(M_PI);
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	T h_m = (h_1 + h_2) * T(0.5);
	T h_d = (h_2 - h_1) * T(0.5);
	if (T(M_PI) < n) {
		if (T(0.0) < h_d)
			h_d -= T(M_PI);
		else
			h_d += T(M_PI);
		h_m += T(M_PI);
	}
	const T p = T(36.0) * h_m - T(55.0) * T(M_PI);
	n = (c_1 + c_2) * T(0.5);
	n = n * n * n * n * n * n * n;
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	const T r_t = T(-2.0) * std::sqrt(n / (n + T(6103515625.0)))
			* std::sin(T(M_PI) / T(3.0) * std::exp(p * p / (T(-25.0) * T(M_PI) * T(M_PI))));
	n = (l_1 + l_2) * T(0.5);
	n = (n - T(50.0)) * (n - T(50.0));
	// Lightness.
	const T l = (l_2 - l_1) / (k_l * (T(1.0) + T(0.015) * n / std::sqrt(T(20.0) + n)));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	const T t = T(1.0)  + T(0.24) * std::sin(T(2.0) * h_m + T(M_PI) / T(2.0))
                      + T(0.32) * std::sin(T(3.0) * h_m + T(8.0) * T(M_PI) / T(15.0))
                      - T(0.17) * std::sin(h_m + T(M_PI) / T(3.0))
                      - T(0.20) * std::sin(T(4.0) * h_m + T(3.0) * T(M_PI) / T(20.0));
	n = c_1 + c_2;
	// Hue.
	const T h = T(2.0) * std::sqrt(c_1 * c_2) * std::sin(h_d) / (k_h * (T(1.0) + T(0.0075) * n * t));
	// Chroma.
	const T c = (c_2 - c_1) / (k_c * (T(1.0) + T(0.0225) * n));
	// Returning the square root ensures that the result reflects the actual geometric
	// distance within the color space, which ranges from 0 to approximately 185.
	return std::sqrt(l * l + h * h + c * c + c * h * r_t);
}

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

// L1 = 42.03          a1 = -124.8         b1 = 114.42
// L2 = 42.03          a2 = -124.8447      b2 = 114.42
// CIE ΔE2000 = ΔE00 = 0.00778590254

// L1 = 32.5           a1 = 124.4          b1 = -24.3
// L2 = 32.5           a2 = 124.4          b2 = -24.0
// CIE ΔE2000 = ΔE00 = 0.07935368405

// L1 = 47.4997        a1 = -117.4393      b1 = 47.968
// L2 = 48.65          a2 = -109.5974      b2 = 47.968
// CIE ΔE2000 = ΔE00 = 1.82001597624

// L1 = 0.33           a1 = 71.7416        b1 = 61.8319
// L2 = 7.1            a2 = 71.7416        b2 = 61.8319
// CIE ΔE2000 = ΔE00 = 4.00341389952

// L1 = 57.0           a1 = -39.118        b1 = -80.9221
// L2 = 59.0           a2 = -28.7015       b2 = -95.2
// CIE ΔE2000 = ΔE00 = 5.02728220577

// L1 = 15.7           a1 = 122.455        b1 = 52.8192
// L2 = 14.464         a2 = 124.564        b2 = 69.838
// CIE ΔE2000 = ΔE00 = 5.38573217055

// L1 = 27.006         a1 = -94.69         b1 = 89.5
// L2 = 37.86          a2 = -110.74        b2 = 115.3
// CIE ΔE2000 = ΔE00 = 9.66249436776

// L1 = 19.78          a1 = 57.0           b1 = -65.2
// L2 = 5.8234         a2 = 64.7084        b2 = -89.4
// CIE ΔE2000 = ΔE00 = 11.29579388797

// L1 = 10.4462        a1 = 118.442        b1 = 98.7
// L2 = 0.055          a2 = 115.387        b2 = 39.0
// CIE ΔE2000 = ΔE00 = 20.1904608524

// L1 = 92.0           a1 = -71.4          b1 = 59.7704
// L2 = 34.3           a2 = -89.5          b2 = -78.14
// CIE ΔE2000 = ΔE00 = 72.56575629926

