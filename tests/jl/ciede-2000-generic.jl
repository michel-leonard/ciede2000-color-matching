# This function written in Julia is not affiliated with the CIE (International Commission on Illumination),
# and is released into the public domain. It is provided "as is" without any warranty, express or implied.

using Base.MathConstants
using LinearAlgebra

###########################################################################################
######                                                                               ######
######                    Measured at 8,751,086 calls per second.                    ######
######             💡 The 32-bit function is up to 30% faster than 64-bit.           ######
######                                                                               ######
######          Using 32-bit numbers results in an almost always negligible          ######
######             difference of ±0.0002 in the calculated Delta E 2000.             ######
######                                                                               ######
###########################################################################################

# The generic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
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

# L1 = 60.9224        a1 = -94.3327       b1 = -91.23
# L2 = 60.9224        a2 = -94.3327       b2 = -86.6248
# CIE ΔE2000 = ΔE00 = 0.9745409123
