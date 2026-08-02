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
	$n = (sqrt($a_1 * $a_1 + $b_1 * $b_1) + sqrt($a_2 * $a_2 + $b_2 * $b_2)) * 0.5;
	$n = $n * $n * $n * $n * $n * $n * $n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	$n = 1.0 + 0.5 * (1.0 - sqrt($n / ($n + 6103515625.0)));
	// Application of the chroma correction factor.
	$c_1 = sqrt($a_1 * $a_1 * $n * $n + $b_1 * $b_1);
	$c_2 = sqrt($a_2 * $a_2 * $n * $n + $b_2 * $b_2);
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
		$h_d += M_PI;
		// 📜 Sharma’s formulation doesn’t use the next line, but the one after it,
		// and these two variants differ by ±0.0003 on the final color differences.
		$h_m += M_PI;
		// $h_m += $h_m < M_PI ? M_PI : -M_PI;
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
	// Returning the square root ensures that dE00 accurately reflects the
	// geometric distance in color space, which can range from 0 to around 185.
	return sqrt($l * $l + $h * $h + $c * $c + $c * $h * $r_t);
}

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//   Online Tests : https://michel-leonard.github.io/ciede2000-color-matching

// L1 = 40.5   a1 = 45.8   b1 = -3.3
// L2 = 40.8   a2 = 51.4   b2 = 3.8
// CIE ΔE00 = 4.0182852221 (Bruce Lindbloom, Netflix’s VMAF, ...)
// CIE ΔE00 = 4.0183007007 (Gaurav Sharma, OpenJDK, ...)
// Deviation between implementations ≈ 1.5e-5

// See the source code comments for easy switching between these two widely used ΔE*00 implementation variants.

// These color conversion functions written in PHP are released into the public domain.
// They are provided "as is" without any warranty, express or implied.

// rgb in 0..1
function rgb_to_xyz($r, $g, $b) {
	// Apply a gamma correction to each channel.
	$r = $r < 0.040448236277105097 ? $r / 12.92 : pow(($r + 0.055) / 1.055, 2.4);
	$g = $g < 0.040448236277105097 ? $g / 12.92 : pow(($g + 0.055) / 1.055, 2.4);
	$b = $b < 0.040448236277105097 ? $b / 12.92 : pow(($b + 0.055) / 1.055, 2.4);

	// Applying linear transformation using RGB to XYZ transformation matrix.
	$x = $r * 41.24564390896921145 + $g * 35.75760776439090507 + $b * 18.04374830853290341;
	$y = $r * 21.26728514056222474 + $g * 71.51521552878181013 + $b * 7.21749933075596513;
	$z = $r * 1.93338955823293176 + $g * 11.91919550818385936 + $b * 95.03040770337479886;

	return [$x, $y, $z];
}

function xyz_to_lab($x, $y, $z) {
	// Reference white point : D65 2° Standard observer
	$refX = 95.047;
	$refY = 100.000;
	$refZ = 108.883;

	$x /= $refX;
	$y /= $refY;
	$z /= $refZ;

	// Applying the CIE standard transformation.
	$x = $x < 216.0 / 24389.0 ? ((841.0 / 108.0) * $x) + (4.0 / 29.0) : pow($x, 1.0 / 3.0);
	$y = $y < 216.0 / 24389.0 ? ((841.0 / 108.0) * $y) + (4.0 / 29.0) : pow($y, 1.0 / 3.0);
	$z = $z < 216.0 / 24389.0 ? ((841.0 / 108.0) * $z) + (4.0 / 29.0) : pow($z, 1.0 / 3.0);

	$l = (116.0 * $y) - 16.0;
	$a = 500.0 * ($x - $y);
	$b = 200.0 * ($y - $z);

	return [$l, $a, $b];
}

// rgb in 0..1
function rgb_to_lab($r, $g, $b) {
	$xyz = rgb_to_xyz($r, $g, $b);
	return xyz_to_lab($xyz[0], $xyz[1], $xyz[2]);
}

function lab_to_xyz($l, $a, $b) {
	// Reference white point : D65 2° Standard observer
	$refX = 95.047;
	$refY = 100.000;
	$refZ = 108.883;

	$y = ($l + 16.0) / 116.0;
	$x = $a / 500.0 + $y;
	$z = $y - $b / 200.0;

	$x3 = $x * $x * $x;
	$z3 = $z * $z * $z;

	$x = $x3 < 216.0 / 24389.0 ? ($x - 4.0 / 29.0) / (841.0 / 108.0) : $x3;
	$y = $l < 8.0 ? l / (24389.0 / 27.0) : $y * $y * $y;
	$z = $z3 < 216.0 / 24389.0 ? ($z - 4.0 / 29.0) / (841.0 / 108.0) : $z3;

	return [$x * $refX, $y * $refY, $z * $refZ];
}

// rgb in 0..1
function xyz_to_rgb($x, $y, $z) {
	// Applying linear transformation using the XYZ to RGB transformation matrix.
	$r = $x * 0.032404541621141049051 + $y * -0.015371385127977165753 + $z * -0.004985314095560160079;
	$g = $x * -0.009692660305051867686 + $y * 0.018760108454466942288 + $z * 0.00041556017530349983;
	$b = $x * 0.000556434309591145522 + $y * -0.002040259135167538416 + $z * 0.010572251882231790398;

	// Apply gamma correction.
	$r = $r < 0.003130668442500634 ? 12.92 * $r : 1.055 * pow($r, 1.0 / 2.4) - 0.055;
	$g = $g < 0.003130668442500634 ? 12.92 * $g : 1.055 * pow($g, 1.0 / 2.4) - 0.055;
	$b = $b < 0.003130668442500634 ? 12.92 * $b : 1.055 * pow($b, 1.0 / 2.4) - 0.055;

	return [$r, $g, $b];
}

// rgb in 0..1
function lab_to_rgb($l, $a, $b) {
	$xyz = lab_to_xyz($l, $a, $b);
	return xyz_to_rgb($xyz[0], $xyz[1], $xyz[2]);
}

// rgb in 0..255
function hex_to_rgb($s) {
	// Also support the short syntax (ie "#FFF") as input.
	if (strlen($s) === 4)
		$s = $s[0] . $s[1] . $s[1] . $s[2] . $s[2] . $s[3] . $s[3];
	$n = (int)hexdec(substr($s, 1));
	return [$n >> 16 & 0xff, $n >> 8 & 0xff, $n & 0xff];
}

// rgb in 0..255
function rgb_to_hex($r, $g, $b) {
	// Also provide the short syntax (ie "#FFF") as output.
	$s = '#' . str_pad(dechex($r), 2, '0', STR_PAD_LEFT);
	$s .= str_pad(dechex($g), 2, '0', STR_PAD_LEFT);
	$s .= str_pad(dechex($b), 2, '0', STR_PAD_LEFT);
	return $s[1] === $s[2] && $s[3] === $s[4] && $s[5] === $s[6] ? '#' . $s[1] . $s[3] . $s[5] : $s;
}

//////////////////////////////////////////////////
///////////                      /////////////////
///////////   CIE ΔE2000 Demo    /////////////////
///////////                      /////////////////
//////////////////////////////////////////////////

// The goal of this demo in PHP is to use the CIEDE2000 function to compare two hexadecimal colors.

$hex_1 = "#00f"; // blue
$hex_2 = "#483D8B"; // darkslateblue

// 1. hex -> RGB (0..255)
[$r_1, $g_1, $b_1] = hex_to_rgb($hex_1);
[$r_2, $g_2, $b_2] = hex_to_rgb($hex_2);
printf("%8s -> RGB(%3d, %3d, %3d)\n", $hex_1, $r_1, $g_1, $b_1);
printf("%8s -> RGB(%3d, %3d, %3d)\n", $hex_2, $r_2, $g_2, $b_2);

// 2. RGB -> LAB
[$l_1, $a_1, $b_1_lab] = rgb_to_lab($r_1 / 255.0, $g_1 / 255.0, $b_1 / 255.0);
[$l_2, $a_2, $b_2_lab] = rgb_to_lab($r_2 / 255.0, $g_2 / 255.0, $b_2 / 255.0);
printf("%8s -> LAB(L: %.5g, a: %.5g, b: %.5g)\n", $hex_1, $l_1, $a_1, $b_1_lab);
printf("%8s -> LAB(L: %.5g, a: %.5g, b: %.5g)\n", $hex_2, $l_2, $a_2, $b_2_lab);

// 3. Delta E 2000
$delta_e = ciede_2000($l_1, $a_1, $b_1_lab, $l_2, $a_2, $b_2_lab);
printf("  ΔE2000: %.5g\n", $delta_e);

// This shows a ΔE2000 of 15.91
