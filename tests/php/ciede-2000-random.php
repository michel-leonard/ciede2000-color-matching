<?php

// This function written in PHP is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

// The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
// "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
function ciede_2000($l_1, $a_1, $b_1, $l_2, $a_2, $b_2) {
	// Working in PHP with the CIEDE2000 color-difference formula.
	// k_l, k_c, k_h are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	$k_l = $k_c = $k_h = 1.0;
	$n = (hypot($a_1, $b_1) + hypot($a_2, $b_2)) * 0.5;
	$n = $n * $n * $n * $n * $n * $n * $n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	$n = 1.0 + 0.5 * (1.0 - sqrt($n / ($n + 6103515625.0)));
	// hypot calculates the Euclidean distance while avoiding overflow/underflow.
	$c_1 = hypot($a_1 * $n, $b_1);
	$c_2 = hypot($a_2 * $n, $b_2);
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	$h_1 = atan2($b_1, $a_1 * $n);
	$h_2 = atan2($b_2, $a_2 * $n);
	$h_1 += 2.0 * M_PI * ($h_1 < 0.0);
	$h_2 += 2.0 * M_PI * ($h_2 < 0.0);
	$n = abs($h_2 - $h_1);
	// Cross-implementation consistent rounding.
	if (M_PI - 1E-14 < $n && $n < M_PI + 1E-14)
		$n = M_PI;
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	$h_m = ($h_1 + $h_2) * 0.5;
	$h_d = ($h_2 - $h_1) * 0.5;
	if (M_PI < $n) {
		if (0.0 < $h_d)
			$h_d -= M_PI;
		else
			$h_d += M_PI;
		$h_m += M_PI;
	}
	$p = 36.0 * $h_m - 55.0 * M_PI;
	$n = ($c_1 + $c_2) * 0.5;
	$n = $n * $n * $n * $n * $n * $n * $n;
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	$r_t = -2.0 * sqrt($n / ($n + 6103515625.0))
					   * sin(M_PI / 3.0 * exp($p * $p / (-25.0 * M_PI * M_PI)));
	$n = ($l_1 + $l_2) * 0.5;
	$n = ($n - 50.0) * ($n - 50.0);
	// Lightness.
	$l = ($l_2 - $l_1) / ($k_l * (1.0 + 0.015 * $n / sqrt(20.0 + $n)));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	$t = 1.0	+ 0.24 * sin(2.0 * $h_m + M_PI * 0.5)
			+ 0.32 * sin(3.0 * $h_m + 8.0 * M_PI / 15.0)
			- 0.17 * sin($h_m + M_PI / 3.0)
			- 0.20 * sin(4.0 * $h_m + 3.0 * M_PI / 20.0);
	$n = $c_1 + $c_2;
	// Hue.
	$h = 2.0 * sqrt($c_1 * $c_2) * sin($h_d) / ($k_h * (1.0 + 0.0075 * $n * $t));
	// Chroma.
	$c = ($c_2 - $c_1) / ($k_c * (1.0 + 0.0225 * $n));
	// Returns the square root so that the Delta E 2000 reflects the actual geometric
	// distance within the color space, which ranges from 0 to approximately 185.
	return sqrt($l * $l + $h * $h + $c * $c + $c * $h * $r_t);
}

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

// L1 = 54.49          a1 = -78.367        b1 = 22.6578
// L2 = 54.49          a2 = -78.367        b2 = 22.6354
// CIE ΔE2000 = ΔE00 = 0.0087933542

// L1 = 74.133         a1 = -118.8743      b1 = 55.5814
// L2 = 74.2979        a2 = -118.8743      b2 = 55.5814
// CIE ΔE2000 = ΔE00 = 0.12150091378

// L1 = 84.976         a1 = 12.7           b1 = -105.6833
// L2 = 88.0           a2 = 7.7            b2 = -102.8
// CIE ΔE2000 = ΔE00 = 2.80822337361

// L1 = 60.87          a1 = -50.7675       b1 = 22.6
// L2 = 60.87          a2 = -42.4          b2 = 22.6
// CIE ΔE2000 = ΔE00 = 2.88601008973

// L1 = 93.3           a1 = 7.452          b1 = 71.9
// L2 = 97.9025        a2 = 2.8            b2 = 67.0
// CIE ΔE2000 = ΔE00 = 4.00858363731

// L1 = 15.0           a1 = -74.2          b1 = -14.0
// L2 = 21.403         a2 = -80.0          b2 = -14.0
// CIE ΔE2000 = ΔE00 = 4.55458599504

// L1 = 27.0           a1 = -8.84          b1 = -50.81
// L2 = 33.9676        a2 = -13.0          b2 = -92.2955
// CIE ΔE2000 = ΔE00 = 10.5699165289

// L1 = 11.0           a1 = 47.0           b1 = 60.071
// L2 = 36.7119        a2 = 43.3787        b2 = 30.61
// CIE ΔE2000 = ΔE00 = 22.4244965166

// L1 = 99.4           a1 = -16.04         b1 = 68.63
// L2 = 5.69           a2 = -86.3          b2 = 25.4
// CIE ΔE2000 = ΔE00 = 97.15088426186

// L1 = 84.993         a1 = 95.348         b1 = -70.8
// L2 = 42.8           a2 = -113.04        b2 = -109.7238
// CIE ΔE2000 = ΔE00 = 103.12035785005

///////////////////////////////////////////////
///////////////////////////////////////////////
///////                                 ///////
///////           CIEDE 2000            ///////
///////      Testing Random Colors      ///////
///////                                 ///////
///////////////////////////////////////////////
///////////////////////////////////////////////

// This program outputs a CSV file to standard output, with its length determined by the first CLI argument.
// Each line contains seven columns:
// - Three columns for the standard L*a*b* color
// - Three columns for the sample L*a*b* color
// - One column for the Delta E 2000 color difference between the standard and sample
// The output can be verified in two ways:
// - With the C driver, which provides a dedicated verification feature
// - By using the JavaScript validator at https://michel-leonard.github.io/ciede2000-color-matching

$n_iterations = 10000;
if (1 < $argc)
	$n_iterations = (int) $argv[1] ;
if ($n_iterations < 1)
	$n_iterations = 10000;

for($i = 0; $i < $n_iterations; ++$i) {
	$l_1 = mt_rand(0, 10000) / 100.0 ;
	$a_1 = mt_rand(-12800, 12800) / 100.0 ;
	$b_1 = mt_rand(-12800, 12800) / 100.0 ;
	$l_2 = mt_rand(0, 10000) / 100.0 ;
	$a_2 = mt_rand(-12800, 12800) / 100.0 ;
	$b_2 = mt_rand(-12800, 12800) / 100.0 ;
	$delta_e = ciede_2000($l_1, $a_1, $b_1, $l_2, $a_2, $b_2);
	echo "$l_1,$a_1,$b_1,$l_2,$a_2,$b_2,$delta_e\n";
}
