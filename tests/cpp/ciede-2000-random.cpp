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
	T n = (std::sqrt(a_1 * a_1 + b_1 * b_1) + std::sqrt(a_2 * a_2 + b_2 * b_2)) * T(0.5);
	n = n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = T(1.0) + T(0.5) * (T(1.0) - std::sqrt(n / (n + T(6103515625.0))));
	// Application of the chroma correction factor.
	const T c_1 = std::sqrt(a_1 * a_1 * n * n + b_1 * b_1);
	const T c_2 = std::sqrt(a_2 * a_2 * n * n + b_2 * b_2);
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	T h_1 = std::atan2(b_1, a_1 * n);
	T h_2 = std::atan2(b_2, a_2 * n);
	h_1 += (h_1 < T(0.0)) * T(2.0) * T(M_PI);
	h_2 += (h_2 < T(0.0)) * T(2.0) * T(M_PI);
	n = std::fabs(h_2 - h_1);
	// Cross-implementation consistent rounding.
	if (T(M_PI) - T(1E-14) < n && n < T(M_PI) + T(1E-14))
		n = T(M_PI);
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	T h_m = (h_1 + h_2) * T(0.5);
	T h_d = (h_2 - h_1) * T(0.5);
	h_d += (T(M_PI) < n) * T(M_PI);
	// 📜 Sharma’s formulation doesn’t use the next line, but the one after it,
	// and these two variants differ by ±0.0003 on the final color differences.
	h_m += (T(M_PI) < n) * T(M_PI);
	// h_m += (T(M_PI) < n) * ((h_m < T(M_PI)) - (T(M_PI) <= h_m)) * T(M_PI);
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
	const T l = (l_2 - l_1) / (k_l * (T(1.0) + T(3.0) / T(200.0) * n / std::sqrt(T(20.0) + n)));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	const T t = T(1.0) 	+ T(6.0) / T(25.0) * std::sin(T(2.0) * h_m + T(M_PI) / T(2.0))
				+ T(8.0) / T(25.0) * std::sin(T(3.0) * h_m + T(8.0) * T(M_PI) / T(15.0))
				- T(17.0) / T(100.0) * std::sin(h_m + T(M_PI) / T(3.0))
				- T(1.0) / T(5.0) * std::sin(T(4.0) * h_m + T(3.0) * T(M_PI) / T(20.0));
	n = c_1 + c_2;
	// Hue.
	const T h = T(2.0) * std::sqrt(c_1 * c_2) * std::sin(h_d) / (k_h * (T(1.0) + T(3.0) / T(400.0) * n * t));
	// Chroma.
	const T c = (c_2 - c_1) / (k_c * (T(1.0) + T(9.0) / T(400.0) * n));
	// Returning the square root ensures that dE00 accurately reflects the
	// geometric distance in color space, which can range from 0 to around 185.
	return std::sqrt(l * l + h * h + c * c + c * h * r_t);
}

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//   Online Tests : https://michel-leonard.github.io/ciede2000-color-matching

// L1 = 13.6   a1 = 25.2   b1 = 3.6
// L2 = 15.8   a2 = 31.3   b2 = -2.8
// CIE ΔE00 = 5.1128822202 (Bruce Lindbloom, Netflix’s VMAF, ...)
// CIE ΔE00 = 5.1128689782 (Gaurav Sharma, OpenJDK, ...)
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

// This C++ program outputs a CSV file to standard output, with its length determined by the first CLI argument.
// Each line contains seven columns :
// - Three columns for the random standard L*a*b* color
// - Three columns for the random sample L*a*b* color
// - And the seventh column for the precise Delta E 2000 color difference between the standard and sample
// The output will be correct, this can be verified :
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
