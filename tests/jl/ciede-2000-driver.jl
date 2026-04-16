# Limited Use License – March 1, 2025

# This source code is provided for public use under the following conditions :
# It may be downloaded, compiled, and executed, including in publicly accessible environments.
# Modification is strictly prohibited without the express written permission of the author.

# © Michel Leonard 2025

using Printf

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
	n = (sqrt(a_1 * a_1 + b_1 * b_1) + sqrt(a_2 * a_2 + b_2 * b_2)) * T(0.5)
	n = n * n * n * n * n * n * n
	# A factor involving chroma raised to the power of 7 designed to make
	# the influence of chroma on the total color difference more accurate.
	n = T(1.0) + T(0.5) * (T(1.0) - sqrt(n / (n + T(6103515625.0))))
	# Application of the chroma correction factor.
	c_1 = sqrt(a_1 * a_1 * n * n + b_1 * b_1)
	c_2 = sqrt(a_2 * a_2 * n * n + b_2 * b_2)
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
		h_d += T(π)
		# 📜 Sharma’s formulation doesn’t use the next line, but the one after it,
		# and these two variants differ by ±0.0003 on the final color differences.
		h_m += T(π)
		# h_m += h_m < T(π) ? T(π) : -T(π)
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
	# Keep these numeric constants as rational to ensure exact representation.
	l = (l_2 - l_1) / (k_l * (T(1.0) + T(3 // 200) * n / sqrt(T(20.0) + n)))
	# These coefficients adjust the impact of different harmonic
	# components on the hue difference calculation.
	t = T(1.0) +	T(6 // 25) * sin(T(2.0) * h_m + T(π) * T(0.5)) +
			T(8 // 25) * sin(T(3.0) * h_m + T(8.0) * T(π) / T(15.0)) -
			T(17 // 100) * sin(h_m + T(π) / T(3.0)) -
			T(1 // 5) * sin(T(4.0) * h_m + T(3.0) * T(π) / T(20.0))
	n = c_1 + c_2
	# Hue.
	h = T(2.0) * sqrt(c_1 * c_2) * sin(h_d) / (k_h * (T(1.0) + T(3 // 400) * n * t))
	# Chroma.
	c = (c_2 - c_1) / (k_c * (T(1.0) + T(9 // 400) * n))
	# Returning the square root ensures that dE00 accurately reflects the
	# geometric distance in color space, which can range from 0 to around 185.
	return sqrt(l * l + h * h + c * c + c * h * r_t)
end

# GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
#   Online Tests : https://michel-leonard.github.io/ciede2000-color-matching

# L1 = 48.9   a1 = 17.9   b1 = 5.1
# L2 = 48.6   a2 = 11.7   b2 = -3.3
# CIE ΔE00 = 7.3619103700 (Bruce Lindbloom, Netflix’s VMAF, ...)
# CIE ΔE00 = 7.3619277820 (Gaurav Sharma, OpenJDK, ...)
# Deviation between implementations ≈ 1.7e-5

# See the source code comments for easy switching between these two widely used ΔE*00 implementation variants.

#################################################
#################################################
############                         ############
############    CIEDE2000 Driver     ############
############                         ############
#################################################
#################################################

# Reads a CSV file specified as the first command-line argument. For each line, this program
# in Julia displays the original line with the computed Delta E 2000 color difference appended.
# The C driver can offer CSV files to process and programmatically check the calculations performed there.

#  Example of a CSV input line : 45.4,27,-19,51,15.8,6
#    Corresponding output line : 45.4,27,-19,51,15.8,6,16.907659933563283573861330385232

function compute(filename)
	open(filename, "r") do io
		for line in eachline(io)
			chomped = chomp(line)
			fields = split(chomped, ',')
			l1, a1, b1, l2, a2, b2 = fields
			# Convert to Float64 for computation
			dE = ciede_2000(parse(Float64, l1), parse(Float64, a1), parse(Float64, b1),
				parse(Float64, l2), parse(Float64, a2), parse(Float64, b2))
			# Print the original line with the computed ΔE appended
			println("$chomped,$dE")
		end
	end
end

# This function compares the value computed in Julia using BigFloat,
# and reports differences beyond 1e-10, or a specified "--tolerance <value>".

# It displays a detailed report of the first few largest deviations on stderr,
# and writes a verification summary to stdout once all lines have been processed.

function verify(tolerance::BigFloat)

	setrounding(BigFloat, RoundNearest) do
		setprecision(Int(floor(64 + abs(log2(tolerance))))) do

			successes = 0.0
			failures = 0.0
			total_delta_e = 0.0
			total_deviation = BigFloat(0)
			max_deviation = BigFloat(0)

			start_time = time()
			first_verified_line = ""
			idx = 0.0
			displayed_errors = 0.0
			last_displayed_deviation = 0.0

			for line in eachline(stdin)
				idx += 1
				v = split(strip(line), ',')
				if length(v) != 7
					continue
				end

				if first_verified_line == ""
					first_verified_line = line
				end

				l1 = parse(BigFloat, v[1])
				a1 = parse(BigFloat, v[2])
				b1 = parse(BigFloat, v[3])
				l2 = parse(BigFloat, v[4])
				a2 = parse(BigFloat, v[5])
				b2 = parse(BigFloat, v[6])
				dE = parse(BigFloat, v[7])

				delta_e = ciede_2000(l1, a1, b1, l2, a2, b2)

				deviation = abs(delta_e - dE)

				if tolerance < deviation
					failures += 1
					if displayed_errors < 5 && deviation > last_displayed_deviation
						print(stderr, "\n")
						@printf(stderr, "Line %-4d : L1=%-15s a1=%-15s b1=%-15s\n", idx, v[1], v[2], v[3])
						@printf(stderr, "            L2=%-15s a2=%-15s b2=%-15s\n", v[4], v[5], v[6])
						@printf(stderr, "Expecting : %.50f       Found deviation : %g\n", delta_e, deviation)
						@printf(stderr, "      Got : %s\n", v[7])

						displayed_errors += 1
						last_displayed_deviation = deviation
					end
				else
					successes += 1
				end

				total_delta_e += Float64(delta_e)
				total_deviation += deviation
				max_deviation = max(max_deviation, deviation)

			end

			duration = time() - start_time

			println("\nCIEDE2000 Verification Summary :")
			println("  First Verified Line : $first_verified_line")
			@printf("             Duration : %.2f s\n", duration)
			@printf("            Successes : %d\n", successes)
			@printf("               Errors : %d\n", failures)
			@printf("      Average Delta E : %.4f\n", total_delta_e / idx)
			@printf("    Average Deviation : %.1e\n", total_deviation / idx)
			@printf("    Maximum Deviation : %.1e\n", max_deviation)

		end
	end
end

function main()
	if length(ARGS) == 0
		verify(BigFloat("1e-10"))
	else
		if length(ARGS) == 1
			compute(ARGS[1])
		elseif ARGS[1] == "--tolerance"
			verify(parse(BigFloat, ARGS[2]))
		end
	end
end

main()
