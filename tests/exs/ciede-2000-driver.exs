# Limited Use License – March 1, 2025

# This source code is provided for public use under the following conditions :
# It may be downloaded, compiled, and executed, including in publicly accessible environments.
# Modification is strictly prohibited without the express written permission of the author.

# © Michel Leonard 2025

defmodule Color do
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
		# Sharma's implementation delete the next line and uncomment the one after it,
		# this can lead to a discrepancy of ±0.0003 in the final color difference.
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
		# Returns the square root so that the DeltaE 2000 reflects the actual geometric
		# distance within the color space, which ranges from 0 to approximately 185.
		:math.sqrt(l * l + h * h + c * c + c * h * r_t)
	end
end

# GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
#  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

# L1 = 14.858         a1 = 73.0           b1 = -3.005
# L2 = 27.9           a2 = 86.08          b2 = -24.09
# CIE ΔE2000 = ΔE00 = 11.94781314768

#################################################
#################################################
############                         ############
############    CIEDE2000 Driver     ############
############                         ############
#################################################
#################################################

# Reads a CSV file specified as the first command-line argument. For each line, this program
# in Elixir displays the original line with the computed Delta E 2000 color difference appended.
# The C driver can offer CSV files to process and programmatically check the calculations performed there.

#  Example of a CSV input line : 67.24,-14.22,70,65,8,46
#    Corresponding output line : 67.24,-14.22,70,65,8,46,15.46723547943141064

case System.argv() do
	[filename | _rest] ->
		File.stream!(filename) |> Enum.each(fn line ->
			line = String.trim_trailing(line)
			with [l1, a1, b1, l2, a2, b2] <- String.split(line, ",") \
				|> Enum.map(fn n -> Float.parse(n) |> elem(0) end) do
				dE = Color.ciede_2000(l1, a1, b1, l2, a2, b2)
				IO.puts("#{line},#{dE}")
			end
		end)
	[] ->
		IO.puts("Please provide the path to the CSV file containing the 6-column L*a*b* colors so that their CIEDE2000 can be calculated.")
		System.halt(1)
end
