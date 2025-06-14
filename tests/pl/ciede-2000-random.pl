# This function written in Perl is not affiliated with the CIE (International Commission on Illumination),
# and is released into the public domain. It is provided "as is" without any warranty, express or implied.

use strict;
use warnings;
use Math::Trig qw(pi);

# The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
# "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
sub ciede_2000 {
	# Working in Perl with the CIEDE2000 color-difference formula.
	# k_l, k_c, k_h are parametric factors to be adjusted according to
	# different viewing parameters such as textures, backgrounds...
	my ($l_1, $a_1, $b_1, $l_2, $a_2, $b_2) = @_;
	my ($k_l, $k_c, $k_h) = (1.0, 1.0, 1.0);
	my $n = (sqrt($a_1 * $a_1 + $b_1 * $b_1) + sqrt($a_2 * $a_2 + $b_2 * $b_2)) * 0.5;
	$n = $n * $n * $n * $n * $n * $n * $n;
	# A factor involving chroma raised to the power of 7 designed to make
	# the influence of chroma on the total color difference more accurate.
	$n = 1.0 + 0.5 * (1.0 - sqrt($n / ($n + 6103515625.0)));
	# Since hypot is not available, sqrt is used here to calculate the
	# Euclidean distance, without avoiding overflow/underflow.
	my $c_1 = sqrt($a_1 * $a_1 * $n * $n + $b_1 * $b_1);
	my $c_2 = sqrt($a_2 * $a_2 * $n * $n + $b_2 * $b_2);
	# atan2 is preferred over atan because it accurately computes the angle of
	# a point (x, y) in all quadrants, handling the signs of both coordinates.
	my $h_1 = atan2($b_1, $a_1 * $n);
	my $h_2 = atan2($b_2, $a_2 * $n);
	$h_1 += 2.0 * pi if $h_1 < 0.0;
	$h_2 += 2.0 * pi if $h_2 < 0.0;
	$n = abs($h_2 - $h_1);
	# Cross-implementation consistent rounding.
	$n = pi if pi - 1E-14 < $n && $n < pi + 1E-14;
	# When the hue angles lie in different quadrants, the straightforward
	# average can produce a mean that incorrectly suggests a hue angle in
	# the wrong quadrant, the next lines handle this issue.
	my $h_m = ($h_1 + $h_2) * 0.5;
	my $h_d = ($h_2 - $h_1) * 0.5;
	if (pi < $n) {
		$h_d += (0.0 < $h_d) ? -pi : pi;
		$h_m += pi;
	}
	my $p = 36.0 * $h_m - 55.0 * pi;
	$n = ($c_1 + $c_2) * 0.5;
	$n = $n * $n * $n * $n * $n * $n * $n;
	# The hue rotation correction term is designed to account for the
	# non-linear behavior of hue differences in the blue region.
	my $r_t = -2.0 * sqrt($n / ($n + 6103515625.0))
			* sin(pi / 3.0 * exp($p * $p / (-25.0 * pi * pi)));
	$n = ($l_1 + $l_2) * 0.5;
	$n = ($n - 50.0) * ($n - 50.0);
	# Lightness.
	my $l = ($l_2 - $l_1) / ($k_l * (1.0 + 0.015 * $n / sqrt(20.0 + $n)));
	# These coefficients adjust the impact of different harmonic
	# components on the hue difference calculation.
	my $t = 1.0	+ 0.24 * sin(2.0 * $h_m + pi * 0.5)
			+ 0.32 * sin(3.0 * $h_m + 8.0 * pi / 15.0)
			- 0.17 * sin($h_m + pi / 3.0)
			- 0.20 * sin(4.0 * $h_m + 3.0 * pi / 20.0);
	$n = $c_1 + $c_2;
	# Hue.
	my $h = 2.0 * sqrt($c_1 * $c_2) * sin($h_d) / ($k_h * (1.0 + 0.0075 * $n * $t));
	# Chroma.
	my $c = ($c_2 - $c_1) / ($k_c * (1.0 + 0.0225 * $n));
	# Returns the square root so that the Delta E 2000 reflects the actual geometric
	# distance within the color space, which ranges from 0 to approximately 185.
	return sqrt($l * $l + $h * $h + $c * $c + $c * $h * $r_t);
}

# GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
#  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

# L1 = 6.4            a1 = -75.0          b1 = -125.0
# L2 = 6.4            a2 = -75.0391       b2 = -125.0
# CIE ΔE2000 = ΔE00 = 0.00839882942

# L1 = 43.5           a1 = 112.809        b1 = 3.0
# L2 = 43.5           a2 = 113.0          b2 = 3.0
# CIE ΔE2000 = ΔE00 = 0.03143067409

# L1 = 87.517         a1 = -53.9          b1 = -126.179
# L2 = 87.517         a2 = -53.9          b2 = -118.0
# CIE ΔE2000 = ΔE00 = 1.16698600061

# L1 = 89.8           a1 = -30.067        b1 = 92.72
# L2 = 90.131         a2 = -35.1          b2 = 92.72
# CIE ΔE2000 = ΔE00 = 2.10586761965

# L1 = 56.98          a1 = 52.928         b1 = 122.2
# L2 = 60.1131        a2 = 52.928         b2 = 122.2
# CIE ΔE2000 = ΔE00 = 2.8135198084

# L1 = 39.349         a1 = 81.7118        b1 = -46.1022
# L2 = 31.0           a2 = 25.5           b2 = -34.6
# CIE ΔE2000 = ΔE00 = 19.14734164254

# L1 = 4.63           a1 = 26.54          b1 = -103.3293
# L2 = 9.4126         a2 = 32.0           b2 = -59.309
# CIE ΔE2000 = ΔE00 = 20.19446926641

# L1 = 53.3           a1 = -106.1         b1 = -118.55
# L2 = 65.0           a2 = -87.9          b2 = -29.0
# CIE ΔE2000 = ΔE00 = 23.29079698104

# L1 = 37.0           a1 = 115.427        b1 = -25.58
# L2 = 58.807         a2 = -84.2          b2 = 78.8655
# CIE ΔE2000 = ΔE00 = 111.25484514923

# L1 = 26.31          a1 = -98.0          b1 = -95.7234
# L2 = 54.84          a2 = 93.0           b2 = 29.78
# CIE ΔE2000 = ΔE00 = 127.80224945213

###############################################
###############################################
#######                                 #######
#######           CIEDE 2000            #######
#######      Testing Random Colors      #######
#######                                 #######
###############################################
###############################################

# This program outputs a CSV file to standard output, with its length determined by the first CLI argument.
# Each line contains seven columns:
# - Three columns for the standard L*a*b* color
# - Three columns for the sample L*a*b* color
# - One column for the Delta E 2000 color difference between the standard and sample
# The output can be verified in two ways:
# - With the C driver, which provides a dedicated verification feature
# - By using the JavaScript validator at https://michel-leonard.github.io/ciede2000-color-matching

my $n_iterations = 10000;
if (@ARGV > 0) {
	$n_iterations = int($ARGV[0]);
}
if ($n_iterations < 1) {
	$n_iterations = 10000;
}

for (my $i = 0; $i < $n_iterations; $i++) {
	my $l_1 = int(rand(10000)) / 100.0;
	my $a_1 = int(rand(25600) - 12800.0) / 100.0;
	my $b_1 = int(rand(25600) - 12800.0) / 100.0;
	my $l_2 = int(rand(10000)) / 100.0;
	my $a_2 = int(rand(25600) - 12800.0) / 100.0;
	my $b_2 = int(rand(25600) - 12800.0) / 100.0;

	my $delta_e = ciede_2000($l_1, $a_1, $b_1, $l_2, $a_2, $b_2);
	print "$l_1,$a_1,$b_1,$l_2,$a_2,$b_2,$delta_e\n";
}
