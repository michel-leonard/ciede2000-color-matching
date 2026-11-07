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

	# This AWK program outputs a CSV file to standard output, with its length determined by the first CLI argument.
	# Each line contains seven columns :
	# - Three columns for the random standard L*a*b* color
	# - Three columns for the random sample L*a*b* color
	# - And the seventh column for the precise Delta E 2000 color difference between the standard and sample
	# The output will be correct, this can be verified :
	# - With the C driver, which provides a dedicated verification feature
	# - By using the JavaScript validator at https://michel-leonard.github.io/ciede2000-color-matching

	n_iterations = ARGV[1]
	if (n_iterations !~ /^[1-9][0-9]*$/)
		n_iterations = 10000.0
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
	# Application of the chroma correction factor.
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
		h_d += M_PI
		# 📜 Sharma’s formulation doesn’t use the next line, but the one after it,
		# and these two variants differ by ±0.0003 on the final color differences.
		h_m += M_PI
		# h_m += ((h_m < M_PI) - (M_PI <= h_m)) * M_PI
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
	# Returning the square root ensures that dE00 accurately reflects the
	# geometric distance in color space, which can range from 0 to around 185.
	return sqrt(l * l + h * h + c * c + c * h * r_t)
}

# GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
#   Online Tests : https://michel-leonard.github.io/ciede2000-color-matching

# L1 = 52.3   a1 = 42.9   b1 = 2.2
# L2 = 52.5   a2 = 38.0   b2 = -1.9
# CIE ΔE00 = 2.8626009287 (Bruce Lindbloom, Netflix’s VMAF, ...)
# CIE ΔE00 = 2.8626143442 (Gaurav Sharma, OpenJDK, ...)
# Deviation between implementations ≈ 1.3e-5

# See the source code comments for easy switching between these two widely used ΔE*00 implementation variants.
