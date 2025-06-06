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
	double n = (hypot(a_1, b_1) + hypot(a_2, b_2)) * 0.5;
	n = n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - sqrt(n / (n + 6103515625.0)));
	// hypot calculates the Euclidean distance while avoiding overflow/underflow.
	const double c_1 = hypot(a_1 * n, b_1);
	const double c_2 = hypot(a_2 * n, b_2);
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	double h_1 = atan2(b_1, a_1 * n);
	double h_2 = atan2(b_2, a_2 * n);
	if (h_1 < 0.0)
		h_1 += 2.0 * M_PI;
	if (h_2 < 0.0)
		h_2 += 2.0 * M_PI;
	n = fabs(h_2 - h_1);
	// Cross-implementation consistent rounding.
	if (M_PI - 1E-14 < n && n < M_PI + 1E-14)
		n = M_PI;
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	double h_m = (h_1 + h_2) * 0.5;
	double h_d = (h_2 - h_1) * 0.5;
	if (M_PI < n) {
		if (0.0 < h_d)
			h_d -= M_PI;
		else
			h_d += M_PI;
		h_m += M_PI;
	}
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
	const double t = 1.0 + 0.24 * sin(2.0 * h_m + M_PI / 2.0)
					 + 0.32 * sin(3.0 * h_m + 8.0 * M_PI / 15.0)
					 - 0.17 * sin(h_m + M_PI / 3.0)
					 - 0.20 * sin(4.0 * h_m + 3.0 * M_PI / 20.0);
	n = c_1 + c_2;
	// Hue.
	const double h = 2.0 * sqrt(c_1 * c_2) * sin(h_d) / (k_h * (1.0 + 0.0075 * n * t));
	// Chroma.
	const double c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
	// Returns the square root so that the Delta E 2000 reflects the actual geometric
	// distance within the color space, which ranges from 0 to approximately 185.
	return sqrt(l * l + h * h + c * c + c * h * r_t);
}

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

// L1 = 95.0           a1 = 41.47          b1 = 78.7
// L2 = 95.0           a2 = 41.51          b2 = 78.7
// CIE ΔE2000 = ΔE00 = 0.01989819054

// L1 = 35.14          a1 = -43.6          b1 = -110.9
// L2 = 35.14          a2 = -43.8          b2 = -110.9
// CIE ΔE2000 = ΔE00 = 0.05793509961

// L1 = 81.0           a1 = 98.8           b1 = -120.4
// L2 = 83.3           a2 = 102.0          b2 = -120.4
// CIE ΔE2000 = ΔE00 = 1.81536313008

// L1 = 88.0804        a1 = 107.0          b1 = -76.2
// L2 = 88.0804        a2 = 116.19         b2 = -76.2
// CIE ΔE2000 = ΔE00 = 1.86514134287

// L1 = 96.606         a1 = -123.0         b1 = -37.1359
// L2 = 96.606         a2 = -116.0         b2 = -45.8945
// CIE ΔE2000 = ΔE00 = 3.64578578912

// L1 = 15.82          a1 = -82.4          b1 = -21.7
// L2 = 13.441         a2 = -79.9          b2 = -38.187
// CIE ΔE2000 = ΔE00 = 7.17093657399

// L1 = 72.956         a1 = -61.859        b1 = -69.25
// L2 = 59.0768        a2 = -32.0          b2 = -49.8917
// CIE ΔE2000 = ΔE00 = 14.36422705822

// L1 = 76.792         a1 = -15.4          b1 = 120.09
// L2 = 80.9558        a2 = 18.103         b2 = 85.0
// CIE ΔE2000 = ΔE00 = 18.96039507717

// L1 = 78.0           a1 = 50.7544        b1 = 73.0
// L2 = 66.8098        a2 = 123.35         b2 = 95.7
// CIE ΔE2000 = ΔE00 = 20.78896469183

// L1 = 98.57          a1 = 108.4226       b1 = 76.57
// L2 = 35.0           a2 = -33.3          b2 = -35.861
// CIE ΔE2000 = ΔE00 = 94.95097544593

//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
///////////////////////                        ///////////////////////////
///////////////////////        TESTING         ///////////////////////////
///////////////////////                        ///////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////

// The output is intended to be checked by the Large-Scale validator
// at https://michel-leonard.github.io/ciede2000-color-matching

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
		default: return round(res * 10.00) / 100.0;
	}
}

#include <stdlib.h>
#include <stdio.h>

int main(int argc, char *argv[]) {
	u64 seed = get_time_ms();
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
		printf("%.15g,%.15g,%.15g,%.15g,%.15g,%.15g,%.15g\n", l_1, a_1, b_1, l_2, a_2, b_2, delta_e);
	}

}

// When "ciede-2000-testing.c" is the current file, compilation is done using GCC or CLang :
// - gcc -std=c99 -Wall -Wextra -pedantic -O3 -o ciede-2000-test ciede-2000-testing.c -lm
// - clang -std=c99 -Wall -Wextra -pedantic -O3 -o ciede-2000-test ciede-2000-testing.c -lm
