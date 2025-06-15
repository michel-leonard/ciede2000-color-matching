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

typedef uint64_t u64;

typedef struct {
	struct {
		u64 seed;
		u64 generate;
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

static inline u64 xor_random(u64 *s) {
	// A shift-register generator has a reproducible behavior across platforms.
	return *s ^= *s << 13, *s ^= *s >> 7, *s ^= *s << 17;
}

static inline double rand_color(const char type, u64 *s) {
	const u64 x = xor_random(s);
	double res ;
	if (type == 'L')
		res = x & 1 ? (double) (xor_random(s) % 100LLU) : x & 2 ? (double) (xor_random(s) % 1000LLU) / 10.0 : (double) (xor_random(s) % 10000LLU) / 100.0;
	else
		res = (x & 1 ? (double) (xor_random(s) % 255LLU) : x & 2 ? (double) (xor_random(s) % 2550LLU) / 10.0 : (double) (xor_random(s) % 25500LLU) / 100.0) - 128.0;
	return 28 == (x & 28) ? res + 3.0e-14 : 224 == (x & 224) ? res - 3.0e-14 : res ;
}

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

static u64 get_time_ms(void) {
	// returns the current Unix timestamp with milliseconds.
	struct timeval time;
	gettimeofday(&time, 0);
	return (u64) time.tv_sec * 1000 + (u64) time.tv_usec / 1000;
}
#define V "%.15g"
#define DeltaE_default(a, b) ((a) <= 0 ? (b) : (a))
static void generate(state *state) {
	const u64 time_1 = get_time_ms();
	if (state->params.seed == 0)
		state->params.seed = time_1;
	u64 seed = state->params.seed ^ 0x2236b69a7d223bd;
	const int number = (int)DeltaE_default(state->params.generate, 10);
	const char s = (char) (state->params.delimiter ? DeltaE_default(*state->params.delimiter, ',') : ',');
	sprintf(state->format, "%" V "%c%" V "%c%" V "%c%" V "%c%" V "%c%" V "\n", s, s, s, s, s);
	for (int i = 1; i < number; ++i) {
		const double l_1 = rand_color('L', &seed), l_2 = rand_color('L', &seed);
		const double a_1 = rand_color('a', &seed), a_2 = rand_color('a', &seed);
		const double b_1 = rand_color('b', &seed), b_2 = rand_color('b', &seed);
		fprintf(state->out_fp, state->format, l_1, a_1, b_1, l_2, a_2, b_2);
		const double delta_1 = ciede_2000(l_1, a_1, b_1, l_2, a_2, b_2);
		const double delta_2 = ciede_2000(l_2, a_2, b_2, l_1, a_1, b_1);
		assert(delta_1 == delta_2 && isfinite(delta_1));
		if (++i < number) {
			// Symmetry : the developed ciede_2000 functions must produce the same
			// result regardless of the order in which the two colors are provided.
			fprintf(state->out_fp, state->format, l_2, a_2, b_2, l_1, a_1, b_1);
		}
	}
	assert(ciede_2000(100.0, 0.005, -0.01, 100.0, 0.005, -0.01) == 0.0);
	fprintf(state->out_fp, "%s", "100.0,0.005,-0.01,100.0,0.005,-0.01\n");
	fprintf(stderr, "Generated in %.2f s using seed %" PRIu64 ".\n", (double) (get_time_ms() - time_1) / 1000.0, state->params.seed);
}

static void solve(state *state) {
	char s[2] = {0};
	const u64 time_1 = get_time_ms();
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
				const double delta_e = ciede_2000(l_1, a_1, b_1, l_2, a_2, b_2);
				fprintf(state->out_fp, "%s%.17f\n", s, delta_e);
			}
		}
	}
	if (state->params.verbose)
		fprintf(stderr, "Solved in %.2f s.\n", (double) (get_time_ms() - time_1) / 1000.0);
}

static void control(state *state) {
	char s[2] = {0};
	u64 time_1 = 0;
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
				const double expected_delta_e = ciede_2000(l_1, a_1, b_1, l_2, a_2, b_2);
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
	return state.code;
}

// Compilation is done with GCC or Clang :
// - gcc -Wall -Wextra -pedantic -Ofast -o driver ciede-2000-driver.c -lm
// - clang -Wall -Wextra -pedantic -Ofast -o driver ciede-2000-driver.c -lm
