// This function written in C is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

#include <math.h>

// Expressly defining pi ensures that the code works on different platforms.
#ifndef M_PI
#define M_PI 3.14159265358979323846264338328
#endif

// The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
// "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
static double ciede_2000(const double l_1, const double a_1, const double b_1, const double l_2, const double a_2, const double b_2) {
	// Working in C with the CIEDE2000 color-difference formula.
	// k_l, k_c, k_h are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	const double k_l = 1.0;
	const double k_c = 1.0;
	const double k_h = 1.0;
	double n = (sqrt(a_1 * a_1 + b_1 * b_1) + sqrt(a_2 * a_2 + b_2 * b_2)) * 0.5;
	n = n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - sqrt(n / (n + 6103515625.0)));
	// Application of the chroma correction factor.
	const double c_1 = sqrt(a_1 * a_1 * n * n + b_1 * b_1);
	const double c_2 = sqrt(a_2 * a_2 * n * n + b_2 * b_2);
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	double h_1 = atan2(b_1, a_1 * n);
	double h_2 = atan2(b_2, a_2 * n);
	h_1 += (h_1 < 0.0) * 2.0 * M_PI;
	h_2 += (h_2 < 0.0) * 2.0 * M_PI;
	n = fabs(h_2 - h_1);
	// Cross-implementation consistent rounding.
	if (M_PI - 1E-14 < n && n < M_PI + 1E-14)
		n = M_PI;
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	double h_m = (h_1 + h_2) * 0.5;
	double h_d = (h_2 - h_1) * 0.5;
	h_d += (M_PI < n) * M_PI;
	// 📜 Sharma’s formulation doesn’t use the next line, but the one after it,
	// and these two variants differ by ±0.0003 on the final color differences.
	h_m += (M_PI < n) * M_PI;
	// h_m += (M_PI < n) * ((h_m < M_PI) - (M_PI <= h_m)) * M_PI;
	const double p = 36.0 * h_m - 55.0 * M_PI;
	n = (c_1 + c_2) * 0.5;
	n = n * n * n * n * n * n * n;
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	const double r_t = -2.0 * sqrt(n / (n + 6103515625.0))
			* sin(M_PI / 3.0 * exp(p * p / (-25.0 * M_PI * M_PI)));
	n = (l_1 + l_2) * 0.5;
	n = (n - 50.0) * (n - 50.0);
	// Lightness.
	const double l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / sqrt(20.0 + n)));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	const double t = 1.0	+ 0.24 * sin(2.0 * h_m + M_PI / 2.0)
				+ 0.32 * sin(3.0 * h_m + 8.0 * M_PI / 15.0)
				- 0.17 * sin(h_m + M_PI / 3.0)
				- 0.20 * sin(4.0 * h_m + 3.0 * M_PI / 20.0);
	n = c_1 + c_2;
	// Hue.
	const double h = 2.0 * sqrt(c_1 * c_2) * sin(h_d) / (k_h * (1.0 + 0.0075 * n * t));
	// Chroma.
	const double c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
	// Returning the square root ensures that dE00 accurately reflects the
	// geometric distance in color space, which can range from 0 to around 185.
	return sqrt(l * l + h * h + c * c + c * h * r_t);
}

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//   Online Tests : https://michel-leonard.github.io/ciede2000-color-matching

// L1 = 42.0   a1 = 20.2   b1 = -4.8
// L2 = 40.0   a2 = 14.3   b2 = 3.5
// CIE ΔE00 = 7.0461082693 (Bruce Lindbloom, Netflix’s VMAF, ...)
// CIE ΔE00 = 7.0460891713 (Gaurav Sharma, OpenJDK, ...)
// Deviation between implementations ≈ 1.9e-5

// See the source code comments for easy switching between these two widely used ΔE*00 implementation variants.

///////////////////////////////////////////////
///////////////////////////////////////////////
///////                                 ///////
///////           CIEDE 2000            ///////
///////      Testing Random Colors      ///////
///////                                 ///////
///////////////////////////////////////////////
///////////////////////////////////////////////

// This C program outputs a CSV file to standard output, with its length determined by the first CLI argument.
// Each line contains seven columns :
// - Three columns for the random standard L*a*b* color
// - Three columns for the random sample L*a*b* color
// - And the seventh column for the precise Delta E 2000 color difference between the standard and sample
// The output will be correct, this can be verified :
// - As done in a GitHub Actions workflow, against Netflix’s VMAF, Rust’s palette, Python’s colormath ...
// - By using the JavaScript validator at https://michel-leonard.github.io/ciede2000-color-matching

typedef unsigned long long int u64;

#include <sys/time.h>

u64 get_time_ms(void) {
	// returns the current Unix timestamp with milliseconds.
	struct timeval time;
	gettimeofday(&time, 0);
	return (u64) time.tv_sec * 1000 + (u64) time.tv_usec / 1000;
}

static inline u64 xor_random(u64 *s) {
	// A shift-register generator has a reproducible behavior across platforms.
	return *s ^= *s << 13, *s ^= *s >> 7, *s ^= *s << 17;
}

static inline double rand_double_64(double min, double max, u64 *restrict seed) {
	const double res = min + (max - min) * ((double) xor_random(seed) / 18446744073709551616.0);
	switch (xor_random(seed) % 3) {
		case 0: return round(res);
		case 1: return round(res * 10.0) / 10.0;
		default: return round(res * 100.0) / 100.0;
	}
}

#include <stdlib.h>
#include <stdio.h>

int main(int argc, char *argv[]) {
	u64 seed = 0xc6a4a7935bd1e995ULL ^ get_time_ms();
	int n_iterations = 10000;
	if (1 < argc)
		n_iterations = (int) strtol(argv[1], 0, 10);
	if (n_iterations < 1)
		n_iterations = 10000;
	for (int i = 0; i < n_iterations; ++i) {
		const double l_1 = rand_double_64(0.0, 100.0, &seed);
		const double a_1 = rand_double_64(-128.0, 128.0, &seed);
		const double b_1 = rand_double_64(-128.0, 128.0, &seed);
		const double l_2 = rand_double_64(0.0, 100.0, &seed);
		const double a_2 = rand_double_64(-128.0, 128.0, &seed);
		const double b_2 = rand_double_64(-128.0, 128.0, &seed);
		const double delta_e = ciede_2000(l_1, a_1, b_1, l_2, a_2, b_2);
		printf("%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.17f\n", l_1, a_1, b_1, l_2, a_2, b_2, delta_e);
	}

}

// When "ciede-2000-testing.c" is the current file, compilation is done using GCC or CLang :
// - gcc -std=c99 -Wall -Wextra -pedantic -O3 -o ciede-2000-test ciede-2000-random.c -lm
// - clang -std=c99 -Wall -Wextra -pedantic -O3 -o ciede-2000-test ciede-2000-random.c -lm
