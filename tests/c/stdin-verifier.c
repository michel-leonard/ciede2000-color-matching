// This function written in C is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

#include <math.h>

// Expressly defining pi ensures that the code works on different platforms.
#ifndef M_PI
#define M_PI 3.14159265358979323846264338328
#endif

// The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
// "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 128.
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
	// Returning the square root ensures that the result reflects the actual geometric
	// distance within the color space, which ranges from 0 to approximately 185.
	return sqrt(l * l + h * h + c * c + c * h * r_t);
}

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/samples.html

// L1 = 29.0           a1 = -48.743        b1 = 25.745
// L2 = 29.0           a2 = -48.743        b2 = 25.69
// CIE ΔE2000 = ΔE00 = 0.02409045823

// L1 = 33.0           a1 = 16.738         b1 = -65.7631
// L2 = 33.2           a2 = 16.738         b2 = -65.7631
// CIE ΔE2000 = ΔE00 = 0.16063421304

// L1 = 7.0            a1 = 100.0          b1 = -7.9
// L2 = 7.0            a2 = 106.4124       b2 = -2.884
// CIE ΔE2000 = ΔE00 = 2.03075015673

// L1 = 79.87          a1 = -126.0         b1 = -90.2
// L2 = 84.9505        a2 = -125.0         b2 = -90.0
// CIE ΔE2000 = ΔE00 = 3.43262555024

// L1 = 56.0           a1 = -76.927        b1 = -98.554
// L2 = 60.739         a2 = -72.1          b2 = -100.048
// CIE ΔE2000 = ΔE00 = 4.4472827296

// L1 = 78.6           a1 = -66.3          b1 = -88.0
// L2 = 85.0           a2 = -58.7741       b2 = -78.623
// CIE ΔE2000 = ΔE00 = 4.83751935108

// L1 = 30.435         a1 = 100.952        b1 = 21.9715
// L2 = 24.2921        a2 = 110.9          b2 = 38.1
// CIE ΔE2000 = ΔE00 = 7.00785113897

// L1 = 92.3           a1 = -40.0          b1 = 96.24
// L2 = 81.0           a2 = -36.2113       b2 = 91.2
// CIE ΔE2000 = ΔE00 = 7.4227595303

// L1 = 79.0           a1 = -42.7          b1 = 75.5648
// L2 = 79.068         a2 = -21.7          b2 = 26.0
// CIE ΔE2000 = ΔE00 = 15.01626307648

// L1 = 6.62           a1 = -86.0          b1 = 118.65
// L2 = 31.0           a2 = -70.444        b2 = 75.0
// CIE ΔE2000 = ΔE00 = 18.51028983738

//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
///////////////////////                        ///////////////////////////
///////////////////////        TESTING         ///////////////////////////
///////////////////////                        ///////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////

// The verification is performed here in C99. It reads the CSV data from STDIN,
// prints a completion message, and exits with code 0 on success or 1 on failure.

// CSV files can also be generated and validated using the Large-Scale Validator,
// available at: https://michel-leonard.github.io/ciede2000-color-matching/batch.html

typedef unsigned long long int u64;

#include <sys/time.h>

u64 get_time_ms(void) {
	// returns the current Unix timestamp with milliseconds.
	struct timeval time;
	gettimeofday(&time, 0);
	return (u64) time.tv_sec * 1000 + (u64) time.tv_usec / 1000;
}

#include <string.h>
#include <stdio.h>
#include <stdlib.h>

int main(void) {

	char buf[256], last[256];
	double max_error = 0;
	int c, n_success = 0, n_errors = 0, display_errors = 10;
	const u64 t_1 = get_time_ms();
	while (fgets(buf, 255, stdin)) {
		c = getchar();
		if (c == EOF)
			strcpy(last, buf);
		else
			ungetc(c, stdin);
		const double l_1 = strtod(strtok(buf, ","), 0);
		const double a_1 = strtod(strtok(0, ","), 0);
		const double b_1 = strtod(strtok(0, ","), 0);
		const double l_2 = strtod(strtok(0, ","), 0);
		const double a_2 = strtod(strtok(0, ","), 0);
		const double b_2 = strtod(strtok(0, ","), 0);
		const double delta_e = strtod(strtok(0, "\n"), 0);
		const double expected_delta_e = ciede_2000(l_1, a_1, b_1, l_2, a_2, b_2);
		const double error = fabs(delta_e - expected_delta_e);
		if (max_error < error)
			max_error = error;
		if (error < 1E-10)
			++n_success;
		else {
			++n_errors;
			if (display_errors) {
				--display_errors;
				printf("Error: ciede_2000(%.15g, %.15g, %.15g, %.15g, %.15g, %.15g) != %.15g ... got %.15g\n", l_1, a_1, b_1, l_2, a_2, b_2, expected_delta_e, delta_e);
			}
		}
	}
	const u64 t_2 = get_time_ms();
	puts("CIEDE2000 Verification Summary :");
	printf("- Last Verified Line : %s", last);
	printf("- Duration : %.02f s\n", (double) (t_2 - t_1) / 1000.0);
	printf("- Successes : %d\n", n_success);
	printf("- Errors : %d\n", n_errors);
	printf("- Maximum Difference : %.16e\n", max_error);
	return 0;
}

// When "stdin-verifier.c" is the current file, compilation is done using GCC or CLang :
// - gcc -std=c99 -Wall -Wextra -pedantic -O3 -o verifier stdin-verifier.c -lm
// - clang -std=c99 -Wall -Wextra -pedantic -O3 -o verifier stdin-verifier.c -lm
