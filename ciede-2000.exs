# This function written in Elixir is not affiliated with the CIE (International Commission on Illumination),
# and is released into the public domain. It is provided "as is" without any warranty, express or implied.

# The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
# "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
def ciede_2000(l_1, a_1, b_1, l_2, a_2, b_2)
	when is_float(l_1) and is_float(a_1)  and is_float(b_1) and is_float(l_2) and is_float(a_2)  and is_float(b_2) do
	# Working in Elixir with the CIEDE2000 color-difference formula.
	# k_l, k_c, k_h are parametric factors to be adjusted according to
	# different viewing parameters such as textures, backgrounds...
	{k_l, k_c, k_h, m_pi} = {1.0, 1.0, 1.0, :math.pi()}
	n = (:math.sqrt(a_1 * a_1 + b_1 * b_1) + :math.sqrt(a_2 * a_2 + b_2 * b_2)) * 0.5
	n = n * n * n * n * n * n * n
	# A factor involving chroma raised to the power of 7 designed to make
	# the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - :math.sqrt(n / (n + 6103515625.0)))
	# Application of the chroma correction factor.
	c_1 = :math.sqrt(a_1 * a_1 * n * n + b_1 * b_1)
	c_2 = :math.sqrt(a_2 * a_2 * n * n + b_2 * b_2)
	# atan2 is preferred over atan because it accurately computes the angle of
	# a point (x, y) in all quadrants, handling the signs of both coordinates.
	h_1 = :math.atan2(b_1, a_1 * n)
	h_2 = :math.atan2(b_2, a_2 * n)
	h_1 = if h_1 < 0.0, do: h_1 + 2.0 * m_pi, else: h_1
	h_2 = if h_2 < 0.0, do: h_2 + 2.0 * m_pi, else: h_2
	n = abs(h_2 - h_1)
	# Cross-implementation consistent rounding.
	n = if m_pi - 1.0E-14 < n and n < m_pi + 1.0E-14, do: m_pi, else: n
	# When the hue angles lie in different quadrants, the straightforward
	# average can produce a mean that incorrectly suggests a hue angle in
	# the wrong quadrant, the next lines handle this issue.
	h_m = (h_1 + h_2) * 0.5
	h_d = (h_2 - h_1) * 0.5
	h_d = if m_pi < n, do: h_d + m_pi, else: h_d
	# 📜 Sharma’s formulation doesn’t use the next line, but the one after it,
	# and these two variants differ by ±0.0003 on the final color differences.
	h_m = if m_pi < n, do: h_m + m_pi, else: h_m
	# h_m = if m_pi < n, do: (if h_m < m_pi, do: h_m + m_pi, else: h_m - m_pi), else: h_m
	p = 36.0 * h_m - 55.0 * m_pi
	n = (c_1 + c_2) * 0.5
	n = n * n * n * n * n * n * n
	# The hue rotation correction term is designed to account for the
	# non-linear behavior of hue differences in the blue region.
	r_t = -2.0 * :math.sqrt(n / (n + 6103515625.0)) *
		:math.sin(m_pi / 3.0 * :math.exp(p * p / (-25.0 * m_pi * m_pi)))
	n = (l_1 + l_2) * 0.5
	n = (n - 50.0) * (n - 50.0)
	# Lightness.
	l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / :math.sqrt(20.0 + n)))
	# These coefficients adjust the impact of different harmonic
	# components on the hue difference calculation.
	t = 1.0 +	0.24 * :math.sin(2.0 * h_m + m_pi / 2.0) +
			0.32 * :math.sin(3.0 * h_m + 8.0 * m_pi / 15.0) -
			0.17 * :math.sin(h_m + m_pi / 3.0) -
			0.20 * :math.sin(4.0 * h_m + 3.0 * m_pi / 20.0)
	n = c_1 + c_2
	# Hue.
	h = 2.0 * :math.sqrt(c_1 * c_2) * :math.sin(h_d) / (k_h * (1.0 + 0.0075 * n * t))
	# Chroma.
	c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n))
	# Returning the square root ensures that dE00 accurately reflects the
	# geometric distance in color space, which can range from 0 to around 185.
	:math.sqrt(l * l + h * h + c * c + c * h * r_t)
end

# GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
#   Online Tests : https://michel-leonard.github.io/ciede2000-color-matching

# L1 = 80.1   a1 = 20.9   b1 = 4.3
# L2 = 82.2   a2 = 26.1   b2 = -3.9
# CIE ΔE00 = 6.1587582595 (Bruce Lindbloom, Netflix’s VMAF, ...)
# CIE ΔE00 = 6.1587450086 (Gaurav Sharma, OpenJDK, ...)
# Deviation between implementations ≈ 1.3e-5

# See the source code comments for easy switching between these two widely used ΔE*00 implementation variants.
