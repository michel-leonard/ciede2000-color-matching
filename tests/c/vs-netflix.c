// This C program is released into the public domain.
// Provided "as is", without any warranty, express or implied.

// © Michel Leonard 2025

///////////////////////////////////////////////
///////                                 ///////
///////           CIEDE 2000            ///////
///////     Validation and Testing      ///////
///////     Against Netflix's VMAF      ///////
///////                                 ///////
///////////////////////////////////////////////

// Project repository :
//   https://github.com/michel-leonard/ciede2000-color-matching

// Description :
//   This program validates two implementations of the CIEDE2000 color difference formula :
//   - ciede_2000 : A native implementation.
//   - ciede2000 : A reference implementation from Netflix's open-source VMAF.

// Purpose :
//   - Generate random L*a*b* color pairs.
//   - Compare ΔE2000 results from both implementations.
//   - Report numerical discrepancies, if any.
//   - Run predefined test cases (Rochester set) to verify accuracy against published ΔE values.

// Usage :
//   The number of iterations can be passed as a command-line argument.
//   Without arguments, defaults to 10,000 iterations.

// Exit codes :
//   - Returns 0 if all comparisons fall within acceptable tolerance (1e-10).
//   - Returns 1 otherwise.

// A GitHub Actions workflow automatically generates the prelude.c file.
// This file contains both ciede_2000 and ciede2000 definitions for comparison.

#include "prelude.c"

static inline double delta_e_netflix(const double l_1, const double a_1, const double b_1, const double l_2, const double a_2, const double b_2) {
	// Video Multi-Method Assessment Fusion developed by Netflix, one of the world's largest video content distributors.
	// VMAF is open source and has been widely adopted by YouTube, Meta, Amazon, Twitch...
	return ciede2000((struct LABColor) {l_1, a_1, b_1}, (struct LABColor) {l_2, a_2, b_2}, (struct KSubArgs) {1, 1, 1});
}

static inline double delta_e_michel(const double l_1, const double a_1, const double b_1, const double l_2, const double a_2, const double b_2) {
	return ciede_2000(l_1, a_1, b_1, l_2, a_2, b_2);
}

#include <sys/time.h>
#include <stdlib.h>
#include <stdio.h>
#include <inttypes.h>

uint64_t get_time_ms(void) {
	// returns the current Unix timestamp in milliseconds.
	struct timeval time;
	gettimeofday(&time, 0);
	return (uint64_t) time.tv_sec * 1000 + (uint64_t) time.tv_usec / 1000;
}

static inline uint64_t xor_random(uint64_t *s) {
	// A shift-register generator has a reproducible behavior across platforms.
	return *s ^= *s << 13, *s ^= *s >> 7, *s ^= *s << 17;
}

static inline double rand_color(const char type, uint64_t *seed) {
	if (type == 'L')
		return 100.0 * ((double) xor_random(seed) / 18446744073709551616.0);
	return 255.0 * ((double) xor_random(seed) / 18446744073709551616.0) - 127.0;
}

static void ensure_rochester(const double l_1, const double a_1, const double b_1, const double l_2, const double a_2, const double b_2, const double delta_e) {
	const double delta_e_1 = delta_e_michel(l_1, a_1, b_1, l_2, a_2, b_2);
	const double delta_e_2 = delta_e_netflix(l_1, a_1, b_1, l_2, a_2, b_2);
	if (1E-4 < fabs(delta_e_1 - delta_e) || 1E-4 < fabs(delta_e_2 - delta_e)) {
		fprintf(stderr, "Test failed: expected %.4f, got michel=%.4f, netflix=%.4f\n", delta_e, delta_e_1, delta_e_2);
		exit(1);
	}
}

int main(int argc, char *argv[]) {
	ensure_rochester(50.0, 2.6772, -79.7751, 50.0, 0.0, -82.7485, 2.0425);
	ensure_rochester(50.0, 3.1571, -77.2803, 50.0, 0.0, -82.7485, 2.8615);
	ensure_rochester(50.0, 2.8361, -74.02, 50.0, 0.0, -82.7485, 3.4412);
	ensure_rochester(50.0, -1.3802, -84.2814, 50.0, 0.0, -82.7485, 1.0);
	ensure_rochester(50.0, -1.1848, -84.8006, 50.0, 0.0, -82.7485, 1.0);
	ensure_rochester(50.0, -0.9009, -85.5211, 50.0, 0.0, -82.7485, 1.0);
	ensure_rochester(50.0, 0.0, 0.0, 50.0, -1.0, 2.0, 2.3669);
	ensure_rochester(50.0, -1.0, 2.0, 50.0, 0.0, 0.0, 2.3669);
	ensure_rochester(50.0, 2.49, -0.001, 50.0, -2.49, 0.0009, 7.1792);
	ensure_rochester(50.0, 2.49, -0.001, 50.0, -2.49, 0.001, 7.1792);
	ensure_rochester(50.0, 2.49, -0.001, 50.0, -2.49, 0.0011, 7.2195);
	ensure_rochester(50.0, 2.49, -0.001, 50.0, -2.49, 0.0012, 7.2195);
	ensure_rochester(50.0, -0.001, 2.49, 50.0, 0.0009, -2.49, 4.8045);
	ensure_rochester(50.0, -0.001, 2.49, 50.0, 0.001, -2.49, 4.8045);
	ensure_rochester(50.0, -0.001, 2.49, 50.0, 0.0011, -2.49, 4.7461);
	ensure_rochester(50.0, 2.5, 0.0, 50.0, 0.0, -2.5, 4.3065);
	ensure_rochester(50.0, 2.5, 0.0, 73.0, 25.0, -18.0, 27.1492);
	ensure_rochester(50.0, 2.5, 0.0, 61.0, -5.0, 29.0, 22.8977);
	ensure_rochester(50.0, 2.5, 0.0, 56.0, -27.0, -3.0, 31.903);
	ensure_rochester(50.0, 2.5, 0.0, 58.0, 24.0, 15.0, 19.4535);
	ensure_rochester(50.0, 2.5, 0.0, 50.0, 3.1736, 0.5854, 1.0);
	ensure_rochester(50.0, 2.5, 0.0, 50.0, 3.2972, 0.0, 1.0);
	ensure_rochester(50.0, 2.5, 0.0, 50.0, 1.8634, 0.5757, 1.0);
	ensure_rochester(50.0, 2.5, 0.0, 50.0, 3.2592, 0.335, 1.0);
	ensure_rochester(60.2574, -34.0099, 36.2677, 60.4626, -34.1751, 39.4387, 1.2644);
	ensure_rochester(63.0109, -31.0961, -5.8663, 62.8187, -29.7946, -4.0864, 1.263);
	ensure_rochester(61.2901, 3.7196, -5.3901, 61.4292, 2.248, -4.962, 1.8731);
	ensure_rochester(35.0831, -44.1164, 3.7933, 35.0232, -40.0716, 1.5901, 1.8645);
	ensure_rochester(22.7233, 20.0904, -46.694, 23.0331, 14.973, -42.5619, 2.0373);
	ensure_rochester(36.4612, 47.858, 18.3852, 36.2715, 50.5065, 21.2231, 1.4146);
	ensure_rochester(90.8027, -2.0831, 1.441, 91.1528, -1.6435, 0.0447, 1.4441);
	ensure_rochester(90.9257, -0.5406, -0.9208, 88.6381, -0.8985, -0.7239, 1.5381);
	ensure_rochester(6.7747, -0.2908, -2.4247, 5.8714, -0.0985, -2.2286, 0.6377);
	ensure_rochester(2.0776, 0.0795, -1.135, 0.9033, -0.0636, -0.5514, 0.9082);
	printf("Sharma's test vectors passed...\n");
	//
	printf("CIEDE2000 Validator...\n");
	printf("Comparing Michel's implementation vs Netflix VMAF...\n");
	uint64_t seed = 0xc6a4a7935bd1e995ULL ^ get_time_ms();
	uint64_t n_iterations = 1 < argc ? strtoull(argv[1], 0, 10) : 10000;
	if (n_iterations < 1)
		n_iterations = 10000;
	uint64_t n_errors = 0;
	uint64_t n_successes = 0;
	uint64_t n_print_error = 0;
	uint64_t t_1 = get_time_ms();
	double max_deviation = 0.0, average_deviation = 0.0;
	for (uint64_t i = 0; i < n_iterations; ++i) {
		const double l_1 = rand_color('L', &seed);
		const double a_1 = rand_color('a', &seed);
		const double b_1 = rand_color('b', &seed);
		const double l_2 = rand_color('L', &seed);
		const double a_2 = rand_color('a', &seed);
		const double b_2 = rand_color('b', &seed);
		const double delta_e_1 = delta_e_michel(l_1, a_1, b_1, l_2, a_2, b_2);
		const double delta_e_2 = delta_e_netflix(l_1, a_1, b_1, l_2, a_2, b_2);
		const double deviation = fabs(delta_e_2 - delta_e_1);
		average_deviation += deviation;
		if (max_deviation < deviation)
			max_deviation = deviation;
		if (1E-10 < deviation) {
			++n_errors;
			if (++n_print_error <= 10) {
				fprintf(stderr, "ciede_2000(%.17f, %.17f, %.17f, %.17f, %.17f, %.17f)\n", l_1, a_1, b_1, l_2, a_2, b_2);
				fprintf(stderr, " Delta E by Michel : %.17f         Found deviation : %.2e\n", delta_e_1, deviation);
				fprintf(stderr, "Delta E by Netflix : %.17f\n\n", delta_e_2);
			}
		} else
			++n_successes;
	}
	printf("====================================\n");
	printf("       CIEDE2000 Comparison\n");
	printf("====================================\n");
	printf("Total duration        : %.02f seconds\n", (double) (get_time_ms() - t_1) / 1000.0);
	printf("Iterations run        : %" PRIu64 "\n", n_iterations);
	printf("Successful matches    : %" PRIu64 "\n", n_successes);
	printf("Discrepancies found   : %" PRIu64 "\n", n_errors);
	printf("Avg Delta E deviation : %.2e\n", average_deviation / (double) n_iterations);
	printf("Max Delta E deviation : %.2e\n", max_deviation);
	printf("====================================\n");
	if (n_print_error > 0)
		fprintf(stderr, "Note: only the first 10 error(s) are printed.\n");
	return 1E-10 < max_deviation;
}
