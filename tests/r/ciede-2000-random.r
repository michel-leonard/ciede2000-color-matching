# This function written in R is not affiliated with the CIE (International Commission on Illumination),
# and is released into the public domain. It is provided "as is" without any warranty, express or implied.

ciede_2000_classic <- function(l_1, a_1, b_1, l_2, a_2, b_2) {
	# This scalar expansion wrapper works with numbers, not vectors.
	delta_e <- ciede_2000(c(l_1), c(a_1), c(b_1), c(l_2), c(a_2), c(b_2))
	return(delta_e[1])
}

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

# L1 = 15.775         a1 = 55.791         b1 = 8.0
# L2 = 22.2           a2 = 55.791         b2 = 5.4069
# CIE ΔE2000 = ΔE00 = 4.58236269566

###############################################
###############################################
#######                                 #######
#######           CIEDE 2000            #######
#######      Testing Random Colors      #######
#######                                 #######
###############################################
###############################################

# This R program outputs a CSV file to standard output, with its length determined by the first CLI argument.
# Each line contains seven columns :
# - Three columns for the random standard L*a*b* color
# - Three columns for the random sample L*a*b* color
# - And the seventh column for the precise Delta E 2000 color difference between the standard and sample
# The output will be correct, this can be verified :
# - With the C driver, which provides a dedicated verification feature
# - By using the JavaScript validator at https://michel-leonard.github.io/ciede2000-color-matching

main <- function(n = 10000, chunk_size = 250000) {
	set.seed(NULL)

	l1 <- runif(n, 0, 100)
	a1 <- runif(n, -128, 128)
	b1 <- runif(n, -128, 128)
	l2 <- runif(n, 0, 100)
	a2 <- runif(n, -128, 128)
	b2 <- runif(n, -128, 128)

	l1 <- round(l1, sample(0:1, n, replace = TRUE))
	a1 <- round(a1, sample(0:1, n, replace = TRUE))
	b1 <- round(b1, sample(0:1, n, replace = TRUE))
	l2 <- round(l2, sample(0:1, n, replace = TRUE))
	a2 <- round(a2, sample(0:1, n, replace = TRUE))
	b2 <- round(b2, sample(0:1, n, replace = TRUE))

	results <- numeric(n)
	for (start in seq(1, n, by = chunk_size)) {
		end <- min(start + chunk_size - 1, n)

		delta_e_chunk <- ciede_2000(l1[start:end], a1[start:end], b1[start:end], l2[start:end], a2[start:end], b2[start:end])

		results[start:end] <- delta_e_chunk

		for (i in start:end) {
			cat(sprintf("%.1f,%.1f,%.1f,%.1f,%.1f,%.1f,%.17f\n", l1[i], a1[i], b1[i], l2[i], a2[i], b2[i], results[i]))
		}
	}
}

args <- commandArgs(trailingOnly = TRUE)

if (length(args) > 0) {
  input_value <- as.numeric(args[1])

  if (!is.na(input_value) && input_value > 0 && input_value == as.integer(input_value)) {
    n_iterations <- as.integer(input_value)
  } else {
    n_iterations <- 10000
  }
} else {
  n_iterations <- 10000
}

main(n_iterations)
