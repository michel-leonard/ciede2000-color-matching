// This function written in Rust is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

use rand::Rng;

// The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
// "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
fn ciede_2000(l_1: f64, a_1: f64, b_1: f64, l_2: f64, a_2: f64, b_2: f64) -> f64 {
	// Working in Rust with the CIEDE2000 color-difference formula.
	// K_L, K_C, K_H are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	const K_L: f64 = 1.0;
	const K_C: f64 = 1.0;
	const K_H: f64 = 1.0;
	const M_PI: f64 = std::f64::consts::PI;
	let mut n = (a_1.hypot(b_1) + a_2.hypot(b_2)) * 0.5;
	n = n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - (n / (n + 6103515625.0)).sqrt());
	// hypot calculates the Euclidean distance while avoiding overflow/underflow.
	let c_1: f64 = (a_1 * n).hypot(b_1);
	let c_2: f64 = (a_2 * n).hypot(b_2);
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	let mut h_1 = b_1.atan2(a_1 * n);
	let mut h_2 = b_2.atan2(a_2 * n);
	if h_1 < 0.0 { h_1 += 2.0 * M_PI; }
	if h_2 < 0.0 { h_2 += 2.0 * M_PI; }
	n = (h_2 - h_1).abs();
	// Cross-implementation consistent rounding.
	 if (M_PI - 1e-14..=M_PI + 1e-14).contains(&n) { n = M_PI; }
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	let mut h_m = (h_1 + h_2) * 0.5;
	let mut h_d = (h_2 - h_1) * 0.5;
	if M_PI < n {
		if 0.0 < h_d { h_d -= M_PI; }
		else { h_d += M_PI; }
		h_m += M_PI;
	}
	let p = 36.0 * h_m - 55.0 * M_PI;
	n = (c_1 + c_2) * 0.5;
	n = n * n * n * n * n * n * n;
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	let r_t = -2.0 * (n / (n + 6103515625.0)).sqrt() * (M_PI / 3.0 * (p * p / (-25.0 * M_PI * M_PI)).exp()).sin();
	n = (l_1 + l_2) * 0.5;
	n = (n - 50.0) * (n - 50.0);
	// Lightness.
	let l = (l_2 - l_1) / (K_L * (1.0 + 0.015 * n / (20.0 + n).sqrt()));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	let t = 1.0 	+ 0.24 * (2.0 * h_m + M_PI * 0.5).sin()
			+ 0.32 * (3.0 * h_m + 8.0 * M_PI / 15.0).sin()
			- 0.17 * (h_m + M_PI / 3.0).sin()
			- 0.20 * (4.0 * h_m + 3.0 * M_PI / 20.0).sin();
	n = c_1 + c_2;
	// Hue.
	let h = 2.0 * (c_1 * c_2).sqrt() * (h_d).sin() / (K_H * (1.0 + 0.0075 * n * t));
	// Chroma.
	let c = (c_2 - c_1) / (K_C * (1.0 + 0.0225 * n));
	// Returns the square root so that the Delta E 2000 reflects the actual geometric
	// distance within the color space, which ranges from 0 to approximately 185.
	(l * l + h * h + c * c + c * h * r_t).sqrt()
}

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

// L1 = 41.6966        a1 = -44.9617       b1 = -47.0
// L2 = 41.6966        a2 = -35.82         b2 = -51.0
// CIE ΔE2000 = ΔE00 = 3.9496674762

///////////////////////////////////////////////
///////////////////////////////////////////////
///////                                 ///////
///////           CIEDE 2000            ///////
///////      Testing Random Colors      ///////
///////                                 ///////
///////////////////////////////////////////////
///////////////////////////////////////////////

// This Rust program outputs a CSV file to standard output, with its length determined by the first CLI argument.
// Each line contains seven columns :
// - Three columns for the random standard L*a*b* color
// - Three columns for the random sample L*a*b* color
// - And the seventh column for the precise Delta E 2000 color difference between the standard and sample
// The output will be correct, this can be verified :
// - With the C driver, which provides a dedicated verification feature
// - By using the JavaScript validator at https://michel-leonard.github.io/ciede2000-color-matching

fn main() {
	let args: Vec<String> = std::env::args().collect();
	let mut n_iterations = 10000;

	if args.len() > 1 {
		if let Ok(val) = args[1].parse::<i32>() {
			if val >= 1 {
				n_iterations = val;
			}
		}
	}

	unsafe {
		libc::signal(libc::SIGPIPE, libc::SIG_DFL);
	}

	let mut rng = rand::rng();

	for _ in 0..n_iterations {
		let l1 = (rng.random_range(0.0..=10000.0) as f64).round() / 100.0;
		let a1 = (rng.random_range(-12800.0..=12800.0) as f64).round() / 100.0;
		let b1 = (rng.random_range(-12800.0..=12800.0) as f64).round() / 100.0;
		let l2 = (rng.random_range(0.0..=10000.0) as f64).round() / 100.0;
		let a2 = (rng.random_range(-12800.0..=12800.0) as f64).round() / 100.0;
		let b2 = (rng.random_range(-12800.0..=12800.0) as f64).round() / 100.0;

		let delta_e = ciede_2000(l1, a1, b1, l2, a2, b2);
		println!("{},{},{},{},{},{},{}", l1, a1, b1, l2, a2, b2, delta_e);
	}
}
