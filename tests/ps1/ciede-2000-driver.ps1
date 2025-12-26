# Limited Use License – March 1, 2025

# This source code is provided for public use under the following conditions :
# It may be downloaded, compiled, and executed, including in publicly accessible environments.
# Modification is strictly prohibited without the express written permission of the author.

# © Michel Leonard 2025

# The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
# "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
function ciede_2000 {
	param(
		[double]$l_1, [double]$a_1, [double]$b_1,
		[double]$l_2, [double]$a_2, [double]$b_2
	)
	# Working in PowerShell with the CIEDE2000 color-difference formula.
	# k_l, k_c, k_h are parametric factors to be adjusted according to
	# different viewing parameters such as textures, backgrounds...
	$k_l = 1.0
	$k_c = 1.0
	$k_h = 1.0
	$n = ([math]::Sqrt($a_1 * $a_1 + $b_1 * $b_1) + [math]::Sqrt($a_2 * $a_2 + $b_2 * $b_2)) * 0.5
	$n = $n * $n * $n * $n * $n * $n * $n
	# A factor involving chroma raised to the power of 7 designed to make
	# the influence of chroma on the total color difference more accurate.
	$n = 1.0 + 0.5 * (1.0 - [math]::Sqrt($n / ($n + 6103515625.0)))
	# Application of the chroma correction factor.
	$c_1 = [math]::Sqrt($a_1 * $a_1 * $n * $n + $b_1 * $b_1)
	$c_2 = [math]::Sqrt($a_2 * $a_2 * $n * $n + $b_2 * $b_2)
	# atan2 is preferred over atan because it accurately computes the angle of
	# a point (x, y) in all quadrants, handling the signs of both coordinates.
	$h_1 = [math]::Atan2($b_1, $a_1 * $n)
	$h_2 = [math]::Atan2($b_2, $a_2 * $n)
	$h_1 = $h_1 + 2.0 * [math]::PI * ($h_1 -lt 0.0)
	$h_2 = $h_2 + 2.0 * [math]::PI * ($h_2 -lt 0.0)
	$n = [math]::Abs($h_2 - $h_1)
	# Cross-implementation consistent rounding.
	if (([math]::PI - 1E-14) -lt $n -and $n -lt ([math]::PI + 1E-14)) {
		$n = [math]::PI
	}
	# When the hue angles lie in different quadrants, the straightforward
	# average can produce a mean that incorrectly suggests a hue angle in
	# the wrong quadrant, the next lines handle this issue.
	$h_m = ($h_1 + $h_2) * 0.5
	$h_d = ($h_2 - $h_1) * 0.5
	if ([math]::PI -lt $n) {
		$h_d += [math]::PI;
  		# 📜 Sharma’s formulation doesn’t use the next line, but the one after it,
		# and these two variants differ by ±0.0003 on the final color differences.
		$h_m += [math]::PI;
  		# $h_m += if ($h_m -lt [Math]::PI) { [Math]::PI } else { -[Math]::PI }
	}
	$p = 36.0 * $h_m - 55.0 * [math]::PI
	$n = ($c_1 + $c_2) * 0.5
	$n = $n * $n * $n * $n * $n * $n * $n
	# The hue rotation correction term is designed to account for the
	# non-linear behavior of hue differences in the blue region.
	$r_t = -2.0 * [math]::Sqrt($n / ($n + 6103515625.0)) * [math]::Sin([math]::PI / 3.0 *
			[math]::Exp($p * $p / (-25.0 * [math]::PI * [math]::PI)))
	$n = ($l_1 + $l_2) * 0.5
	$n = ($n - 50.0) * ($n - 50.0)
	# Lightness.
	$l = ($l_2 - $l_1) / ($k_l * (1.0 + 0.015 * $n / [math]::Sqrt(20.0 + $n)))
	# These coefficients adjust the impact of different harmonic
	# components on the hue difference calculation.
	$t = 1.0 +	0.24 * [math]::Sin(2.0 * $h_m + [math]::PI * 0.5) +
			0.32 * [math]::Sin(3.0 * $h_m + 8.0 * [math]::PI / 15.0) -
			0.17 * [math]::Sin($h_m + [math]::PI / 3.0) -
			0.20 * [math]::Sin(4.0 * $h_m + 3.0 * [math]::PI / 20.0)
	$n = $c_1 + $c_2
	# Hue.
	$h = 2.0 * [math]::Sqrt($c_1 * $c_2) * [math]::Sin($h_d) / ($k_h * (1.0 + 0.0075 * $n * $t))
	# Chroma.
	$c = ($c_2 - $c_1) / ($k_c * (1.0 + 0.0225 * $n))
	# Returning the square root ensures that dE00 accurately reflects the
	# geometric distance in color space, which can range from 0 to around 185.
	return [math]::Sqrt($l * $l + $h * $h + $c * $c + $c * $h * $r_t)
}

# GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
#   Online Tests : https://michel-leonard.github.io/ciede2000-color-matching

# L1 = 76.6   a1 = 30.2   b1 = -1.8
# L2 = 76.2   a2 = 36.3   b2 = 3.4
# CIE ΔE00 = 3.9467098057 (Bruce Lindbloom, Netflix’s VMAF, ...)
# CIE ΔE00 = 3.9467239485 (Gaurav Sharma, OpenJDK, ...)
# Deviation between implementations ≈ 1.4e-5

# See the source code comments for easy switching between these two widely used ΔE*00 implementation variants.

#################################################
#################################################
############                         ############
############    CIEDE2000 Driver     ############
############                         ############
#################################################
#################################################

# Reads a CSV file specified as the first command-line argument. For each line, this program
# in PowerShell displays the original line with the computed Delta E 2000 color difference appended.
# The C driver can offer CSV files to process and programmatically check the calculations performed there.

#  Example of a CSV input line : 35,81,1,32.3,41,-15.9
#    Corresponding output line : 35,81,1,32.3,41,-15.9,13.881493636996540127439229200245

if (-not (Test-Path $args[0] -PathType Leaf)) {
	Write-Output "CIEDE2000: Please specify the path of a CSV file containing L*a*b* colors."
	return
}

$culture = [System.Globalization.CultureInfo]::CreateSpecificCulture("en-US")
$culture.NumberFormat.NumberDecimalSeparator = "."
$culture.NumberFormat.NumberGroupSeparator = ""
[System.Threading.Thread]::CurrentThread.CurrentCulture = $culture

Get-Content $args[0] | ForEach-Object {
	$v = $_ -split ','
	$dE = ciede_2000 ([double]$v[0]) ([double]$v[1]) ([double]$v[2]) ([double]$v[3]) ([double]$v[4]) ([double]$v[5])
	Write-Output ("{0},{1}" -f $_.TrimEnd(), $dE)
}
