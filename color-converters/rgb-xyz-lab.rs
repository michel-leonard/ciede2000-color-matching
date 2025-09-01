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

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching

// Constants used in Color Conversion :
// 216.0 / 24389.0 = 0.0088564516790356308171716757554635286399606379925376194185903481077
// 841.0 / 108.0 = 7.78703703703703703703703703703703703703703703703703703703703703703703703703
// 4.0 / 29.0 = 0.13793103448275862068965517241379310344827586206896551724137931034482758620
// 24389.0 / 27.0 = 903.296296296296296296296296296296296296296296296296296296296296296296296296
// 1.0 / 2.4 = 0.41666666666666666666666666666666666666666666666666666666666666666666666666
// To get 0.040448236277105097132567243294938 we perform x/12.92 = ((x+0.055)/1.055)^2.4
// To get 0.00313066844250063403284123841596 we perform 12.92*x = 1.055*x^(1/2.4)-0.055
