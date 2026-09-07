# Limited Use License – March 1, 2025

# This source code is provided for public use under the following conditions :
# It may be downloaded, compiled, and executed, including in publicly accessible environments.
# Modification is strictly prohibited without the express written permission of the author.

# © Michel Leonard 2025

# The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
# "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
proc ciede_2000 { l_1 a_1 b_1 l_2 a_2 b_2 } {
	# Working in TCL with the CIEDE2000 color-difference formula.
	# k_l, k_c, k_h are parametric factors to be adjusted according to
	# different viewing parameters such as textures, backgrounds...
	set k_l 1.0
	set k_c 1.0
	set k_h 1.0
	set pi 3.14159265358979323846264338328
	set n [expr { (sqrt($a_1 * $a_1 + $b_1 * $b_1) + sqrt($a_2 * $a_2 + $b_2 * $b_2)) * 0.5 }]
	set n [expr { $n * $n * $n * $n * $n * $n * $n }]
	# A factor involving chroma raised to the power of 7 designed to make
	# the influence of chroma on the total color difference more accurate.
	set n [expr { 1.0 + 0.5 * (1.0 - sqrt($n / ($n + 6103515625.0))) }]
	# Application of the chroma correction factor.
	set c_1 [expr { sqrt($a_1 * $a_1 * $n * $n + $b_1 * $b_1) }]
	set c_2 [expr { sqrt($a_2 * $a_2 * $n * $n + $b_2 * $b_2) }]
	# atan2 is preferred over atan because it accurately computes the angle of
	# a point (x, y) in all quadrants, handling the signs of both coordinates.
	set h_1 [expr { atan2($b_1, $a_1 * $n) }]
	set h_2 [expr { atan2($b_2, $a_2 * $n) }]
	if { $h_1 < 0.0 } { set h_1 [expr { $h_1 + 2.0 * $pi }] }
	if { $h_2 < 0.0 } { set h_2 [expr { $h_2 + 2.0 * $pi }] }
	set n [expr { abs($h_2 - $h_1) }]
	# Cross-implementation consistent rounding.
	if { $pi - 1E-14 < $n && $n < $pi + 1E-14 } {
		set n $pi
	}
	# When the hue angles lie in different quadrants, the straightforward
	# average can produce a mean that incorrectly suggests a hue angle in
	# the wrong quadrant, the next lines handle this issue.
	set h_m [expr { ($h_1 + $h_2) * 0.5 }]
	set h_d [expr { ($h_2 - $h_1) * 0.5 }]
	if { $pi < $n } {
		set h_d [expr { $h_d + $pi }]
  		# 📜 Sharma’s formulation doesn’t use the next line, but the one after it,
		# and these two variants differ by ±0.0003 on the final color differences.
		set h_m [expr { $h_m + $pi }]
  		# set h_m [expr {$h_m + ($h_m < $pi ? $pi : -$pi)}]
	}
	set p [expr { 36.0 * $h_m - 55.0 * $pi }]
	set n [expr { ($c_1 + $c_2) * 0.5 }]
	set n [expr { $n * $n * $n * $n * $n * $n * $n }]
	# The hue rotation correction term is designed to account for the
	# non-linear behavior of hue differences in the blue region.
	set r_t [expr { -2.0 * sqrt($n / ($n + 6103515625.0))
				* sin($pi / 3.0 * exp($p * $p / (-25.0 * $pi * $pi))) }]
	set n [expr { ($l_1 + $l_2) * 0.5 }]
	set n [expr { ($n - 50.0) * ($n - 50.0) }]
	# Lightness.
	set l [expr { ($l_2 - $l_1) / ($k_l * (1.0 + 0.015 * $n / sqrt(20.0 + $n))) }]
	# These coefficients adjust the impact of different harmonic
	# components on the hue difference calculation.
	set t [expr { 1.0	+ 0.24 * sin(2.0 * $h_m + $pi * 0.5)
						+ 0.32 * sin(3.0 * $h_m + 8.0 * $pi / 15.0)
						- 0.17 * sin($h_m + $pi / 3.0)
						- 0.20 * sin(4.0 * $h_m + 3.0 * $pi / 20.0) }]
	set n [expr { $c_1 + $c_2 }]
	# Hue.
	set h [expr { 2.0 * sqrt($c_1 * $c_2) * sin($h_d) / ($k_h * (1.0 + 0.0075 * $n * $t)) }]
	# Chroma.
	set c [expr { ($c_2 - $c_1) / ($k_c * (1.0 + 0.0225 * $n)) }]
	# Returning the square root ensures that dE00 accurately reflects the
	# geometric distance in color space, which can range from 0 to around 185.
	return [expr { sqrt($l * $l + $h * $h + $c * $c + $c * $h * $r_t) }]
}

# GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
#   Online Tests : https://michel-leonard.github.io/ciede2000-color-matching

# L1 = 7.1    a1 = 29.2   b1 = 3.7
# L2 = 7.0    a2 = 33.8   b2 = -3.9
# CIE ΔE00 = 4.9909730707 (Bruce Lindbloom, Netflix’s VMAF, ...)
# CIE ΔE00 = 4.9909578172 (Gaurav Sharma, OpenJDK, ...)
# Deviation between implementations ≈ 1.5e-5

# See the source code comments for easy switching between these two widely used ΔE*00 implementation variants.

# ################################################
# ################################################
# ###########                         ############
# ###########    CIEDE2000 Driver     ############
# ###########                         ############
# ################################################
# ################################################

# Reads a CSV file specified as the first command-line argument. For each line, this program
# in TCL displays the original line with the computed Delta E 2000 color difference appended.
# The C driver can offer CSV files to process and programmatically check the calculations performed there.

#  Example of a CSV input line : 22,-1.1,55,35.3,4,48
#    Corresponding output line : 22,-1.1,55,35.3,4,48,10.948424676650040290099123275584

if { $argc < 1 } {
	puts "Usage: tclsh $argv0 <filename>"
	return
}

set fp [open [lindex $argv 0] rb]
while {[gets $fp line] >= 0} {
	set line [ string trimright $line ]
	set v [split $line ","]
	set dE [ciede_2000 [lindex $v 0] [lindex $v 1] [lindex $v 2] [lindex $v 3] [lindex $v 4] [lindex $v 5]]
	puts "$line,$dE"
}
close $fp
