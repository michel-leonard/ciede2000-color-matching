// This C++ program is released into the public domain.
// Provided "as is", without any warranty, express or implied.

#include "prelude.cpp"

/////////////////////////////////////////////////
////////                                 ////////
////////             CIEDE2000           ////////
////////          Precision Match        ////////
////////          in C99 and C++         ////////
////////                                 ////////
/////////////////////////////////////////////////

// This file serves as a precision validator between the C99 and C++ implementations
// of the CIE ΔE2000 algorithm. It is an integral part of the CI pipeline to ensure
// bit-level agreement across language boundaries, enabling safe reuse of the algorithm
// in cross-platform or cross-language contexts.

// This ensures bit-level precision consistency both in 32-bit and 64-bit environments.
// Project : https://github.com/michel-leonard/ciede2000-color-matching

#include <cmath>
#include <iostream>
#include <random>
#include <string>
#include <cstdlib>
#include <chrono>
#include <cinttypes>

int main(int argc, char *argv[]) {
	using clock = std::chrono::steady_clock;
	//
	const auto parsed_n_iterations = strtol(1 < argc ? argv[1] : "0", nullptr, 10);
	const auto n_iterations = parsed_n_iterations < 1000000L ? 1000000L : parsed_n_iterations, error_print_length = 1000L;
	//
	const auto parsed_seed = strtoull(2 < argc ? argv[2] : "0", nullptr, 10);
	const auto seed = static_cast<uint64_t>(parsed_seed ? parsed_seed : std::chrono::system_clock::to_time_t(std::chrono::system_clock::now()));
	std::mt19937 rng(seed);
	//
	const auto tolerance_initial = 2e-4;
	const auto tolerance_64_bits = 0.0;
	const auto tolerance_32_bits = 0.0f;
	auto max_deviation_64_bits = 0.0, avg_deviation_64_bits = 0.0;
	auto max_deviation_32_bits = 0.0f, avg_deviation_32_bits = 0.0f;
	long chars_printed = 0, n_err_ini = 0, n_err_64 = 0, n_err_32 = 0;

	std::fprintf(stdout, "======= Delta E 2000 Precision Test Suite =======\n");
	std::fprintf(stdout, "=================================================\n\n");
	std::fprintf(stdout, "Purpose       : Color precision test using Delta E 2000 on L*a*b* values\n");
	std::fprintf(stdout, "                - Validates 32-bit and 64-bit implementations (C++ and C99)\n\n");
	std::fprintf(stdout, "Domain        : Public domain development of a high-precision color difference algorithm\n");
	std::fprintf(stdout, "Color Source  : Generated from C++ Mersenne Twister PRNG (seed = %" PRIu64 ")\n", static_cast<unsigned long>(seed));
	std::fprintf(stdout, "Iterations    : %" PRId64 "\n\n", n_iterations);
	std::fprintf(stdout, "Algorithm     : State-of-the-art Delta E 2000\n");
	std::fprintf(stdout, "Library Ver.  : Initial public release\n\n");
	std::fprintf(stdout, "Tolerance (init)   : %.2e   (used for comparing float vs double)\n", tolerance_initial);
	std::fprintf(stdout, "Tolerance (float)  : %.2e       (C++ vs C99)\n", tolerance_32_bits);
	std::fprintf(stdout, "Tolerance (double) : %.2e       (C++ vs C99)\n\n", tolerance_64_bits);
	std::fprintf(stdout, "-- Test Results --\n\n");
	fflush(stdout);

	std::uniform_real_distribution<double> gen_1(0.0, 100.0);
	std::uniform_real_distribution<float> gen_2(0.0, 100.0);
	std::uniform_real_distribution<double> gen_3(-128.0, 127.0);
	std::uniform_real_distribution<float> gen_4(-128.0, 127.0);
	// ------------------------ //
	const auto t_1 = clock::now().time_since_epoch().count();
	{
		const long n_initial_iterations = n_iterations >> 5;
		float l_1 = gen_2(rng), a_1 = gen_4(rng), b_1 = gen_4(rng);
		// Small initial validation.
		for (long i = 0; i < n_initial_iterations && chars_printed < error_print_length; ++i) {
			const auto l_2 = gen_2(rng), a_2 = gen_4(rng), b_2 = gen_4(rng);
			const auto delta_1 = (double) ciede_2000_c_float(l_1, a_1, b_1, l_2, a_2, b_2);
			const auto delta_2 = (double) ciede_2000_cpp<float>(l_1, a_1, b_1, l_2, a_2, b_2);
			const auto delta_3 = ciede_2000_c_double(l_1, a_1, b_1, l_2, a_2, b_2);
			const auto delta_4 = ciede_2000_cpp<double>(l_1, a_1, b_1, l_2, a_2, b_2);
			const auto min = std::min(std::min(std::min(delta_1, delta_2), delta_3), delta_4);
			const auto max = std::max(std::max(std::max(delta_1, delta_2), delta_3), delta_4);
			const auto error = max - min;
			if (tolerance_initial < error) {
				++n_err_ini;
				chars_printed += std::fprintf(stderr, "Failed at index %" PRId64 " with a deviation of %.1e.\n", i, error);
				fflush(stderr);
			}
			l_1 = l_2, a_1 = a_2, b_1 = b_2;
		}
	}
	const auto t_2 = clock::now().time_since_epoch().count();
	if (n_err_ini) {
		std::fprintf(stderr, "Initial test failed in  %0.2f seconds\n", (double) (t_2 - t_1) / 1e9);
		fflush(stderr);
		return 1;
	}
	std::fprintf(stdout, "Initial test passed in  %0.2f seconds\n\n", (double) (t_2 - t_1) / 1e9);
	fflush(stdout);
	// ------------------------ //
	chars_printed = 0;
	const auto t_3 = clock::now().time_since_epoch().count();
	{
		// Test the 64 bits version.
		double l_1 = gen_1(rng), a_1 = gen_3(rng), b_1 = gen_3(rng);
		for (long i = 0; i < n_iterations; ++i) {
			const auto l_2 = gen_1(rng), a_2 = gen_3(rng), b_2 = gen_3(rng);
			const auto delta_1 = ciede_2000_c_double(l_1, a_1, b_1, l_2, a_2, b_2);
			const auto delta_2 = ciede_2000_cpp<double>(l_1, a_1, b_1, l_2, a_2, b_2);
			const auto deviation = delta_2 < delta_1 ? delta_1 - delta_2 : delta_2 - delta_1;
			avg_deviation_64_bits += deviation;
			if (max_deviation_64_bits < deviation)
				max_deviation_64_bits = deviation;
			if (tolerance_64_bits < deviation) {
				++n_err_64;
				if (chars_printed < error_print_length) {
					chars_printed += std::fprintf(stderr, "L1=%-18.12f a1=%-18.12f b1=%-18.12f\n", l_1, a_1, b_1);
					chars_printed += std::fprintf(stderr, "L2=%-18.12f a2=%-18.12f b2=%-18.12f\n", l_2, a_2, b_2);
					chars_printed += std::fprintf(stderr, "     Delta E in C99 : %-18.15f    (deviation: %.1e)\n", delta_1, deviation);
					chars_printed += std::fprintf(stderr, "     Delta E in C++ : %-18.15f\n\n", delta_2);
					fflush(stderr);
				}
			}
			l_1 = l_2, a_1 = a_2, b_1 = b_2;
		}
	}
	const auto t_4 = clock::now().time_since_epoch().count();
	std::fprintf(stdout, "64-bit \"double\" precision test %s in %.02f seconds\n", n_err_64 ? "failed" : "passed", (double) (t_4 - t_3) / 1e9);
	std::fprintf(stdout, "  - Avg deviation  : %.2e\n", avg_deviation_64_bits / (double) n_iterations);
	std::fprintf(stdout, "  - Max deviation  : %.2e\n", max_deviation_64_bits);
	std::fprintf(stdout, "  - Errors         : %" PRId64 "\n\n", n_err_64);
	fflush(stdout);
	// ------------------------ //
	chars_printed = 0;
	const auto t_5 = clock::now().time_since_epoch().count();
	{
		// Test the 32 bits version.
		float l_1 = gen_2(rng), a_1 = gen_4(rng), b_1 = gen_4(rng);
		for (long i = 0; i < n_iterations; ++i) {
			const auto l_2 = gen_2(rng), a_2 = gen_4(rng), b_2 = gen_4(rng);
			const auto delta_1 = ciede_2000_c_float(l_1, a_1, b_1, l_2, a_2, b_2);
			const auto delta_2 = ciede_2000_cpp<float>(l_1, a_1, b_1, l_2, a_2, b_2);
			const auto deviation = delta_2 < delta_1 ? delta_1 - delta_2 : delta_2 - delta_1;
			avg_deviation_32_bits += deviation;
			if (max_deviation_32_bits < deviation)
				max_deviation_32_bits = deviation;
			if (tolerance_32_bits < deviation) {
				++n_err_32;
				if (chars_printed < error_print_length) {
					chars_printed += std::fprintf(stderr, "L1=%-13.7f a1=%-13.7f b1=%-13.7f\n", l_1, a_1, b_1);
					chars_printed += std::fprintf(stderr, "L2=%-13.7f a2=%-13.7f b2=%-13.7f\n", l_2, a_2, b_2);
					chars_printed += std::fprintf(stderr, "Delta E in C99 : %-13.7f    (deviation: %.1e)\n", delta_1, deviation);
					chars_printed += std::fprintf(stderr, "Delta E in C++ : %-13.7f\n\n", delta_2);
					fflush(stderr);
				}
			}
			l_1 = l_2, a_1 = a_2, b_1 = b_2;
		}
	}
	const auto t_6 = clock::now().time_since_epoch().count();
	std::fprintf(stdout, "32-bit \"float\" precision test %s in %.02f seconds\n", n_err_32 ? "failed" : "passed", (double) (t_6 - t_5) / 1e9);
	std::fprintf(stdout, "  - Avg deviation  : %.2e\n", avg_deviation_32_bits / (float) n_iterations);
	std::fprintf(stdout, "  - Max deviation  : %.2e\n", max_deviation_32_bits);
	std::fprintf(stdout, "  - Errors         : %" PRId64 "\n\n", n_err_32);
	if (!n_err_32 && !n_err_64) {
		std::fprintf(stdout, "-- Performance Summary --\n\n");
		std::fprintf(stdout, "  - double (64-bit)           : %.02f M calls/sec\n", (double) n_iterations / (double) (t_4 - t_3) * 2e3);
		std::fprintf(stdout, "  - float (32-bit)            : %.02f M calls/sec\n", (double) n_iterations / (double) (t_6 - t_5) * 2e3);
		std::fprintf(stdout, "  - Speedup (float vs double) : %.02fx\n\n", (double) (t_4 - t_3) / (double) (t_6 - t_5));
		std::fprintf(stdout, "-- Conclusion --\n\n  - PASS : Both implementations (C++ and C99) correspond in 32-bit and 64-bit with zero tolerance\n");
	} else
		std::fprintf(stdout, "-- Conclusion --\n\n  - FAIL : Results diverge between C++ and C99 (see above)\n");
	return 0;
}

// In addition, this workflow :
// - Ensures that any deviation across 40+ implementations is reliably detected.
// - Catches regressions between the C99 and C++ implementations.
