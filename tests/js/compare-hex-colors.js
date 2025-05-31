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
// for each hexadecimal color in set 1, the closest hexadecimal color in set 2.

const hex_set_1 = [['#ffe4c4', 'bisque'], ['#9acd32', 'yellowgreen'], ['#808080', 'gray'], ['#ff69b4', 'hotpink'], ['#add8e6', 'lightblue'], ['#483d8b', 'darkslateblue'], ['#789', 'lightslategray'], ['#6495ed', 'cornflowerblue'], ['#fffacd', 'lemonchiffon'], ['#ffa07a', 'lightsalmon'], ['#a52a2a', 'brown'], ['#bc8f8f', 'rosybrown'], ['#f5deb3', 'wheat'], ['#48d1cc', 'mediumturquoise'], ['#ffdab9', 'peachpuff'], ['#ffb6c1', 'lightpink'], ['#3cb371', 'mediumseagreen'], ['#228b22', 'forestgreen'], ['#fffaf0', 'floralwhite'], ['#fafad2', 'lightgoldenrodyellow'], ['#90ee90', 'lightgreen'], ['#bdb76b', 'darkkhaki'], ['#daa520', 'goldenrod'], ['#8fbc8f', 'darkseagreen'], ['#ff6347', 'tomato'], ['#ff1493', 'deeppink'], ['#00bfff', 'deepskyblue'], ['#556b2f', 'darkolivegreen'], ['#ff7f50', 'coral'], ['#b22222', 'firebrick'], ['#fffff0', 'ivory'], ['#9400d3', 'darkviolet'], ['#ffffe0', 'lightyellow'], ['#008080', 'teal'], ['#000', 'black'], ['#faf0e6', 'linen'], ['#e9967a', 'darksalmon'], ['#ff8c00', 'darkorange'], ['#2f4f4f', 'darkslategray'], ['#006400', 'darkgreen'], ['#cd5c5c', 'indianred'], ['#808000', 'olive'], ['#6b8e23', 'olivedrab'], ['#4b0082', 'indigo'], ['#ba55d3', 'mediumorchid'], ['#d8bfd8', 'thistle'], ['#00008b', 'darkblue'], ['#ffefd5', 'papayawhip'], ['#7b68ee', 'mediumslateblue'], ['#fdf5e6', 'oldlace'], ['#0ff', 'aqua'], ['#4169e1', 'royalblue'], ['#9932cc', 'darkorchid'], ['#f0f', 'fuchsia'], ['#8b4513', 'saddlebrown'], ['#008b8b', 'darkcyan'], ['#800080', 'purple'], ['#ffebcd', 'blanchedalmond'], ['#00ff7f', 'springgreen'], ['#ffc0cb', 'pink'], ['#20b2aa', 'lightseagreen'], ['#6a5acd', 'slateblue'], ['#98fb98', 'palegreen'], ['#dda0dd', 'plum'], ['#00f', 'blue'], ['#f4a460', 'sandybrown'], ['#0f0', 'lime'], ['#40e0d0', 'turquoise'], ['#dc143c', 'crimson'], ['#fff8dc', 'cornsilk']]
const hex_set_2 = [['#faebd7', 'antiquewhite'], ['#fff', 'white'], ['#9370db', 'mediumpurple'], ['#a9a9a9', 'darkgray'], ['#ffa500', 'orange'], ['#1e90ff', 'dodgerblue'], ['#191970', 'midnightblue'], ['#f5fffa', 'mintcream'], ['#a0522d', 'sienna'], ['#deb887', 'burlywood'], ['#e6e6fa', 'lavender'], ['#8a2be2', 'blueviolet'], ['#ffe4e1', 'mistyrose'], ['#ff4500', 'orangered'], ['#afeeee', 'paleturquoise'], ['#f0fff0', 'honeydew'], ['#66cdaa', 'mediumaquamarine'], ['#fff0f5', 'lavenderblush'], ['#32cd32', 'limegreen'], ['#0000cd', 'mediumblue'], ['#c0c0c0', 'silver'], ['#800000', 'maroon'], ['#8b0000', 'darkred'], ['#d2b48c', 'tan'], ['#ffd700', 'gold'], ['#5f9ea0', 'cadetblue'], ['#00ced1', 'darkturquoise'], ['#ff0', 'yellow'], ['#db7093', 'palevioletred'], ['#b8860b', 'darkgoldenrod'], ['#708090', 'slategray'], ['#00fa9a', 'mediumspringgreen'], ['#f08080', 'lightcoral'], ['#dcdcdc', 'gainsboro'], ['#ee82ee', 'violet'], ['#d3d3d3', 'lightgray'], ['#fff5ee', 'seashell'], ['#d2691e', 'chocolate'], ['#f00', 'red'], ['#f5f5dc', 'beige'], ['#b0e0e6', 'powderblue'], ['#cd853f', 'peru'], ['#7fffd4', 'aquamarine'], ['#adff2f', 'greenyellow'], ['#f0e68c', 'khaki'], ['#b0c4de', 'lightsteelblue'], ['#f0f8ff', 'aliceblue'], ['#7fff00', 'chartreuse'], ['#ffdead', 'navajowhite'], ['#2e8b57', 'seagreen'], ['#8b008b', 'darkmagenta'], ['#eee8aa', 'palegoldenrod'], ['#fa8072', 'salmon'], ['#e0ffff', 'lightcyan'], ['#f8f8ff', 'ghostwhite'], ['#da70d6', 'orchid'], ['#696969', 'dimgray'], ['#87cefa', 'lightskyblue'], ['#87ceeb', 'skyblue'], ['#ffe4b5', 'moccasin'], ['#000080', 'navy'], ['#4682b4', 'steelblue'], ['#008000', 'green'], ['#c71585', 'mediumvioletred'], ['#f0ffff', 'azure'], ['#7cfc00', 'lawngreen'], ['#639', 'rebeccapurple'], ['#fffafa', 'snow']]

// Converts the hexadecimal colors to L*a*b* colors.
const lab_set_1 = hex_set_1.map(hex => rgb_to_lab(...hex_to_rgb(hex[0]).map(n => n / 255.0)))
const lab_set_2 = hex_set_2.map(hex => rgb_to_lab(...hex_to_rgb(hex[0]).map(n => n / 255.0)))

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
	const hex_1 = hex_set_1[i]
	const hex_2 = hex_set_2[k]
	let str = "The closest color from " + hex_1[1] + " = " + hex_1[0] + " "
	str += "is " + hex_2[1] + " = " + hex_2[0] + " "
	str += "with a distance of " + min_delta_e.toFixed(5)
	console.log(str)
}
