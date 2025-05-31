# This function written in Ruby is not affiliated with the CIE (International Commission on Illumination),
# and is released into the public domain. It is provided "as is" without any warranty, express or implied.

# The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
# "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 128.
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
	# Returning the square root ensures that the result reflects the actual geometric
	# distance within the color space, which ranges from 0 to approximately 185.
	Math.sqrt(l * l + h * h + c * c + c * h * r_t)
end

# GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
#  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/samples.html

# L1 = 72.9           a1 = -89.0          b1 = -70.093
# L2 = 72.9           a2 = -89.0          b2 = -70.1805
# CIE ΔE2000 = ΔE00 = 0.02225627442

# L1 = 71.18          a1 = 35.0           b1 = -92.4787
# L2 = 71.18          a2 = 35.0           b2 = -92.3764
# CIE ΔE2000 = ΔE00 = 0.03741527937

# L1 = 63.94          a1 = 107.749        b1 = 120.248
# L2 = 63.94          a2 = 107.749        b2 = 120.0
# CIE ΔE2000 = ΔE00 = 0.06747335156

# L1 = 47.2638        a1 = -55.3          b1 = 46.0357
# L2 = 47.2638        a2 = -55.3          b2 = 46.6464
# CIE ΔE2000 = ΔE00 = 0.20946592769

# L1 = 40.3264        a1 = -120.4         b1 = -51.4
# L2 = 40.3264        a2 = -120.4         b2 = -48.34
# CIE ΔE2000 = ΔE00 = 0.93064418385

# L1 = 50.0           a1 = -109.0         b1 = -28.0
# L2 = 50.0           a2 = -116.716       b2 = -28.0
# CIE ΔE2000 = ΔE00 = 1.38757584894

# L1 = 0.0            a1 = 63.0           b1 = 100.97
# L2 = 2.98           a2 = 55.0           b2 = 96.4
# CIE ΔE2000 = ΔE00 = 3.0786380245

# L1 = 83.02          a1 = -113.6         b1 = -64.0
# L2 = 88.2           a2 = -114.5         b2 = -64.0
# CIE ΔE2000 = ΔE00 = 3.39011793384

# L1 = 76.775         a1 = -37.961        b1 = 52.4
# L2 = 76.0           a2 = -57.0          b2 = 78.032
# CIE ΔE2000 = ΔE00 = 6.91937190011

# L1 = 1.0512         a1 = 98.1           b1 = 102.7
# L2 = 4.0            a2 = 24.418         b2 = 62.191
# CIE ΔE2000 = ΔE00 = 23.22062460489


##########################################################################
##########################################################################
#######################                        ###########################
#######################        TESTING         ###########################
#######################                        ###########################
##########################################################################
##########################################################################

# The output is intended to be checked by the Large-Scale validator
# at https://michel-leonard.github.io/ciede2000-color-matching/batch.html

def rand_in_range(min, max)
	n = min + (max - min) * rand
	case rand(3)
	when 0
		n.round
	when 1
		(n * 10.0).round / 10.0
	else
		(n * 100.0).round / 100.0
	end
end

arg = ARGV.length > 0 ? ARGV[0].to_i : 10000
n_iterations = arg.finite? && arg > 0 ? arg : 10000

n_iterations.times do
	l1 = rand_in_range(0.0, 100.0)
	a1 = rand_in_range(-128.0, 128.0)
	b1 = rand_in_range(-128.0, 128.0)
	l2 = rand_in_range(0.0, 100.0)
	a2 = rand_in_range(-128.0, 128.0)
	b2 = rand_in_range(-128.0, 128.0)

	delta_e = ciede_2000(l1, a1, b1, l2, a2, b2)

	puts "#{l1},#{a1},#{b1},#{l2},#{a2},#{b2},#{delta_e}"
end
