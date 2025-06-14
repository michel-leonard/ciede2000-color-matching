// This function written in Rust is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

use std::f64::consts::PI;
use std::env;
use rand::Rng;
use palette::color_difference::Ciede2000;
use palette::Lab;
use palette::white_point::D65;

// The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
// "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
fn ciede_2000(l_1: f64, a_1: f64, b_1: f64, l_2: f64, a_2: f64, b_2: f64) -> f64 {
	// Working in Rust with the CIEDE2000 color-difference formula.
	// K_L, K_C, K_H are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	const K_L: f64 = 1.0;
	const K_C: f64 = 1.0;
	const K_H: f64 = 1.0;
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
	if h_1 < 0.0 { h_1 += 2.0 * PI; }
	if h_2 < 0.0 { h_2 += 2.0 * PI; }
	n = (h_2 - h_1).abs();
	// Cross-implementation consistent rounding.
	 if (PI - 1e-14..=PI + 1e-14).contains(&n) { n = PI; }
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	let mut h_m = (h_1 + h_2) * 0.5;
	let mut h_d = (h_2 - h_1) * 0.5;
	if PI < n {
		if 0.0 < h_d { h_d -= PI; }
		else { h_d += PI; }
		h_m += PI;
	}
	let p = 36.0 * h_m - 55.0 * PI;
	n = (c_1 + c_2) * 0.5;
	n = n * n * n * n * n * n * n;
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	let r_t = -2.0 * (n / (n + 6103515625.0)).sqrt() * (PI / 3.0 * (p * p / (-25.0 * PI * PI)).exp()).sin();
	n = (l_1 + l_2) * 0.5;
	n = (n - 50.0) * (n - 50.0);
	// Lightness.
	let l = (l_2 - l_1) / (K_L * (1.0 + 0.015 * n / (20.0 + n).sqrt()));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	let t = 1.0 	+ 0.24 * (2.0 * h_m + PI * 0.5).sin()
			+ 0.32 * (3.0 * h_m + 8.0 * PI / 15.0).sin()
			- 0.17 * (h_m + PI / 3.0).sin()
			- 0.20 * (4.0 * h_m + 3.0 * PI / 20.0).sin();
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

// L1 = 34.0           a1 = 76.0           b1 = 99.56
// L2 = 34.0           a2 = 76.0           b2 = 99.5811
// CIE ΔE2000 = ΔE00 = 0.00633299044

// L1 = 94.7           a1 = 102.4          b1 = -74.34
// L2 = 94.7           a2 = 106.5          b2 = -74.34
// CIE ΔE2000 = ΔE00 = 0.88787106205

// L1 = 78.21          a1 = 27.4           b1 = 28.0
// L2 = 78.21          a2 = 27.4           b2 = 24.0658
// CIE ΔE2000 = ΔE00 = 2.28612885558

// L1 = 21.284         a1 = -45.239        b1 = -63.0
// L2 = 24.498         a2 = -54.6          b2 = -63.0
// CIE ΔE2000 = ΔE00 = 3.69116669305

// L1 = 13.6318        a1 = -110.432       b1 = -20.4421
// L2 = 10.6           a2 = -115.0411      b2 = -52.5
// CIE ΔE2000 = ΔE00 = 10.86731529447

// L1 = 61.697         a1 = 58.6           b1 = -25.2
// L2 = 60.0           a2 = 122.8615       b2 = -38.3424
// CIE ΔE2000 = ΔE00 = 12.64231028081

// L1 = 23.0           a1 = 89.0           b1 = 111.228
// L2 = 28.0           a2 = 118.8241       b2 = 96.4
// CIE ΔE2000 = ΔE00 = 13.23179932781

// L1 = 10.0           a1 = 20.226         b1 = -125.49
// L2 = 17.4           a2 = -0.6           b2 = -27.0
// CIE ΔE2000 = ΔE00 = 17.92394233566

// L1 = 42.59          a1 = 2.2938         b1 = -41.163
// L2 = 37.26          a2 = 79.2           b2 = -109.33
// CIE ΔE2000 = ΔE00 = 21.39819001494

// L1 = 35.7           a1 = -88.0          b1 = -76.8
// L2 = 23.15          a2 = -29.8          b2 = 52.0
// CIE ΔE2000 = ΔE00 = 54.69054028251

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

	let mut rng = rand::thread_rng();
	let mut worst_diff = 0.0;
	let mut worst_case = (0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);

	for _ in 0..n_iterations {
		let l1 = rng.gen_range(0.0..=100.0) as f64;
		let a1 = rng.gen_range(-128.0..=127.0) as f64;
		let b1 = rng.gen_range(-128.0..=127.0) as f64;
		let l2 = rng.gen_range(0.0..=100.0) as f64;
		let a2 = rng.gen_range(-128.0..=127.0) as f64;
		let b2 = rng.gen_range(-128.0..=127.0) as f64;

		let lab1: Lab<D65, f64> = Lab { l: l1, a: a1, b: b1, ..Default::default() };
		let lab2: Lab<D65, f64> = Lab { l: l2, a: a2, b: b2, ..Default::default() };
		
		let delta_e_1 = lab1.difference(lab2);
		let delta_e_2 = ciede_2000(l1, a1, b1, l2, a2, b2);

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
	println!("  diff: {}", worst_case.8);
	println!("}}");

	if worst_diff > 1e-10 {
		std::process::exit(1);
	} else {
		std::process::exit(0);
	}
}
