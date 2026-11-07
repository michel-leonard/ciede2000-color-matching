' This function written in VBA is not affiliated with the CIE (International Commission on Illumination),
' and is released into the public domain. It is provided "as is" without any warranty, express or implied.

' The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
' "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
Public Function ciede_2000(l_1 As Double, a_1 As Double, b_1 As Double, l_2 As Double, a_2 As Double, b_2 As Double) As Double
	' Working in VBA with the CIEDE2000 color-difference formula.
	' k_l, k_c, k_h are parametric factors to be adjusted according to
	' different viewing parameters such as textures, backgrounds...
	Const M_PI = 3.14159265358979323846264338328, k_l = 1.0, k_c = 1.0, k_h = 1.0
	Dim n As Double, c_1 As Double, c_2 As Double, h_1 As Double, h_2 As Double
	Dim h_m As Double, h_d As Double, p As Double, r_t As Double, l As Double
	Dim t As Double, h As Double, c As Double
	n = (Sqr(a_1 * a_1 + b_1 * b_1) + Sqr(a_2 * a_2 + b_2 * b_2)) * 0.5
	n = n * n * n * n * n * n * n
	' A factor involving chroma raised to the power of 7 designed to make
	' the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - Sqr(n / (n + 6103515625.0)))
	' Application of the chroma correction factor.
	c_1 = Sqr(a_1 * a_1 * n * n + b_1 * b_1)
	c_2 = Sqr(a_2 * a_2 * n * n + b_2 * b_2)
	' Using 14 lines to simulate atan2, as VBA does not have this built-in.
	If 0.0 < a_1 Then
		h_1 = Atn(b_1 / (a_1 * n)) - (b_1 < 0.0) * 2.0 * M_PI
	ElseIf a_1 < 0.0 Then
		h_1 = Atn(b_1 / (a_1 * n)) + M_PI
	Else
		h_1 = M_PI + ((0.0 < b_1) - (b_1 < 0.0)) * 0.5 * M_PI
	End If
	If 0.0 < a_2 Then
		h_2 = Atn(b_2 / (a_2 * n)) - (b_2 < 0.0) * 2.0 * M_PI
	ElseIf a_2 < 0.0 Then
		h_2 = Atn(b_2 / (a_2 * n)) + M_PI
	Else
		h_2 = M_PI + ((0.0 < b_2) - (b_2 < 0.0)) * 0.5 * M_PI
	End If
	' The atan2 polyfill (customized) is complete.
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
	' Returning the square root ensures that dE00 accurately reflects the
	' geometric distance in color space, which can range from 0 to around 185.
	ciede_2000 = Sqr(l * l + h * h + c * c + c * h * r_t)
End Function

' GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
'   Online Tests : https://michel-leonard.github.io/ciede2000-color-matching

' L1 = 87.9   a1 = 43.0   b1 = -2.8
' L2 = 88.1   a2 = 48.5   b2 = 3.2
' CIE ΔE00 = 3.6166283338 (Bruce Lindbloom, Netflix’s VMAF, ...)
' CIE ΔE00 = 3.6166437205 (Gaurav Sharma, OpenJDK, ...)
' Deviation between implementations ≈ 1.5e-5

' See the source code comments for easy switching between these two widely used ΔE*00 implementation variants.

'''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''
'''''''                                 '''''''
'''''''           CIEDE 2000            '''''''
'''''''      Testing Random Colors      '''''''
'''''''                                 '''''''
'''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''

' This VBA/FreeBASIC program outputs a CSV file to standard output, with its length determined by the first CLI argument.
' Each line contains seven columns :
' - Three columns for the random standard L*a*b* color
' - Three columns for the random sample L*a*b* color
' - And the seventh column for the precise Delta E 2000 color difference between the standard and sample
' The output will be correct, this can be verified :
' - With the C driver, which provides a dedicated verification feature
' - By using the JavaScript validator at https://michel-leonard.github.io/ciede2000-color-matching

Randomize Timer

Function RandomLabComponent(min As Double, max As Double) As Double
    Dim n As Double = min + Rnd * (max - min)
    If Rnd < 0.5 Then
        Return Int(n * 10.0 + 0.5) / 10.0
    Else
        Return Int(n + 0.5)
    End If
End Function

Sub Main(ByVal iterations As Integer)
	If iterations <= 0 Then iterations = 10000.0

	For i As Integer = 1.0 To iterations
		Dim l1 As Double = RandomLabComponent(0, 100)
		Dim a1 As Double = RandomLabComponent(-128, 128)
		Dim b1 As Double = RandomLabComponent(-128, 128)
		Dim l2 As Double = RandomLabComponent(0, 100)
		Dim a2 As Double = RandomLabComponent(-128, 128)
		Dim b2 As Double = RandomLabComponent(-128, 128)

		Dim deltaE As Double = ciede_2000(l1, a1, b1, l2, a2, b2)

		Print l1; ","; a1; ","; b1; ","; l2; ","; a2; ","; b2; ","; deltaE
	Next
End Sub

Dim iterations As Integer
If Command(1) <> "" Then
	iterations = Val(Command(1))
Else
	iterations = 10000.0
End If

Main(iterations)
