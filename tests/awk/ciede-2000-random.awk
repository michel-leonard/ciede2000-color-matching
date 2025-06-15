# This function written in AWK is not affiliated with the CIE (International Commission on Illumination),
# and is released into the public domain. It is provided "as is" without any warranty, express or implied.

BEGIN {
	# k_l, k_c, k_h are parametric factors to be adjusted according to
	# different viewing parameters such as textures, backgrounds...
	k_l = k_c = k_h = 1.0
	M_PI = 3.14159265358979323846264338328
	
	###############################################
	###############################################
	#######                                 #######
	#######           CIEDE 2000            #######
	#######      Testing Random Colors      #######
	#######                                 #######
	###############################################
	###############################################
	
	# This program outputs a CSV file to standard output, with its length determined by the first CLI argument.
	# Each line contains seven columns:
	# - Three columns for the standard L*a*b* color
	# - Three columns for the sample L*a*b* color
	# - One column for the Delta E 2000 color difference between the standard and sample
	# The output can be verified in two ways:
	# - With the C driver, which provides a dedicated verification feature
	# - By using the JavaScript validator at https://michel-leonard.github.io/ciede2000-color-matching

	n_iterations = ARGV[1]
	if (n_iterations !~ /^[1-9][0-9]*$/)
		n_iterations = 10000
	delete ARGV[1]
	srand()
	for (i = 0; i < n_iterations; ++i) {
		l_1 = int(rand() * 10000.0) / 100.0
		a_1 = int(rand() * 25600.0 - 12800.0) / 100.0
		b_1 = int(rand() * 25600.0 - 12800.0) / 100.0
		l_2 = int(rand() * 10000.0) / 100.0
		a_2 = int(rand() * 25600.0 - 12800.0) / 100.0
		b_2 = int(rand() * 25600.0 - 12800.0) / 100.0
		delta_e = ciede_2000(l_1, a_1, b_1, l_2, a_2, b_2)
		printf("%g,%g,%g,%g,%g,%g,%.17g\n", l_1, a_1, b_1, l_2, a_2, b_2, delta_e)
	}
}

# The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
# "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
function ciede_2000(l_1, a_1, b_1, l_2, a_2, b_2) {
	# Working in AWK with the CIEDE2000 color-difference formula.
	n = (sqrt(a_1 * a_1 + b_1 * b_1) + sqrt(a_2 * a_2 + b_2 * b_2)) * 0.5
	n = n * n * n * n * n * n * n
	# A factor involving chroma raised to the power of 7 designed to make
	# the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - sqrt(n / (n + 6103515625.0)))
	# Since hypot is not available, sqrt is used here to calculate the
	# Euclidean distance, without avoiding overflow/underflow.
	c_1 = sqrt(a_1 * a_1 * n * n + b_1 * b_1)
	c_2 = sqrt(a_2 * a_2 * n * n + b_2 * b_2)
	# atan2 is preferred over atan because it accurately computes the angle of
	# a point (x, y) in all quadrants, handling the signs of both coordinates.
	h_1 = atan2(b_1, a_1 * n)
	h_2 = atan2(b_2, a_2 * n)
	if (h_1 < 0.0) h_1 += 2.0 * M_PI
	h_2 += 2.0 * M_PI * (h_2 < 0.0)
	n = h_2 < h_1 ? h_1 - h_2 : h_2 - h_1
	# Cross-implementation consistent rounding.
	if (M_PI - 1E-14 < n && n < M_PI + 1E-14)
		n = M_PI
	# When the hue angles lie in different quadrants, the straightforward
	# average can produce a mean that incorrectly suggests a hue angle in
	# the wrong quadrant, the next lines handle this issue.
	h_m = (h_1 + h_2) * 0.5
	h_d = (h_2 - h_1) * 0.5
	if (M_PI < n) {
		if (0.0 < h_d)
			h_d -= M_PI
		else
			h_d += M_PI
		h_m += M_PI
	}
	p = 36.0 * h_m - 55.0 * M_PI
	n = (c_1 + c_2) * 0.5
	n = n * n * n * n * n * n * n
	# The hue rotation correction term is designed to account for the
	# non-linear behavior of hue differences in the blue region.
	r_t = -2.0 * sqrt(n / (n + 6103515625.0)) \
			* sin(M_PI / 3.0 * exp(p * p / (-25.0 * M_PI * M_PI)))
	n = (l_1 + l_2) * 0.5
	n = (n - 50.0) * (n - 50.0)
	# Lightness.
	l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / sqrt(20.0 + n)))
	# These coefficients adjust the impact of different harmonic
	# components on the hue difference calculation.
	t = 1.0	+ 0.24 * sin(2.0 * h_m + M_PI * 0.5) \
		+ 0.32 * sin(3.0 * h_m + 8.0 * M_PI / 15.0) \
		- 0.17 * sin(h_m + M_PI / 3.0) \
		- 0.20 * sin(4.0 * h_m + 3.0 * M_PI / 20.0)
	n = c_1 + c_2
	# Hue.
	h = 2.0 * sqrt(c_1 * c_2) * sin(h_d) / (k_h * (1.0 + 0.0075 * n * t))
	# Chroma.
	c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n))
	# Returns the square root so that the Delta E 2000 reflects the actual geometric
	# distance within the color space, which ranges from 0 to approximately 185.
	return sqrt(l * l + h * h + c * c + c * h * r_t)
}

# GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
#  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

# L1 = 16.0           a1 = -79.5          b1 = 102.0
# L2 = 16.0           a2 = -79.5          b2 = 102.1
# CIE ΔE2000 = ΔE00 = 0.02144913929

# L1 = 20.1           a1 = 92.0           b1 = -93.2731
# L2 = 22.7           a2 = 92.0           b2 = -93.2731
# CIE ΔE2000 = ΔE00 = 1.82603567943

# L1 = 73.0           a1 = 99.68          b1 = 44.935
# L2 = 73.0           a2 = 107.7          b2 = 51.75
# CIE ΔE2000 = ΔE00 = 1.99168708059

# L1 = 84.31          a1 = -79.872        b1 = 81.0
# L2 = 88.0           a2 = -79.872        b2 = 80.0
# CIE ΔE2000 = ΔE00 = 2.41133631034

# L1 = 72.59          a1 = 15.0           b1 = -11.0352
# L2 = 74.6787        a2 = 19.14          b2 = -17.0
# CIE ΔE2000 = ΔE00 = 4.14379929235

# L1 = 10.7076        a1 = 112.238        b1 = -87.0
# L2 = 9.67           a2 = 108.902        b2 = -31.9469
# CIE ΔE2000 = ΔE00 = 14.00948455226

# L1 = 23.0           a1 = -56.332        b1 = -12.5444
# L2 = 20.272         a2 = -124.059       b2 = -61.0
# CIE ΔE2000 = ΔE00 = 17.2395710964

# L1 = 94.1164        a1 = 85.7           b1 = 59.3
# L2 = 64.3727        a2 = 58.5           b2 = 28.0
# CIE ΔE2000 = ΔE00 = 23.22101318896

# L1 = 9.3827         a1 = -66.0888       b1 = 50.112
# L2 = 81.0           a2 = 88.0           b2 = -42.4
# CIE ΔE2000 = ΔE00 = 118.85423680408

# L1 = 51.477         a1 = -122.5         b1 = -88.5
# L2 = 81.0           a2 = 109.8013       b2 = 51.2
# CIE ΔE2000 = ΔE00 = 142.45453458159
