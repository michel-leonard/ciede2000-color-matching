<?php

// These color conversion functions written in PHP are released into the public domain.
// They are provided "as is" without any warranty, express or implied.

// rgb in 0..1
function rgb_to_xyz($r, $g, $b) {
	// Apply a gamma correction to each channel.
	$r = $r < 0.0404482362771082 ? $r / 12.92 : pow(($r + 0.055) / 1.055, 2.4);
	$g = $g < 0.0404482362771082 ? $g / 12.92 : pow(($g + 0.055) / 1.055, 2.4);
	$b = $b < 0.0404482362771082 ? $b / 12.92 : pow(($b + 0.055) / 1.055, 2.4);

	// Applying linear transformation using RGB to XYZ transformation matrix.
	$x = $r * 41.24564390896921 + $g * 35.7576077643909 + $b * 18.043748326639894;
	$y = $r * 21.267285140562248 + $g * 71.5152155287818 + $b * 7.217499330655958;
	$z = $r * 1.9333895582329317 + $g * 11.9192025881303 + $b * 95.03040785363677;

	return [$x, $y, $z];
}

function xyz_to_lab($x, $y, $z) {
	// Reference white point (D65)
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
	// Reference white point (D65)
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
	$r = $x * 0.032404541621141054 + $y * -0.015371385127977166 + $z * -0.004985314095560162;
	$g = $x * -0.009692660305051868 + $y * 0.018760108454466942 + $z * 0.0004155601753034984;
	$b = $x * 0.0005564343095911469 + $y * -0.0020402591351675387 + $z * 0.010572251882231791;

	// Apply gamma correction.
	$r = $r < 0.0031306684425005883 ? 12.92 * $r : 1.055 * pow($r, 1.0 / 2.4) - 0.055;
	$g = $g < 0.0031306684425005883 ? 12.92 * $g : 1.055 * pow($g, 1.0 / 2.4) - 0.055;
	$b = $b < 0.0031306684425005883 ? 12.92 * $b : 1.055 * pow($b, 1.0 / 2.4) - 0.055;

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

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching

// Constants used in Color Conversion :
// 216.0 / 24389.0 = 0.0088564516790356308171716757554635286399606379925376194185903481077
// 841.0 / 108.0 = 7.78703703703703703703703703703703703703703703703703703703703703703703703703
// 4.0 / 29.0 = 0.13793103448275862068965517241379310344827586206896551724137931034482758620
// 24389.0 / 27.0 = 903.296296296296296296296296296296296296296296296296296296296296296296296296
// 1.0 / 2.4 = 0.41666666666666666666666666666666666666666666666666666666666666666666666666
