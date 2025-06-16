// Limited Use License – March 1, 2025

// This source code is provided for public use under the following conditions :
// It may be downloaded, compiled, and executed, including in publicly accessible environments.
// Modification is strictly prohibited without the express written permission of the author.

// © Michel Leonard 2025

#include <cmath>

// Expressly defining pi ensures that the code works on different platforms.
#ifndef M_PI
#define M_PI 3.14159265358979323846264338328
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

// L1 = 67.372         a1 = -100.0         b1 = 54.725
// L2 = 67.372         a2 = -100.0         b2 = 54.7
// CIE ΔE2000 = ΔE00 = 0.00687214098

// L1 = 63.0           a1 = 59.1429        b1 = -16.923
// L2 = 63.0           a2 = 59.1429        b2 = -17.0
// CIE ΔE2000 = ΔE00 = 0.03222662831

// L1 = 53.72          a1 = 88.4032        b1 = -124.509
// L2 = 53.72          a2 = 88.4032        b2 = -120.6
// CIE ΔE2000 = ΔE00 = 1.15100948621

// L1 = 93.0           a1 = -0.235         b1 = 12.623
// L2 = 93.0           a2 = 1.106          b2 = 11.7
// CIE ΔE2000 = ΔE00 = 1.88099081865

// L1 = 37.1           a1 = -76.7          b1 = 97.5134
// L2 = 40.832         a2 = -83.0          b2 = 102.1011
// CIE ΔE2000 = ΔE00 = 3.4749287749

// L1 = 88.0           a1 = 80.4           b1 = 113.227
// L2 = 92.0           a2 = 74.9857        b2 = 121.4
// CIE ΔE2000 = ΔE00 = 4.65343370601

// L1 = 44.3           a1 = 101.0          b1 = -15.0
// L2 = 42.83          a2 = 77.1305        b2 = -14.18
// CIE ΔE2000 = ΔE00 = 4.98452428029

// L1 = 68.5927        a1 = -17.1          b1 = -61.9
// L2 = 72.9226        a2 = 15.25          b2 = -110.7
// CIE ΔE2000 = ΔE00 = 10.79736575069

// L1 = 68.309         a1 = 96.14          b1 = 121.0
// L2 = 86.477         a2 = 96.7           b2 = 106.0
// CIE ΔE2000 = ΔE00 = 13.64241656135

// L1 = 58.22          a1 = -103.08        b1 = -20.6
// L2 = 68.67          a2 = -109.0         b2 = -71.893
// CIE ΔE2000 = ΔE00 = 18.31855788761

/////////////////////////////////////////////////
/////////////////////////////////////////////////
////////////                         ////////////
////////////    CIEDE2000 Driver     ////////////
////////////                         ////////////
/////////////////////////////////////////////////
/////////////////////////////////////////////////

// Reads a CSV file specified as the first command-line argument. For each line, the program
// outputs the original line with the computed Delta E 2000 color difference appended.

//  Example of a CSV input line : 67.24,-14.22,70,65,8,46
//    Corresponding output line : 67.24,-14.22,70,65,8,46,15.46723547943141064

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
