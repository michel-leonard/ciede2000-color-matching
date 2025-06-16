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
	n <- n ^ 7;
	# A factor involving chroma raised to the power of 7 designed to make
	# the influence of chroma on the total color difference more accurate.
	n <- 1.0 + 0.5 * (1.0 - sqrt(n / (n + 6103515625.0)));
	# Since hypot is not available, sqrt is used here to calculate the
	# Euclidean distance, without avoiding overflow/underflow.
	c_1 <- sqrt((a_1 * n) ^ 2 + b_1 * b_1);
	c_2 <- sqrt((a_2 * n) ^ 2 + b_2 * b_2);
	# atan2 is preferred over atan because it accurately computes the angle of
	# a point (x, y) in all quadrants, handling the signs of both coordinates.
	h_1 <- atan2(b_1, a_1 * n);
	h_2 <- atan2(b_2, a_2 * n);
	h_1[h_1 < 0] <- h_1[h_1 < 0] + 2.0 * pi;
	h_2[h_2 < 0] <- h_2[h_2 < 0] + 2.0 * pi;
	n <- abs(h_2 - h_1);
	# Cross-implementation consistent rounding.
	n[abs(n - pi) < 1E-14] <- pi;
	# When the hue angles lie in different quadrants, the straightforward
	# average can produce a mean that incorrectly suggests a hue angle in
	# the wrong quadrant, the next lines handle this issue.
	h_m <- (h_1 + h_2) * 0.5;
	h_d <- (h_2 - h_1) * 0.5;
	m_1 <- (pi < n);
	m_2 <- (0.0 < h_d);
	h_d[m_1] <- h_d[m_1] + ifelse(m_2[m_1], -pi, pi);
	h_m[m_1] <- h_m[m_1] + pi;
	p <- 36.0 * h_m - 55.0 * pi;
	n <- (c_1 + c_2) * 0.5;
	n <- n ^ 7;
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
	# Returns the square root so that the Delta E 2000 reflects the actual geometric
	# distance within the color space, which ranges from 0 to approximately 185.
	return(sqrt(l * l + h * h + c * c + c * h * r_t));
}

# GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
#  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

# L1 = 77.26          a1 = -122.0         b1 = -66.293
# L2 = 77.26          a2 = -122.0         b2 = -66.337
# CIE ΔE2000 = ΔE00 = 0.0115229719

# L1 = 83.1481        a1 = 121.2          b1 = 1.9
# L2 = 83.1481        a2 = 121.4407       b2 = 1.9
# CIE ΔE2000 = ΔE00 = 0.03727174218

# L1 = 40.5268        a1 = -39.5923       b1 = -50.3
# L2 = 40.6           a2 = -39.5923       b2 = -50.3
# CIE ΔE2000 = ΔE00 = 0.06489869049

# L1 = 19.9           a1 = 61.0           b1 = 41.48
# L2 = 19.9           a2 = 56.3           b2 = 43.0
# CIE ΔE2000 = ΔE00 = 2.30600135481

# L1 = 74.2642        a1 = -15.674        b1 = -75.0
# L2 = 79.0           a2 = -13.5427       b2 = -78.52
# CIE ΔE2000 = ΔE00 = 3.52244199224

# L1 = 0.937          a1 = -10.4726       b1 = 74.0
# L2 = 7.0            a2 = -15.0          b2 = 74.0
# CIE ΔE2000 = ΔE00 = 4.36297424664

# L1 = 52.0           a1 = 86.3442        b1 = -121.7
# L2 = 56.7276        a2 = 59.71          b2 = -79.0
# CIE ΔE2000 = ΔE00 = 9.34838752165

# L1 = 78.543         a1 = 88.608         b1 = -115.997
# L2 = 84.09          a2 = 107.018        b2 = -58.28
# CIE ΔE2000 = ΔE00 = 19.53657779929

# L1 = 69.2759        a1 = 111.88         b1 = 83.9
# L2 = 97.7373        a2 = 65.812         b2 = 29.478
# CIE ΔE2000 = ΔE00 = 24.38671791763

# L1 = 87.0           a1 = -122.0862      b1 = 4.9
# L2 = 56.461         a2 = -17.54         b2 = -31.72
# CIE ΔE2000 = ΔE00 = 41.47840353963

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

args <- commandArgs(trailingOnly = TRUE)

if (length(args) >= 1) {
	file_path <- args[1]
	chunk_size <- 10000
	con <- file(file_path, open = "r")
	on.exit(close(con))
	repeat {
		lines <- readLines(con, n = chunk_size)
		if (length(lines) == 0) break
		v <- do.call(rbind, strsplit(lines, ","))
		v <- apply(v, 2, as.numeric)
		delta_e <- ciede_2000(v[,1], v[,2], v[,3], v[,4], v[,5], v[,6])
		for (i in seq_along(delta_e)) {
			cat(sprintf("%g,%g,%g,%g,%g,%g,%.17g\n",
				v[i,1], v[i,2], v[i,3], v[i,4], v[i,5], v[i,6], delta_e[i]))
		}
	}
}
