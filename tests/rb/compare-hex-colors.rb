# This function written in Ruby is not affiliated with the CIE (International Commission on Illumination),
# and is released into the public domain. It is provided "as is" without any warranty, express or implied.

# The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
# "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
def ciede_2000(l_1, a_1, b_1, l_2, a_2, b_2)
	# Working in Ruby with the CIEDE2000 color-difference formula.
	# k_l, k_c, k_h are parametric factors to be adjusted according to
	# different viewing parameters such as textures, backgrounds...
	k_l = k_c = k_h = 1.0
	n = (Math.hypot(a_1, b_1) + Math.hypot(a_2, b_2)) * 0.5
	n = n * n * n * n * n * n * n
	# A factor involving chroma raised to the power of 7 designed to make
	# the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - Math.sqrt(n / (n + 6103515625.0)))
	# hypot calculates the Euclidean distance while avoiding overflow/underflow.
	c_1 = Math.hypot(a_1 * n, b_1)
	c_2 = Math.hypot(a_2 * n, b_2)
	# atan2 is preferred over atan because it accurately computes the angle of
	# a point (x, y) in all quadrants, handling the signs of both coordinates.
	h_1 = Math.atan2(b_1, a_1 * n)
	h_2 = Math.atan2(b_2, a_2 * n)
	h_1 += 2.0 * Math::PI if h_1 < 0.0
	h_2 += 2.0 * Math::PI if h_2 < 0.0
	n = (h_2 - h_1).abs
	# Cross-implementation consistent rounding.
	n = Math::PI if Math::PI - 1E-14 < n && n < Math::PI + 1E-14
	# When the hue angles lie in different quadrants, the straightforward
	# average can produce a mean that incorrectly suggests a hue angle in
	# the wrong quadrant, the next lines handle this issue.
	h_m = (h_1 + h_2) * 0.5
	h_d = (h_2 - h_1) * 0.5
	if Math::PI < n
		if 0.0 < h_d
			h_d -= Math::PI
		else
			h_d += Math::PI
		end
		h_m += Math::PI
	end
	p = 36.0 * h_m - 55.0 * Math::PI
	n = (c_1 + c_2) * 0.5
	n = n * n * n * n * n * n * n
	# The hue rotation correction term is designed to account for the
	# non-linear behavior of hue differences in the blue region.
	r_t = -2.0 * Math.sqrt(n / (n + 6103515625.0)) \
		* Math.sin(Math::PI / 3.0 * Math.exp(p * p / (-25.0 * Math::PI * Math::PI)))
	n = (l_1 + l_2) * 0.5
	n = (n - 50.0) * (n - 50.0)
	# Lightness.
	l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / Math.sqrt(20.0 + n)))
	# These coefficients adjust the impact of different harmonic
	# components on the hue difference calculation.
	t = 1.0 + 0.24 * Math.sin(2.0 * h_m + Math::PI * 0.5) \
		+ 0.32 * Math.sin(3.0 * h_m + 8.0 * Math::PI / 15.0) \
		- 0.17 * Math.sin(h_m + Math::PI / 3.0) \
		- 0.20 * Math.sin(4.0 * h_m + 3.0 * Math::PI / 20.0)
	n = c_1 + c_2
	# Hue.
	h = 2.0 * Math.sqrt(c_1 * c_2) * Math.sin(h_d) / (k_h * (1.0 + 0.0075 * n * t))
	# Chroma.
	c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n))
	# Returns the square root so that the Delta E 2000 reflects the actual geometric
	# distance within the color space, which ranges from 0 to approximately 185.
	Math.sqrt(l * l + h * h + c * c + c * h * r_t)
end

# GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
#  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

# L1 = 45.5           a1 = -97.1441       b1 = 96.2
# L2 = 45.5           a2 = -97.09         b2 = 96.2
# CIE ΔE2000 = ΔE00 = 0.01149794022

# L1 = 96.66          a1 = 40.7           b1 = -66.4
# L2 = 96.66          a2 = 40.7           b2 = -66.46
# CIE ΔE2000 = ΔE00 = 0.02614792511

# L1 = 80.9623        a1 = 90.882         b1 = 89.1
# L2 = 80.9623        a2 = 91.0           b2 = 86.51
# CIE ΔE2000 = ΔE00 = 0.88490727439

# L1 = 91.72          a1 = 68.94          b1 = -27.9425
# L2 = 95.2           a2 = 76.2677        b2 = -27.9425
# CIE ΔE2000 = ΔE00 = 2.78370354456

# L1 = 14.589         a1 = 120.4          b1 = -95.93
# L2 = 20.36          a2 = 120.4          b2 = -95.93
# CIE ΔE2000 = ΔE00 = 3.89055713701

# L1 = 81.7           a1 = 33.0           b1 = 80.1961
# L2 = 80.5505        a2 = 33.133         b2 = 56.0
# CIE ΔE2000 = ΔE00 = 8.10332839553

# L1 = 53.4754        a1 = -126.871       b1 = 120.91
# L2 = 66.95          a2 = -94.2          b2 = 73.8534
# CIE ΔE2000 = ΔE00 = 14.30177579475

# L1 = 16.7068        a1 = -27.43         b1 = -63.36
# L2 = 16.7           a2 = -83.8268       b2 = -61.0
# CIE ΔE2000 = ΔE00 = 16.65649957331

# L1 = 5.25           a1 = -15.0          b1 = 89.78
# L2 = 27.548         a2 = -30.5097       b2 = 72.3357
# CIE ΔE2000 = ΔE00 = 17.92206173771

# L1 = 51.075         a1 = -48.042        b1 = 52.928
# L2 = 39.2           a2 = 112.0          b2 = 21.544
# CIE ΔE2000 = ΔE00 = 87.97962520785

# These color conversion functions written in Ruby are released into the public domain.
# They are provided "as is" without any warranty, express or implied.

# rgb in 0..1
def rgb_to_xyz(r, g, b)
	# Apply a gamma correction to each channel.
	r = r < 0.040448236276933 ? r / 12.92 : ((r + 0.055) / 1.055) ** 2.4
	g = g < 0.040448236276933 ? g / 12.92 : ((g + 0.055) / 1.055) ** 2.4
	b = b < 0.040448236276933 ? b / 12.92 : ((b + 0.055) / 1.055) ** 2.4

	# Applying linear transformation using RGB to XYZ transformation matrix.
	x = r * 41.24564390896921145 + g * 35.75760776439090507 + b * 18.04374830853290341
	y = r * 21.26728514056222474 + g * 71.51521552878181013 + b * 7.21749933075596513
	z = r * 1.93338955823293176 + g * 11.91919550818385936 + b * 95.03040770337479886

  [x, y, z]
end

def xyz_to_lab(x, y, z)
	# Reference white point (D65)
	refX = 95.047
	refY = 100.000
	refZ = 108.883

	x /= refX
	y /= refY
	z /= refZ

	# Applying the CIE standard transformation.
	x = x < 216.0 / 24389.0 ? ((841.0 / 108.0) * x) + (4.0 / 29.0) : Math.cbrt(x)
	y = y < 216.0 / 24389.0 ? ((841.0 / 108.0) * y) + (4.0 / 29.0) : Math.cbrt(y)
	z = z < 216.0 / 24389.0 ? ((841.0 / 108.0) * z) + (4.0 / 29.0) : Math.cbrt(z)

	l = (116.0 * y) - 16.0
	a = 500.0 * (x - y)
	b = 200.0 * (y - z)

	[l, a, b]
end

# rgb in 0..1
def rgb_to_lab(r, g, b)
	xyz = rgb_to_xyz(r, g, b)
	xyz_to_lab(xyz[0], xyz[1], xyz[2])
end

def lab_to_xyz(l, a, b)
	# Reference white point (D65)
	refX = 95.047
	refY = 100.000
	refZ = 108.883

	y = (l + 16.0) / 116.0
	x = a / 500.0 + y
	z = y - b / 200.0

	x3 = x * x * x
	z3 = z * z * z

	x = x3 < 216.0 / 24389.0 ? (x - 4.0 / 29.0) / (841.0 / 108.0) : x3
	y = l < 8.0 ? l / (24389.0 / 27.0) : y * y * y
	z = z3 < 216.0 / 24389.0 ? (z - 4.0 / 29.0) / (841.0 / 108.0) : z3

	[x * refX, y * refY, z * refZ]
end

# rgb in 0..1
def xyz_to_rgb(x, y, z)
	# Applying linear transformation using the XYZ to RGB transformation matrix.
	r = x * 0.032404541621141049051 + y * -0.015371385127977165753 + z * -0.004985314095560160079
	g = x * -0.009692660305051867686 + y * 0.018760108454466942288 + z * 0.00041556017530349983
	b = x * 0.000556434309591145522 + y * -0.002040259135167538416 + z * 0.010572251882231790398

	# Apply gamma correction.
	r = r < 0.0031306684424956 ? 12.92 * r : 1.055 * r ** (1.0 / 2.4) - 0.055
	g = g < 0.0031306684424956 ? 12.92 * g : 1.055 * g ** (1.0 / 2.4) - 0.055
	b = b < 0.0031306684424956 ? 12.92 * b : 1.055 * b ** (1.0 / 2.4) - 0.055

	[r, g, b]
end

# rgb in 0..1
def lab_to_rgb(l, a, b)
	xyz = lab_to_xyz(l, a, b)
	xyz_to_rgb(xyz[0], xyz[1], xyz[2])
end

# rgb in 0..255
def hex_to_rgb(s)
	# Also support the short syntax (ie "#FFF") as input.
	s = "##{s[1]*2}#{s[2]*2}#{s[3]*2}" if s.length == 4
	n = s[1..].to_i(16)
	[(n >> 16) & 0xff, (n >> 8) & 0xff, n & 0xff]
end

# rgb in 0..255
def rgb_to_hex(r, g, b)
	# Also provide the short syntax (ie "#FFF") as output.
	s = '#' + [r, g, b].map { |x| x.to_s(16).rjust(2, '0') }.join
	s[1] == s[2] && s[3] == s[4] && s[5] == s[6] ? "##{s[1]}#{s[3]}#{s[5]}" : s
end

# Constants used in Color Conversion :
# 216.0 / 24389.0 = 0.0088564516790356308171716757554635286399606379925376194185903481077
# 841.0 / 108.0 = 7.78703703703703703703703703703703703703703703703703703703703703703703703703
# 4.0 / 29.0 = 0.13793103448275862068965517241379310344827586206896551724137931034482758620
# 24389.0 / 27.0 = 903.296296296296296296296296296296296296296296296296296296296296296296296296
# 1.0 / 2.4 = 0.41666666666666666666666666666666666666666666666666666666666666666666666666
# To get 0.040448236276933 we perform x/12.92 = ((x+0.055)/1.055)^2.4
# To get 0.0031306684424956 we perform 12.92*x = 1.055*x^(1/2.4)-0.055

##################################################
###########                      #################
###########   CIE ΔE2000 Demo    #################
###########                      #################
##################################################

# The goal of this demo is to use the CIEDE2000 function to compare two hexadecimal colors.

hex_1 = "#d2691e" # Chocolate color in hex
hex_2 = "#ff6347" # Tomato color in hex

# Convert hex colors to RGB, normalize to [0,1], then convert to CIELAB
lab_1 = rgb_to_lab(*hex_to_rgb(hex_1).map! { |i| i / 255.0 })
lab_2 = rgb_to_lab(*hex_to_rgb(hex_2).map! { |i| i / 255.0 })

# Compute the color difference using the CIEDE2000 formula
delta_e = ciede_2000(*lab_1, *lab_2)

puts delta_e

# This shows a ΔE2000 of 14.29
