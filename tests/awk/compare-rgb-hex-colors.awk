# This function written in AWK is not affiliated with the CIE (International Commission on Illumination),
# and is released into the public domain. It is provided "as is" without any warranty, express or implied.

# This function can process CSV files, and accepts RGB and hexadecimal
# color formats to calculate color difference using the CIE ΔE2000 formula.

# Examples of use :
# echo '#00F,#483D8B' | awk -f compare-rgb-hex-colors.awk
# echo '#483d8b,75,0,130' | awk -f compare-rgb-hex-colors.awk
# echo '75,0,130,#00008b' | awk -f compare-rgb-hex-colors.awk
# echo '0,0,139,0,0,128' | awk -f compare-rgb-hex-colors.awk

# Displays :
# #00F,#483D8B,15.907285790774
# #483d8b,75,0,130,12.1877110902539
# 75,0,130,#00008b,7.717768543828
# 0,0,139,0,0,128,1.56020064648619

BEGIN {
	# k_l, k_c, k_h are parametric factors to be adjusted according to
	# different viewing parameters such as textures, backgrounds...
	k_l = k_c = k_h = 1.0
	FS = ","
	M_PI = 3.14159265358979323846264338328
}

{
	# Receives a CSV file through a pipe and adds the color difference as the last column.
	sub(/\r$/, "") # Normalize Windows files
	printf("%s,%.17g\n", $0, ciede_2000($1, $2, $3, $4, $5, $6))
}

# Calculates the CIE ΔE2000 color difference between two RGB or hex colors.
# Accepts RGB values (0–255) and/or hex strings ("#fff" or "#ffffff").
# Returns the Delta E 2000 value as a numerical difference.
function ciede_2000(r_1, g_1, b_1, r_2, g_2, b_2) {
	if (sub("^#", "", r_1)) {
		if (sub("^#", "", g_1)) {
			n = strtonum("0x" g_1)
			if (length(g_1) == 3) {
				r_2 = rshift(n, 8); r_2 = or(lshift(r_2, 4), r_2)
				g_2 = and(rshift(n, 4), 15); g_2 = or(lshift(g_2, 4), g_2)
				b_2 = and(n, 15); b_2 = or(lshift(b_2, 4), b_2)
			} else {
				r_2 = rshift(n, 16)
				g_2 = and(rshift(n, 8),  255)
				b_2 = and(n, 255)
			}
		} else {
			b_2 = r_2; g_2 = b_1; r_2 = g_1 ;
		}
		n = strtonum("0x" r_1)
		if (length(r_1) == 3) {
			r_1 = rshift(n, 8); r_1 = or(lshift(r_1, 4), r_1)
			g_1 = and(rshift(n, 4), 15); g_1 = or(lshift(g_1, 4), g_1)
			b_1 = and(n, 15); b_1 = or(lshift(b_1, 4), b_1)
		} else {
			r_1 = rshift(n, 16)
			g_1 = and(rshift(n, 8),  255)
			b_1 = and(n, 255)
		}
	} else if(sub("^#", "", r_2)) {
		n = strtonum("0x" r_2)
		if (length(r_2) == 3) {
			r_2 = rshift(n, 8); r_2 = or(lshift(r_2, 4), r_2)
			g_2 = and(rshift(n, 4), 15); g_2 = or(lshift(g_2, 4), g_2)
			b_2 = and(n, 15); b_2 = or(lshift(b_2, 4), b_2)
		} else {
			r_2 = rshift(n, 16)
			g_2 = and(rshift(n, 8),  255)
			b_2 = and(n, 255)
		}
	}
	r_1 /= 255.0; g_1 /= 255.0; b_1 /= 255.0; r_2 /= 255.0; g_2 /= 255.0; b_2 /= 255.0;
	# Apply a gamma correction to each channel.
	r_1 = r_1 < 0.040448236277105097 ? r_1 / 12.92 : ((r_1 + 0.055) / 1.055) ^ 2.4
	r_2 = r_2 < 0.040448236277105097 ? r_2 / 12.92 : ((r_2 + 0.055) / 1.055) ^ 2.4
	g_1 = g_1 < 0.040448236277105097 ? g_1 / 12.92 : ((g_1 + 0.055) / 1.055) ^ 2.4
	g_2 = g_2 < 0.040448236277105097 ? g_2 / 12.92 : ((g_2 + 0.055) / 1.055) ^ 2.4
	b_1 = b_1 < 0.040448236277105097 ? b_1 / 12.92 : ((b_1 + 0.055) / 1.055) ^ 2.4
	b_2 = b_2 < 0.040448236277105097 ? b_2 / 12.92 : ((b_2 + 0.055) / 1.055) ^ 2.4
	# Applying linear transformation using RGB to XYZ transformation matrix.
	x_1 = r_1 * 41.24564390896921145 + g_1 * 35.75760776439090507 + b_1 * 18.04374830853290341
	x_2 = r_2 * 41.24564390896921145 + g_2 * 35.75760776439090507 + b_2 * 18.04374830853290341
	y_1 = r_1 * 21.26728514056222474 + g_1 * 71.51521552878181013 + b_1 * 7.21749933075596513
	y_2 = r_2 * 21.26728514056222474 + g_2 * 71.51521552878181013 + b_2 * 7.21749933075596513
	z_1 = r_1 * 1.93338955823293176 + g_1 * 11.91919550818385936 + b_1 * 95.03040770337479886
	z_2 = r_2 * 1.93338955823293176 + g_2 * 11.91919550818385936 + b_2 * 95.03040770337479886
	# Reference white point : D65 2° Standard observer
	x_1 /= 95.047; x_2 /= 95.047; y_1 /= 100.000; y_2 /= 100.000; z_1 /= 108.883; z_2 /= 108.883
	# Applying the CIE standard transformation.
	x_1 = x_1 < 216.0 / 24389.0 ? ((841.0 / 108.0) * x_1) + (4.0 / 29.0) : x_1 ^ (1.0 / 3.0)
	x_2 = x_2 < 216.0 / 24389.0 ? ((841.0 / 108.0) * x_2) + (4.0 / 29.0) : x_2 ^ (1.0 / 3.0)
	y_1 = y_1 < 216.0 / 24389.0 ? ((841.0 / 108.0) * y_1) + (4.0 / 29.0) : y_1 ^ (1.0 / 3.0)
	y_2 = y_2 < 216.0 / 24389.0 ? ((841.0 / 108.0) * y_2) + (4.0 / 29.0) : y_2 ^ (1.0 / 3.0)
	z_1 = z_1 < 216.0 / 24389.0 ? ((841.0 / 108.0) * z_1) + (4.0 / 29.0) : z_1 ^ (1.0 / 3.0)
	z_2 = z_2 < 216.0 / 24389.0 ? ((841.0 / 108.0) * z_2) + (4.0 / 29.0) : z_2 ^ (1.0 / 3.0)
	l_1 = (116.0 * y_1) - 16.0
	l_2 = (116.0 * y_2) - 16.0
	a_1 = 500.0 * (x_1 - y_1)
	a_2 = 500.0 * (x_2 - y_2)
	b_1 = 200.0 * (y_1 - z_1)
	b_2 = 200.0 * (y_2 - z_2)
	# Working in AWK with the CIEDE2000 color-difference formula.
	n = (sqrt(a_1 * a_1 + b_1 * b_1) + sqrt(a_2 * a_2 + b_2 * b_2)) * 0.5
	n = n * n * n * n * n * n * n
	# A factor involving chroma raised to the power of 7 designed to make
	# the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - sqrt(n / (n + 6103515625.0)))
	# Application of the chroma correction factor.
	c_1 = sqrt(a_1 * a_1 * n * n + b_1 * b_1)
	c_2 = sqrt(a_2 * a_2 * n * n + b_2 * b_2)
	# atan2 is preferred over atan because it accurately computes the angle of
	# a point (x, y) in all quadrants, handling the signs of both coordinates.
	h_1 = atan2(b_1, a_1 * n)
	h_2 = atan2(b_2, a_2 * n)
	if (h_1 < 0.0) h_1 += 2.0 * M_PI
	h_2 += 2.0 * M_PI * (h_2 < 0.0)
	n = h_2 < h_1 ? h_1 - h_2 : h_2 - h_1
	# Cross-implementation consistent rounding.
	if (M_PI - 1E-14 < n && n < M_PI + 1E-14)
		n = M_PI
	# When the hue angles lie in different quadrants, the straightforward
	# average can produce a mean that incorrectly suggests a hue angle in
	# the wrong quadrant, the next lines handle this issue.
	h_m = (h_1 + h_2) * 0.5
	h_d = (h_2 - h_1) * 0.5
	if (M_PI < n) {
		h_d += M_PI
		# 📜 Sharma’s formulation doesn’t use the next line, but the one after it,
		# and these two variants differ by ±0.0003 on the final color differences.
		h_m += M_PI
		# h_m += ((h_m < M_PI) - (M_PI <= h_m)) * M_PI
	}
	p = 36.0 * h_m - 55.0 * M_PI
	n = (c_1 + c_2) * 0.5
	n = n * n * n * n * n * n * n
	# The hue rotation correction term is designed to account for the
	# non-linear behavior of hue differences in the blue region.
	r_t = -2.0 * sqrt(n / (n + 6103515625.0)) \
			* sin(M_PI / 3.0 * exp(p * p / (-25.0 * M_PI * M_PI)))
	n = (l_1 + l_2) * 0.5
	n = (n - 50.0) * (n - 50.0)
	# Lightness.
	l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / sqrt(20.0 + n)))
	# These coefficients adjust the impact of different harmonic
	# components on the hue difference calculation.
	t = 1.0	+ 0.24 * sin(2.0 * h_m + M_PI * 0.5) \
			+ 0.32 * sin(3.0 * h_m + 8.0 * M_PI / 15.0) \
			- 0.17 * sin(h_m + M_PI / 3.0) \
			- 0.20 * sin(4.0 * h_m + 3.0 * M_PI / 20.0)
	n = c_1 + c_2
	# Hue.
	h = 2.0 * sqrt(c_1 * c_2) * sin(h_d) / (k_h * (1.0 + 0.0075 * n * t))
	# Chroma.
	c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n))
	# Returning the square root ensures that dE00 accurately reflects the
	# geometric distance in color space, which can range from 0 to around 185.
	return sqrt(l * l + h * h + c * c + c * h * r_t)
}

# GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
#   Online Tests : https://michel-leonard.github.io/ciede2000-color-matching

# L1 = 82.9   a1 = 32.7   b1 = 3.6
# L2 = 82.5   a2 = 37.9   b2 = -3.7
# CIE ΔE00 = 4.7246056416 (Bruce Lindbloom, Netflix’s VMAF, ...)
# CIE ΔE00 = 4.7245897156 (Gaurav Sharma, OpenJDK, ...)
# Deviation between implementations ≈ 1.6e-5

# See the source code comments for easy switching between these two widely used ΔE*00 implementation variants.
