<%
' This function written in VBScript is not affiliated with the CIE (International Commission on Illumination),
' and is released into the public domain. It is provided "as is" without any warranty, express or implied.

' Prevents errors due to typos or undeclared variables.
Option Explicit

' The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
' "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
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
	' Application of the chroma correction factor.
	c_1 = Sqr(a_1 * a_1 * n * n + b_1 * b_1)
	c_2 = Sqr(a_2 * a_2 * n * n + b_2 * b_2)
	' Using 16 lines to simulate atan2, as VBScript does not have this built-in.
	c = a_1 * n
	If 0.0 < c Then
		h_1 = Atn(b_1 / c)
	ElseIf c < 0.0 Then
		h_1 = Atn(b_1 / c) + ((b_1 < 0.0) - (0.0 <= b_1)) * M_PI
	Else
		h_1 = ((b_1 < 0.0) - (0.0 < b_1)) * M_PI * 0.5
	End If
	c = a_2 * n
	If 0.0 < c Then
		h_2 = Atn(b_2 / c)
	ElseIf c < 0.0 Then
		h_2 = Atn(b_2 / c) + ((b_2 < 0.0) - (0.0 <= b_2)) * M_PI
	Else
		h_2 = ((b_2 < 0.0) - (0.0 < b_2)) * M_PI * 0.5
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
		h_d = h_d + M_PI
		' 📜 Sharma’s formulation doesn’t use the next line, but the one after it,
		' and these two variants differ by ±0.0003 on the final color differences.
		h_m = h_m + M_PI
		' If h_m < M_PI Then h_m = h_m + M_PI Else h_m = h_m - M_PI
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
	' Returns the square root so that the DeltaE 2000 reflects the actual geometric
	' distance within the color space, which ranges from 0 to approximately 185.
	ciede_2000 = Sqr(l * l + h * h + c * c + c * h * r_t)
End Function

' GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
'   Online Tests : https://michel-leonard.github.io/ciede2000-color-matching

' L1 = 15.8   a1 = 48.0   b1 = 2.4
' L2 = 15.2   a2 = 53.8   b2 = -2.4
' CIE ΔE00 = 2.9971560512 (Bruce Lindbloom, Netflix’s VMAF, ...)
' CIE ΔE00 = 2.9971426307 (Gaurav Sharma, OpenJDK, ...)
' Deviation between implementations ≈ 1.3e-5

' See the source code comments for easy switching between these two widely used ΔE*00 implementation variants.

%>
