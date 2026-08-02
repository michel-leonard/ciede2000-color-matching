// This function written in C++ is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

#include <cmath>

// The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
// "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
template<typename T>
constexpr T ciede_2000(const T l1, const T a1, const T b1, const T l2, const T a2, const T b2, const T kl = T(1.0), const T kc = T(1.0), const T kh = T(1.0), const bool canonical = false) {
	// Working in C++ with the CIEDE2000 color-difference formula.
	// kl, kc, kh are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...

	constexpr T pi_1 = T(3.141592653589793238462643383279502884);
	constexpr T pi_3 = pi_1 / T(3.0);

	// 1. Compute chroma magnitudes ... a and b usually range from -128 to +127
	const T a1_sq = a1 * a1;
	const T b1_sq = b1 * b1;
	const T c1_orig = std::sqrt(a1_sq + b1_sq);

	const T a2_sq = a2 * a2;
	const T b2_sq = b2 * b2;
	const T c2_orig = std::sqrt(a2_sq + b2_sq);

	// 2. Compute chroma mean and apply G compensation
	const T c_avg = T(0.5) * (c1_orig + c2_orig);
	const T c_avg_3 = c_avg * c_avg * c_avg;
	const T c_avg_7 = c_avg_3 * c_avg_3 * c_avg;
	const T g_denom = c_avg_7 + T(6103515625.0);
	const T g_ratio = c_avg_7 / g_denom;
	const T g_sqrt = std::sqrt(g_ratio);
	const T g_factor = T(1.0) + T(0.5) * (T(1.0) - g_sqrt);

	// 3. Apply G correction to a components, compute corrected chroma
	const T a1_prime = a1 * g_factor;
	const T c1_prime_sq = a1_prime * a1_prime + b1 * b1;
	const T c1_prime = std::sqrt(c1_prime_sq);
	const T a2_prime = a2 * g_factor;
	const T c2_prime_sq = a2_prime * a2_prime + b2 * b2;
	const T c2_prime = std::sqrt(c2_prime_sq);

	// 4. Compute hue angles in radians, adjust for negatives and wrap
	const T h1_raw = std::atan2(b1, a1_prime);
	const T h2_raw = std::atan2(b2, a2_prime);
	const T h1_adj = h1_raw + T(h1_raw < T(0.0)) * T(2.0) * pi_1;
	const T h2_adj = h2_raw + T(h2_raw < T(0.0)) * T(2.0) * pi_1;
	const T delta_h = std::fabs(h1_adj - h2_adj);
	const T h_mean_raw = T(0.5) * (h1_adj + h2_adj);
	const T h_diff_raw = T(0.5) * (h2_adj - h1_adj);

	constexpr T epsilon = T(sizeof(T) == sizeof(float) ? 1E-6 : 1E-14);

	// Check if hue mean wraps around pi (180 deg)
	const T hue_wrap = T(pi_1 + epsilon < delta_h);

	// The part where most programmers get it wrong
	const T h_mean = h_mean_raw - T(canonical && pi_1 + epsilon < h_mean_raw ?
		1.0 : // canonical=true acts like Gaurav Sharma, OpenJDK, ...
		-1.0 // canonical=false acts like Bruce Lindbloom, Netflix’s VMAF, ...
	) * hue_wrap * pi_1;

	// Michel Leonard 2026 - When mean wraps, difference wraps too
	const T h_diff = h_diff_raw + hue_wrap * pi_1;

	// 5. Compute hue rotation correction factor R_T
	const T c_bar = T(0.5) * (c1_prime + c2_prime);
	const T c_bar_3 = c_bar * c_bar * c_bar;
	const T c_bar_7 = c_bar_3 * c_bar_3 * c_bar;
	const T rc_denom = c_bar_7 + T(6103515625.0);
	const T R_C = std::sqrt(c_bar_7 / rc_denom);

	const T theta = T(36.0) * h_mean - T(55.0) * pi_1;
	const T theta_denom = T(-25.0) * pi_1 * pi_1;
	const T exp_argument = theta * theta / theta_denom;
	const T exp_term = std::exp(exp_argument);
	const T delta_theta = pi_3 * exp_term;
	const T sin_term = std::sin(delta_theta);

	// Rotation factor ... cross-effect between chroma and hue
	const T R_T = T(-2.0) * R_C * sin_term;

	// 6. Compute lightness term ... L nominally ranges from 0 to 100
	const T l_avg = T(0.5) * (l1 + l2);
	const T l_delta_sq = (l_avg - T(50.0)) * (l_avg - T(50.0));
	const T l_delta = l2 - l1;

	// Adaptation to the non-linearity of light perception ... S_L
	const T sl_num = T(3.0) / T(200.0) * l_delta_sq;
	const T sl_denom = std::sqrt(T(20.0) + l_delta_sq);
	const T S_L = T(1.0) + sl_num / sl_denom;
	const T L_term = l_delta / (kl * S_L);

	// 7. Compute chroma-related trig terms and factor T
	const T trig_1 = T(17.0) / T(100.0) * std::sin(h_mean + pi_3);
	const T trig_2 = T(6.0) / T(25.0) * std::sin(T(2.0) * h_mean + T(0.5) * pi_1);
	const T trig_3 = T(8.0) / T(25.0) * std::sin(T(3.0) * h_mean + T(8.0) / T(5.0) * pi_3);
	const T trig_4 = T(1.0) / T(5.0) * std::sin(T(4.0) * h_mean + T(3.0) / T(20.0) * pi_1);
	const T trig = T(1.0) - trig_1 + trig_2 + trig_3 - trig_4;

	const T c_sum = c1_prime + c2_prime;
	const T c_product = c1_prime * c2_prime;
	const T c_geo_mean = std::sqrt(c_product);

	// 8. Compute hue difference and scaling factor S_H
	const T sin_h_diff = std::sin(h_diff);
	const T S_H = T(1.0) + T(3.0) / T(400.0) * c_sum * trig;
	const T H_term = T(2.0) * c_geo_mean * sin_h_diff / (kh * S_H);

	// 9. Compute chroma difference and scaling factor S_C
	const T c_delta = c2_prime - c1_prime;
	const T S_C = T(1.0) + T(9.0) / T(400.0) * c_sum;
	const T C_term = c_delta / (kc * S_C);

	// 10. Combine lightness, chroma, hue, and interaction terms
	const T L_part = L_term * L_term;
	const T C_part = C_term * C_term;
	const T H_part = H_term * H_term;
	const T interaction = C_term * H_term * R_T;
	const T delta_e_squared = L_part + C_part + H_part + interaction;
	const T delta_e = std::sqrt(delta_e_squared);

	// The result reflects the actual geometric distance in the color space.
	// Given a tolerance of 0.00015 in 32 bits.
	// Given a tolerance of 3.4e-13 in 64 bits.
	return delta_e;
}

// If you remove the constants 1E-6 and 1E-14, the code will continue to work, but CIEDE2000
// interoperability between all programming languages will no longer be guaranteed.

// Source code tested by Michel LEONARD
// Website: github.com/michel-leonard/ciede2000-cpp

int main() {
	// These tests were successfully run in C++26 using GCC version 16.
	static_assert(std::fabs(ciede_2000(95.3, 58.8, 2.1, 95.7, 61.9, -1.7, 1.0, 1.0, 1.0, false) - 1.94085923041943820907) < 1E-12);
	static_assert(std::fabs(ciede_2000(95.3, 58.8, 2.1, 95.7, 61.9, -1.7, 1.0, 1.0, 1.0, true) - 1.94085227194482418169) < 1E-12);
	static_assert(std::fabs(ciede_2000(78.7, 65.2, -2.9, 77.5, 60.7, 2.8, 1.0, 1.0, 1.0, false) - 2.91989529567114087822) < 1E-12);
	static_assert(std::fabs(ciede_2000(78.7, 65.2, -2.9, 77.5, 60.7, 2.8, 1.0, 1.0, 1.0, true) - 2.91988525261658605311) < 1E-12);
	static_assert(std::fabs(ciede_2000(88.3, 126.1, -1.7, 89.3, 109.1, 4.6, 1.0, 1.0, 0.9, false) - 3.52575069135331917409) < 1E-12);
	static_assert(std::fabs(ciede_2000(88.3, 126.1, -1.7, 89.3, 109.1, 4.6, 1.0, 1.0, 0.9, true) - 3.52573735080764876312) < 1E-12);
	static_assert(std::fabs(ciede_2000(76.8, 103.9, 6.6, 73.6, 116.1, -3.9, 1.0, 1.0, 0.9, false) - 4.85910095282673306855) < 1E-12);
	static_assert(std::fabs(ciede_2000(76.8, 103.9, 6.6, 73.6, 116.1, -3.9, 1.0, 1.0, 0.9, true) - 4.85908859516939575581) < 1E-12);
	static_assert(std::fabs(ciede_2000(79.5, 66.7, 4.6, 76.1, 81.8, -5.0, 1.0, 0.9, 1.1, false) - 5.76099150475162379453) < 1E-12);
	static_assert(std::fabs(ciede_2000(79.5, 66.7, 4.6, 76.1, 81.8, -5.0, 1.0, 0.9, 1.1, true) - 5.76096924936866172022) < 1E-12);
	static_assert(std::fabs(ciede_2000(59.2, 71.8, 5.1, 58.6, 94.1, -4.7, 1.0, 0.9, 1.1, false) - 6.26446979481597228780) < 1E-12);
	static_assert(std::fabs(ciede_2000(59.2, 71.8, 5.1, 58.6, 94.1, -4.7, 1.0, 0.9, 1.1, true) - 6.26444558597530434010) < 1E-12);
	static_assert(std::fabs(ciede_2000(20.5, 119.1, 8.1, 19.4, 96.5, -6.4, 1.0, 0.9, 1.0, false) - 6.33145635344967449655) < 1E-12);
	static_assert(std::fabs(ciede_2000(20.5, 119.1, 8.1, 19.4, 96.5, -6.4, 1.0, 0.9, 1.0, true) - 6.33148705084895521235) < 1E-12);
	static_assert(std::fabs(ciede_2000(29.6, 72.9, 7.1, 33.3, 113.4, -5.1, 1.0, 1.1, 1.1, false) - 8.68695997741328123613) < 1E-12);
	static_assert(std::fabs(ciede_2000(29.6, 72.9, 7.1, 33.3, 113.4, -5.1, 1.0, 1.1, 1.1, true) - 8.68693753419288109384) < 1E-12);
	static_assert(std::fabs(ciede_2000(86.3, 88.0, -4.8, 78.7, 118.6, 7.4, 1.0, 0.9, 1.0, false) - 8.83363506762574415824) < 1E-12);
	static_assert(std::fabs(ciede_2000(86.3, 88.0, -4.8, 78.7, 118.6, 7.4, 1.0, 0.9, 1.0, true) - 8.83366024958667014071) < 1E-12);
	static_assert(std::fabs(ciede_2000(98.8, 71.4, 6.4, 93.9, 43.4, -3.3, 1.0, 1.1, 0.9, false) - 9.06652292034467328084) < 1E-12);
	static_assert(std::fabs(ciede_2000(98.8, 71.4, 6.4, 93.9, 43.4, -3.3, 1.0, 1.1, 0.9, true) - 9.06655677652780030117) < 1E-12);
	static_assert(std::fabs(ciede_2000(2.2, 97.5, -8.4, 7.0, 73.3, 10.5, 1.0, 1.1, 0.9, false) - 9.64943880051260659224) < 1E-12);
	static_assert(std::fabs(ciede_2000(2.2, 97.5, -8.4, 7.0, 73.3, 10.5, 1.0, 1.1, 0.9, true) - 9.64941494316372210575) < 1E-12);
	static_assert(std::fabs(ciede_2000(43.8, 57.1, -5.2, 44.1, 91.2, 13.8, 1.0, 1.1, 1.1, false) - 9.74596427375642726535) < 1E-12);
	static_assert(std::fabs(ciede_2000(43.8, 57.1, -5.2, 44.1, 91.2, 13.8, 1.0, 1.1, 1.1, true) - 9.74599456055264884188) < 1E-12);
	static_assert(std::fabs(ciede_2000(87.5, 94.2, -12.5, 85.5, 71.4, 14.8, 1.0, 1.1, 1.0, false) - 11.50838166559227916653) < 1E-12);
	static_assert(std::fabs(ciede_2000(87.5, 94.2, -12.5, 85.5, 71.4, 14.8, 1.0, 1.1, 1.0, true) - 11.50835974496583671561) < 1E-12);
	static_assert(std::fabs(ciede_2000(6.5, 54.8, -3.2, 14.5, 99.9, 6.0, 0.9, 1.0, 1.0, false) - 12.02882579429005156853) < 1E-12);
	static_assert(std::fabs(ciede_2000(6.5, 54.8, -3.2, 14.5, 99.9, 6.0, 0.9, 1.0, 1.0, true) - 12.02885434991815202119) < 1E-12);
	static_assert(std::fabs(ciede_2000(49.3, 115.6, 15.8, 55.5, 68.6, -3.7, 0.9, 1.0, 1.0, false) - 13.00482889762819009845) < 1E-12);
	static_assert(std::fabs(ciede_2000(49.3, 115.6, 15.8, 55.5, 68.6, -3.7, 0.9, 1.0, 1.0, true) - 13.00485163892002509853) < 1E-12);
	static_assert(std::fabs(ciede_2000(93.9, 125.4, -7.6, 98.1, 60.4, 3.9, 0.9, 1.0, 0.9, false) - 13.53732246206312746009) < 1E-12);
	static_assert(std::fabs(ciede_2000(93.9, 125.4, -7.6, 98.1, 60.4, 3.9, 0.9, 1.0, 0.9, true) - 13.53728420335438970854) < 1E-12);
	static_assert(std::fabs(ciede_2000(51.2, 48.7, 12.3, 47.1, 68.3, -15.2, 0.9, 0.9, 1.1, false) - 13.65210535595789555755) < 1E-12);
	static_assert(std::fabs(ciede_2000(51.2, 48.7, 12.3, 47.1, 68.3, -15.2, 0.9, 0.9, 1.1, true) - 13.65206573841337269448) < 1E-12);
	static_assert(std::fabs(ciede_2000(75.4, 72.4, 14.1, 66.1, 42.7, -7.6, 0.9, 0.9, 1.1, false) - 15.01858617580990805048) < 1E-12);
	static_assert(std::fabs(ciede_2000(75.4, 72.4, 14.1, 66.1, 42.7, -7.6, 0.9, 0.9, 1.1, true) - 15.01863373764194466828) < 1E-12);
	static_assert(std::fabs(ciede_2000(92.0, 83.5, -17.2, 94.0, 55.0, 12.5, 0.9, 1.0, 0.9, false) - 15.33433138237918558308) < 1E-12);
	static_assert(std::fabs(ciede_2000(92.0, 83.5, -17.2, 94.0, 55.0, 12.5, 0.9, 1.0, 0.9, true) - 15.33427919695440244764) < 1E-12);
	static_assert(std::fabs(ciede_2000(2.6, 47.0, -7.3, 5.8, 117.6, 19.6, 0.9, 1.1, 1.1, false) - 16.12496252255085502475) < 1E-12);
	static_assert(std::fabs(ciede_2000(2.6, 47.0, -7.3, 5.8, 117.6, 19.6, 0.9, 1.1, 1.1, true) - 16.12502659883752889818) < 1E-12);
	static_assert(std::fabs(ciede_2000(47.7, 24.9, -10.5, 42.7, 38.4, 16.9, 0.9, 1.1, 1.1, false) - 16.16188451930645718378) < 1E-12);
	static_assert(std::fabs(ciede_2000(47.7, 24.9, -10.5, 42.7, 38.4, 16.9, 0.9, 1.1, 1.1, true) - 16.16192477450090184896) < 1E-12);
	static_assert(std::fabs(ciede_2000(73.9, 58.9, -10.7, 78.8, 99.1, 26.0, 0.9, 0.9, 1.0, false) - 17.13706181605960745840) < 1E-12);
	static_assert(std::fabs(ciede_2000(73.9, 58.9, -10.7, 78.8, 99.1, 26.0, 0.9, 0.9, 1.0, true) - 17.13710455668721354362) < 1E-12);
	static_assert(std::fabs(ciede_2000(17.0, 103.1, 17.5, 6.2, 47.2, -7.2, 0.9, 1.1, 0.9, false) - 17.15502364533678697347) < 1E-12);
	static_assert(std::fabs(ciede_2000(17.0, 103.1, 17.5, 6.2, 47.2, -7.2, 0.9, 1.1, 0.9, true) - 17.15508320784189811337) < 1E-12);
	static_assert(std::fabs(ciede_2000(61.3, 65.6, 14.8, 73.3, 89.2, -18.8, 0.9, 0.9, 1.0, false) - 17.81338636557549685611) < 1E-12);
	static_assert(std::fabs(ciede_2000(61.3, 65.6, 14.8, 73.3, 89.2, -18.8, 0.9, 0.9, 1.0, true) - 17.81334827962618422763) < 1E-12);
	static_assert(std::fabs(ciede_2000(24.1, 31.9, 11.3, 26.1, 76.3, -17.3, 0.9, 1.1, 1.0, false) - 18.06284088259899451733) < 1E-12);
	static_assert(std::fabs(ciede_2000(24.1, 31.9, 11.3, 26.1, 76.3, -17.3, 0.9, 1.1, 1.0, true) - 18.06280635743619223791) < 1E-12);
	static_assert(std::fabs(ciede_2000(76.6, 42.5, 18.7, 73.1, 25.0, -9.2, 0.9, 1.1, 0.9, false) - 18.56371424691992320981) < 1E-12);
	static_assert(std::fabs(ciede_2000(76.6, 42.5, 18.7, 73.1, 25.0, -9.2, 0.9, 1.1, 0.9, true) - 18.56375175757327048081) < 1E-12);
	static_assert(std::fabs(ciede_2000(58.4, 53.4, 17.4, 73.6, 84.8, -24.6, 1.1, 0.9, 1.1, false) - 20.97701098095782588640) < 1E-12);
	static_assert(std::fabs(ciede_2000(58.4, 53.4, 17.4, 73.6, 84.8, -24.6, 1.1, 0.9, 1.1, true) - 20.97696265633271514383) < 1E-12);
	static_assert(std::fabs(ciede_2000(34.3, 51.7, -16.4, 37.9, 95.8, 32.8, 1.1, 1.0, 1.0, false) - 21.30472695141261612657) < 1E-12);
	static_assert(std::fabs(ciede_2000(34.3, 51.7, -16.4, 37.9, 95.8, 32.8, 1.1, 1.0, 1.0, true) - 21.30480230097303868981) < 1E-12);
	static_assert(std::fabs(ciede_2000(11.8, 33.3, 9.9, 15.6, 98.7, -24.7, 1.1, 1.0, 1.0, false) - 21.38255904461508639978) < 1E-12);
	static_assert(std::fabs(ciede_2000(11.8, 33.3, 9.9, 15.6, 98.7, -24.7, 1.1, 1.0, 1.0, true) - 21.38248563461511850021) < 1E-12);
	static_assert(std::fabs(ciede_2000(38.3, 112.8, -19.9, 28.7, 35.1, 6.4, 1.1, 1.0, 0.9, false) - 21.81150150951723601095) < 1E-12);
	static_assert(std::fabs(ciede_2000(38.3, 112.8, -19.9, 28.7, 35.1, 6.4, 1.1, 1.0, 0.9, true) - 21.81142191433416683199) < 1E-12);
	static_assert(std::fabs(ciede_2000(31.0, 40.0, -10.5, 19.9, 95.1, 32.7, 1.1, 0.9, 1.1, false) - 22.51208149151830503368) < 1E-12);
	static_assert(std::fabs(ciede_2000(31.0, 40.0, -10.5, 19.9, 95.1, 32.7, 1.1, 0.9, 1.1, true) - 22.51213697394075791030) < 1E-12);
	static_assert(std::fabs(ciede_2000(65.1, 119.6, 34.0, 52.8, 75.5, -20.6, 1.1, 1.0, 0.9, false) - 23.51896200161117138039) < 1E-12);
	static_assert(std::fabs(ciede_2000(65.1, 119.6, 34.0, 52.8, 75.5, -20.6, 1.1, 1.0, 0.9, true) - 23.51902558300420726187) < 1E-12);
	static_assert(std::fabs(ciede_2000(71.7, 117.3, -41.7, 67.4, 64.9, 23.1, 1.1, 0.9, 1.0, false) - 24.41586908953993753146) < 1E-12);
	static_assert(std::fabs(ciede_2000(71.7, 117.3, -41.7, 67.4, 64.9, 23.1, 1.1, 0.9, 1.0, true) - 24.41576877980548038990) < 1E-12);
	static_assert(std::fabs(ciede_2000(20.1, 23.4, -6.6, 12.8, 83.4, 31.1, 1.1, 0.9, 1.0, false) - 24.92218272063192672329) < 1E-12);
	static_assert(std::fabs(ciede_2000(20.1, 23.4, -6.6, 12.8, 83.4, 31.1, 1.1, 0.9, 1.0, true) - 24.92224139197610431656) < 1E-12);
	static_assert(std::fabs(ciede_2000(40.1, 15.7, 8.6, 49.8, 72.6, -34.6, 1.1, 1.1, 1.1, false) - 25.32169561894007569524) < 1E-12);
	static_assert(std::fabs(ciede_2000(40.1, 15.7, 8.6, 49.8, 72.6, -34.6, 1.1, 1.1, 1.1, true) - 25.32162387362604456976) < 1E-12);
	static_assert(std::fabs(ciede_2000(74.4, 33.6, 14.7, 89.2, 99.4, -43.2, 1.1, 1.1, 1.1, false) - 25.90852187537030209305) < 1E-12);
	static_assert(std::fabs(ciede_2000(74.4, 33.6, 14.7, 89.2, 99.4, -43.2, 1.1, 1.1, 1.1, true) - 25.90841306621602456028) < 1E-12);
	static_assert(std::fabs(ciede_2000(37.2, 118.5, 36.4, 22.4, 32.1, -9.4, 1.1, 1.1, 0.9, false) - 26.37618409498421573915) < 1E-12);
	static_assert(std::fabs(ciede_2000(37.2, 118.5, 36.4, 22.4, 32.1, -9.4, 1.1, 1.1, 0.9, true) - 26.37628386184765567677) < 1E-12);
	static_assert(std::fabs(ciede_2000(44.5, 112.5, 44.0, 50.3, 28.9, -9.4, 1.1, 1.1, 0.9, false) - 26.71479772759133226984) < 1E-12);
	static_assert(std::fabs(ciede_2000(44.5, 112.5, 44.0, 50.3, 28.9, -9.4, 1.1, 1.1, 0.9, true) - 26.71487885694120816828) < 1E-12);
	static_assert(std::fabs(ciede_2000(89.0, 122.1, 53.2, 70.3, 90.0, -33.1, 1.1, 1.1, 1.0, false) - 29.19969941395083530767) < 1E-12);
	static_assert(std::fabs(ciede_2000(89.0, 122.1, 53.2, 70.3, 90.0, -33.1, 1.1, 1.1, 1.0, true) - 29.19973049970667885284) < 1E-12);
	static_assert(std::fabs(ciede_2000(24.6, 0.0, 0.0, 71.4, 0.0, 0.0, 1.1, 1.1, 1.0, false) - 42.0306858757802182373009) < 1E-12);
	static_assert(std::fabs(ciede_2000(24.6, 0.0, 0.0, 71.4, 0.0, 0.0, 1.1, 1.1, 1.0, true) - 42.0306858757802182373009) < 1E-12);
}
