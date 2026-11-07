// This function written in D is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

import std.traits;
import std.math;

///////////////////////////////////////////////////////////////////////////////////////////
//////                                                                               //////
//////                    Measured at 8,686,588 calls per second.                    //////
//////               💡 This function is up to 60% faster than 64-bit.               //////
//////                                                                               //////
//////          Using 32-bit numbers results in an almost always negligible          //////
//////             difference of ±0.0002 in the calculated Delta E 2000.             //////
//////                                                                               //////
///////////////////////////////////////////////////////////////////////////////////////////

// The generic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
// "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
F ciede_2000(F)(F l_1, F a_1, F b_1, F l_2, F a_2, F b_2) {
	// Working in D with the CIEDE2000 color-difference formula.
	// k_l, k_c, k_h are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	alias T = Unqual!F;
	enum T k_l = T(1.0);
	enum T k_c = T(1.0);
	enum T k_h = T(1.0);
	T n = (sqrt(a_1 * a_1 + b_1 * b_1) + sqrt(a_2 * a_2 + b_2 * b_2)) * T(0.5);
	n = n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = T(1.0) + T(0.5) * (T(1.0) - sqrt(n / (n + T(6103515625.0))));
	// Application of the chroma correction factor.
	const T c_1 = sqrt(a_1 * a_1 * n * n + b_1 * b_1);
	const T c_2 = sqrt(a_2 * a_2 * n * n + b_2 * b_2);
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	T h_1 = atan2(b_1, a_1 * n);
	T h_2 = atan2(b_2, a_2 * n);
	h_1 += (h_1 < T(0.0)) * T(2.0) * T(PI);
	h_2 += (h_2 < T(0.0)) * T(2.0) * T(PI);
	n = fabs(h_2 - h_1);
	// Cross-implementation consistent rounding.
	if (T(PI) - T(1E-14) < n && n < T(PI) + T(1E-14))
		n = T(PI);
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	T h_m = (h_1 + h_2) * T(0.5);
	T h_d = (h_2 - h_1) * T(0.5);
	h_d += (T(PI) < n) * T(PI);
	// 📜 Sharma’s formulation doesn’t use the next line, but the one after it,
	// and these two variants differ by ±0.0003 on the final color differences.
	h_m += (T(PI) < n) * T(PI);
	// h_m += (T(PI) < n) * ((h_m < T(PI)) - (T(PI) <= h_m)) * T(PI);
	const T p = T(36.0) * h_m - T(55.0) * T(PI);
	n = (c_1 + c_2) * T(0.5);
	n = n * n * n * n * n * n * n;
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	const T r_t = T(-2.0) * sqrt(n / (n + T(6103515625.0)))
			* sin(T(PI) / T(3.0) * exp(p * p / (T(-25.0) * T(PI) * T(PI))));
	n = (l_1 + l_2) * T(0.5);
	n = (n - T(50.0)) * (n - T(50.0));
	// Lightness.
	const T l = (l_2 - l_1) / (k_l * (T(1.0) + T(3.0) / T(200.0) * n / sqrt(T(20.0) + n)));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	const T t = T(1.0) 	+ T(6.0) / T(25.0) * sin(T(2.0) * h_m + T(PI) / T(2.0))
				+ T(8.0) / T(25.0) * sin(T(3.0) * h_m + T(8.0) * T(PI) / T(15.0))
				- T(17.0) / T(100.0) * sin(h_m + T(PI) / T(3.0))
				- T(1.0) / T(5.0) * sin(T(4.0) * h_m + T(3.0) * T(PI) / T(20.0));
	n = c_1 + c_2;
	// Hue.
	const T h = T(2.0) * sqrt(c_1 * c_2) * sin(h_d) / (k_h * (T(1.0) + T(3.0) / T(400.0) * n * t));
	// Chroma.
	const T c = (c_2 - c_1) / (k_c * (T(1.0) + T(9.0) / T(400.0) * n));
	// Returning the square root ensures that dE00 accurately reflects the
	// geometric distance in color space, which can range from 0 to around 185.
	return sqrt(l * l + h * h + c * c + c * h * r_t);
}

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//   Online Tests : https://michel-leonard.github.io/ciede2000-color-matching

// L1 = 52.5   a1 = 13.6   b1 = -3.0
// L2 = 50.4   a2 = 19.5   b2 = 5.3
// CIE ΔE00 = 7.1924418224 (Bruce Lindbloom, Netflix’s VMAF, ...)
// CIE ΔE00 = 7.1924561695 (Gaurav Sharma, OpenJDK, ...)
// Deviation between implementations ≈ 1.4e-5

// See the source code comments for easy switching between these two widely used ΔE*00 implementation variants.
