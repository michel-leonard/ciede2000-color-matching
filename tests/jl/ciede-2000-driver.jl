# Limited Use License – March 1, 2025

# This source code is provided for public use under the following conditions :
# It may be downloaded, compiled, and executed, including in publicly accessible environments.
# Modification is strictly prohibited without the express written permission of the author.

# © Michel Leonard 2025

###########################################################################################
######                                                                               ######
######          Using 32-bit numbers results in an almost always negligible          ######
######             difference of ±0.0002 in the calculated Delta E 2000.             ######
######                                                                               ######
###########################################################################################

# The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
# "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
function ciede_2000(l_1::T, a_1::T, b_1::T, l_2::T, a_2::T, b_2::T)::T where T<:AbstractFloat
	# Working in Julia with the CIEDE2000 color-difference formula.
	# k_l, k_c, k_h are parametric factors to be adjusted according to
	# different viewing parameters such as textures, backgrounds...
	k_l = k_c = k_h = T(1.0)
	n = (hypot(a_1, b_1) + hypot(a_2, b_2)) * T(0.5)
	n = n * n * n * n * n * n * n
	# A factor involving chroma raised to the power of 7 designed to make
	# the influence of chroma on the total color difference more accurate.
	n = T(1.0) + T(0.5) * (T(1.0) - sqrt(n / (n + T(6103515625.0))))
	# hypot calculates the Euclidean distance while avoiding overflow/underflow.
	c_1 = hypot(a_1 * n, b_1)
	c_2 = hypot(a_2 * n, b_2)
	# atan2 is preferred over atan because it accurately computes the angle of
	# a point (x, y) in all quadrants, handling the signs of both coordinates.
	h_1 = atan(b_1, a_1 * n)
	h_2 = atan(b_2, a_2 * n)
	h_1 += T(2.0) * T(π) * (h_1 < T(0.0))
	h_2 += T(2.0) * T(π) * (h_2 < T(0.0))
	n = abs(h_2 - h_1)
	# Cross-implementation consistent rounding.
	if T(π) - T(1E-14) < n && n < T(π) + T(1E-14)
		n = T(π)
	end
	# When the hue angles lie in different quadrants, the straightforward
	# average can produce a mean that incorrectly suggests a hue angle in
	# the wrong quadrant, the next lines handle this issue.
	h_m = (h_1 + h_2) * T(0.5)
	h_d = (h_2 - h_1) * T(0.5)
	if T(π) < n
		if (T(0.0) < h_d)
			h_d -= T(π)
		else
			h_d += T(π)
		end
		h_m += T(π)
	end
	p = T(36.0) * h_m - T(55.0) * T(π)
	n = (c_1 + c_2) * T(0.5)
	n = n * n * n * n * n * n * n
	# The hue rotation correction term is designed to account for the
	# non-linear behavior of hue differences in the blue region.
	r_t = T(-2.0) * sqrt(n / (n + T(6103515625.0))) *
			sin(T(π) / T(3.0) * exp(p * p / (T(-25.0) * T(π) * T(π))))
	n = (l_1 + l_2) * T(0.5)
	n = (n - T(50.0)) * (n - T(50.0))
	# Lightness.
	l = (l_2 - l_1) / (k_l * (T(1.0) + T(0.015) * n / sqrt(T(20.0) + n)))
	# These coefficients adjust the impact of different harmonic
	# components on the hue difference calculation.
	t = T(1.0)	+ T(0.24) * sin(T(2.0) * h_m + T(π) * T(0.5)) +
		T(0.32) * sin(T(3.0) * h_m + T(8.0) * T(π) / T(15.0)) -
		T(0.17) * sin(h_m + T(π) / T(3.0)) -
		T(0.20) * sin(T(4.0) * h_m + T(3.0) * T(π) / T(20.0))
	n = c_1 + c_2
	# Hue.
	h = T(2.0) * sqrt(c_1 * c_2) * sin(h_d) / (k_h * (T(1.0) + T(0.0075) * n * t))
	# Chroma.
	c = (c_2 - c_1) / (k_c * (T(1.0) + T(0.0225) * n))
	# Returns the square root so that the Delta E 2000 reflects the actual geometric
	# distance within the color space, which ranges from 0 to approximately 185.
	return sqrt(l * l + h * h + c * c + c * h * r_t)
end

# GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
#  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

# L1 = 38.843         a1 = -59.0          b1 = 77.908
# L2 = 38.843         a2 = -59.0          b2 = 78.0
# CIE ΔE2000 = ΔE00 = 0.0240636919

# L1 = 23.0           a1 = -32.108        b1 = 109.0
# L2 = 23.0           a2 = -32.108        b2 = 109.5
# CIE ΔE2000 = ΔE00 = 0.09788023571

# L1 = 75.94          a1 = -115.9516      b1 = 109.0
# L2 = 78.0           a2 = -115.9516      b2 = 107.1716
# CIE ΔE2000 = ΔE00 = 1.5138291195

# L1 = 6.8            a1 = 114.042        b1 = -122.9
# L2 = 10.92          a2 = 114.042        b2 = -113.0
# CIE ΔE2000 = ΔE00 = 3.58111946871

# L1 = 56.251         a1 = -8.9           b1 = -21.37
# L2 = 56.251         a2 = -8.9           b2 = -13.0
# CIE ΔE2000 = ΔE00 = 4.68207780817

# L1 = 59.9           a1 = -102.0         b1 = 86.5632
# L2 = 56.9225        a2 = -96.87         b2 = 110.2696
# CIE ΔE2000 = ΔE00 = 6.248525079

# L1 = 20.52          a1 = -109.3         b1 = 22.0
# L2 = 29.3           a2 = -110.255       b2 = 41.6
# CIE ΔE2000 = ΔE00 = 8.86777340222

# L1 = 16.0           a1 = 51.24          b1 = 48.96
# L2 = 20.0944        a2 = 9.75           b2 = 20.08
# CIE ΔE2000 = ΔE00 = 18.69394475489

# L1 = 32.7895        a1 = -51.0          b1 = -57.469
# L2 = 3.7499         a2 = -41.12         b2 = -118.183
# CIE ΔE2000 = ΔE00 = 23.81482278358

# L1 = 29.0           a1 = 65.8301        b1 = -4.0
# L2 = 93.0           a2 = -124.0         b2 = -38.3111
# CIE ΔE2000 = ΔE00 = 125.8065958916

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

if length(ARGS) > 0
	filename = ARGS[1]
	open(filename, "r") do io
		for line in eachline(io)
			chomped = chomp(line)
			fields = split(chomped, ',')
			x1, y1, z1, x2, y2, z2 = fields
			# Convert to Float64 for computation
			dE = ciede_2000(parse(Float64, x1), parse(Float64, y1), parse(Float64, z1),
							parse(Float64, x2), parse(Float64, y2), parse(Float64, z2))
			# Print the original line with the computed ΔE appended
			println("$chomped,$dE")
		end
	end
end
