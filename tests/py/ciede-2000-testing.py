# This function written in Python is not affiliated with the CIE (International Commission on Illumination),
# and is released into the public domain. It is provided "as is" without any warranty, express or implied.

# The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
# "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
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
	# Returns the square root so that the Delta E 2000 reflects the actual geometric
	# distance within the color space, which ranges from 0 to approximately 185.
	return sqrt(l * l + h * h + c * c + c * h * r_t)

# GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
#  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

# L1 = 11.82          a1 = 70.0           b1 = -117.827
# L2 = 11.82          a2 = 70.0           b2 = -117.75
# CIE ΔE2000 = ΔE00 = 0.0249185622

# L1 = 18.4           a1 = -78.0          b1 = -118.393
# L2 = 18.4           a2 = -78.0          b2 = -118.2
# CIE ΔE2000 = ΔE00 = 0.03118386136

# L1 = 11.2375        a1 = -66.613        b1 = -41.616
# L2 = 11.2375        a2 = -61.9922       b2 = -41.616
# CIE ΔE2000 = ΔE00 = 1.34187960128

# L1 = 41.7           a1 = -35.065        b1 = -120.146
# L2 = 43.4743        a2 = -35.065        b2 = -120.146
# CIE ΔE2000 = ΔE00 = 1.62005709846

# L1 = 72.0           a1 = -91.969        b1 = -36.0
# L2 = 72.0           a2 = -82.93         b2 = -36.0
# CIE ΔE2000 = ΔE00 = 2.09863453389

# L1 = 76.08          a1 = 63.8199        b1 = 81.0
# L2 = 77.11          a2 = 63.8199        b2 = 72.32
# CIE ΔE2000 = ΔE00 = 3.15165462586

# L1 = 38.133         a1 = 96.4709        b1 = -19.5
# L2 = 41.5825        a2 = 86.901         b2 = -10.251
# CIE ΔE2000 = ΔE00 = 4.48187292257

# L1 = 15.0           a1 = -96.05         b1 = 32.0
# L2 = 0.1            a2 = -121.6572      b2 = 81.6
# CIE ΔE2000 = ΔE00 = 14.77576441748

# L1 = 52.9           a1 = -68.31         b1 = 1.1917
# L2 = 75.05          a2 = -93.1          b2 = 20.0
# CIE ΔE2000 = ΔE00 = 20.50190103403

# L1 = 44.0           a1 = -75.656        b1 = -30.58
# L2 = 94.7           a2 = 19.147         b2 = 69.18
# CIE ΔE2000 = ΔE00 = 66.46967261215

#####################################################################
#####################################################################
#####################################################################
####################                         ########################
####################         TESTING         ########################
####################                         ########################
#####################################################################
#####################################################################
#####################################################################
#####################################################################

# The output is intended to be checked by the Large-Scale validator
# at https://michel-leonard.github.io/ciede2000-color-matching

import sys
import random

# Generate a random float rounded to 0, 1, or 2 decimal places
def random_lab_value(min_val, max_val):
	value = random.uniform(min_val, max_val)
	decimals = random.choice([0, 1, 2])
	return round(value, decimals)

# Parse command-line argument for n_iterations
n_iterations = int(sys.argv[1]) if 1 < len(sys.argv) and sys.argv[1].rstrip('0123456789') == '' else 10000
n_iterations = n_iterations if 0 < n_iterations else 10000

for _ in range(n_iterations):
	# Generate random LAB values with random rounding
	l_1 = random_lab_value(0.0, 100.0)
	a_1 = random_lab_value(-128.0, 128.0)
	b_1 = random_lab_value(-128.0, 128.0)
	l_2 = random_lab_value(0.0, 100.0)
	a_2 = random_lab_value(-128.0, 128.0)
	b_2 = random_lab_value(-128.0, 128.0)

	delta_e = ciede_2000(l_1, a_1, b_1, l_2, a_2, b_2)

	# Output values in CSV format
	print(f'{l_1},{a_1},{b_1},{l_2},{a_2},{b_2},{delta_e}')
