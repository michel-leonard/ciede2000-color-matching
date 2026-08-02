# This function written in Python is not affiliated with the CIE (International Commission on Illumination),
# and is released into the public domain. It is provided "as is" without any warranty, express or implied.

# The vecorized CIEDE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
# "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
def ciede_2000(l1, a1, b1, l2, a2, b2, kl = 1.0, kc = 1.0, kh = 1.0, canonical = False) :
	import numpy as np
	# Working in Python with the CIEDE2000 color-difference formula.
	# kl, kc, kh are parametric factors to be adjusted according to
	# different viewing parameters such as textures, backgrounds...
	m_pi = np.asarray("3.141592653589793238462643383279502884", dtype = l2.dtype)
	pi_interoperability = m_pi + (1E-6 if m_pi.dtype == np.float32 else 1E-14)
	c1 = b1 * b1
	c2 = b2 * b2
	n = np.sqrt(a1 * a1 + c1)
	n += np.sqrt(a2 * a2 + c2)
	n *= 0.5
	n **= 7.0
	n /= n + 6103515625.0
	n = np.sqrt(n)
	n *= 0.5
	n = 1.5 - n # The chroma correction factor.

	# atan2 is preferred over atan because it accurately computes the angle of
	# a point (x, y) in all quadrants, handling the signs of both coordinates.
	c = a1 * n
	c1 += c * c
	c1 = np.sqrt(c1)
	hm = np.arctan2(b1, c)
	hm[hm < 0.0] += 2.0 * m_pi

	c = a2 * n
	c2 += c * c
	c2 = np.sqrt(c2)
	h = np.arctan2(b2, c)
	h[h < 0.0] += 2.0 * m_pi

	# When the hue angles lie in different quadrants, the straightforward
	# average can produce a mean that incorrectly suggests a hue angle in
	# the wrong quadrant, the next 10 lines handle this issue.
	h -= hm
	n = pi_interoperability < np.abs(h)
	h *= 0.5 # h_delta
	hm += h  # h_mean

	# The part where most programmers get it wrong.
	if canonical :
		# When canonical is set to True, this acts like Gaurav Sharma, OpenJDK, ...
		hm[n] -= (pi_interoperability < hm[n]) * (2.0 * m_pi)
	# When canonical is set to False, this acts like Bruce Lindbloom, Netflix’s VMAF, ...
	hm[n] += m_pi
	h[n] += m_pi
	h = 2.0 * np.sin(h)
	h *= np.sqrt(c1 * c2)

	# Application of the chroma correction factor.
	c = c1 + c2
	n = 0.5 * c
	n **= 7.0
	n /= n + 6103515625.0

	# The hue rotation correction term is designed to account for the
	# non-linear behavior of hue differences in the blue region.
	r_t = -2.0 * np.sqrt(n)
	n = 36.0 * hm
	n -= 55.0 * m_pi
	n /= 5.0 * m_pi
	n *= n
	n = np.exp(-n)
	n *= m_pi / 3.0
	r_t *= np.sin(n)

	# These coefficients adjust the impact of different harmonic
	# components on the hue difference calculation.
	n = 150.0
	n -= 25.5 * np.sin(hm + m_pi / 3.0)
	n += 36.0 * np.sin(2.0 * hm + m_pi * 0.5)
	n += 48.0 * np.sin(3.0 * hm + 8.0 * m_pi / 15.0)
	n -= 30.0 * np.sin(4.0 * hm + 3.0 * m_pi / 20.0)
	hm = False # Not used anymore.
	n /= 20000.0
	n *= c
	n += 1.0
	n *= kh
	# Hue.
	h /= n

	# Lightness.
	l = l2 - l1
	n = l1 + l2
	n *= 0.5
	n -= 50.0
	n *= n
	n /= np.sqrt(20.0 + n)
	n *= 3.0
	n /= 200.0
	n += 1.0
	n *= kl
	l /= n

	# Chroma.
	n = 9.0 * c
	n /= 400.0
	c = c2 - c1
	n += 1.0
	n *= kc
	c /= n
	c1 = c2 = n = False # Not used anymore.

	cie00 = l * l
	cie00 += h * h
	h *= r_t
	h += c
	cie00 += c * h
	cie00 = np.sqrt(cie00)
	# The result accurately reflects the geometric distance in the color space.
	# The function allocates no more than 9 temporary vectors at any one time.
	##############################################################################
	#       Goal         Data type    Speed gain      Accuracy     Correct digits
	##############################################################################
	#      General        float32         x6           ± 2e-4            3
	#     Scientific      float64         x4          ± 4e-13            12
	#     Metrology       float96         x1          ± 2e-16            15
	return cie00

# If you remove the constant 1E-14, the code will continue to work, but CIEDE2000
# interoperability between all programming languages will no longer be guaranteed.

# Source code tested by Michel LEONARD
# Website: github.com/michel-leonard/ciede2000-python

################################################################
################################################################
#############                                 ##################
#############             TESTING             ##################
#############                                 ##################
################################################################
################################################################

references = [
	[ 95.3, 58.8, 2.1, 95.7, 61.9, -1.7, 1.0, 1.0, 1.0, 1.94085923041943820907, 1.94085227194482418169 ],
	[ 78.7, 65.2, -2.9, 77.5, 60.7, 2.8, 1.0, 1.0, 1.0, 2.91989529567114087822, 2.91988525261658605311 ],
	[ 88.3, 126.1, -1.7, 89.3, 109.1, 4.6, 1.0, 1.0, 0.9, 3.52575069135331917409, 3.52573735080764876312 ],
	[ 76.8, 103.9, 6.6, 73.6, 116.1, -3.9, 1.0, 1.0, 0.9, 4.85910095282673306855, 4.85908859516939575581 ],
	[ 79.5, 66.7, 4.6, 76.1, 81.8, -5.0, 1.0, 0.9, 1.1, 5.76099150475162379453, 5.76096924936866172022 ],
	[ 59.2, 71.8, 5.1, 58.6, 94.1, -4.7, 1.0, 0.9, 1.1, 6.26446979481597228780, 6.26444558597530434010 ],
	[ 20.5, 119.1, 8.1, 19.4, 96.5, -6.4, 1.0, 0.9, 1.0, 6.33145635344967449655, 6.33148705084895521235 ],
	[ 29.6, 72.9, 7.1, 33.3, 113.4, -5.1, 1.0, 1.1, 1.1, 8.68695997741328123613, 8.68693753419288109384 ],
	[ 86.3, 88.0, -4.8, 78.7, 118.6, 7.4, 1.0, 0.9, 1.0, 8.83363506762574415824, 8.83366024958667014071 ],
	[ 98.8, 71.4, 6.4, 93.9, 43.4, -3.3, 1.0, 1.1, 0.9, 9.06652292034467328084, 9.06655677652780030117 ],
	[ 2.2, 97.5, -8.4, 7.0, 73.3, 10.5, 1.0, 1.1, 0.9, 9.64943880051260659224, 9.64941494316372210575 ],
	[ 43.8, 57.1, -5.2, 44.1, 91.2, 13.8, 1.0, 1.1, 1.1, 9.74596427375642726535, 9.74599456055264884188 ],
	[ 87.5, 94.2, -12.5, 85.5, 71.4, 14.8, 1.0, 1.1, 1.0, 11.50838166559227916653, 11.50835974496583671561 ],
	[ 6.5, 54.8, -3.2, 14.5, 99.9, 6.0, 0.9, 1.0, 1.0, 12.02882579429005156853, 12.02885434991815202119 ],
	[ 49.3, 115.6, 15.8, 55.5, 68.6, -3.7, 0.9, 1.0, 1.0, 13.00482889762819009845, 13.00485163892002509853 ],
	[ 93.9, 125.4, -7.6, 98.1, 60.4, 3.9, 0.9, 1.0, 0.9, 13.53732246206312746009, 13.53728420335438970854 ],
	[ 51.2, 48.7, 12.3, 47.1, 68.3, -15.2, 0.9, 0.9, 1.1, 13.65210535595789555755, 13.65206573841337269448 ],
	[ 75.4, 72.4, 14.1, 66.1, 42.7, -7.6, 0.9, 0.9, 1.1, 15.01858617580990805048, 15.01863373764194466828 ],
	[ 92.0, 83.5, -17.2, 94.0, 55.0, 12.5, 0.9, 1.0, 0.9, 15.33433138237918558308, 15.33427919695440244764 ],
	[ 2.6, 47.0, -7.3, 5.8, 117.6, 19.6, 0.9, 1.1, 1.1, 16.12496252255085502475, 16.12502659883752889818 ],
	[ 47.7, 24.9, -10.5, 42.7, 38.4, 16.9, 0.9, 1.1, 1.1, 16.16188451930645718378, 16.16192477450090184896 ],
	[ 73.9, 58.9, -10.7, 78.8, 99.1, 26.0, 0.9, 0.9, 1.0, 17.13706181605960745840, 17.13710455668721354362 ],
	[ 17.0, 103.1, 17.5, 6.2, 47.2, -7.2, 0.9, 1.1, 0.9, 17.15502364533678697347, 17.15508320784189811337 ],
	[ 61.3, 65.6, 14.8, 73.3, 89.2, -18.8, 0.9, 0.9, 1.0, 17.81338636557549685611, 17.81334827962618422763 ],
	[ 24.1, 31.9, 11.3, 26.1, 76.3, -17.3, 0.9, 1.1, 1.0, 18.06284088259899451733, 18.06280635743619223791 ],
	[ 76.6, 42.5, 18.7, 73.1, 25.0, -9.2, 0.9, 1.1, 0.9, 18.56371424691992320981, 18.56375175757327048081 ],
	[ 58.4, 53.4, 17.4, 73.6, 84.8, -24.6, 1.1, 0.9, 1.1, 20.97701098095782588640, 20.97696265633271514383 ],
	[ 34.3, 51.7, -16.4, 37.9, 95.8, 32.8, 1.1, 1.0, 1.0, 21.30472695141261612657, 21.30480230097303868981 ],
	[ 11.8, 33.3, 9.9, 15.6, 98.7, -24.7, 1.1, 1.0, 1.0, 21.38255904461508639978, 21.38248563461511850021 ],
	[ 38.3, 112.8, -19.9, 28.7, 35.1, 6.4, 1.1, 1.0, 0.9, 21.81150150951723601095, 21.81142191433416683199 ],
	[ 31.0, 40.0, -10.5, 19.9, 95.1, 32.7, 1.1, 0.9, 1.1, 22.51208149151830503368, 22.51213697394075791030 ],
	[ 65.1, 119.6, 34.0, 52.8, 75.5, -20.6, 1.1, 1.0, 0.9, 23.51896200161117138039, 23.51902558300420726187 ],
	[ 71.7, 117.3, -41.7, 67.4, 64.9, 23.1, 1.1, 0.9, 1.0, 24.41586908953993753146, 24.41576877980548038990 ],
	[ 20.1, 23.4, -6.6, 12.8, 83.4, 31.1, 1.1, 0.9, 1.0, 24.92218272063192672329, 24.92224139197610431656 ],
	[ 40.1, 15.7, 8.6, 49.8, 72.6, -34.6, 1.1, 1.1, 1.1, 25.32169561894007569524, 25.32162387362604456976 ],
	[ 74.4, 33.6, 14.7, 89.2, 99.4, -43.2, 1.1, 1.1, 1.1, 25.90852187537030209305, 25.90841306621602456028 ],
	[ 37.2, 118.5, 36.4, 22.4, 32.1, -9.4, 1.1, 1.1, 0.9, 26.37618409498421573915, 26.37628386184765567677 ],
	[ 44.5, 112.5, 44.0, 50.3, 28.9, -9.4, 1.1, 1.1, 0.9, 26.71479772759133226984, 26.71487885694120816828 ],
	[ 89.0, 122.1, 53.2, 70.3, 90.0, -33.1, 1.1, 1.1, 1.0, 29.19969941395083530767, 29.19973049970667885284 ],
	[ 24.6, 0.0, 0.0, 71.4, 0.0, 0.0, 1.1, 1.1, 1.0, 42.0306858757802182373009, 42.0306858757802182373009 ],
]

# Using reference values, we guarantee that the CIEDE2000
# function always provides at least 12 correct decimal places

import numpy as np

l1 = np.asarray([ el[0] for el in references ])
a1 = np.asarray([ el[1] for el in references ])
b1 = np.asarray([ el[2] for el in references ])
l2 = np.asarray([ el[3] for el in references ])
a2 = np.asarray([ el[4] for el in references ])
b2 = np.asarray([ el[5] for el in references ])
kl = np.asarray([ el[6] for el in references ])
kc = np.asarray([ el[7] for el in references ])
kh = np.asarray([ el[8] for el in references ])

print("Tests of the CIEDE2000 function with parameter canonical = False")
i = 0
for computed_delta_e in ciede_2000(l1, a1, b1, l2, a2, b2, kl, kc, kh, False) :
	expected_delta_e = references[i][9]
	diff = abs(computed_delta_e - expected_delta_e)
	if 1E-12 < diff :
		print(f"- ERROR : a deviation of {diff} was observed for index {i}")
	i = i + 1
print(f"The {i} tests are completed\n")

print("Tests of the CIEDE2000 function with parameter canonical = True")
i = 0
for computed_delta_e in ciede_2000(l1, a1, b1, l2, a2, b2, kl, kc, kh, True) :
	expected_delta_e = references[i][10]
	diff = abs(computed_delta_e - expected_delta_e)
	if 1E-12 < diff :
		print(f"- ERROR : a deviation of {diff} was observed for index {i}")
	i = i + 1
print(f"The {i} tests are completed")

# At this stage, 80 well-chosen tests have been carried out, and if no errors
# appear on the screen, CIEDE2000 has surely been correctly implemented
