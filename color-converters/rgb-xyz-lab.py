# These color conversion functions written in Python are released into the public domain.
# They are provided "as is" without any warranty, express or implied.

import math

# rgb in 0..1
def rgb_to_xyz(r, g, b):
	# Apply a gamma correction to each channel
	r = math.pow((r + 0.055) / 1.055, 2.4) if r > 0.040448236277105097 else r / 12.92
	g = math.pow((g + 0.055) / 1.055, 2.4) if g > 0.040448236277105097 else g / 12.92
	b = math.pow((b + 0.055) / 1.055, 2.4) if b > 0.040448236277105097 else b / 12.92

	# Applying linear transformation using RGB to XYZ transformation matrix.
	x = r * 41.24564390896921145 + g * 35.75760776439090507 + b * 18.04374830853290341
	y = r * 21.26728514056222474 + g * 71.51521552878181013 + b * 7.21749933075596513
	z = r * 1.93338955823293176 + g * 11.91919550818385936 + b * 95.03040770337479886

	return (x, y, z)

def xyz_to_lab(x, y, z):
	# Reference white point : D65 2° Standard observer
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
	# Reference white point : D65 2° Standard observer
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
	r = x * 0.032404541621141049051 + y * -0.015371385127977165753 + z * -0.004985314095560160079
	g = x * -0.009692660305051867686 + y * 0.018760108454466942288 + z * 0.00041556017530349983
	b = x * 0.000556434309591145522 + y * -0.002040259135167538416 + z * 0.010572251882231790398

	# Apply gamma correction
	r = 1.055 * math.pow(r, 1.0 / 2.4) - 0.055 if r > 0.003130668442500634 else 12.92 * r
	g = 1.055 * math.pow(g, 1.0 / 2.4) - 0.055 if g > 0.003130668442500634 else 12.92 * g
	b = 1.055 * math.pow(b, 1.0 / 2.4) - 0.055 if b > 0.003130668442500634 else 12.92 * b

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

# GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching

# Constants used in Color Conversion :
# 216.0 / 24389.0 = 0.0088564516790356308171716757554635286399606379925376194185903481077
# 841.0 / 108.0 = 7.78703703703703703703703703703703703703703703703703703703703703703703703703
# 4.0 / 29.0 = 0.13793103448275862068965517241379310344827586206896551724137931034482758620
# 24389.0 / 27.0 = 903.296296296296296296296296296296296296296296296296296296296296296296296296
# 1.0 / 2.4 = 0.41666666666666666666666666666666666666666666666666666666666666666666666666
# To get 0.040448236277105097132567243294938 we perform x/12.92 = ((x+0.055)/1.055)^2.4
# To get 0.00313066844250063403284123841596 we perform 12.92*x = 1.055*x^(1/2.4)-0.055
