# Limited Use License – March 1, 2025

# This source code is provided for public use under the following conditions :
# It may be downloaded, compiled, and executed, including in publicly accessible environments.
# Modification is strictly prohibited without the express written permission of the author.

# © Michel Leonard 2025

from math import pi, sqrt, hypot, atan2, sin, exp

# The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
# "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
def ciede_2000(l_1, a_1, b_1, l_2, a_2, b_2):
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
	# Returns the square root so that the Delta E 2000 reflects the actual geometric
	# distance within the color space, which ranges from 0 to approximately 185.
	return sqrt(l * l + h * h + c * c + c * h * r_t)

# GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
#  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

# L1 = 80.39          a1 = 44.5           b1 = 121.0185
# L2 = 80.39          a2 = 44.5           b2 = 121.0
# CIE ΔE2000 = ΔE00 = 0.00393140072

# L1 = 39.0           a1 = 127.2          b1 = -73.6159
# L2 = 39.0           a2 = 127.0          b2 = -73.6159
# CIE ΔE2000 = ΔE00 = 0.03473624555

# L1 = 54.0           a1 = -76.0          b1 = 2.0
# L2 = 54.0           a2 = -73.55         b2 = 9.9215
# CIE ΔE2000 = ΔE00 = 3.76793697674

# L1 = 85.44          a1 = -95.3          b1 = -60.0
# L2 = 86.5           a2 = -90.265        b2 = -76.1
# CIE ΔE2000 = ΔE00 = 4.92249542439

# L1 = 11.8           a1 = 96.87          b1 = 69.07
# L2 = 21.3091        a2 = 116.0          b2 = 106.8
# CIE ΔE2000 = ΔE00 = 10.77374824439

# L1 = 67.0           a1 = -38.3          b1 = 98.0
# L2 = 61.682         a2 = -104.15        b2 = 112.4
# CIE ΔE2000 = ΔE00 = 16.99281039316

# L1 = 30.1           a1 = 77.0           b1 = 11.0
# L2 = 1.0            a2 = 103.2094       b2 = 29.2262
# CIE ΔE2000 = ΔE00 = 20.64402884493

# L1 = 40.0           a1 = 3.96           b1 = 0.68
# L2 = 26.5062        a2 = 14.0           b2 = 32.8497
# CIE ΔE2000 = ΔE00 = 22.18271913437

# L1 = 46.0           a1 = -15.0          b1 = 61.2121
# L2 = 59.61          a2 = 17.33          b2 = 84.45
# CIE ΔE2000 = ΔE00 = 23.83496580284

# L1 = 82.9341        a1 = 128.0          b1 = -118.55
# L2 = 10.9           a2 = -70.16         b2 = 97.4798
# CIE ΔE2000 = ΔE00 = 133.31739649939

#################################################
#################################################
############                         ############
############    CIEDE2000 Driver     ############
############                         ############
#################################################
#################################################

# Reads a CSV file specified as the first command-line argument. For each line, the program
# outputs the original line with the computed Delta E 2000 color difference appended.

#  Example of a CSV input line : 67.24,-14.22,70,65,8,46
#    Corresponding output line : 67.24,-14.22,70,65,8,46,15.46723547943141064

import sys

if len(sys.argv) != 2:
	print("Usage: python ciede-2000-driver.py <filename>")
	sys.exit(1)

with open(sys.argv[1], 'r') as f:
	for line in f:
		line = line.strip()
		if not line:
			continue
		result = ciede_2000(*list(map(float, line.split(','))))
		print(f"{line},{result}")
