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
	let pi = T::from(std::f64::consts::PI).unwrap();
	// Sets an epsilon value that matches the currently used type.
	let epsilon = T::from(1e-14).unwrap() ;
	let mut n = (a_1.hypot(b_1) + a_2.hypot(b_2)) * T::from(0.5).unwrap();
	n = n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = T::one() + T::from(0.5).unwrap() * (T::one()
			- (n / (n + T::from(6103515625.0).unwrap())).sqrt());
	// hypot calculates the Euclidean distance while avoiding overflow/underflow.
	let c_1: T = (a_1 * n).hypot(b_1);
	let c_2: T = (a_2 * n).hypot(b_2);
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	let mut h_1 = b_1.atan2(a_1 * n);
	let mut h_2 = b_2.atan2(a_2 * n);
	if h_1 < T::zero() { h_1 = h_1 + T::from(2.0).unwrap() * pi; }
	if h_2 < T::zero() { h_2 = h_2 + T::from(2.0).unwrap() * pi; }
	n = (h_2 - h_1).abs();
	// Consistent rounding between 64-bit implementations, ignored in 32-bit.
	 if (pi - epsilon..=pi + epsilon).contains(&n) { n = pi; }
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	let mut h_m = (h_1 + h_2) * T::from(0.5).unwrap();
	let mut h_d = (h_2 - h_1) * T::from(0.5).unwrap();
	if pi < n {
		if T::zero() < h_d { h_d = h_d - pi; }
		else { h_d = h_d + pi; }
		h_m = h_m + pi;
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
	let l = (l_2 - l_1) / (k_l * (T::one() + T::from(0.015).unwrap()
		* n / (T::from(20.0).unwrap() + n).sqrt()));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	let t = T::one()
		+ T::from(0.24).unwrap()
			* (T::from(2.0).unwrap() * h_m + pi * T::from(0.5).unwrap()).sin()
		+ T::from(0.32).unwrap()
			* (T::from(3.0).unwrap() * h_m + T::from(8.0).unwrap() * pi / T::from(15.0).unwrap()).sin()
		- T::from(0.17).unwrap()
			* (h_m + pi / T::from(3.0).unwrap()).sin()
		- T::from(0.20).unwrap()
			* (T::from(4.0).unwrap() * h_m + T::from(3.0).unwrap() * pi / T::from(20.0).unwrap()).sin();
	n = c_1 + c_2;
	// Hue.
	let h = T::from(2.0).unwrap() * (c_1 * c_2).sqrt()
		* (h_d).sin() / (k_h * (T::one() + T::from(0.0075).unwrap() * n * t));
	// Chroma.
	let c = (c_2 - c_1) / (k_c * (T::one() + T::from(0.0225).unwrap() * n));
	// Returns the square root so that the Delta E 2000 reflects the actual geometric
	// distance within the color space, which ranges from 0 to approximately 185.
	(l * l + h * h + c * c + c * h * r_t).sqrt()
}

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

// L1 = 21.476         a1 = 85.695         b1 = 15.8674
// L2 = 17.79          a2 = 97.4           b2 = 27.12
// CIE ΔE2000 = ΔE00 = 4.93344803196
