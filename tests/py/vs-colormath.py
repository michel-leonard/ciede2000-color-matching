import random
import sys
from math import pi, sqrt, hypot, atan2, sin, exp

# This function written in Python is not affiliated with the CIE (International Commission on Illumination),
# and is released into the public domain. It is provided "as is" without any warranty, express or implied.

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

# L1 = 29.52          a1 = 78.5           b1 = 53.728
# L2 = 29.52          a2 = 78.5           b2 = 53.72
# CIE ΔE2000 = ΔE00 = 0.00328275314

# L1 = 99.13          a1 = -59.81         b1 = 126.465
# L2 = 99.13          a2 = -60.0          b2 = 126.465
# CIE ΔE2000 = ΔE00 = 0.05672747898

# L1 = 48.774         a1 = 114.2819       b1 = -19.496
# L2 = 49.54          a2 = 114.2819       b2 = -19.496
# CIE ΔE2000 = ΔE00 = 0.76420996201

# L1 = 21.8           a1 = -96.619        b1 = 23.945
# L2 = 26.12          a2 = -94.0          b2 = 23.945
# CIE ΔE2000 = ΔE00 = 3.16284327223

# L1 = 37.0           a1 = 118.669        b1 = 11.24
# L2 = 43.2146        a2 = 124.16         b2 = 5.0
# CIE ΔE2000 = ΔE00 = 5.88138554587

# L1 = 83.0           a1 = -12.4          b1 = -47.158
# L2 = 75.682         a2 = 8.4            b2 = -72.42
# CIE ΔE2000 = ΔE00 = 9.72338688469

# L1 = 59.2864        a1 = -30.4          b1 = -52.0
# L2 = 59.47          a2 = -74.877        b2 = -37.0
# CIE ΔE2000 = ΔE00 = 16.74899164103

# L1 = 77.0           a1 = -13.988        b1 = -79.0
# L2 = 81.9511        a2 = -88.72         b2 = -123.8
# CIE ΔE2000 = ΔE00 = 20.93451640053

# L1 = 7.44           a1 = 94.9759        b1 = -114.7
# L2 = 2.0            a2 = 27.6653        b2 = -25.64
# CIE ΔE2000 = ΔE00 = 22.57074637891

# L1 = 11.0           a1 = 83.92          b1 = 26.36
# L2 = 0.8            a2 = -115.1         b2 = -58.6
# CIE ΔE2000 = ΔE00 = 137.57559506024

########################################################
########################################################
############                               #############
############         Compare with          #############
############          colormath            #############
############                               #############
########################################################
########################################################

# The goal is to demonstrate that the library produces results identical to colormath.  
# If the results differ by more than a tolerance of 1E-10, a non-zero value will be returned.
# Explore the workflows to see how this code is executed.

def exec_colormath(n):
	import numpy
	import math
	from random import random

	def patch_asscalar(a):
		return a.item()
	setattr(numpy, "asscalar", patch_asscalar)

	from colormath.color_objects import LabColor
	from colormath.color_diff import delta_e_cie2000

	max_diff = -1.0
	worst_case = {}

	for _ in range(n):
		l1 = random() * 100.0
		a1 = random() * 255.0 - 128.0
		b1 = random() * 255.0 - 128.0
		l2 = random() * 100.0
		a2 = random() * 255.0 - 128.0
		b2 = random() * 255.0 - 128.0

		delta1 = delta_e_cie2000(LabColor(l1, a1, b1), LabColor(l2, a2, b2))
		delta2 = ciede_2000(l1, a1, b1, l2, a2, b2)

		if not (math.isfinite(delta1) and math.isfinite(delta2)):
			exit(1)

		diff = abs(delta1 - delta2)
		if diff > max_diff:
			max_diff = diff
			worst_case = {
				'l1': l1,
				'a1': a1,
				'b1': b1,
				'l2': l2,
				'a2': a2,
				'b2': b2,
				'delta1': delta1,
				'delta2': delta2,
				'diff': diff
			}

	print(f"Total runs : {n}")
	print("Worst case : {")
	for k, v in worst_case.items():
		print(f"  {k}: {v},")
	print("}")
	exit(0 if max_diff < 1E-10 else 1)

if __name__ == "__main__":
	n_iterations = int(sys.argv[1]) if 1 < len(sys.argv) and sys.argv[1].rstrip('0123456789') == '' else 10000
	n_iterations = n_iterations if 0 < n_iterations else 10000
	exec_colormath(n_iterations)
