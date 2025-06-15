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
	// returns the current Unix timestamp with milliseconds.
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

int main(int argc, char *argv[]) {
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
	printf("-------------------------------\n");
	printf("----   CIEDE2000 Summary   ----\n");
	printf("-------------------------------\n");
	printf("         Duration : %.02f s\n", (double) (get_time_ms() - t_1) / 1000.0);
	printf("       Iterations : %" PRIu64 "\n", n_iterations);
	printf("        Successes : %" PRIu64 "\n", n_successes);
	printf("           Errors : %" PRIu64 "\n", n_errors);
	printf("Average deviation : %.2e\n", average_deviation / (double) n_iterations);
	printf("Maximum deviation : %.2e\n", max_deviation);
	return 1E-10 < max_deviation;
}
