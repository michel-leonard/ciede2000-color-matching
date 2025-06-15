# This function written in Ruby is not affiliated with the CIE (International Commission on Illumination),
# and is released into the public domain. It is provided "as is" without any warranty, express or implied.

# The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
# "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
def ciede_2000_one(l_1, a_1, b_1, l_2, a_2, b_2)
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

# L1 = 29.97          a1 = 90.9           b1 = 119.0
# L2 = 29.97          a2 = 90.9           b2 = 119.02
# CIE ΔE2000 = ΔE00 = 0.00538192563

# L1 = 88.0           a1 = 71.0           b1 = -63.95
# L2 = 88.0           a2 = 71.213         b2 = -63.95
# CIE ΔE2000 = ΔE00 = 0.06615700559

# L1 = 31.0           a1 = 26.0           b1 = -41.948
# L2 = 31.0           a2 = 25.3           b2 = -41.948
# CIE ΔE2000 = ΔE00 = 0.4175899838

# L1 = 32.667         a1 = 49.6834        b1 = 6.29
# L2 = 33.452         a2 = 49.6834        b2 = 6.29
# CIE ΔE2000 = ΔE00 = 0.63017260569

# L1 = 48.11          a1 = -117.0         b1 = -102.7873
# L2 = 49.3923        a2 = -116.77        b2 = -106.4
# CIE ΔE2000 = ΔE00 = 1.45434124267

# L1 = 22.0           a1 = -65.919        b1 = -30.0
# L2 = 26.8996        a2 = -65.919        b2 = -30.0
# CIE ΔE2000 = ΔE00 = 3.55684290804

# L1 = 70.2           a1 = 9.072          b1 = 90.701
# L2 = 66.69          a2 = 18.508         b2 = 122.0
# CIE ΔE2000 = ΔE00 = 6.78124222507

# L1 = 81.0           a1 = -23.0          b1 = -101.34
# L2 = 66.3669        a2 = -17.96         b2 = -82.0
# CIE ΔE2000 = ΔE00 = 11.55671032926

# L1 = 27.47          a1 = 89.0           b1 = 105.71
# L2 = 44.3           a2 = 53.0           b2 = 62.95
# CIE ΔE2000 = ΔE00 = 16.85338265675

# L1 = 5.0            a1 = -116.3         b1 = -85.81
# L2 = 47.2           a2 = 113.485        b2 = -21.7
# CIE ΔE2000 = ΔE00 = 138.01516709461

def ciede_2000_two(l1, a1, b1, l2, a2, b2)
	# The other function here.
end

########################################################
########################################################
############                               #############
############         Compare with          #############
############         ___________           #############
############                               #############
########################################################
########################################################

## The goal is to demonstrate that the library produces results identical to ___________.  
## If the results differ by more than a tolerance of 1E-10, a non-zero value will be returned.

def finite?(f)
	!f.nan? && !f.infinite?
end

runs = (ARGV[0] || 10_000).to_i

worst = {
	diff: 0.0
}

runs.times do |i|
	l1 = rand * 100.0
	a1 = rand * 256.0 - 128.0
	b1 = rand * 256.0 - 128.0
	l2 = rand * 100.0
	a2 = rand * 256.0 - 128.0
	b2 = rand * 256.0 - 128.0
	d1 = ciede_2000_one(l1, a1, b1, l2, a2, b2)
	d2 = ciede_2000_two(l1, a1, b1, l2, a2, b2)

	unless finite?(d1) && finite?(d2)
		puts "Non-finite value detected at run #{i}"
		exit(1)
	end

	diff = (d1 - d2).abs

	if diff > worst[:diff]
		worst = {
			l1: l1, a1: a1, b1: b1,
			l2: l2, a2: a2, b2: b2,
			delta1: d1, delta2: d2,
			diff: diff
		}
	end
end

puts "Total runs : #{runs}"
puts "Worst case : {"
worst.each do |k, v|
	if v.is_a?(Float)
		puts "	%.17g," % v
	else
		puts "	#{k}: #{v},"
	end
end
puts "}"
