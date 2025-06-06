# This function written in Julia is not affiliated with the CIE (International Commission on Illumination),
# and is released into the public domain. It is provided "as is" without any warranty, express or implied.

using Base.MathConstants
using LinearAlgebra

# The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
# "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
function ciede_2000(l_1::Float64, a_1::Float64, b_1::Float64, l_2::Float64, a_2::Float64, b_2::Float64)::Float64
	# Working in Julia with the CIEDE2000 color-difference formula.
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
	h_1 = atan(b_1, a_1 * n)
	h_2 = atan(b_2, a_2 * n)
	h_1 += 2.0 * π * (h_1 < 0.0)
	h_2 += 2.0 * π * (h_2 < 0.0)
	n = abs(h_2 - h_1)
	# Cross-implementation consistent rounding.
	if π - 1E-14 < n && n < π + 1E-14
		n = π
	end
	# When the hue angles lie in different quadrants, the straightforward
	# average can produce a mean that incorrectly suggests a hue angle in
	# the wrong quadrant, the next lines handle this issue.
	h_m = (h_1 + h_2) * 0.5
	h_d = (h_2 - h_1) * 0.5
	if π < n
		if (0.0 < h_d)
			h_d -= π
		else
			h_d += π
		end
		h_m += π
	end
	p = 36.0 * h_m - 55.0 * π
	n = (c_1 + c_2) * 0.5
	n = n * n * n * n * n * n * n
	# The hue rotation correction term is designed to account for the
	# non-linear behavior of hue differences in the blue region.
	r_t = -2.0 * sqrt(n / (n + 6103515625.0)) *
			sin(π / 3.0 * exp(p * p / (-25.0 * π * π)))
	n = (l_1 + l_2) * 0.5
	n = (n - 50.0) * (n - 50.0)
	# Lightness.
	l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / sqrt(20.0 + n)))
	# These coefficients adjust the impact of different harmonic
	# components on the hue difference calculation.
	t = 1.0	+ 0.24 * sin(2.0 * h_m + π * 0.5) +
		0.32 * sin(3.0 * h_m + 8.0 * π / 15.0) -
		0.17 * sin(h_m + π / 3.0) -
		0.20 * sin(4.0 * h_m + 3.0 * π / 20.0)
	n = c_1 + c_2
	# Hue.
	h = 2.0 * sqrt(c_1 * c_2) * sin(h_d) / (k_h * (1.0 + 0.0075 * n * t))
	# Chroma.
	c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n))
	# Returns the square root so that the Delta E 2000 reflects the actual geometric
	# distance within the color space, which ranges from 0 to approximately 185.
	return sqrt(l * l + h * h + c * c + c * h * r_t)
end

# GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
#  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

# L1 = 32.9795        a1 = -45.4          b1 = 70.7381
# L2 = 32.9795        a2 = -45.4          b2 = 70.8
# CIE ΔE2000 = ΔE00 = 0.01749627827

# L1 = 22.0           a1 = -19.303        b1 = -103.934
# L2 = 22.0           a2 = -19.282        b2 = -104.2
# CIE ΔE2000 = ΔE00 = 0.03403407909

# L1 = 9.0            a1 = 76.0           b1 = 102.8
# L2 = 9.0            a2 = 76.0           b2 = 102.5034
# CIE ΔE2000 = ΔE00 = 0.08693442336

# L1 = 15.0756        a1 = 126.0          b1 = -72.6
# L2 = 15.0756        a2 = 126.0          b2 = -78.1
# CIE ΔE2000 = ΔE00 = 1.31585657116

# L1 = 79.36          a1 = 34.462         b1 = -119.0
# L2 = 79.36          a2 = 41.2           b2 = -123.6249
# CIE ΔE2000 = ΔE00 = 2.35693648837

# L1 = 89.8007        a1 = -84.943        b1 = -92.909
# L2 = 93.7314        a2 = -86.992        b2 = -86.2821
# CIE ΔE2000 = ΔE00 = 2.93231153166

# L1 = 55.85          a1 = 14.2           b1 = 55.711
# L2 = 65.2           a2 = 2.8496         b2 = 55.415
# CIE ΔE2000 = ΔE00 = 11.09420398377

# L1 = 84.3           a1 = 4.6            b1 = -59.0
# L2 = 88.87          a2 = 72.9108        b2 = -126.06
# CIE ΔE2000 = ΔE00 = 18.45381544592

# L1 = 70.01          a1 = 118.1          b1 = -42.4
# L2 = 81.888         a2 = 39.36          b2 = -44.29
# CIE ΔE2000 = ΔE00 = 22.2817739011

# L1 = 66.5           a1 = 82.03          b1 = 20.7084
# L2 = 75.0184        a2 = -127.9         b2 = -101.8
# CIE ΔE2000 = ΔE00 = 138.33502802626
