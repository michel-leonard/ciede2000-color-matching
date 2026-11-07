# Limited Use License – March 1, 2025

# This source code is provided for public use under the following conditions :
# It may be downloaded, compiled, and executed, including in publicly accessible environments.
# Modification is strictly prohibited without the express written permission of the author.

# © Michel Leonard 2025

# The classic vectorized CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
# "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
ciede_2000 <- function(l_1, a_1, b_1, l_2, a_2, b_2) {
	# Working in R with the CIEDE2000 color-difference formula.
	# k_l, k_c, k_h are parametric factors to be adjusted according to
	# different viewing parameters such as textures, backgrounds...
	k_l <- 1.0;
	k_c <- 1.0;
	k_h <- 1.0;
	n <- (sqrt(a_1 * a_1 + b_1 * b_1) + sqrt(a_2 * a_2 + b_2 * b_2)) * 0.5;
	n <- n ^ 7.0;
	# A factor involving chroma raised to the power of 7 designed to make
	# the influence of chroma on the total color difference more accurate.
	n <- 1.0 + 0.5 * (1.0 - sqrt(n / (n + 6103515625.0)));
	# Application of the chroma correction factor.
	c_1 <- sqrt((a_1 * n) ^ 2.0 + b_1 * b_1);
	c_2 <- sqrt((a_2 * n) ^ 2.0 + b_2 * b_2);
	# atan2 is preferred over atan because it accurately computes the angle of
	# a point (x, y) in all quadrants, handling the signs of both coordinates.
	h_1 <- atan2(b_1, a_1 * n);
	h_2 <- atan2(b_2, a_2 * n);
	h_1 <- h_1 + ifelse(h_1 < 0.0, 2.0 * pi, 0.0)
	h_2 <- h_2 + ifelse(h_2 < 0.0, 2.0 * pi, 0.0)
	n <- abs(h_2 - h_1);
	# Cross-implementation consistent rounding.
	n[abs(n - pi) < 1E-14] <- pi;
	# When the hue angles lie in different quadrants, the straightforward
	# average can produce a mean that incorrectly suggests a hue angle in
	# the wrong quadrant, the next lines handle this issue.
	h_m <- (h_1 + h_2) * 0.5;
	h_d <- (h_2 - h_1) * 0.5;
	mask <- pi < n;
	h_d[mask] <- h_d[mask] + pi;
	# 📜 Sharma’s formulation doesn’t use the next line, but the one after it,
	# and these two variants differ by ±0.0003 on the final color differences.
	h_m[mask] <- h_m[mask] + pi;
	# h_m[mask] <- h_m[mask] + ifelse(h_m[mask] < pi, pi, -pi);
	p <- 36.0 * h_m - 55.0 * pi;
	n <- (c_1 + c_2) * 0.5;
	n <- n ^ 7.0;
	# The hue rotation correction term is designed to account for the
	# non-linear behavior of hue differences in the blue region.
	r_t <- -2.0 * sqrt(n / (n + 6103515625.0)) *
			sin(pi / 3.0 * exp(p * p / (-25.0 * pi * pi)));
	n <- (l_1 + l_2) * 0.5;
	n <- (n - 50.0) * (n - 50.0);
	# Lightness.
	l <- (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / sqrt(20.0 + n)));
	# These coefficients adjust the impact of different harmonic
	# components on the hue difference calculation.
	t <- 1.0 +	0.24 * sin(2.0 * h_m + pi * 0.5) +
			0.32 * sin(3.0 * h_m + 8.0 * pi / 15.0) -
			0.17 * sin(h_m + pi / 3.0) -
			0.20 * sin(4.0 * h_m + 3.0 * pi / 20.0);
	n <- c_1 + c_2;
	# Hue.
	h <- 2.0 * sqrt(c_1 * c_2) * sin(h_d) / (k_h * (1.0 + 0.0075 * n * t));
	# Chroma.
	c <- (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
	# Returning the square root ensures that dE00 accurately reflects the
	# geometric distance in color space, which can range from 0 to around 185.
	return(sqrt(l * l + h * h + c * c + c * h * r_t));
}

# GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
#   Online Tests : https://michel-leonard.github.io/ciede2000-color-matching

# L1 = 18.0   a1 = 31.0   b1 = -2.7
# L2 = 15.8   a2 = 36.6   b2 = 4.2
# CIE ΔE00 = 4.8664834903 (Bruce Lindbloom, Netflix’s VMAF, ...)
# CIE ΔE00 = 4.8664981555 (Gaurav Sharma, OpenJDK, ...)
# Deviation between implementations ≈ 1.5e-5

# See the source code comments for easy switching between these two widely used ΔE*00 implementation variants.

#################################################
#################################################
############                         ############
############    CIEDE2000 Driver     ############
############                         ############
#################################################
#################################################

# Reads a CSV file specified as the first command-line argument. For each line, this program
# in R displays the original line with the computed Delta E 2000 color difference appended.
# The C driver can offer CSV files to process and programmatically check the calculations performed there.

#  Example of a CSV input line : 79,72,5,68.3,81.5,-39
#    Corresponding output line : 79,72,5,68.3,81.5,-39,17.383801218729621407605496585258

args <- commandArgs(trailingOnly = TRUE)

if (length(args) >= 1) {
	file_path <- args[1]
	chunk_size <- 100000
	con <- file(file_path, open = "r")
	on.exit(close(con))
	repeat {
		lines <- readLines(con, n = chunk_size)
		if (length(lines) == 0) break
		v <- do.call(rbind, strsplit(lines, ","))
		v <- apply(v, 2, as.numeric)
		delta_e <- ciede_2000(v[,1], v[,2], v[,3], v[,4], v[,5], v[,6])
		for (i in seq_along(delta_e)) {
			cat(lines[i], sprintf(",%.17f\n", delta_e[i]), sep = "")
		}
	}
}
