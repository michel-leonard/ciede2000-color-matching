# Limited Use License – March 1, 2025

# This source code is provided for public use under the following conditions :
# It may be downloaded, compiled, and executed, including in publicly accessible environments.
# Modification is strictly prohibited without the express written permission of the author.

# © Michel Leonard 2025

# The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
# "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
def ciede_2000(l_1, a_1, b_1, l_2, a_2, b_2)
	# Working in Ruby with the CIEDE2000 color-difference formula.
	# k_l, k_c, k_h are parametric factors to be adjusted according to
	# different viewing parameters such as textures, backgrounds...
	k_l = k_c = k_h = 1.0
	n = (Math.hypot(a_1, b_1) + Math.hypot(a_2, b_2)) * 0.5
	n = n * n * n * n * n * n * n
	# A factor involving chroma raised to the power of 7 designed to make
	# the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - Math.sqrt(n / (n + 6103515625.0)))
	# hypot calculates the Euclidean distance while avoiding overflow/underflow.
	c_1 = Math.hypot(a_1 * n, b_1)
	c_2 = Math.hypot(a_2 * n, b_2)
	# atan2 is preferred over atan because it accurately computes the angle of
	# a point (x, y) in all quadrants, handling the signs of both coordinates.
	h_1 = Math.atan2(b_1, a_1 * n)
	h_2 = Math.atan2(b_2, a_2 * n)
	h_1 += 2.0 * Math::PI if h_1 < 0.0
	h_2 += 2.0 * Math::PI if h_2 < 0.0
	n = (h_2 - h_1).abs
	# Cross-implementation consistent rounding.
	n = Math::PI if Math::PI - 1E-14 < n && n < Math::PI + 1E-14
	# When the hue angles lie in different quadrants, the straightforward
	# average can produce a mean that incorrectly suggests a hue angle in
	# the wrong quadrant, the next lines handle this issue.
	h_m = (h_1 + h_2) * 0.5
	h_d = (h_2 - h_1) * 0.5
	if Math::PI < n
		if 0.0 < h_d
			h_d -= Math::PI
		else
			h_d += Math::PI
		end
		h_m += Math::PI
	end
	p = 36.0 * h_m - 55.0 * Math::PI
	n = (c_1 + c_2) * 0.5
	n = n * n * n * n * n * n * n
	# The hue rotation correction term is designed to account for the
	# non-linear behavior of hue differences in the blue region.
	r_t = -2.0 * Math.sqrt(n / (n + 6103515625.0)) \
		* Math.sin(Math::PI / 3.0 * Math.exp(p * p / (-25.0 * Math::PI * Math::PI)))
	n = (l_1 + l_2) * 0.5
	n = (n - 50.0) * (n - 50.0)
	# Lightness.
	l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / Math.sqrt(20.0 + n)))
	# These coefficients adjust the impact of different harmonic
	# components on the hue difference calculation.
	t = 1.0 + 0.24 * Math.sin(2.0 * h_m + Math::PI * 0.5) \
		+ 0.32 * Math.sin(3.0 * h_m + 8.0 * Math::PI / 15.0) \
		- 0.17 * Math.sin(h_m + Math::PI / 3.0) \
		- 0.20 * Math.sin(4.0 * h_m + 3.0 * Math::PI / 20.0)
	n = c_1 + c_2
	# Hue.
	h = 2.0 * Math.sqrt(c_1 * c_2) * Math.sin(h_d) / (k_h * (1.0 + 0.0075 * n * t))
	# Chroma.
	c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n))
	# Returns the square root so that the Delta E 2000 reflects the actual geometric
	# distance within the color space, which ranges from 0 to approximately 185.
	Math.sqrt(l * l + h * h + c * c + c * h * r_t)
end

# GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
#  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

# L1 = 96.0           a1 = 65.76          b1 = 55.116
# L2 = 96.0           a2 = 65.76          b2 = 55.1201
# CIE ΔE2000 = ΔE00 = 0.00172812224

# L1 = 49.884         a1 = 19.0934        b1 = 30.8
# L2 = 49.91          a2 = 19.0934        b2 = 30.8
# CIE ΔE2000 = ΔE00 = 0.0259990751

# L1 = 47.0           a1 = 1.143          b1 = -33.0531
# L2 = 49.27          a2 = 1.143          b2 = -33.0531
# CIE ΔE2000 = ΔE00 = 2.24581807477

# L1 = 8.0            a1 = -22.1467       b1 = -80.24
# L2 = 8.0            a2 = -27.7          b2 = -87.0531
# CIE ΔE2000 = ΔE00 = 2.5141935745

# L1 = 48.83          a1 = -64.848        b1 = 102.6
# L2 = 48.83          a2 = -56.086        b2 = 102.6
# CIE ΔE2000 = ΔE00 = 2.64122982196

# L1 = 89.0           a1 = 32.2838        b1 = 64.8
# L2 = 90.0           a2 = 43.92          b2 = 70.0
# CIE ΔE2000 = ΔE00 = 5.02554924643

# L1 = 17.9315        a1 = -48.44         b1 = 53.3547
# L2 = 3.0            a2 = -33.5          b2 = 45.53
# CIE ΔE2000 = ΔE00 = 10.62879400135

# L1 = 20.3915        a1 = -35.0          b1 = -81.0
# L2 = 28.8           a2 = -6.6           b2 = -94.0
# CIE ΔE2000 = ΔE00 = 12.66837687315

# L1 = 14.0           a1 = -68.29         b1 = -7.0
# L2 = 77.6           a2 = -14.3          b2 = 97.2
# CIE ΔE2000 = ΔE00 = 74.04271583078

# L1 = 91.0505        a1 = 107.2          b1 = -35.376
# L2 = 16.995         a2 = -66.247        b2 = -62.08
# CIE ΔE2000 = ΔE00 = 125.12434605001

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

if ARGV[0]
	File.foreach(ARGV[0]) do |line|
		line.chomp!
		fields = line.split(',')
		l1, a1, b1, l2, a2, b2 = fields.map(&:to_f)
		delta_e = ciede_2000(l1, a1, b1, l2, a2, b2)
		puts "#{line},#{'%.17f' % delta_e}"
	end
end
