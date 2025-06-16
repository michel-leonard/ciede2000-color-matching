// This function written in Rust is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

use std::f64::consts::PI;

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

// L1 = 80.4           a1 = -12.4          b1 = 42.13
// L2 = 70.4           a2 = -67.329        b2 = 83.1863
// CIE ΔE2000 = ΔE00 = 20.26431548393

// These color conversion functions written in Rust are released into the public domain.
// They are provided "as is" without any warranty, express or implied.

// rgb in 0..1
fn rgb_to_xyz(r: f64, g: f64, b: f64) -> (f64, f64, f64) {
	// Apply a gamma correction to each channel.
	let r = if r < 0.040448236276933 { r / 12.92 } else { ((r + 0.055) / 1.055).powf(2.4) };
	let g = if g < 0.040448236276933 { g / 12.92 } else { ((g + 0.055) / 1.055).powf(2.4) };
	let b = if b < 0.040448236276933 { b / 12.92 } else { ((b + 0.055) / 1.055).powf(2.4) };

	// Applying linear transformation using RGB to XYZ transformation matrix.
	let x = r * 41.24564390896921145 + g * 35.75760776439090507 + b * 18.04374830853290341;
	let y = r * 21.26728514056222474 + g * 71.51521552878181013 + b * 7.21749933075596513;
	let z = r * 1.93338955823293176 + g * 11.91919550818385936 + b * 95.03040770337479886;

	(x, y, z)
}

fn xyz_to_lab(x: f64, y: f64, z: f64) -> (f64, f64, f64) {
	// Reference white point (D65)
	let refX = 95.047;
	let refY = 100.000;
	let refZ = 108.883;

	let mut x = x / refX;
	let mut y = y / refY;
	let mut z = z / refZ;

	// Applying the CIE standard transformation.
	x = if x < 216.0 / 24389.0 { ((841.0 / 108.0) * x) + (4.0 / 29.0) } else { x.cbrt() };
	y = if y < 216.0 / 24389.0 { ((841.0 / 108.0) * y) + (4.0 / 29.0) } else { y.cbrt() };
	z = if z < 216.0 / 24389.0 { ((841.0 / 108.0) * z) + (4.0 / 29.0) } else { z.cbrt() };

	let l = (116.0 * y) - 16.0;
	let a = 500.0 * (x - y);
	let b = 200.0 * (y - z);

	(l, a, b)
}

// rgb in 0..1
fn rgb_to_lab(r: f64, g: f64, b: f64) -> (f64, f64, f64) {
	let xyz = rgb_to_xyz(r, g, b);
	xyz_to_lab(xyz.0, xyz.1, xyz.2)
}

fn lab_to_xyz(l: f64, a: f64, b: f64) -> (f64, f64, f64) {
	// Reference white point (D65)
	let refX = 95.047;
	let refY = 100.000;
	let refZ = 108.883;

	let mut y = (l + 16.0) / 116.0;
	let mut x = a / 500.0 + y;
	let mut z = y - b / 200.0;

	let x3 = x * x * x;
	let z3 = z * z * z;

	x = if x3 < 216.0 / 24389.0 { (x - 4.0 / 29.0) / (841.0 / 108.0) } else { x3 };
	y = if l < 8.0 { l / (24389.0 / 27.0) } else { y * y * y };
	z = if z3 < 216.0 / 24389.0 { (z - 4.0 / 29.0) / (841.0 / 108.0) } else { z3 };

	(x * refX, y * refY, z * refZ)
}

// rgb in 0..1
fn xyz_to_rgb(x: f64, y: f64, z: f64) -> (f64, f64, f64) {
	// Applying linear transformation using the XYZ to RGB transformation matrix.
	let mut r = x * 0.032404541621141049051 + y * -0.015371385127977165753 + z * -0.004985314095560160079;
	let mut g = x * -0.009692660305051867686 + y * 0.018760108454466942288 + z * 0.00041556017530349983;
	let mut b = x * 0.000556434309591145522 + y * -0.002040259135167538416 + z * 0.010572251882231790398;

	// Apply gamma correction.
	r = if r < 0.0031306684424956 { 12.92 * r } else { 1.055 * r.powf(1.0 / 2.4) - 0.055 };
	g = if g < 0.0031306684424956 { 12.92 * g } else { 1.055 * g.powf(1.0 / 2.4) - 0.055 };
	b = if b < 0.0031306684424956 { 12.92 * b } else { 1.055 * b.powf(1.0 / 2.4) - 0.055 };

	(r, g, b)
}

// rgb in 0..1
fn lab_to_rgb(l: f64, a: f64, b: f64) -> (f64, f64, f64) {
	let xyz = lab_to_xyz(l, a, b);
	xyz_to_rgb(xyz.0, xyz.1, xyz.2)
}

// rgb in 0..255
fn hex_to_rgb(s: &str) -> (u8, u8, u8) {
	// Also support the short syntax (ie "#FFF") as input.
	let h = if s.len() == 4 {
		format!("{0}{0}{1}{1}{2}{2}", &s[1..2], &s[2..3], &s[3..4])
	} else {
		s[1..].to_string()
	};
	let n = u32::from_str_radix(&h, 16).unwrap();
	((n >> 16) as u8, (n >> 8) as u8, n as u8)
}

// rgb in 0..255
fn rgb_to_hex(r: u8, g: u8, b: u8) -> String {
	// Also provide the short syntax (ie "#FFF") as output.
	let s = format!("#{:02X}{:02X}{:02X}", r, g, b);
	let c: Vec<char> = s.chars().collect();
	if c[1] == c[2] && c[3] == c[4] && c[5] == c[6] { format!("#{}{}{}", c[1], c[3], c[5]) }  else { s }
}

// Constants used in Color Conversion :
// 216.0 / 24389.0 = 0.0088564516790356308171716757554635286399606379925376194185903481077
// 841.0 / 108.0 = 7.78703703703703703703703703703703703703703703703703703703703703703703703703
// 4.0 / 29.0 = 0.13793103448275862068965517241379310344827586206896551724137931034482758620
// 24389.0 / 27.0 = 903.296296296296296296296296296296296296296296296296296296296296296296296296
// 1.0 / 2.4 = 0.41666666666666666666666666666666666666666666666666666666666666666666666666
// To get 0.040448236276933 we perform x/12.92 = ((x+0.055)/1.055)^2.4
// To get 0.0031306684424956 we perform 12.92*x = 1.055*x^(1/2.4)-0.055

//////////////////////////////////////////////////
///////////                      /////////////////
///////////   CIE ΔE2000 Demo    /////////////////
///////////                      /////////////////
//////////////////////////////////////////////////

// The goal of this demo is to use the CIEDE2000 function to compare two hexadecimal colors.

fn main() {
	let hex_1 = "#00f"; // blue
	let hex_2 = "#483D8B"; // darkslateblue

	// 1. hex -> RGB (0..255)
	let (r_1, g_1, b_1) = hex_to_rgb(hex_1);
	let (r_2, g_2, b_2) = hex_to_rgb(hex_2);
	println!("{:8} -> RGB({}, {}, {})", hex_1, r_1, g_1, b_1);
	println!("{:8} -> RGB({}, {}, {})", hex_2, r_2, g_2, b_2);

	// 2. RGB -> LAB
	let (l_1, a_1, b_1_lab) = rgb_to_lab(r_1 as f64 / 255.0, g_1 as f64 / 255.0, b_1 as f64 / 255.0);
	let (l_2, a_2, b_2_lab) = rgb_to_lab(r_2 as f64 / 255.0, g_2 as f64 / 255.0, b_2 as f64 / 255.0);
	println!("{:8} -> LAB(L: {:.4}, a: {:.4}, b: {:.4})", hex_1, l_1, a_1, b_1_lab);
	println!("{:8} -> LAB(L: {:.4}, a: {:.4}, b: {:.4})", hex_2, l_2, a_2, b_2_lab);

	// 3. Delta E 2000
	let delta_e = ciede_2000(l_1, a_1, b_1_lab, l_2, a_2, b_2_lab);
	println!("ΔE2000 between {} and {}: {:.4}", hex_1, hex_2, delta_e);

	// This shows a ΔE2000 of 15.91
}
