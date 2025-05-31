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
# for each RGB color in set 1, the closest RGB color in set 2.

rgb_set_1 = [[255, 228, 196, 'bisque'], [154, 205, 50, 'yellowgreen'], [128, 128, 128, 'gray'], [255, 105, 180, 'hotpink'], [173, 216, 230, 'lightblue'], [72, 61, 139, 'darkslateblue'], [119, 136, 153, 'lightslategray'], [100, 149, 237, 'cornflowerblue'], [255, 250, 205, 'lemonchiffon'], [255, 160, 122, 'lightsalmon'], [165, 42, 42, 'brown'], [188, 143, 143, 'rosybrown'], [245, 222, 179, 'wheat'], [72, 209, 204, 'mediumturquoise'], [255, 218, 185, 'peachpuff'], [255, 182, 193, 'lightpink'], [60, 179, 113, 'mediumseagreen'], [34, 139, 34, 'forestgreen'], [255, 250, 240, 'floralwhite'], [250, 250, 210, 'lightgoldenrodyellow'], [144, 238, 144, 'lightgreen'], [189, 183, 107, 'darkkhaki'], [218, 165, 32, 'goldenrod'], [143, 188, 143, 'darkseagreen'], [255, 99, 71, 'tomato'], [255, 20, 147, 'deeppink'], [0, 191, 255, 'deepskyblue'], [85, 107, 47, 'darkolivegreen'], [255, 127, 80, 'coral'], [178, 34, 34, 'firebrick'], [255, 255, 240, 'ivory'], [148, 0, 211, 'darkviolet'], [255, 255, 224, 'lightyellow'], [0, 128, 128, 'teal'], [0, 0, 0, 'black'], [250, 240, 230, 'linen'], [233, 150, 122, 'darksalmon'], [255, 140, 0, 'darkorange'], [47, 79, 79, 'darkslategray'], [0, 100, 0, 'darkgreen'], [205, 92, 92, 'indianred'], [128, 128, 0, 'olive'], [107, 142, 35, 'olivedrab'], [75, 0, 130, 'indigo'], [186, 85, 211, 'mediumorchid'], [216, 191, 216, 'thistle'], [0, 0, 139, 'darkblue'], [255, 239, 213, 'papayawhip'], [123, 104, 238, 'mediumslateblue'], [253, 245, 230, 'oldlace'], [0, 255, 255, 'aqua'], [65, 105, 225, 'royalblue'], [153, 50, 204, 'darkorchid'], [255, 0, 255, 'fuchsia'], [139, 69, 19, 'saddlebrown'], [0, 139, 139, 'darkcyan'], [128, 0, 128, 'purple'], [255, 235, 205, 'blanchedalmond'], [0, 255, 127, 'springgreen'], [255, 192, 203, 'pink'], [32, 178, 170, 'lightseagreen'], [106, 90, 205, 'slateblue'], [152, 251, 152, 'palegreen'], [221, 160, 221, 'plum'], [0, 0, 255, 'blue'], [244, 164, 96, 'sandybrown'], [0, 255, 0, 'lime'], [64, 224, 208, 'turquoise'], [220, 20, 60, 'crimson'], [255, 248, 220, 'cornsilk']]
rgb_set_2 = [[250, 235, 215, 'antiquewhite'], [255, 255, 255, 'white'], [147, 112, 219, 'mediumpurple'], [169, 169, 169, 'darkgray'], [255, 165, 0, 'orange'], [30, 144, 255, 'dodgerblue'], [25, 25, 112, 'midnightblue'], [245, 255, 250, 'mintcream'], [160, 82, 45, 'sienna'], [222, 184, 135, 'burlywood'], [230, 230, 250, 'lavender'], [138, 43, 226, 'blueviolet'], [255, 228, 225, 'mistyrose'], [255, 69, 0, 'orangered'], [175, 238, 238, 'paleturquoise'], [240, 255, 240, 'honeydew'], [102, 205, 170, 'mediumaquamarine'], [255, 240, 245, 'lavenderblush'], [50, 205, 50, 'limegreen'], [0, 0, 205, 'mediumblue'], [192, 192, 192, 'silver'], [128, 0, 0, 'maroon'], [139, 0, 0, 'darkred'], [210, 180, 140, 'tan'], [255, 215, 0, 'gold'], [95, 158, 160, 'cadetblue'], [0, 206, 209, 'darkturquoise'], [255, 255, 0, 'yellow'], [219, 112, 147, 'palevioletred'], [184, 134, 11, 'darkgoldenrod'], [112, 128, 144, 'slategray'], [0, 250, 154, 'mediumspringgreen'], [240, 128, 128, 'lightcoral'], [220, 220, 220, 'gainsboro'], [238, 130, 238, 'violet'], [211, 211, 211, 'lightgray'], [255, 245, 238, 'seashell'], [210, 105, 30, 'chocolate'], [255, 0, 0, 'red'], [245, 245, 220, 'beige'], [176, 224, 230, 'powderblue'], [205, 133, 63, 'peru'], [127, 255, 212, 'aquamarine'], [173, 255, 47, 'greenyellow'], [240, 230, 140, 'khaki'], [176, 196, 222, 'lightsteelblue'], [240, 248, 255, 'aliceblue'], [127, 255, 0, 'chartreuse'], [255, 222, 173, 'navajowhite'], [46, 139, 87, 'seagreen'], [139, 0, 139, 'darkmagenta'], [238, 232, 170, 'palegoldenrod'], [250, 128, 114, 'salmon'], [224, 255, 255, 'lightcyan'], [248, 248, 255, 'ghostwhite'], [218, 112, 214, 'orchid'], [105, 105, 105, 'dimgray'], [135, 206, 250, 'lightskyblue'], [135, 206, 235, 'skyblue'], [255, 228, 181, 'moccasin'], [0, 0, 128, 'navy'], [70, 130, 180, 'steelblue'], [0, 128, 0, 'green'], [199, 21, 133, 'mediumvioletred'], [240, 255, 255, 'azure'], [124, 252, 0, 'lawngreen'], [102, 51, 153, 'rebeccapurple'], [255, 250, 250, 'snow']]

# Converts the RGB colors to L*a*b* colors.
lab_set_1 = [ rgb_to_lab(i[0] / 255.0, i[1] / 255.0, i[2] / 255.0) for i in rgb_set_1 ]
lab_set_2 = [ rgb_to_lab(i[0] / 255.0, i[1] / 255.0, i[2] / 255.0) for i in rgb_set_2 ]

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
	rgb_1 = rgb_set_1[i]
	rgb_2 = rgb_set_2[k]
	result = "The closest color from " + rgb_1[3] + " = RGB(" + ", ".join(map(str, rgb_1[:-1])) + ") "
	result += "is " + rgb_2[3] + " = RGB(" + ", ".join(map(str, rgb_2[:-1])) + ") "
	result += "with a distance of " + str(round(min_delta_e, 5))
	print(result)
