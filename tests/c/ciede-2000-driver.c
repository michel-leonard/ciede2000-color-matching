// Limited Use License – March 1, 2025

// This source code is provided for public use under the following conditions :
// It may be downloaded, compiled, and executed, including in publicly accessible environments.
// Modification is strictly prohibited without the express written permission of the author.

// © Michel Leonard 2025

#include <math.h>
#include <stdlib.h>
#include <assert.h>
#include <stdio.h>
#include <string.h>
#include <inttypes.h>
#include <sys/time.h>

// Expressly defining pi ensures that the code works on different platforms.
#ifndef M_PI
#define M_PI 3.14159265358979323846264338328
#endif

typedef struct {
	struct {
		uint64_t seed;
		uint64_t generate;
		double tolerance;
		const char *delimiter;
		const char *input_file;
		const char *output_file;
		int precision;
		int verbose;
		int help;
		char mode;
	} params;
	char buf_1[255];
	char buf_2[255];
	char format[127];
	FILE *in_fp;
	FILE *out_fp;
	int code;
} state;

#define DeltaE(a, b, c) if (!strcmp(key, "--" #a) || !strcmp(key, "-" #b)) (c)
static int read_arg_2(const char **argv, state *state) {
	// Reads a key/value parameter received on the command line.
	const char *key = *argv, *value = *(argv + 1);
	DeltaE(delimiter, d, state->params.delimiter = value);
	else DeltaE(generate, g, state->params.generate = strtoull(value, 0, 10));
	else DeltaE(input-file, i, state->params.input_file = value);
	else DeltaE(output-file, o, state->params.output_file = value);
	else DeltaE(precision, p, state->params.precision = (int) strtol(value, 0, 10));
	else DeltaE(rand-seed, r, state->params.seed = strtol(value, 0, 10));
	else DeltaE(tolerance, t, state->params.tolerance = strtod(value, 0));
	else
		return 0;
	return 1;
}

static int read_arg_1(const char **argv, state *state) {
	// Reads a flag received on the command line.
	const char *key = *argv;
	DeltaE(control, c, state->params.mode = 'c');
	else DeltaE(help, h, state->params.help = 1);
	else DeltaE(solve, s, state->params.mode = 's');
	else DeltaE(verbose, v, state->params.verbose = 1);
	else
		return 0;
	return 1;
}
#undef DeltaE

static void open_descriptors(state *state) {
	if (state->params.input_file && state->params.output_file && !strcmp(state->params.input_file, state->params.output_file)) {
		fprintf(stderr, "Delta E 2000: Can't read and write the same file.\n");
		state->code = 3;
		return;
	}
	state->in_fp = stdin;
	state->out_fp = stdout;
	if (state->params.input_file) {
		state->in_fp = fopen(state->params.input_file, "rb");
		if (state->in_fp == 0) {
			perror("Delta E 2000");
			state->code = 3;
			return;
		}
	}
	if (state->params.output_file) {
		state->out_fp = fopen(state->params.output_file, "wb");
		if (state->out_fp == 0) {
			perror("Delta E 2000");
			state->code = 3;
			return;
		}
	}
}

static void close_descriptors(state *state) {
	if (state->in_fp != stdin)
		fclose(state->in_fp);
	if (state->out_fp != stdout)
		fclose(state->out_fp);
}

static inline uint64_t xor_random(uint64_t *s) {
	// A shift-register generator has a reproducible behavior across platforms.
	return *s ^= *s << 13, *s ^= *s >> 7, *s ^= *s << 17;
}

static inline void perturb(double *value, const double min, const double max, const uint32_t seed) {
	static const double magnitudes[16] = {
			-1e-12, +1e-12, -1.7e-11, +1.7e-11, -2.9e-10, +2.9e-10,
			-4.9e-9, +4.9e-9, -8.4e-8, +8.4e-8, -1.4e-6, +1.4e-6,
			-2.4e-5, +2.4e-5, -4.1e-4, +4.1e-4
	};
	if (!(seed & 15)) {
		*value += magnitudes[(seed >> 4) & 15] * (1.0 + ((seed >> 8) & 15));
		if (*value < min) *value = min; else if(max < *value) *value = max;
	}
}

static inline void rand_lab(double *l, double *a, double *b, uint64_t *seed) {
	uint64_t x = xor_random(seed);
	const uint32_t y = x & 16383; x >>= 14;
	const uint32_t z = x & 32767; x >>= 15;
	const uint32_t t = x & 32767; x >>= 15;
	*l = x & 1 ? y % 101 : x & 2 ? y % 1000 / 10.0 : y % 10000 / 100.0;
	*a = (x & 4 ? z % 257 : x & 8 ? z % 2560 / 10.0 : z % 25600 / 100.0) - 128.0;
	*b = (x & 16 ? t % 257 : x & 32 ? t % 2560 / 10.0 : t % 25600 / 100.0) - 128.0;
	x = xor_random(seed);
	if (x & 251719695) {
		perturb(l, 0.0, 100.0, x & 4095);
		perturb(a, -128.0, 128.0, (x >> 12) & 4095);
		perturb(b, -128.0, 128.0, (x >> 24) & 4095);
	}
}

// The functional CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
// "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
static double ciede_2000_functional(const double l1, const double a1, const double b1, const double l2, const double a2, const double b2) {
	// Working in C with the CIEDE2000 color-difference formula.
	// k_L, k_C, k_H are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	const double k_L = 1.0;
	const double k_C = 1.0;
	const double k_H = 1.0;

	const double pi_1 = 3.14159265358979323846;
	const double pi_3 = 1.04719755119659774615;

	// 1. Compute chroma magnitudes ... a and b usually range from -128 to +127
	const double a1_sq = a1 * a1;
	const double b1_sq = b1 * b1;
	const double c_orig_1 = sqrt(a1_sq + b1_sq);

	const double a2_sq = a2 * a2;
	const double b2_sq = b2 * b2;
	const double c_orig_2 = sqrt(a2_sq + b2_sq);

	// 2. Compute chroma mean and apply G compensation
	const double c_avg = 0.5 * (c_orig_1 + c_orig_2);
	const double c_avg_3 = c_avg * c_avg * c_avg;
	const double c_avg_7 = c_avg_3 * c_avg_3 * c_avg;
	const double g_denom = c_avg_7 + 6103515625.0;
	const double g_ratio = c_avg_7 / g_denom;
	const double g_sqrt = sqrt(g_ratio);
	const double g_factor = 1.0 + 0.5 * (1.0 - g_sqrt);

	// 3. Apply G correction to a components, compute corrected chroma
	const double a1_prime = a1 * g_factor;
	const double c1_prime_sq = a1_prime * a1_prime + b1 * b1;
	const double c1_prime = sqrt(c1_prime_sq);
	const double a2_prime = a2 * g_factor;
	const double c2_prime_sq = a2_prime * a2_prime + b2 * b2;
	const double c2_prime = sqrt(c2_prime_sq);

	// 4. Compute hue angles in radians, adjust for negatives and wrap
	const double safe_1 = 1e30 * (double)(b1 == 0.0 && a1_prime == 0.0);
	const double safe_2 = 1e30 * (double)(b2 == 0.0 && a2_prime == 0.0);
	// Compatibility: this can avoid NaN in atan2 when parameters are both zero
	const double h1_raw = atan2(b1, a1_prime + safe_1);
	const double h2_raw = atan2(b2, a2_prime + safe_2);
	const double h1_adj = h1_raw + (double) (h1_raw < 0.0) * 2.0 * pi_1;
	const double h2_adj = h2_raw + (double) (h2_raw < 0.0) * 2.0 * pi_1;
	const double delta_h = fabs(h1_adj - h2_adj);
	const double h_mean_raw = 0.5 * (h1_adj + h2_adj) ;
	const double h_diff_raw = 0.5 * (h2_adj - h1_adj);

	// Check if hue mean wraps around pi (180 deg)
	const double wrap_dist = fabs(pi_1 - delta_h);
	const double hue_wrap = (double) (1e-14 < wrap_dist && pi_1 < delta_h);
	const double h_mean = h_mean_raw + hue_wrap * pi_1;

	// Michel Leonard 2025 - When mean wraps, difference wraps too
	const double h_diff_hi = (double) (hue_wrap && h_diff_raw < 0.0) * pi_1;
	const double h_diff_lo = (double) (hue_wrap && h_diff_hi == 0.0) * pi_1;
	const double h_diff = h_diff_raw + h_diff_hi - h_diff_lo;

	// 5. Compute hue rotation correction factor R_T
	const double c_bar = 0.5 * (c1_prime + c2_prime);
	const double c_bar_3 = c_bar * c_bar * c_bar;
	const double c_bar_7 = c_bar_3 * c_bar_3 * c_bar;
	const double rc_denom = c_bar_7 + 6103515625.0;
	const double R_C = sqrt(c_bar_7 / rc_denom);

	const double theta = 36.0 * h_mean - 55.0 * pi_1;
	const double theta_denom = -25.0 * pi_1 * pi_1;
	const double exp_argument = theta * theta / theta_denom;
	const double exp_term = exp(exp_argument);
	const double delta_theta = pi_3 * exp_term;
	const double sin_term = sin(delta_theta);

	// Rotation factor ... cross-effect between chroma and hue
	const double R_T = -2.0 * R_C * sin_term;

	// 6. Compute lightness term ... L nominally ranges from 0 to 100
	const double l_avg = 0.5 * (l1 + l2);
	const double l_delta_sq = (l_avg - 50.0) * (l_avg - 50.0);
	const double l_delta = l2 - l1;

	// Adaptation to the non-linearity of light perception ... S_L
	const double s_l_num = 0.015 * l_delta_sq;
	const double s_l_denom = sqrt(20.0 + l_delta_sq);
	const double S_L = 1.0 + s_l_num / s_l_denom;
	const double L_term = l_delta / (k_L * S_L);

	// 7. Compute chroma-related trig terms and factor T
	const double trig_1 = 0.17 * sin(h_mean + pi_3);
	const double trig_2 = 0.24 * sin(2.0 * h_mean + 0.5 * pi_1);
	const double trig_3 = 0.32 * sin(3.0 * h_mean + 1.6  * pi_3);
	const double trig_4 =  0.2 * sin(4.0 * h_mean + 0.15 * pi_1);
	const double T = 1.0 - trig_1 + trig_2 + trig_3 - trig_4;

	const double c_sum = c1_prime + c2_prime;
	const double c_product = c1_prime * c2_prime;
	const double c_geo_mean = sqrt(c_product);

	// 8. Compute hue difference and scaling factor S_H
	const double sin_h_diff = sin(h_diff);
	const double S_H = 1.0 + 0.0075 * c_sum * T;
	const double H_term = 2.0 * c_geo_mean * sin_h_diff / (k_H * S_H);

	// 9. Compute chroma difference and scaling factor S_C
	const double c_delta = c2_prime - c1_prime;
	const double S_C = 1.0 + 0.0225 * c_sum;
	const double C_term = c_delta / (k_C * S_C);

	// 10. Combine lightness, chroma, hue, and interaction terms
	const double L_part = L_term * L_term;
	const double C_part = C_term * C_term;
	const double H_part = H_term * H_term;
	const double interaction = C_term * H_term * R_T;
	const double delta_e_squared = L_part + C_part + H_part + interaction;
	const double delta_e_2000 = sqrt(delta_e_squared);

	return delta_e_2000;
}

// The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
// "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
static double ciede_2000_standard(const double l_1, const double a_1, const double b_1, const double l_2, const double a_2, const double b_2) {
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
	// The hypot function can do the following, but is not required here.
	const double c_1 = sqrt(a_1 * a_1 * n * n + b_1 * b_1);
	const double c_2 = sqrt(a_2 * a_2 * n * n + b_2 * b_2);
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
	const double t = 1.0 	+ 0.24 * sin(2.0 * h_m + M_PI / 2.0)
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

static int ensure(const double l_1, const double a_1, const double b_1, const double l_2, const double a_2, const double b_2, const double delta_e, const double precision, const char *name) {
	const double delta_e_1 = ciede_2000_standard(l_1, a_1, b_1, l_2, a_2, b_2);
	const double delta_e_2 = ciede_2000_functional(l_1, a_1, b_1, l_2, a_2, b_2);
	const int res = fabs(delta_e_1 - delta_e) <= precision && fabs(delta_e_2 - delta_e) <= precision;
	if (!res) {
		fprintf(stderr, "%s test failed :\n", name);
		fprintf(stderr, "  - ciede_2000(%g, %g, %g, %g, %g, %g) != %g\n", l_1, a_1, b_1, l_2, a_2, b_2, delta_e);
		fprintf(stderr, "  - got standard=%g, functional=%g\n", delta_e_1, delta_e_2);
	}
	return res;
}

static int static_controls() {
	int res = 1;
	res &= ensure(100.0, 0.005, -0.01, 100.0, 0.005, -0.01, 0.0, 0.0, "Basic");
	res &= ensure(100.0, 0.0, 0.0, 0.0, 0.0, 0.0, 100.0, 1E-4, "ICC HDR Working Group");
	res &= ensure(100.0, 0.0, 0.0, 100.0, 0.0, 0.0, 0.0, 1E-4, "ICC HDR Working Group");
	res &= ensure(50.0, 2.5, 0.0, 73.0, 25.0, -18.0, 27.1492, 1E-4, "ICC HDR Working Group");
	res &= ensure(50.0, 2.5, 0.0, 61.0, -5.0, 29.0, 22.8977, 1E-4, "ICC HDR Working Group");
	res &= ensure(50.0, 2.5, 0.0, 56.0, -27.0, -3.0, 31.903, 1E-4, "ICC HDR Working Group");
	res &= ensure(50.0, 2.5, 0.0, 58.0, 24.0, 15.0, 19.4535, 1E-4, "ICC HDR Working Group");
	res &= ensure(84.25, 5.74, 96.0, 84.46, 8.88, 96.49, 1.6743, 1E-4, "ICC HDR Working Group");
	res &= ensure(84.25, 5.74, 96.0, 84.52, 5.75, 93.09, 0.5887, 1E-4, "ICC HDR Working Group");
	res &= ensure(84.25, 5.74, 96.0, 84.37, 5.86, 99.42, 0.6395, 1E-4, "ICC HDR Working Group");
	res &= ensure(50.0, 2.6772, -79.7751, 50.0, 0.0, -82.7485, 2.0425, 1E-4, "Gaurav Sharma");
	res &= ensure(50.0, 3.1571, -77.2803, 50.0, 0.0, -82.7485, 2.8615, 1E-4, "Gaurav Sharma");
	res &= ensure(50.0, 2.8361, -74.02, 50.0, 0.0, -82.7485, 3.4412, 1E-4, "Gaurav Sharma");
	res &= ensure(50.0, -1.3802, -84.2814, 50.0, 0.0, -82.7485, 1.0, 1E-4, "Gaurav Sharma");
	res &= ensure(50.0, -1.1848, -84.8006, 50.0, 0.0, -82.7485, 1.0, 1E-4, "Gaurav Sharma");
	res &= ensure(50.0, -0.9009, -85.5211, 50.0, 0.0, -82.7485, 1.0, 1E-4, "Gaurav Sharma");
	res &= ensure(50.0, 0.0, 0.0, 50.0, -1.0, 2.0, 2.3669, 1E-4, "Gaurav Sharma");
	res &= ensure(50.0, -1.0, 2.0, 50.0, 0.0, 0.0, 2.3669, 1E-4, "Gaurav Sharma");
	res &= ensure(50.0, 2.49, -0.001, 50.0, -2.49, 0.0009, 7.1792, 1E-4, "Gaurav Sharma");
	res &= ensure(50.0, 2.49, -0.001, 50.0, -2.49, 0.001, 7.1792, 1E-4, "Gaurav Sharma");
	res &= ensure(50.0, 2.49, -0.001, 50.0, -2.49, 0.0011, 7.2195, 1E-4, "Gaurav Sharma");
	res &= ensure(50.0, 2.49, -0.001, 50.0, -2.49, 0.0012, 7.2195, 1E-4, "Gaurav Sharma");
	res &= ensure(50.0, -0.001, 2.49, 50.0, 0.0009, -2.49, 4.8045, 1E-4, "Gaurav Sharma");
	res &= ensure(50.0, -0.001, 2.49, 50.0, 0.001, -2.49, 4.8045, 1E-4, "Gaurav Sharma");
	res &= ensure(50.0, -0.001, 2.49, 50.0, 0.0011, -2.49, 4.7461, 1E-4, "Gaurav Sharma");
	res &= ensure(50.0, 2.5, 0.0, 50.0, 0.0, -2.5, 4.3065, 1E-4, "Gaurav Sharma");
	res &= ensure(50.0, 2.5, 0.0, 73.0, 25.0, -18.0, 27.1492, 1E-4, "Gaurav Sharma");
	res &= ensure(50.0, 2.5, 0.0, 61.0, -5.0, 29.0, 22.8977, 1E-4, "Gaurav Sharma");
	res &= ensure(50.0, 2.5, 0.0, 56.0, -27.0, -3.0, 31.903, 1E-4, "Gaurav Sharma");
	res &= ensure(50.0, 2.5, 0.0, 58.0, 24.0, 15.0, 19.4535, 1E-4, "Gaurav Sharma");
	res &= ensure(50.0, 2.5, 0.0, 50.0, 3.1736, 0.5854, 1.0, 1E-4, "Gaurav Sharma");
	res &= ensure(50.0, 2.5, 0.0, 50.0, 3.2972, 0.0, 1.0, 1E-4, "Gaurav Sharma");
	res &= ensure(50.0, 2.5, 0.0, 50.0, 1.8634, 0.5757, 1.0, 1E-4, "Gaurav Sharma");
	res &= ensure(50.0, 2.5, 0.0, 50.0, 3.2592, 0.335, 1.0, 1E-4, "Gaurav Sharma");
	res &= ensure(60.2574, -34.0099, 36.2677, 60.4626, -34.1751, 39.4387, 1.2644, 1E-4, "Gaurav Sharma");
	res &= ensure(63.0109, -31.0961, -5.8663, 62.8187, -29.7946, -4.0864, 1.263, 1E-4, "Gaurav Sharma");
	res &= ensure(61.2901, 3.7196, -5.3901, 61.4292, 2.248, -4.962, 1.8731, 1E-4, "Gaurav Sharma");
	res &= ensure(35.0831, -44.1164, 3.7933, 35.0232, -40.0716, 1.5901, 1.8645, 1E-4, "Gaurav Sharma");
	res &= ensure(22.7233, 20.0904, -46.694, 23.0331, 14.973, -42.5619, 2.0373, 1E-4, "Gaurav Sharma");
	res &= ensure(36.4612, 47.858, 18.3852, 36.2715, 50.5065, 21.2231, 1.4146, 1E-4, "Gaurav Sharma");
	res &= ensure(90.8027, -2.0831, 1.441, 91.1528, -1.6435, 0.0447, 1.4441, 1E-4, "Gaurav Sharma");
	res &= ensure(90.9257, -0.5406, -0.9208, 88.6381, -0.8985, -0.7239, 1.5381, 1E-4, "Gaurav Sharma");
	res &= ensure(6.7747, -0.2908, -2.4247, 5.8714, -0.0985, -2.2286, 0.6377, 1E-4, "Gaurav Sharma");
	res &= ensure(2.0776, 0.0795, -1.135, 0.9033, -0.0636, -0.5514, 0.9082, 1E-4, "Gaurav Sharma");
	return res;
}

static uint64_t get_time_ms(void) {
	// returns the current Unix timestamp with milliseconds.
	struct timeval time;
	gettimeofday(&time, 0);
	return (uint64_t) time.tv_sec * 1000 + (uint64_t) time.tv_usec / 1000;
}
#define Precision "%.15g"
#define DeltaE_default(a, b) ((a) <= 0 ? (b) : (a))
static void generate(state *state) {
	const uint64_t time_1 = get_time_ms();
	if (state->params.seed == 0)
		state->params.seed = time_1;
	uint64_t seed = state->params.seed ^ 0x2236b69a7d223bd;
	for (uint64_t i = 0, j = seed + (seed == 0); xor_random(&j), i < 64; ++i)
		seed ^= (j & 1) << i;
	const int number = (int)DeltaE_default(state->params.generate, 10);
	const char s = (char) (state->params.delimiter ? DeltaE_default(*state->params.delimiter, ',') : ',');
	sprintf(state->format, "%" Precision "%c%" Precision "%c%" Precision "%c%" Precision "%c%" Precision "%c%" Precision "\n", s, s, s, s, s);
	double l_1, a_1, b_1, l_2, a_2, b_2;
	for (int i = 1; i < number; ++i) {
		rand_lab(&l_1, &a_1, &b_1, &seed);
		rand_lab(&l_2, &a_2, &b_2, &seed);
		fprintf(state->out_fp, state->format, l_1, a_1, b_1, l_2, a_2, b_2);
		const double delta_1 = ciede_2000_standard(l_1, a_1, b_1, l_2, a_2, b_2);
		const double delta_2 = ciede_2000_functional(l_2, a_2, b_2, l_1, a_1, b_1);
		assert(isfinite(delta_1) && isfinite(delta_2) && fabs(delta_1 - delta_2) < 1E-12);
		if (++i < number) {
			// Symmetry : the developed ciede_2000 functions must produce the same
			// result regardless of the order in which the two colors are provided.
			fprintf(state->out_fp, state->format, l_2, a_2, b_2, l_1, a_1, b_1);
		}
	}
	fprintf(state->out_fp, "%s", "100.0,0.005,-0.01,100.0,0.005,-0.01\n");
	fprintf(stderr, "Generated in %.2f s using seed %" PRIu64 ".\n", (double) (get_time_ms() - time_1) / 1000.0, state->params.seed);
}
#undef Precision

static void solve(state *state) {
	char s[2] = {0};
	const uint64_t time_1 = get_time_ms();
	const int p = state->params.precision, q = p < 0 ? 0 : 17 < p ? 17 : p;
	s[0] = (char) (state->params.delimiter ? DeltaE_default(*state->params.delimiter, ',') : ',');
	sprintf(state->format, "%s%%.%df\n", s, q);
	while (fgets(state->buf_1, sizeof(state->buf_1) / sizeof(*state->buf_1) - 1, state->in_fp)) {
		char *pos = strrchr(state->buf_1, '\n');
		*(pos - (pos != state->buf_1 && *(pos - 1) == '\r')) = 0;
		fprintf(state->out_fp, "%s", state->buf_1);
		const char *t_1 = strtok(state->buf_1, s), *t_2 = strtok(0, s), *t_3 = strtok(0, s);
		const char *t_4 = strtok(0, s), *t_5 = strtok(0, s), *t_6 = strtok(0, "\r\n");
		if (t_1 && t_2 && t_3 && t_4 && t_5 && t_6) {
			const double l_1 = strtod(t_1, 0), a_1 = strtod(t_2, 0), b_1 = strtod(t_3, 0);
			const double l_2 = strtod(t_4, 0), a_2 = strtod(t_5, 0), b_2 = strtod(t_6, 0);
			if (isfinite(l_1) && isfinite(a_1) && isfinite(b_1) && isfinite(l_2) && isfinite(a_2) && isfinite(b_2)) {
				const double delta_e = ciede_2000_standard(l_1, a_1, b_1, l_2, a_2, b_2);
				fprintf(state->out_fp, "%s%.17f\n", s, delta_e);
			} else
				fputc('\n', state->out_fp);
		} else
			fputc('\n', state->out_fp);
	}
	if (state->params.verbose)
		fprintf(stderr, "Solved in %.2f s.\n", (double) (get_time_ms() - time_1) / 1000.0);
}

static void control(state *state) {
	char s[2] = {0};
	uint64_t time_1 = 0;
	const double t = state->params.tolerance, tolerance = t < 0.0 ? 0.0 : 10.0 < t ? 10.0 : t;
	s[0] = (char) (state->params.delimiter ? DeltaE_default(*state->params.delimiter, ',') : ',');
	int do_copy = 1, n_lines = 0, n_errors = 0, n_successes = 0, errors_displayed = 0, has_new_error;
	double max_error = 0.0, sum_errors = 0.0, sum_delta_e = 0.0;
	while (fgets(state->buf_1, sizeof(state->buf_1) / sizeof(*state->buf_1) - 1, state->in_fp)) {
		++n_lines;
		if (do_copy)
			strcpy(state->buf_2, state->buf_1);
		const char *t_1 = strtok(state->buf_1, s), *t_2 = strtok(0, s), *t_3 = strtok(0, s);
		const char *t_4 = strtok(0, s), *t_5 = strtok(0, s), *t_6 = strtok(0, s), *t_7 = strtok(0, "\r\n");
		if (t_1 && t_2 && t_3 && t_4 && t_5 && t_6 && t_7) {
			const double l_1 = strtod(t_1, 0), a_1 = strtod(t_2, 0), b_1 = strtod(t_3, 0);
			const double l_2 = strtod(t_4, 0), a_2 = strtod(t_5, 0), b_2 = strtod(t_6, 0);
			const double delta_e = strtod(t_7, 0);
			if (isfinite(l_1) && isfinite(a_1) && isfinite(b_1) && isfinite(l_2) && isfinite(a_2) && isfinite(b_2) && isfinite(delta_e)) {
				const double expected_delta_e = ciede_2000_standard(l_1, a_1, b_1, l_2, a_2, b_2);
				const double error = fabs(expected_delta_e - delta_e);
				sum_delta_e += expected_delta_e;
				sum_errors += error;
				has_new_error = max_error < error;
				if (has_new_error)
					max_error = error;
				if (tolerance < error) {
					++n_errors;
					if (has_new_error && ++errors_displayed <= 5) {
						fprintf(stderr, "  Line %2d : L1=%.17g a1=%.17g b1=%.17g\n", n_lines, l_1, a_1, b_1);
						fprintf(stderr, "            L2=%.17g a2=%.17g b2=%.17g\n", l_2, a_2, b_2);
						fprintf(stderr, "Expecting : %.17f       Found deviation : %.17g\n", expected_delta_e, error);
						fprintf(stderr, "      Got : %.17f\n\n", delta_e);
					}
				} else
					++n_successes;
				if (do_copy) {
					do_copy = 0;
					time_1 = get_time_ms();
				}
			}
		}
	}
	if (n_successes || n_errors) {
		fprintf(state->out_fp, "CIEDE2000 Verification Summary :\n");
		fprintf(state->out_fp, "  First Verified Line : %s", state->buf_2);
		fprintf(state->out_fp, "             Duration : %.02f s\n", (double) (get_time_ms() - time_1) / 1000.0);
		fprintf(state->out_fp, "            Successes : %d\n", n_successes);
		fprintf(state->out_fp, "               Errors : %d\n", n_errors);
		fprintf(state->out_fp, "      Average Delta E : %.4f\n", sum_delta_e / (n_successes + n_errors));
		fprintf(state->out_fp, "    Average Deviation : %.1e\n", sum_errors / (n_successes + n_errors));
		fprintf(state->out_fp, "    Maximum Deviation : %.1e\n\n", max_error);
	} else
		fprintf(stderr, "No data to verify.\n");
}
#undef DeltaE_default

void print_help() {
	puts("           Name: Delta E 2000 Driver");
	puts("    Description: Generate, solve and control Color Difference");
	puts("");
	puts("     General options:");
	puts("       -d <char> or --delimiter to customize the field separator (default to comma)");
	puts("       -i <path> or --input-file to specify a file (default to stdin)");
	puts("       -o <path> or --outout-file to specify a file (default to stdout)");
	puts("");
	puts("     Options:");
	puts("       -g <count> or --generate to generate a dataset of Lab colors");
	puts("          -r <seed> or --rand-seed to customize the RNG seed");
	puts("       -s or --solve to solve a dataset by appending the Delta E 2000");
	puts("          -p <digits> or --precision to customize the display precision");
	puts("       -c or --control (default) to control a dataset");
	puts("          -t <decimal> or --tolerance to customize the tolerance (default to 1e-10)");
	puts("");
	puts(" GitHub Project: https://github.com/michel-leonard/ciede2000-color-matching");
	puts(" Release Date: March 1, 2025");
}

int main(int argc, const char *argv[]) {
	state state = {0};
	if (static_controls()) {
		state.params.tolerance = 1e-10;
		state.params.precision = 12;
		for (int i = 1; i < argc; ++i)
			if (!(i + 1 < argc && read_arg_2(argv + i, &state) && ++i))
				if (!read_arg_1(argv + i, &state))
					fprintf(stderr, "Delta E 2000: Unknown argument '%s'.\n", (state.code = 2, argv[i]));
		if (state.params.help)
			print_help();
		else if (state.code == 0) {
			open_descriptors(&state);
			if (state.code == 0) {
				if (state.params.generate)
					generate(&state);
				else if (state.params.mode == 's')
					solve(&state);
				else
					control(&state);
			}
			close_descriptors(&state);
		}
	} else
		state.code = 1;
	return state.code;
}

// Compilation is done with GCC or Clang :
// - gcc -Wall -Wextra -pedantic -Ofast -o driver ciede-2000-driver.c -lm
// - clang -Wall -Wextra -pedantic -Ofast -o driver ciede-2000-driver.c -lm
