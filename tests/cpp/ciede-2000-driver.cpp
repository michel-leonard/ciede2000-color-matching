// Limited Use License – March 1, 2025

// This source code is provided for public use under the following conditions :
// It may be downloaded, compiled, and executed, including in publicly accessible environments.
// Modification is strictly prohibited without the express written permission of the author.

// © Michel Leonard 2025

#include <cmath>

// Expressly defining pi ensures that the code works on different platforms.
#ifndef M_PI
#define M_PI 3.14159265358979323846264338327950288419716939937511
#endif

// The generic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
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

// L1 = 38.4   a1 = 52.3   b1 = 2.4
// L2 = 39.0   a2 = 46.1   b2 = -1.9
// CIE ΔE00 = 2.9486939486 (Bruce Lindbloom, Netflix’s VMAF, ...)
// CIE ΔE00 = 2.9487075690 (Gaurav Sharma, OpenJDK, ...)
// Deviation between implementations ≈ 1.4e-5

// See the source code comments for easy switching between these two widely used ΔE*00 implementation variants.

/////////////////////////////////////////////////
/////////////////////////////////////////////////
////////////                         ////////////
////////////    CIEDE2000 Driver     ////////////
////////////                         ////////////
/////////////////////////////////////////////////
/////////////////////////////////////////////////

// Reads a CSV file specified as the first command-line argument. For each line, this program
// in C++ displays the original line with the computed Delta E 2000 color difference appended.
// The C driver can offer CSV files to process and programmatically check the calculations performed there.

//  Example of a CSV input line : 66,119,-22,60.3,119.4,10
//    Corresponding output line : 66,119,-22,60.3,119.4,10,10.418440455009543162253314076692

#include <algorithm>
#include <cctype>
#include <fstream>
#include <iostream>
#include <sstream>
#include <string>

void rtrim(std::string& s) {
	// Strip whitespace from the end of a string.
	s.erase(std::find_if(s.rbegin(), s.rend(),
			[](unsigned char ch) { return !std::isspace(ch); }).base(),
		s.end());
}

int main(int argc, char* argv[]) {
	if (argc < 2) {
		std::cerr << "Usage: " << argv[0] << " <filename>\n";
		return 1;
	}
	const std::string filename = argv[1];
	std::ifstream file(filename);
	std::string line;
	while (std::getline(file, line)) {
		rtrim(line);
		std::istringstream iss(line);
		std::string value;
		const double l_1 = (std::getline(iss, value, ','), std::stod(value));
		const double a_1 = (std::getline(iss, value, ','), std::stod(value));
		const double b_1 = (std::getline(iss, value, ','), std::stod(value));
		const double l_2 = (std::getline(iss, value, ','), std::stod(value));
		const double a_2 = (std::getline(iss, value, ','), std::stod(value));
		const double b_2 = (std::getline(iss, value, ','), std::stod(value));
		const double delta_e = ciede_2000(l_1, a_1, b_1, l_2, a_2, b_2);
		std::printf("%s,%.17f\n", line.c_str(), delta_e);
	}
	return 0;
}
