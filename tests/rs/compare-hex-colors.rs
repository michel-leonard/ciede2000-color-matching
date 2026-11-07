// This function written in Rust is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

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
	let mut n = ((a_1 * a_1 + b_1 * b_1).sqrt() + (a_2 * a_2 + b_2 * b_2).sqrt()) * 0.5;
	n = n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - (n / (n + 6103515625.0)).sqrt());
	// Application of the chroma correction factor.
	let c_1: f64 = (a_1 * a_1 * n * n + b_1 * b_1).sqrt();
	let c_2: f64 = (a_2 * a_2 * n * n + b_2 * b_2).sqrt();
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
		h_d += M_PI;
		// 📜 Sharma’s formulation doesn’t use the next line, but the one after it,
		// and these two variants differ by ±0.0003 on the final color differences.
		h_m += M_PI;
		// if h_m < M_PI { h_m += M_PI; } else { h_m -= M_PI; }
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
	// Returning the square root ensures that dE00 accurately reflects the
	// geometric distance in color space, which can range from 0 to around 185.
	(l * l + h * h + c * c + c * h * r_t).sqrt()
}

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//   Online Tests : https://michel-leonard.github.io/ciede2000-color-matching

// L1 = 24.2   a1 = 32.3   b1 = 4.6
// L2 = 26.0   a2 = 27.6   b2 = -3.8
// CIE ΔE00 = 5.6829981096 (Bruce Lindbloom, Netflix’s VMAF, ...)
// CIE ΔE00 = 5.6830146363 (Gaurav Sharma, OpenJDK, ...)
// Deviation between implementations ≈ 1.7e-5

// See the source code comments for easy switching between these two widely used ΔE*00 implementation variants.

// These color conversion functions written in Rust are released into the public domain.
// They are provided "as is" without any warranty, express or implied.

// rgb in 0..1
fn rgb_to_xyz(r: f64, g: f64, b: f64) -> (f64, f64, f64) {
	// Apply a gamma correction to each channel.
	let r = if r < 0.040448236277105097 { r / 12.92 } else { ((r + 0.055) / 1.055).powf(2.4) };
	let g = if g < 0.040448236277105097 { g / 12.92 } else { ((g + 0.055) / 1.055).powf(2.4) };
	let b = if b < 0.040448236277105097 { b / 12.92 } else { ((b + 0.055) / 1.055).powf(2.4) };

	// Applying linear transformation using RGB to XYZ transformation matrix.
	let x = r * 41.24564390896921145 + g * 35.75760776439090507 + b * 18.04374830853290341;
	let y = r * 21.26728514056222474 + g * 71.51521552878181013 + b * 7.21749933075596513;
	let z = r * 1.93338955823293176 + g * 11.91919550818385936 + b * 95.03040770337479886;

	(x, y, z)
}

fn xyz_to_lab(x: f64, y: f64, z: f64) -> (f64, f64, f64) {
	// Reference white point : D65 2° Standard observer
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
	// Reference white point : D65 2° Standard observer
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
	r = if r < 0.003130668442500634 { 12.92 * r } else { 1.055 * r.powf(1.0 / 2.4) - 0.055 };
	g = if g < 0.003130668442500634 { 12.92 * g } else { 1.055 * g.powf(1.0 / 2.4) - 0.055 };
	b = if b < 0.003130668442500634 { 12.92 * b } else { 1.055 * b.powf(1.0 / 2.4) - 0.055 };

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
// To get 0.040448236277105097132567243294938 we perform x/12.92 = ((x+0.055)/1.055)^2.4
// To get 0.00313066844250063403284123841596 we perform 12.92*x = 1.055*x^(1/2.4)-0.055

//////////////////////////////////////////////////
///////////                      /////////////////
///////////   CIE ΔE2000 Demo    /////////////////
///////////                      /////////////////
//////////////////////////////////////////////////

// The goal of this demo in Rust is to use the CIEDE2000 function to compare two hexadecimal colors.

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
