# This function written in Python is not affiliated with the CIE (International Commission on Illumination),
# and is released into the public domain. It is provided "as is" without any warranty, express or implied.

# The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
# "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 128.
def ciede_2000(l_1, a_1, b_1, l_2, a_2, b_2):
	from math import pi, sqrt, hypot, atan2, sin, exp
	# Working in Python with the CIEDE2000 color-difference formula.
	# k_l, k_c, k_h are parametric factors to be adjusted according to
	# different viewing parameters such as textures, backgrounds...
	k_l = k_c = k_h = 1.0
	n = (hypot(a_1, b_1) + hypot(a_2, b_2)) * 0.5
	n = n * n * n * n * n * n * n
	# A factor involving chroma raised to the power of 7 designed to make
	# the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - sqrt(n / (n + 6103515625.0)))
	# hypot calculates the Euclidean distance while avoiding overflow/underflow.
	c_1 = hypot(a_1 * n, b_1)
	c_2 = hypot(a_2 * n, b_2)
	# atan2 is preferred over atan because it accurately computes the angle of
	# a point (x, y) in all quadrants, handling the signs of both coordinates.
	h_1 = atan2(b_1, a_1 * n)
	h_2 = atan2(b_2, a_2 * n)
	h_1 += 2.0 * pi * (h_1 < 0.0)
	h_2 += 2.0 * pi * (h_2 < 0.0)
	n = abs(h_2 - h_1)
	# Cross-implementation consistent rounding.
	if pi - 1E-14 < n and n < pi + 1E-14 :
		n = pi
	# When the hue angles lie in different quadrants, the straightforward
	# average can produce a mean that incorrectly suggests a hue angle in
	# the wrong quadrant, the next lines handle this issue.
	h_m = (h_1 + h_2) * 0.5
	h_d = (h_2 - h_1) * 0.5
	if pi < n :
		if (0.0 < h_d) :
			h_d -= pi
		else :
			h_d += pi
		h_m += pi
	p = 36.0 * h_m - 55.0 * pi
	n = (c_1 + c_2) * 0.5
	n = n * n * n * n * n * n * n
	# The hue rotation correction term is designed to account for the
	# non-linear behavior of hue differences in the blue region.
	r_t = -2.0 * sqrt(n / (n + 6103515625.0)) \
			* sin(pi / 3.0 * exp(p * p / (-25.0 * pi * pi)))
	n = (l_1 + l_2) * 0.5
	n = (n - 50.0) * (n - 50.0)
	# Lightness.
	l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / sqrt(20.0 + n)))
	# These coefficients adjust the impact of different harmonic
	# components on the hue difference calculation.
	t = 1.0	+ 0.24 * sin(2.0 * h_m + pi * 0.5) \
		+ 0.32 * sin(3.0 * h_m + 8.0 * pi / 15.0) \
		- 0.17 * sin(h_m + pi / 3.0) \
		- 0.20 * sin(4.0 * h_m + 3.0 * pi / 20.0)
	n = c_1 + c_2
	# Hue.
	h = 2.0 * sqrt(c_1 * c_2) * sin(h_d) / (k_h * (1.0 + 0.0075 * n * t))
	# Chroma.
	c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n))
	# Returning the square root ensures that the result reflects the actual geometric
	# distance within the color space, which ranges from 0 to approximately 185.
	return sqrt(l * l + h * h + c * c + c * h * r_t)

# These color conversion functions written in Python are released into the public domain.
# They are provided "as is" without any warranty, express or implied.

import math

# rgb in 0..1
def rgb_to_xyz(r, g, b):
	# Apply a gamma correction to each channel
	r = math.pow((r + 0.055) / 1.055, 2.4) if r > 0.0404482362771082 else r / 12.92
	g = math.pow((g + 0.055) / 1.055, 2.4) if g > 0.0404482362771082 else g / 12.92
	b = math.pow((b + 0.055) / 1.055, 2.4) if b > 0.0404482362771082 else b / 12.92

	# Applying linear transformation using RGB to XYZ transformation matrix.
	x = r * 41.24564390896921 + g * 35.7576077643909 + b * 18.043748326639894
	y = r * 21.267285140562248 + g * 71.5152155287818 + b * 7.217499330655958
	z = r * 1.9333895582329317 + g * 11.9192025881303 + b * 95.03040785363677

	return (x, y, z)

def xyz_to_lab(x, y, z):
	# Reference white point (D65)
	refX = 95.047
	refY = 100.000
	refZ = 108.883

	x /= refX
	y /= refY
	z /= refZ

	# Applying the CIE standard transformation
	x = math.pow(x, 1.0 / 3.0) if x > 216.0 / 24389.0 else ((841.0 / 108.0) * x) + (4.0 / 29.0)
	y = math.pow(y, 1.0 / 3.0) if y > 216.0 / 24389.0 else ((841.0 / 108.0) * y) + (4.0 / 29.0)
	z = math.pow(z, 1.0 / 3.0) if z > 216.0 / 24389.0 else ((841.0 / 108.0) * z) + (4.0 / 29.0)

	l = (116.0 * y) - 16.0
	a = 500.0 * (x - y)
	b = 200.0 * (y - z)

	return (l, a, b)

# rgb in 0..1
def rgb_to_lab(r, g, b):
	xyz = rgb_to_xyz(r, g, b)
	return xyz_to_lab(*xyz)

def lab_to_xyz(l, a, b):
	# Reference white point (D65)
	refX = 95.047
	refY = 100.000
	refZ = 108.883

	y = (l + 16.0) / 116.0
	x = a / 500.0 + y
	z = y - b / 200.0

	x3 = x * x * x
	y3 = y * y * y
	z3 = z * z * z

	x = x3 if x3 > 216.0 / 24389.0 else (x - 4.0 / 29.0) / (841.0 / 108.0)
	y = y3 if l > 8.0 else l / (24389.0 / 27.0)
	z = z3 if z3 > 216.0 / 24389.0 else (z - 4.0 / 29.0) / (841.0 / 108.0)

	return (x * refX, y * refY, z * refZ)

def xyz_to_rgb(x, y, z):
	# Applying linear transformation using the XYZ to RGB transformation matrix.
	r = x * 0.032404541621141054 + y * -0.015371385127977166 + z * -0.004985314095560162
	g = x * -0.009692660305051868 + y * 0.018760108454466942 + z * 0.0004155601753034984
	b = x * 0.0005564343095911469 + y * -0.0020402591351675387 + z * 0.010572251882231791

	# Apply gamma correction
	r = 1.055 * math.pow(r, 1.0 / 2.4) - 0.055 if r > 0.0031306684425005883 else 12.92 * r
	g = 1.055 * math.pow(g, 1.0 / 2.4) - 0.055 if g > 0.0031306684425005883 else 12.92 * g
	b = 1.055 * math.pow(b, 1.0 / 2.4) - 0.055 if b > 0.0031306684425005883 else 12.92 * b

	return (r, g, b)

# rgb in 0..1
def lab_to_rgb(l, a, b):
	xyz = lab_to_xyz(l, a, b)
	return xyz_to_rgb(*xyz)

# rgb in 0..255
def hex_to_rgb(s):
	# Also support the short syntax (ie "#FFF") as input.
	if len(s) == 4:
		s = '#' + s[1] + s[1] + s[2] + s[2] + s[3] + s[3]
	n = int(s[1:], 16)
	return ((n >> 16) & 0xff, (n >> 8) & 0xff, n & 0xff)

# rgb in 0..255
def rgb_to_hex(r, g, b):
	# Also provide the short syntax (ie "#FFF") as output.
	s = '#%02x%02x%02x' % (r, g, b)
	return '#' + s[1] + s[3] + s[5]  if s[1] == s[2] and s[3] == s[4] and s[5] == s[6] else s

#####################################
######                      #########
######   CIE ΔE2000 Demo    #########
######                      #########
#####################################

# The goal of this demo is to use the CIEDE2000 function to identify,
# for each hexadecimal color in set 1, the closest hexadecimal color in set 2.

hex_set_1 = [['#ffe4c4', 'bisque'], ['#9acd32', 'yellowgreen'], ['#808080', 'gray'], ['#ff69b4', 'hotpink'], ['#add8e6', 'lightblue'], ['#483d8b', 'darkslateblue'], ['#789', 'lightslategray'], ['#6495ed', 'cornflowerblue'], ['#fffacd', 'lemonchiffon'], ['#ffa07a', 'lightsalmon'], ['#a52a2a', 'brown'], ['#bc8f8f', 'rosybrown'], ['#f5deb3', 'wheat'], ['#48d1cc', 'mediumturquoise'], ['#ffdab9', 'peachpuff'], ['#ffb6c1', 'lightpink'], ['#3cb371', 'mediumseagreen'], ['#228b22', 'forestgreen'], ['#fffaf0', 'floralwhite'], ['#fafad2', 'lightgoldenrodyellow'], ['#90ee90', 'lightgreen'], ['#bdb76b', 'darkkhaki'], ['#daa520', 'goldenrod'], ['#8fbc8f', 'darkseagreen'], ['#ff6347', 'tomato'], ['#ff1493', 'deeppink'], ['#00bfff', 'deepskyblue'], ['#556b2f', 'darkolivegreen'], ['#ff7f50', 'coral'], ['#b22222', 'firebrick'], ['#fffff0', 'ivory'], ['#9400d3', 'darkviolet'], ['#ffffe0', 'lightyellow'], ['#008080', 'teal'], ['#000', 'black'], ['#faf0e6', 'linen'], ['#e9967a', 'darksalmon'], ['#ff8c00', 'darkorange'], ['#2f4f4f', 'darkslategray'], ['#006400', 'darkgreen'], ['#cd5c5c', 'indianred'], ['#808000', 'olive'], ['#6b8e23', 'olivedrab'], ['#4b0082', 'indigo'], ['#ba55d3', 'mediumorchid'], ['#d8bfd8', 'thistle'], ['#00008b', 'darkblue'], ['#ffefd5', 'papayawhip'], ['#7b68ee', 'mediumslateblue'], ['#fdf5e6', 'oldlace'], ['#0ff', 'aqua'], ['#4169e1', 'royalblue'], ['#9932cc', 'darkorchid'], ['#f0f', 'fuchsia'], ['#8b4513', 'saddlebrown'], ['#008b8b', 'darkcyan'], ['#800080', 'purple'], ['#ffebcd', 'blanchedalmond'], ['#00ff7f', 'springgreen'], ['#ffc0cb', 'pink'], ['#20b2aa', 'lightseagreen'], ['#6a5acd', 'slateblue'], ['#98fb98', 'palegreen'], ['#dda0dd', 'plum'], ['#00f', 'blue'], ['#f4a460', 'sandybrown'], ['#0f0', 'lime'], ['#40e0d0', 'turquoise'], ['#dc143c', 'crimson'], ['#fff8dc', 'cornsilk']]
hex_set_2 = [['#faebd7', 'antiquewhite'], ['#fff', 'white'], ['#9370db', 'mediumpurple'], ['#a9a9a9', 'darkgray'], ['#ffa500', 'orange'], ['#1e90ff', 'dodgerblue'], ['#191970', 'midnightblue'], ['#f5fffa', 'mintcream'], ['#a0522d', 'sienna'], ['#deb887', 'burlywood'], ['#e6e6fa', 'lavender'], ['#8a2be2', 'blueviolet'], ['#ffe4e1', 'mistyrose'], ['#ff4500', 'orangered'], ['#afeeee', 'paleturquoise'], ['#f0fff0', 'honeydew'], ['#66cdaa', 'mediumaquamarine'], ['#fff0f5', 'lavenderblush'], ['#32cd32', 'limegreen'], ['#0000cd', 'mediumblue'], ['#c0c0c0', 'silver'], ['#800000', 'maroon'], ['#8b0000', 'darkred'], ['#d2b48c', 'tan'], ['#ffd700', 'gold'], ['#5f9ea0', 'cadetblue'], ['#00ced1', 'darkturquoise'], ['#ff0', 'yellow'], ['#db7093', 'palevioletred'], ['#b8860b', 'darkgoldenrod'], ['#708090', 'slategray'], ['#00fa9a', 'mediumspringgreen'], ['#f08080', 'lightcoral'], ['#dcdcdc', 'gainsboro'], ['#ee82ee', 'violet'], ['#d3d3d3', 'lightgray'], ['#fff5ee', 'seashell'], ['#d2691e', 'chocolate'], ['#f00', 'red'], ['#f5f5dc', 'beige'], ['#b0e0e6', 'powderblue'], ['#cd853f', 'peru'], ['#7fffd4', 'aquamarine'], ['#adff2f', 'greenyellow'], ['#f0e68c', 'khaki'], ['#b0c4de', 'lightsteelblue'], ['#f0f8ff', 'aliceblue'], ['#7fff00', 'chartreuse'], ['#ffdead', 'navajowhite'], ['#2e8b57', 'seagreen'], ['#8b008b', 'darkmagenta'], ['#eee8aa', 'palegoldenrod'], ['#fa8072', 'salmon'], ['#e0ffff', 'lightcyan'], ['#f8f8ff', 'ghostwhite'], ['#da70d6', 'orchid'], ['#696969', 'dimgray'], ['#87cefa', 'lightskyblue'], ['#87ceeb', 'skyblue'], ['#ffe4b5', 'moccasin'], ['#000080', 'navy'], ['#4682b4', 'steelblue'], ['#008000', 'green'], ['#c71585', 'mediumvioletred'], ['#f0ffff', 'azure'], ['#7cfc00', 'lawngreen'], ['#639', 'rebeccapurple'], ['#fffafa', 'snow']]

# Converts the hexadecimal colors to L*a*b* colors.
lab_set_1 = [ rgb_to_lab(*[ i / 255.0 for i in hex_to_rgb(i[0]) ]) for i in hex_set_1 ]
lab_set_2 = [ rgb_to_lab(*[ i / 255.0 for i in hex_to_rgb(i[0]) ]) for i in hex_set_2 ]

for i, lab_1 in enumerate(lab_set_1):
	# For each color of the set 1.
	min_delta_e = 1E+10
	for j, lab_2 in enumerate(lab_set_2):
		# We optionally ignore strictly equal colors, they have a color difference of 0.
		if lab_1[0] == lab_2[0] and lab_1[1] == lab_2[1] and lab_1[2] == lab_2[2]:
			continue
		# We calculate the color difference.
		delta_e = ciede_2000(*lab_1, *lab_2)
		if delta_e < min_delta_e:
			# Based on the difference, we identify the closest color from the set 2.
			min_delta_e = delta_e
			k = j
	# And we display the results.
	hex_1 = hex_set_1[i]
	hex_2 = hex_set_2[k]
	result = "The closest color from " + hex_1[1] + " = " + hex_1[0] + " "
	result += "is " + hex_2[1] + " = " + hex_2[0] + " "
	result += "with a distance of " + str(round(min_delta_e, 5))
	print(result)
