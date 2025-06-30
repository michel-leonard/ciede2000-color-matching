// This function written in Rust is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

use num_traits::Float;
use std::env;
use rand::Rng;
use palette::color_difference::Ciede2000;
use palette::Lab;
use palette::white_point::D65;

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
	// The hypot function can do the following, but is not required here.
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
	// Returns the square root so that the Delta E 2000 reflects the actual geometric
	// distance within the color space, which ranges from 0 to approximately 185.
	(l * l + h * h + c * c + c * h * r_t).sqrt()
}

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

// L1 = 10.0           a1 = 20.226         b1 = -125.49
// L2 = 17.4           a2 = -0.6           b2 = -27.0
// CIE ΔE2000 = ΔE00 = 17.92394233566

////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
////////////                               /////////////
////////////         Compare with          /////////////
////////////            palette            /////////////
////////////                               /////////////
////////////////////////////////////////////////////////
////////////////////////////////////////////////////////

// The goal is to demonstrate that the library produces results identical to palette.
// If the results differ by more than a tolerance of 1E-10, a non-zero value will be returned.
// Explore the workflows to see how this code is executed.

fn main() {
	let args: Vec<String> = env::args().collect();
	let mut n_iterations: i32 = 10_000;

	if args.len() > 1 {
		if let Ok(val) = args[1].parse::<i32>() {
			if val >= 1 {
				n_iterations = val;
			}
		}
	}

	let mut rng = rand::rng();
	let mut worst_diff = 0.0;
	let mut worst_case = (0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);

	for _ in 0..n_iterations {
		let l1 = rng.random_range(0.0..=100.0) as f64;
		let a1 = rng.random_range(-128.0..=127.0) as f64;
		let b1 = rng.random_range(-128.0..=127.0) as f64;
		let l2 = rng.random_range(0.0..=100.0) as f64;
		let a2 = rng.random_range(-128.0..=127.0) as f64;
		let b2 = rng.random_range(-128.0..=127.0) as f64;

		let lab1: Lab<D65, f64> = Lab { l: l1, a: a1, b: b1, ..Default::default() };
		let lab2: Lab<D65, f64> = Lab { l: l2, a: a2, b: b2, ..Default::default() };

		let delta_e_1 = lab1.difference(lab2);
		let delta_e_2 = ciede_2000::<f64>(l1, a1, b1, l2, a2, b2);

		if !delta_e_1.is_finite() || !delta_e_2.is_finite() {
			eprintln!("Non-finite delta_e encountered");
			std::process::exit(1);
		}

		let diff = (delta_e_1 - delta_e_2).abs();
		if diff > worst_diff {
			worst_diff = diff;
			worst_case = (
				l1, a1, b1,
				l2, a2, b2,
				delta_e_1, delta_e_2,
				diff,
			);
		}
	}

	println!(" Total runs : {}", n_iterations);
	println!("Worst case : {{");
	println!("  l1: {},", worst_case.0);
	println!("  a1: {},", worst_case.1);
	println!("  b1: {},", worst_case.2);
	println!("  l2: {},", worst_case.3);
	println!("  a2: {},", worst_case.4);
	println!("  b2: {},", worst_case.5);
	println!("  delta1: {},", worst_case.6);
	println!("  delta2: {},", worst_case.7);
	println!("  diff: {:.2e}", worst_case.8);
	println!("}}");

	std::process::exit((worst_diff > 1e-10) as i32);
}
