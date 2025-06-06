# This function written in AWK is not affiliated with the CIE (International Commission on Illumination),
# and is released into the public domain. It is provided "as is" without any warranty, express or implied.

BEGIN {
	# k_l, k_c, k_h are parametric factors to be adjusted according to
	# different viewing parameters such as textures, backgrounds...
	k_l = k_c = k_h = 1.0
	FS = ","
	M_PI = 3.14159265358979323846264338328
}

{
	# Receives a 6-column CSV file through a pipe and adds the color difference as the last column.
	sub(/\r$/, "") # Normalize Windows files
	printf("%s,%.15g\n", $0, ciede_2000($1, $2, $3, $4, $5, $6))
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

# L1 = 70.87          a1 = -113.0409      b1 = 82.8835
# L2 = 70.87          a2 = -113.0         b2 = 82.8835
# CIE ΔE2000 = ΔE00 = 0.00764787222

# L1 = 98.9097        a1 = 73.17          b1 = -24.0
# L2 = 98.9097        a2 = 73.17          b2 = -23.8282
# CIE ΔE2000 = ΔE00 = 0.06260808019

# L1 = 31.6           a1 = -42.91         b1 = 66.0
# L2 = 34.635         a2 = -42.91         b2 = 65.0
# CIE ΔE2000 = ΔE00 = 2.45620796751

# L1 = 67.26          a1 = -124.947       b1 = -114.3691
# L2 = 72.1           a2 = -117.0         b2 = -114.3691
# CIE ΔE2000 = ΔE00 = 3.99512367078

# L1 = 21.402         a1 = 23.9           b1 = -72.884
# L2 = 21.402         a2 = 23.9           b2 = -63.0
# CIE ΔE2000 = ΔE00 = 4.18029933008

# L1 = 83.4035        a1 = -20.631        b1 = 67.8482
# L2 = 90.516         a2 = -20.631        b2 = 66.0
# CIE ΔE2000 = ΔE00 = 4.61639402068

# L1 = 89.8201        a1 = -14.01         b1 = 100.478
# L2 = 95.1074        a2 = -22.2914       b2 = 114.0
# CIE ΔE2000 = ΔE00 = 4.91799338752

# L1 = 72.553         a1 = 80.0           b1 = -97.8
# L2 = 79.1           a2 = 77.33          b2 = -104.0
# CIE ΔE2000 = ΔE00 = 5.49964056274

# L1 = 43.1434        a1 = 77.0           b1 = -122.6115
# L2 = 26.4           a2 = 66.08          b2 = -89.0
# CIE ΔE2000 = ΔE00 = 15.80685586552

# L1 = 44.8554        a1 = -45.8332       b1 = -8.0
# L2 = 30.7           a2 = -84.44         b2 = -58.68
# CIE ΔE2000 = ΔE00 = 22.29433000045
