// This function written in JavaScript is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

// The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
// "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 128.
function ciede_2000(l_1, a_1, b_1, l_2, a_2, b_2) {
	"use strict"
	// Working in JavaScript with the CIEDE2000 color-difference formula.
	// k_l, k_c, k_h are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	var k_l = 1.0, k_c = 1.0, k_h = 1.0;
	var n = (Math.hypot(a_1, b_1) + Math.hypot(a_2, b_2)) * 0.5;
	n = n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - Math.sqrt(n / (n + 6103515625.0)));
	// hypot calculates the Euclidean distance while avoiding overflow/underflow.
	var c_1 = Math.hypot(a_1 * n, b_1), c_2 = Math.hypot(a_2 * n, b_2);
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	var h_1 = Math.atan2(b_1, a_1 * n), h_2 = Math.atan2(b_2, a_2 * n);
	h_1 += 2.0 * Math.PI * (h_1 < 0.0);
	h_2 += 2.0 * Math.PI * (h_2 < 0.0);
	n = Math.abs(h_2 - h_1);
	// Cross-implementation consistent rounding.
	if (Math.PI - 1E-14 < n && n < Math.PI + 1E-14)
		n = Math.PI;
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	var h_m = (h_1 + h_2) * 0.5, h_d = (h_2 - h_1) * 0.5;
	if (Math.PI < n) {
		if (0.0 < h_d)
			h_d -= Math.PI;
		else
			h_d += Math.PI;
		h_m += Math.PI;
	}
	var p = 36.0 * h_m - 55.0 * Math.PI;
	n = (c_1 + c_2) * 0.5;
	n = n * n * n * n * n * n * n;
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	var r_t = -2.0 * Math.sqrt(n / (n + 6103515625.0))
		* Math.sin(Math.PI / 3.0 * Math.exp(p * p / (-25.0 * Math.PI * Math.PI)));
	n = (l_1 + l_2) * 0.5;
	n = (n - 50.0) * (n - 50.0);
	// Lightness.
	var l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / Math.sqrt(20.0 + n)));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	var t = 1.0	+ 0.24 * Math.sin(2.0 * h_m + Math.PI * 0.5)
		+ 0.32 * Math.sin(3.0 * h_m + 8.0 * Math.PI / 15.0)
		- 0.17 * Math.sin(h_m + Math.PI / 3.0)
		- 0.20 * Math.sin(4.0 * h_m + 3.0 * Math.PI / 20.0);
	n = c_1 + c_2;
	// Hue.
	var h = 2.0 * Math.sqrt(c_1 * c_2) * Math.sin(h_d) / (k_h * (1.0 + 0.0075 * n * t));
	// Chroma.
	var c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
	// Returning the square root ensures that the result reflects the actual geometric
	// distance within the color space, which ranges from 0 to approximately 185.
	return Math.sqrt(l * l + h * h + c * c + c * h * r_t);
}

// These color conversion functions written in JavaScript are released into the public domain.
// They are provided "as is" without any warranty, express or implied.

// rgb in 0..1
function rgb_to_xyz(r, g, b) {
	// Apply a gamma correction to each channel.
	r = r < 0.0404482362771082 ? r / 12.92 : Math.pow((r + 0.055) / 1.055, 2.4)
	g = g < 0.0404482362771082 ? g / 12.92 : Math.pow((g + 0.055) / 1.055, 2.4)
	b = b < 0.0404482362771082 ? b / 12.92 : Math.pow((b + 0.055) / 1.055, 2.4)

	// Applying linear transformation using RGB to XYZ transformation matrix.
	var x = r * 41.24564390896921 + g * 35.7576077643909 + b * 18.043748326639894
	var y = r * 21.267285140562248 + g * 71.5152155287818 + b * 7.217499330655958
	var z = r * 1.9333895582329317 + g * 11.9192025881303 + b * 95.03040785363677

	return [x, y, z]
}

function xyz_to_lab(x, y, z) {
	// Reference white point (D65)
	var refX = 95.047
	var refY = 100.000
	var refZ = 108.883

	x /= refX
	y /= refY
	z /= refZ

	// Applying the CIE standard transformation.
	x = x < 216.0 / 24389.0 ? ((841.0 / 108.0) * x) + (4.0 / 29.0) : Math.cbrt(x)
	y = y < 216.0 / 24389.0 ? ((841.0 / 108.0) * y) + (4.0 / 29.0) : Math.cbrt(y)
	z = z < 216.0 / 24389.0 ? ((841.0 / 108.0) * z) + (4.0 / 29.0) : Math.cbrt(z)

	var l = (116.0 * y) - 16.0
	var a = 500.0 * (x - y)
	var b = 200.0 * (y - z)

	return [l, a, b]
}

// rgb in 0..1
function rgb_to_lab(r, g, b) {
	var xyz = rgb_to_xyz(r, g, b)
	return xyz_to_lab(xyz[0], xyz[1], xyz[2])
}

function lab_to_xyz(l, a, b) {
	// Reference white point (D65)
	var refX = 95.047
	var refY = 100.000
	var refZ = 108.883

	var y = (l + 16.0) / 116.0
	var x = a / 500.0 + y
	var z = y - b / 200.0

	var x3 = x * x * x
	var z3 = z * z * z

	x = x3 < 216.0 / 24389.0 ? (x - 4.0 / 29.0) / (841.0 / 108.0) : x3
	y = l < 8.0 ? l / (24389.0 / 27.0) : y * y * y
	z = z3 < 216.0 / 24389.0 ? (z - 4.0 / 29.0) / (841.0 / 108.0) : z3

	return [x * refX, y * refY, z * refZ]
}

// rgb in 0..1
function xyz_to_rgb(x, y, z) {
	// Applying linear transformation using the XYZ to RGB transformation matrix.
	var r = x * 0.032404541621141054 + y * -0.015371385127977166 + z * -0.004985314095560162
	var g = x * -0.009692660305051868 + y * 0.018760108454466942 + z * 0.0004155601753034984
	var b = x * 0.0005564343095911469 + y * -0.0020402591351675387 + z * 0.010572251882231791

	// Apply gamma correction.
	r = r < 0.0031306684425005883 ? 12.92 * r : 1.055 * Math.pow(r, 1.0 / 2.4) - 0.055
	g = g < 0.0031306684425005883 ? 12.92 * g : 1.055 * Math.pow(g, 1.0 / 2.4) - 0.055
	b = b < 0.0031306684425005883 ? 12.92 * b : 1.055 * Math.pow(b, 1.0 / 2.4) - 0.055

	return [r, g, b]
}

// rgb in 0..1
function lab_to_rgb(l, a, b) {
	var xyz = lab_to_xyz(l, a, b)
	return xyz_to_rgb(xyz[0], xyz[1], xyz[2])
}

// rgb in 0..255
function hex_to_rgb(s) {
	// Also support the short syntax (ie "#FFF") as input.
	var n = parseInt((s.length === 4 ? s[0] + s[1] + s[1] + s[2] + s[2] + s[3] + s[3] : s).substring(1), 16)
	return [n >> 16 & 0xff, n >> 8 & 0xff, n & 0xff]
}

// rgb in 0..255
function rgb_to_hex(r, g, b) {
	// Also provide the short syntax (ie "#FFF") as output.
	var s = '#' + r.toString(16).padStart(2, '0') + g.toString(16).padStart(2, '0') + b.toString(16).padStart(2, '0')
	return s[1] === s[2] && s[3] === s[4] && s[5] === s[6] ? '#' + s[1] + s[3] + s[5] : s
}

//////////////////////////////////////////////////
///////////                      /////////////////
///////////   CIE ΔE2000 Demo    /////////////////
///////////                      /////////////////
//////////////////////////////////////////////////

// The goal of this demo is to use the CIEDE2000 function to identify,
// for each RGB color in set 1, the closest RGB color in set 2.

const rgb_set_1 = [[255, 228, 196, 'bisque'], [154, 205, 50, 'yellowgreen'], [128, 128, 128, 'gray'], [255, 105, 180, 'hotpink'], [173, 216, 230, 'lightblue'], [72, 61, 139, 'darkslateblue'], [119, 136, 153, 'lightslategray'], [100, 149, 237, 'cornflowerblue'], [255, 250, 205, 'lemonchiffon'], [255, 160, 122, 'lightsalmon'], [165, 42, 42, 'brown'], [188, 143, 143, 'rosybrown'], [245, 222, 179, 'wheat'], [72, 209, 204, 'mediumturquoise'], [255, 218, 185, 'peachpuff'], [255, 182, 193, 'lightpink'], [60, 179, 113, 'mediumseagreen'], [34, 139, 34, 'forestgreen'], [255, 250, 240, 'floralwhite'], [250, 250, 210, 'lightgoldenrodyellow'], [144, 238, 144, 'lightgreen'], [189, 183, 107, 'darkkhaki'], [218, 165, 32, 'goldenrod'], [143, 188, 143, 'darkseagreen'], [255, 99, 71, 'tomato'], [255, 20, 147, 'deeppink'], [0, 191, 255, 'deepskyblue'], [85, 107, 47, 'darkolivegreen'], [255, 127, 80, 'coral'], [178, 34, 34, 'firebrick'], [255, 255, 240, 'ivory'], [148, 0, 211, 'darkviolet'], [255, 255, 224, 'lightyellow'], [0, 128, 128, 'teal'], [0, 0, 0, 'black'], [250, 240, 230, 'linen'], [233, 150, 122, 'darksalmon'], [255, 140, 0, 'darkorange'], [47, 79, 79, 'darkslategray'], [0, 100, 0, 'darkgreen'], [205, 92, 92, 'indianred'], [128, 128, 0, 'olive'], [107, 142, 35, 'olivedrab'], [75, 0, 130, 'indigo'], [186, 85, 211, 'mediumorchid'], [216, 191, 216, 'thistle'], [0, 0, 139, 'darkblue'], [255, 239, 213, 'papayawhip'], [123, 104, 238, 'mediumslateblue'], [253, 245, 230, 'oldlace'], [0, 255, 255, 'aqua'], [65, 105, 225, 'royalblue'], [153, 50, 204, 'darkorchid'], [255, 0, 255, 'fuchsia'], [139, 69, 19, 'saddlebrown'], [0, 139, 139, 'darkcyan'], [128, 0, 128, 'purple'], [255, 235, 205, 'blanchedalmond'], [0, 255, 127, 'springgreen'], [255, 192, 203, 'pink'], [32, 178, 170, 'lightseagreen'], [106, 90, 205, 'slateblue'], [152, 251, 152, 'palegreen'], [221, 160, 221, 'plum'], [0, 0, 255, 'blue'], [244, 164, 96, 'sandybrown'], [0, 255, 0, 'lime'], [64, 224, 208, 'turquoise'], [220, 20, 60, 'crimson'], [255, 248, 220, 'cornsilk']]
const rgb_set_2 = [[250, 235, 215, 'antiquewhite'], [255, 255, 255, 'white'], [147, 112, 219, 'mediumpurple'], [169, 169, 169, 'darkgray'], [255, 165, 0, 'orange'], [30, 144, 255, 'dodgerblue'], [25, 25, 112, 'midnightblue'], [245, 255, 250, 'mintcream'], [160, 82, 45, 'sienna'], [222, 184, 135, 'burlywood'], [230, 230, 250, 'lavender'], [138, 43, 226, 'blueviolet'], [255, 228, 225, 'mistyrose'], [255, 69, 0, 'orangered'], [175, 238, 238, 'paleturquoise'], [240, 255, 240, 'honeydew'], [102, 205, 170, 'mediumaquamarine'], [255, 240, 245, 'lavenderblush'], [50, 205, 50, 'limegreen'], [0, 0, 205, 'mediumblue'], [192, 192, 192, 'silver'], [128, 0, 0, 'maroon'], [139, 0, 0, 'darkred'], [210, 180, 140, 'tan'], [255, 215, 0, 'gold'], [95, 158, 160, 'cadetblue'], [0, 206, 209, 'darkturquoise'], [255, 255, 0, 'yellow'], [219, 112, 147, 'palevioletred'], [184, 134, 11, 'darkgoldenrod'], [112, 128, 144, 'slategray'], [0, 250, 154, 'mediumspringgreen'], [240, 128, 128, 'lightcoral'], [220, 220, 220, 'gainsboro'], [238, 130, 238, 'violet'], [211, 211, 211, 'lightgray'], [255, 245, 238, 'seashell'], [210, 105, 30, 'chocolate'], [255, 0, 0, 'red'], [245, 245, 220, 'beige'], [176, 224, 230, 'powderblue'], [205, 133, 63, 'peru'], [127, 255, 212, 'aquamarine'], [173, 255, 47, 'greenyellow'], [240, 230, 140, 'khaki'], [176, 196, 222, 'lightsteelblue'], [240, 248, 255, 'aliceblue'], [127, 255, 0, 'chartreuse'], [255, 222, 173, 'navajowhite'], [46, 139, 87, 'seagreen'], [139, 0, 139, 'darkmagenta'], [238, 232, 170, 'palegoldenrod'], [250, 128, 114, 'salmon'], [224, 255, 255, 'lightcyan'], [248, 248, 255, 'ghostwhite'], [218, 112, 214, 'orchid'], [105, 105, 105, 'dimgray'], [135, 206, 250, 'lightskyblue'], [135, 206, 235, 'skyblue'], [255, 228, 181, 'moccasin'], [0, 0, 128, 'navy'], [70, 130, 180, 'steelblue'], [0, 128, 0, 'green'], [199, 21, 133, 'mediumvioletred'], [240, 255, 255, 'azure'], [124, 252, 0, 'lawngreen'], [102, 51, 153, 'rebeccapurple'], [255, 250, 250, 'snow']]

// Converts the RGB colors to L*a*b* colors.
const lab_set_1 = rgb_set_1.map(rgb => rgb_to_lab(rgb[0] / 255.0, rgb[1] / 255.0, rgb[2] / 255.0))
const lab_set_2 = rgb_set_2.map(rgb => rgb_to_lab(rgb[0] / 255.0, rgb[1] / 255.0, rgb[2] / 255.0))

for (let i = 0, k = 0; i < lab_set_1.length; ++i) {
	// For each color of the set 1.
	const lab_1 = lab_set_1[i]
	let min_delta_e = Infinity
	for (let j = 0; j < lab_set_2.length; ++j) {
		const lab_2 = lab_set_2[j]
		// We optionally ignore strictly equal colors, they have a color difference of 0.
		if (lab_1[0] === lab_2[0] && lab_1[1] === lab_2[1] && lab_1[2] === lab_2[2])
			continue
		// We calculate the color difference.
		const delta_e = ciede_2000(...lab_1, ...lab_2)
		if (delta_e < min_delta_e) {
			// Based on the difference, we identify the closest color from the set 2.
			min_delta_e = delta_e
			k = j
		}
	}
	// And we display the results.
	const rgb_1 = rgb_set_1[i]
	const rgb_2 = rgb_set_2[k]
	let str = "The closest color from " + rgb_1[3] + " = RGB(" + rgb_1[0] + ", " + rgb_1[1] + ", " + rgb_1[2] + ") "
	str += "is " + rgb_2[3] + " = RGB(" + rgb_2[0] + ", " + rgb_2[1] + ", " + rgb_2[2] + ") "
	str += "with a distance of " + min_delta_e.toFixed(5)
	console.log(str)
}
