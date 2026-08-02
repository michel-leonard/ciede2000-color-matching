# This function written in Python is not affiliated with the CIE (International Commission on Illumination),
# and is released into the public domain. It is provided "as is" without any warranty, express or implied.

# The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
# "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
def ciede_2000(l_1, a_1, b_1, l_2, a_2, b_2) :
	from math import pi, sqrt, atan2, sin, exp
	# Working in Python with the CIEDE2000 color-difference formula.
	# k_l, k_c, k_h are parametric factors to be adjusted according to
	# different viewing parameters such as textures, backgrounds...
	k_l = k_c = k_h = 1.0
	n = (sqrt(a_1 * a_1 + b_1 * b_1) + sqrt(a_2 * a_2 + b_2 * b_2)) * 0.5
	n = n * n * n * n * n * n * n
	# A factor involving chroma raised to the power of 7 designed to make
	# the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - sqrt(n / (n + 6103515625.0)))
	# Application of the chroma correction factor.
	c_1 = sqrt(a_1 * a_1 * n * n + b_1 * b_1)
	c_2 = sqrt(a_2 * a_2 * n * n + b_2 * b_2)
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
		h_d += pi
		# 📜 Sharma’s formulation doesn’t use the next line, but the one after it,
		# and these two variants differ by ±0.0003 on the final color differences.
		h_m += pi
		# h_m += pi if h_m < pi else -pi
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
	# Returning the square root ensures that dE00 accurately reflects the
	# geometric distance in color space, which can range from 0 to around 185.
	return sqrt(l * l + h * h + c * c + c * h * r_t)

# GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
#   Online Tests : https://michel-leonard.github.io/ciede2000-color-matching

# L1 = 49.5   a1 = 20.1   b1 = -3.5
# L2 = 49.6   a2 = 25.7   b2 = 5.0
# CIE ΔE00 = 6.2225289581 (Bruce Lindbloom, Netflix’s VMAF, ...)
# CIE ΔE00 = 6.2225479808 (Gaurav Sharma, OpenJDK, ...)
# Deviation between implementations ≈ 1.9e-5

# See the source code comments for easy switching between these two widely used ΔE*00 implementation variants.

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

#####################################
######                      #########
######   CIE ΔE2000 Demo    #########
######                      #########
#####################################

# The goal of this demo in Python is to use the CIEDE2000 function to compare two RGB colors.

# Step 1: Define two RGB colors directly as tuples
rgb_1 = (0, 0, 128)   # navy
rgb_2 = (0, 0, 139)   # darkblue

# Step 2: Normalize RGB values (scale 0–255 to 0–1) before converting to Lab
lab_1 = rgb_to_lab(rgb_1[0] / 255.0, rgb_1[1] / 255.0, rgb_1[2] / 255.0)
lab_2 = rgb_to_lab(rgb_2[0] / 255.0, rgb_2[1] / 255.0, rgb_2[2] / 255.0)

# Step 3: Calculate the color difference (ΔE) using the CIEDE2000 formula
delta_e = ciede_2000(lab_1[0], lab_1[1], lab_1[2],
                     lab_2[0], lab_2[1], lab_2[2])

# Step 4: Display the original RGB values
print(f"Color 1 RGB: {rgb_1}")
print(f"Color 2 RGB: {rgb_2}")

# Step 5: Display converted Lab values with formatted precision
print(f"Color 1 Lab: (L={lab_1[0]:.2f}, a={lab_1[1]:.2f}, b={lab_1[2]:.2f})")
print(f"Color 2 Lab: (L={lab_2[0]:.2f}, a={lab_2[1]:.2f}, b={lab_2[2]:.2f})")

# Step 6: Display the calculated color difference
print(f"Delta E (CIEDE2000) = {delta_e:.4f}")

# This shows a ΔE2000 of 1.56
