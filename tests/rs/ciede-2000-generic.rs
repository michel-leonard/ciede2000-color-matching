// This function written in Rust is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

use num_traits::Float;

///////////////////////////////////////////////////////////////////////////////////////////
//////                                                                               //////
//////                    Measured at 8,296,192 calls per second.                    //////
//////              💡 The 32-bit function is up to 40% faster than 64-bit.          //////
//////                                                                               //////
//////          Using 32-bit numbers results in an almost always negligible          //////
//////             difference of ±0.0002 in the calculated Delta E 2000.             //////
//////                                                                               //////
///////////////////////////////////////////////////////////////////////////////////////////

// The generic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
// "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
fn ciede_2000<T: Float>(l_1: T, a_1: T, b_1: T, l_2: T, a_2: T, b_2: T) -> T {
	// Working in Rust with the CIEDE2000 color-difference formula.
	// k_l, k_c, k_h are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	let k_l = T::from(1.0).unwrap();
	let k_c = T::from(1.0).unwrap();
	let k_h = T::from(1.0).unwrap();
	// Gets an accurate pi value up to 64 bits.
	let pi = T::from(std::f64::consts::PI).unwrap();
	let mut n = ((a_1 * a_1 + b_1 * b_1).sqrt() + (a_2 * a_2 + b_2 * b_2).sqrt()) * T::from(0.5).unwrap();
	n = n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = T::one() + T::from(0.5).unwrap() * (T::one()
			- (n / (n + T::from(6103515625.0).unwrap())).sqrt());
	// Application of the chroma correction factor.
	let c_1: T = (a_1 * a_1 * n * n + b_1 * b_1).sqrt();
	let c_2: T = (a_2 * a_2 * n * n + b_2 * b_2).sqrt();
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	let mut h_1 = b_1.atan2(a_1 * n);
	let mut h_2 = b_2.atan2(a_2 * n);
	if h_1 < T::zero() { h_1 = h_1 + pi + pi; }
	if h_2 < T::zero() { h_2 = h_2 + pi + pi; }
	n = (h_2 - h_1).abs();
	// Consistent rounding between 64-bit implementations, ignored in 32-bit.
	 if (pi - T::from(1e-14).unwrap()..=pi + T::from(1e-14).unwrap()).contains(&n) { n = pi; }
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	let mut h_m = (h_1 + h_2) * T::from(0.5).unwrap();
	let mut h_d = (h_2 - h_1) * T::from(0.5).unwrap();
	if pi < n {
		h_d = h_d + pi;
		// 📜 Sharma’s formulation doesn’t use the next line, but the one after it,
		// and these two variants differ by ±0.0003 on the final color differences.
		h_m = h_m + pi;
		// if h_m < pi { h_m = h_m + pi; } else { h_m = h_m - pi; }
	}
	let p = T::from(36.0).unwrap() * h_m - T::from(55.0).unwrap() * pi;
	n = (c_1 + c_2) * T::from(0.5).unwrap();
	n = n * n * n * n * n * n * n;
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	let r_t = -T::from(2.0).unwrap() * (n / (n + T::from(6103515625.0).unwrap())).sqrt()
		* (pi / T::from(3.0).unwrap() * (p * p / (-T::from(25.0).unwrap() * pi * pi)).exp()).sin();
	n = (l_1 + l_2) * T::from(0.5).unwrap();
	n = (n - T::from(50.0).unwrap()) * (n - T::from(50.0).unwrap());
	// Lightness.
	let l = (l_2 - l_1) / (k_l * (T::one() + T::from(3.0).unwrap() / T::from(200.0).unwrap()
		* n / (T::from(20.0).unwrap() + n).sqrt()));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	let t = T::one()
		+ T::from(6.0).unwrap() / T::from(25.0).unwrap()
			* (T::from(2.0).unwrap() * h_m + pi * T::from(0.5).unwrap()).sin()
		+ T::from(8.0).unwrap() / T::from(25.0).unwrap()
			* (T::from(3.0).unwrap() * h_m + T::from(8.0).unwrap() * pi / T::from(15.0).unwrap()).sin()
		- T::from(17.0).unwrap() / T::from(100.0).unwrap()
			* (h_m + pi / T::from(3.0).unwrap()).sin()
		- T::from(1.0).unwrap() / T::from(5.0).unwrap()
			* (T::from(4.0).unwrap() * h_m + T::from(3.0).unwrap() * pi / T::from(20.0).unwrap()).sin();
	n = c_1 + c_2;
	// Hue.
	let h = T::from(2.0).unwrap() * (c_1 * c_2).sqrt()
		* (h_d).sin() / (k_h * (T::one() + T::from(3.0).unwrap() / T::from(400.0).unwrap() * n * t));
	// Chroma.
	let c = (c_2 - c_1) / (k_c * (T::one() + T::from(9.0).unwrap() / T::from(400.0).unwrap() * n));
	// Returning the square root ensures that dE00 accurately reflects the
	// geometric distance in color space, which can range from 0 to around 185.
	(l * l + h * h + c * c + c * h * r_t).sqrt()
}

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//   Online Tests : https://michel-leonard.github.io/ciede2000-color-matching

// L1 = 1.8    a1 = 47.7   b1 = -3.0
// L2 = 0.0   a2 = 42.2   b2 = 3.4
// CIE ΔE00 = 3.9906909593 (Bruce Lindbloom, Netflix’s VMAF, ...)
// CIE ΔE00 = 3.9906776491 (Gaurav Sharma, OpenJDK, ...)
// Deviation between implementations ≈ 1.3e-5

// See the source code comments for easy switching between these two widely used ΔE*00 implementation variants.
