<%
' This function written in VBScript is not affiliated with the CIE (International Commission on Illumination),
' and is released into the public domain. It is provided "as is" without any warranty, express or implied.

' Prevents errors due to typos or undeclared variables.
Option Explicit

' The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
Public Function ciede_2000(l_1, a_1, b_1, l_2, a_2, b_2)
	' Working in ASP Classic 3.0 (IIS 10.0) with the CIEDE2000 color-difference formula.
	' k_l, k_c, k_h are parametric factors to be adjusted according to
	' different viewing parameters such as textures, backgrounds...
	Const M_PI = 3.14159265358979323846264338328, k_l = 1.0, k_c = 1.0, k_h = 1.0
	Dim n, c_1, c_2, h_1, h_2, h_m, h_d, p, r_t, l, t, h, c
	n = (Sqr(a_1 * a_1 + b_1 * b_1) + Sqr(a_2 * a_2 + b_2 * b_2)) * 0.5
	n = n * n * n * n * n * n * n
	' A factor involving chroma raised to the power of 7 designed to make
	' the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - Sqr(n / (n + 6103515625.0)))
	' Since hypot is not available, sqrt is used here to calculate the
	' Euclidean distance, without avoiding overflow/underflow.
	c_1 = Sqr(a_1 * a_1 * n * n + b_1 * b_1)
	c_2 = Sqr(a_2 * a_2 * n * n + b_2 * b_2)
	' Using 38 lines to simulate atan2, as VBScript does not have this built-in.
	c = a_1 * n
	If 0.0 < c Then
		h_1 = Atn(b_1 / c)
	ElseIf c < 0.0 Then
		If 0.0 <= b_1 Then
			h_1 = Atn(b_1 / c) + M_PI
		Else
			h_1 = Atn(b_1 / c) - M_PI
		End If
	Else
		If 0.0 < b_1 Then
			h_1 = M_PI / 2.0
		ElseIf b_1 < 0 Then
			h_1 = -M_PI / 2.0
		Else
			h_1 = 0.0
		End If
	End If
	c = a_2 * n
	If 0.0 < c Then
		h_2 = Atn(b_2 / c)
	ElseIf c < 0.0 Then
		If 0.0 <= b_2 Then
			h_2 = Atn(b_2 / c) + M_PI
		Else
			h_2 = Atn(b_2 / c) - M_PI
		End If
	Else
		If 0.0 < b_2 Then
			h_2 = M_PI / 2.0
		ElseIf b_2 < 0 Then
			h_2 = -M_PI / 2.0
		Else
			h_2 = 0.0
		End If
	End If
	' The atan2 polyfill is complete.
	If h_1 < 0.0 Then h_1 = h_1 + 2.0 * M_PI
	If h_2 < 0.0 Then h_2 = h_2 + 2.0 * M_PI
	n = Abs(h_2 - h_1)
	' Cross-implementation consistent rounding.
	If M_PI - 1E-14 < n And n < M_PI + 1E-14 Then n = M_PI
	' When the hue angles lie in different quadrants, the straightforward
	' average can produce a mean that incorrectly suggests a hue angle in
	' the wrong quadrant, the next lines handle this issue.
	h_m = (h_1 + h_2) * 0.5
	h_d = (h_2 - h_1) * 0.5
	If M_PI < n Then
		If 0.0 < h_d Then h_d = h_d - M_PI Else h_d = h_d + M_PI
		h_m = h_m + M_PI
	End If
	p = 36.0 * h_m - 55.0 * M_PI
	n = (c_1 + c_2) * 0.5
	n = n * n * n * n * n * n * n
	' The hue rotation correction term is designed to account for the
	' non-linear behavior of hue differences in the blue region.
	r_t = -2.0 * Sqr(n / (n + 6103515625.0)) _
			* Sin(M_PI / 3.0 * Exp(p * p / (-25.0 * M_PI * M_PI)))
	n = (l_1 + l_2) * 0.5
	n = (n - 50.0) * (n - 50.0)
	' Lightness.
	l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / Sqr(20.0 + n)))
	' These coefficients adjust the impact of different harmonic
	' components on the hue difference calculation.
	t = 1.0		+ 0.24 * Sin(2.0 * h_m + M_PI * 0.5) _
			+ 0.32 * Sin(3.0 * h_m + 8.0 * M_PI / 15.0) _
			- 0.17 * Sin(h_m + M_PI / 3.0) _
			- 0.2 * Sin(4.0 * h_m + 3.0 * M_PI / 20.0)
	n = c_1 + c_2
	' Hue.
	h = 2.0 * Sqr(c_1 * c_2) * Sin(h_d) / (k_h * (1.0 + 0.0075 * n * t))
	' Chroma.
	c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n))
	' Returning the square root ensures that the result represents
	' the "true" geometric distance in the color space.
	ciede_2000 = Sqr(l * l + h * h + c * c + c * h * r_t)
End Function

' GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
'  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/samples.html

' L1 = 75.0           a1 = 88.0518        b1 = 76.56
' L2 = 75.0           a2 = 88.0           b2 = 76.56
' CIE ΔE2000 = ΔE00 = 0.01647346252

' L1 = 83.3144        a1 = 76.1431        b1 = -70.765
' L2 = 83.3144        a2 = 76.002         b2 = -70.765
' CIE ΔE2000 = ΔE00 = 0.04268822885

' L1 = 91.3           a1 = 126.9          b1 = -64.8354
' L2 = 91.3           a2 = 126.641        b2 = -65.4
' CIE ΔE2000 = ΔE00 = 0.16194586871

' L1 = 61.709         a1 = 86.082         b1 = -24.33
' L2 = 61.709         a2 = 86.4           b2 = -17.51
' CIE ΔE2000 = ΔE00 = 2.30623301233

' L1 = 44.0           a1 = 35.05          b1 = 63.2057
' L2 = 44.0           a2 = 31.81          b2 = 72.38
' CIE ΔE2000 = ΔE00 = 4.41626752134

' L1 = 87.4           a1 = 52.038         b1 = -72.399
' L2 = 92.6           a2 = 45.1041        b2 = -59.0
' CIE ΔE2000 = ΔE00 = 4.95290572839

' L1 = 64.0           a1 = 43.6588        b1 = 99.0
' L2 = 73.2637        a2 = 44.76          b2 = 90.1659
' CIE ΔE2000 = ΔE00 = 7.79665900284

' L1 = 68.03          a1 = -52.97         b1 = -24.37
' L2 = 95.0           a2 = -41.9          b2 = -6.0
' CIE ΔE2000 = ΔE00 = 20.70589058722

' L1 = 79.6088        a1 = -102.101       b1 = 65.7
' L2 = 95.4           a2 = 81.0           b2 = 104.951
' CIE ΔE2000 = ΔE00 = 79.64883798627

' L1 = 15.0           a1 = -103.0057      b1 = -50.127
' L2 = 66.13          a2 = 92.285         b2 = 2.3257
' CIE ΔE2000 = ΔE00 = 134.76820817071

%>
