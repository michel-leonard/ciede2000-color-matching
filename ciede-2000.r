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

# L1 = 50.59          a1 = 114.1336       b1 = 98.837
# L2 = 50.59          a2 = 114.1          b2 = 98.837
# CIE ΔE2000 = ΔE00 = 0.00908382021

# L1 = 5.4508         a1 = 52.589         b1 = 42.97
# L2 = 5.4508         a2 = 52.589         b2 = 44.9
# CIE ΔE2000 = ΔE00 = 0.90754103544

# L1 = 97.7           a1 = 53.5           b1 = -98.5
# L2 = 97.7           a2 = 46.139         b2 = -98.5
# CIE ΔE2000 = ΔE00 = 3.70534162171

# L1 = 29.5385        a1 = -98.74         b1 = -88.684
# L2 = 25.0           a2 = -81.0          b2 = -90.5
# CIE ΔE2000 = ΔE00 = 5.23286161483

# L1 = 97.7208        a1 = -25.355        b1 = 25.2586
# L2 = 98.975         a2 = -26.0          b2 = 13.223
# CIE ΔE2000 = ΔE00 = 6.59422714042

# L1 = 61.31          a1 = 91.8609        b1 = 97.7
# L2 = 53.0           a2 = 102.4445       b2 = 97.1219
# CIE ΔE2000 = ΔE00 = 8.35723590773

# L1 = 21.0           a1 = 108.0          b1 = -116.482
# L2 = 11.0           a2 = 91.0           b2 = -56.0
# CIE ΔE2000 = ΔE00 = 15.54606922191

# L1 = 44.76          a1 = -85.94         b1 = 15.6
# L2 = 27.7048        a2 = -119.7311      b2 = 47.8
# CIE ΔE2000 = ΔE00 = 17.46537947373

# L1 = 57.0           a1 = 55.535         b1 = -80.0
# L2 = 84.31          a2 = 77.8           b2 = -105.43
# CIE ΔE2000 = ΔE00 = 21.63269104622

# L1 = 74.9           a1 = -118.101       b1 = 51.0
# L2 = 67.9           a2 = -2.4           b2 = -126.59
# CIE ΔE2000 = ΔE00 = 61.86870630019

