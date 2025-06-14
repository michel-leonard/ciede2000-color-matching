# Limited Use License – March 1, 2025

# This source code is provided for public use under the following conditions :
# It may be downloaded, compiled, and executed, including in publicly accessible environments.
# Modification is strictly prohibited without the express written permission of the author.

# © Michel Leonard 2025

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

# L1 = 60.0           a1 = -105.2394      b1 = 96.0515
# L2 = 60.0           a2 = -105.35        b2 = 96.0515
# CIE ΔE2000 = ΔE00 = 0.02202517727

# L1 = 46.6           a1 = 53.723         b1 = 54.3132
# L2 = 46.6           a2 = 56.567         b2 = 54.3132
# CIE ΔE2000 = ΔE00 = 1.20314222052

# L1 = 52.1608        a1 = 79.368         b1 = 122.417
# L2 = 52.1608        a2 = 79.368         b2 = 117.0
# CIE ΔE2000 = ΔE00 = 1.41029263713

# L1 = 1.3979         a1 = -18.4265       b1 = -30.7
# L2 = 1.3979         a2 = -18.4265       b2 = -20.72
# CIE ΔE2000 = ΔE00 = 4.58819201451

# L1 = 63.087         a1 = 60.0           b1 = -124.8
# L2 = 63.466         a2 = 25.0           b2 = -91.0
# CIE ΔE2000 = ΔE00 = 9.60425267866

# L1 = 7.0            a1 = -58.31         b1 = 2.999
# L2 = 1.719          a2 = -49.0831       b2 = 32.9
# CIE ΔE2000 = ΔE00 = 15.2690081235

# L1 = 64.0           a1 = 22.8           b1 = -91.336
# L2 = 56.0           a2 = 50.8           b2 = -83.83
# CIE ΔE2000 = ΔE00 = 19.65036260363

# L1 = 31.145         a1 = -78.0          b1 = 76.7067
# L2 = 54.3277        a2 = -82.699        b2 = 65.879
# CIE ΔE2000 = ΔE00 = 21.51040108145

# L1 = 22.677         a1 = -80.6          b1 = 75.6
# L2 = 7.0            a2 = -19.225        b2 = 20.389
# CIE ΔE2000 = ΔE00 = 22.56995948482

# L1 = 74.0           a1 = 116.0          b1 = -89.8
# L2 = 56.45          a2 = 74.3628        b2 = -118.0
# CIE ΔE2000 = ΔE00 = 23.6930460644

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

die "Usage: perl ciede-2000-driver.pl <filename>\n" unless @ARGV == 1;
my $filename = $ARGV[0];
open my $fh, '<', $filename or die "Cannot open file '$filename': $!";
while (my $line = <$fh>) {
	chomp $line;
	my @vals = map { $_ + 0 } split /,/, $line;
	my $result = ciede_2000(@vals);
	print "$line,$result\n";
}
close $fh;
