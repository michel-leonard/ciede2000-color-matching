// This function written in C++ is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

#include <cmath>

// Expressly defining pi ensures that the code works on different platforms.
#ifndef M_PI
#define M_PI 3.14159265358979323846264338328
#endif

// The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
// "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
template<typename T>
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

// L1 = 31.4           a1 = 81.1           b1 = 110.7607
// L2 = 31.4015        a2 = 81.1           b2 = 110.7607
// CIE ΔE2000 = ΔE00 = 0.00117993398

// L1 = 46.8973        a1 = 124.8          b1 = 118.0
// L2 = 46.8973        a2 = 124.8          b2 = 118.739
// CIE ΔE2000 = ΔE00 = 0.20197117389

// L1 = 48.0           a1 = 96.556         b1 = -80.0
// L2 = 48.0           a2 = 92.96          b2 = -80.0
// CIE ΔE2000 = ΔE00 = 0.89919076712

// L1 = 95.34          a1 = -55.28         b1 = -60.0
// L2 = 95.34          a2 = -60.55         b2 = -60.0
// CIE ΔE2000 = ΔE00 = 1.53303039895

// L1 = 67.0           a1 = 47.836         b1 = -14.9958
// L2 = 68.1           a2 = 47.836         b2 = -11.8
// CIE ΔE2000 = ΔE00 = 1.74098907459

// L1 = 23.9192        a1 = 82.5           b1 = 22.0
// L2 = 23.9192        a2 = 86.0           b2 = 30.0
// CIE ΔE2000 = ΔE00 = 3.05910158452

// L1 = 0.003          a1 = 47.4052        b1 = -7.79
// L2 = 3.3194         a2 = 42.92          b2 = -1.4728
// CIE ΔE2000 = ΔE00 = 3.92562377939

// L1 = 12.644         a1 = 79.6           b1 = -78.5802
// L2 = 35.491         a2 = 62.2402        b2 = -57.1246
// CIE ΔE2000 = ΔE00 = 17.36922940503

// L1 = 97.29          a1 = -7.2           b1 = 54.208
// L2 = 71.4           a2 = -25.81         b2 = 35.9
// CIE ΔE2000 = ΔE00 = 22.51172649209

// L1 = 47.0412        a1 = 11.0           b1 = 97.89
// L2 = 39.0           a2 = 123.63         b2 = -55.8
// CIE ΔE2000 = ΔE00 = 77.62017222236

///////////////////////////////////////////////
///////////////////////////////////////////////
///////                                 ///////
///////           CIEDE 2000            ///////
///////      Testing Random Colors      ///////
///////                                 ///////
///////////////////////////////////////////////
///////////////////////////////////////////////

// This program outputs a CSV file to standard output, with its length determined by the first CLI argument.
// Each line contains seven columns:
// - Three columns for the standard L*a*b* color
// - Three columns for the sample L*a*b* color
// - One column for the Delta E 2000 color difference between the standard and sample
// The output can be verified in two ways:
// - With the C driver, which provides a dedicated verification feature
// - By using the JavaScript validator at https://michel-leonard.github.io/ciede2000-color-matching

#include <iostream>
#include <random>
#include <string>

template<typename T>
T round_to_n_decimals(T value, int n) {
	const T factor = T(n ? n == 1 ? 10.0 : 100.0 : 1.0);
	return std::round(value * factor) / factor;
}

template<typename T>
void run_iterations(int n_iterations, const char *fmt) {
	std::random_device rd;
	std::mt19937 gen(rd());

	std::uniform_real_distribution<T> dist_l(0.0, 100.0);
	std::uniform_real_distribution<T> dist_ab(-128.0, 127.0);
	std::uniform_int_distribution<int> decimals(0, 2);

	for (int i = 0; i < n_iterations; ++i) {
		T l1 = round_to_n_decimals(dist_l(gen), decimals(gen));
		T a1 = round_to_n_decimals(dist_ab(gen), decimals(gen));
		T b1 = round_to_n_decimals(dist_ab(gen), decimals(gen));
		T l2 = round_to_n_decimals(dist_l(gen), decimals(gen));
		T a2 = round_to_n_decimals(dist_ab(gen), decimals(gen));
		T b2 = round_to_n_decimals(dist_ab(gen), decimals(gen));
		T delta_e = ciede_2000(l1, a1, b1, l2, a2, b2);
		std::printf(fmt, l1, a1, b1, l2, a2, b2, delta_e);
	}
}

int main(int argc, char *argv[]) {
	int n_iterations = 10000;
	if (1 < argc)
		try {
			int val = std::stoi(argv[1]);
			if (0 < val)
				n_iterations = val;
		} catch (...) {}
	bool use_float = (2 < argc) && std::string(argv[2]) == "--32-bit";
	if (use_float) run_iterations<float>(n_iterations, "%g,%g,%g,%g,%g,%g,%.10g\n");
	else run_iterations<double>(n_iterations, "%g,%g,%g,%g,%g,%g,%.17g\n");
	return 0;
}
