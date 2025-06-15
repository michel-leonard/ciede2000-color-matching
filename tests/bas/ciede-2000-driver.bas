' Limited Use License – March 1, 2025

' This source code is provided for public use under the following conditions :
' It may be downloaded, compiled, and executed, including in publicly accessible environments.
' Modification is strictly prohibited without the express written permission of the author.

' © Michel Leonard 2025

' The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
' "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
Public Function ciede_2000(l_1 As Double, a_1 As Double, b_1 As Double, l_2 As Double, a_2 As Double, b_2 As Double) As Double
	' Working in VBA with the CIEDE2000 color-difference formula.
	' k_l, k_c, k_h are parametric factors to be adjusted according to
	' different viewing parameters such as textures, backgrounds...
	Const PI = 3.14159265358979323846264338328, k_l = 1.0, k_c = 1.0, k_h = 1.0
	Dim n As Double, c_1 As Double, c_2 As Double, h_1 As Double, h_2 As Double
	Dim h_m As Double, h_d As Double, p As Double, r_t As Double, l As Double
	Dim t As Double, h As Double, c As Double
	n = (Sqr(a_1 * a_1 + b_1 * b_1) + Sqr(a_2 * a_2 + b_2 * b_2)) * 0.5
	n = n * n * n * n * n * n * n
	' A factor involving chroma raised to the power of 7 designed to make
	' the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - Sqr(n / (n + 6103515625.0)))
	' Since hypot is not available, sqrt is used here to calculate the
	' Euclidean distance, without avoiding overflow/underflow.
	c_1 = Sqr(a_1 * a_1 * n * n + b_1 * b_1)
	c_2 = Sqr(a_2 * a_2 * n * n + b_2 * b_2)
	' Using 20 lines to simulate atan2, as VBA does not have this built-in.
	c = a_1 * n
	If 0 < c Then
		h_1 = Atn(b_1 / c)
	ElseIf c < 0 Then
		h_1 = Atn(b_1 / c) + PI * Sgn(b_1)
		If b_1 = 0 Then h_1 = h_1 + PI
	Else
		h_1 = PI * 0.5 * Sgn(b_1)
	EndIf
	c = a_2 * n
	If 0 < c Then
		h_2 = Atn(b_2 / c)
	ElseIf c < 0 Then
		h_2 = Atn(b_2 / c) + PI * Sgn(b_2)
		If b_2 = 0 Then h_2 = h_2 + PI
	Else
		h_2 = PI * 0.5 * Sgn(b_2)
	EndIf
	' The atan2 polyfill is complete.
	If h_1 < 0.0 Then h_1 = h_1 + 2.0 * PI
	If h_2 < 0.0 Then h_2 = h_2 + 2.0 * PI
	n = Abs(h_2 - h_1)
	' Cross-implementation consistent rounding.
	If PI - 1E-14 < n And n < PI + 1E-14 Then n = PI
	' When the hue angles lie in different quadrants, the straightforward
	' average can produce a mean that incorrectly suggests a hue angle in
	' the wrong quadrant, the next lines handle this issue.
	h_m = (h_1 + h_2) * 0.5
	h_d = (h_2 - h_1) * 0.5
	If PI < n Then
		If 0.0 < h_d Then h_d = h_d - PI Else h_d = h_d + PI
		h_m = h_m + PI
	End If
	p = 36.0 * h_m - 55.0 * PI
	n = (c_1 + c_2) * 0.5
	n = n * n * n * n * n * n * n
	' The hue rotation correction term is designed to account for the
	' non-linear behavior of hue differences in the blue region.
	r_t = -2.0 * Sqr(n / (n + 6103515625.0)) _
			* Sin(PI / 3.0 * Exp(p * p / (-25.0 * PI * PI)))
	n = (l_1 + l_2) * 0.5
	n = (n - 50.0) * (n - 50.0)
	' Lightness.
	l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / Sqr(20.0 + n)))
	' These coefficients adjust the impact of different harmonic
	' components on the hue difference calculation.
	t = 1.0		+ 0.24 * Sin(2.0 * h_m + PI * 0.5) _
			+ 0.32 * Sin(3.0 * h_m + 8.0 * PI / 15.0) _
			- 0.17 * Sin(h_m + PI / 3.0) _
			- 0.2 * Sin(4.0 * h_m + 3.0 * PI / 20.0)
	n = c_1 + c_2
	' Hue.
	h = 2.0 * Sqr(c_1 * c_2) * Sin(h_d) / (k_h * (1.0 + 0.0075 * n * t))
	' Chroma.
	c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n))
	' Returns the square root so that the Delta E 2000 reflects the actual geometric
	' distance within the color space, which ranges from 0 to approximately 185.
	ciede_2000 = Sqr(l * l + h * h + c * c + c * h * r_t)
End Function

' GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
'  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

' L1 = 48.175         a1 = -96.39         b1 = 10.12
' L2 = 48.175         a2 = -96.5          b2 = 10.12
' CIE ΔE2000 = ΔE00 = 0.02089612211

' L1 = 79.2972        a1 = -78.924        b1 = 40.699
' L2 = 79.2972        a2 = -78.924        b2 = 37.0
' CIE ΔE2000 = ΔE00 = 1.24278845909

' L1 = 58.0           a1 = -47.48         b1 = 127.562
' L2 = 58.0           a2 = -51.0          b2 = 125.07
' CIE ΔE2000 = ΔE00 = 1.47217351197

' L1 = 59.415         a1 = -109.185       b1 = 63.0
' L2 = 61.5483        a2 = -109.185       b2 = 57.193
' CIE ΔE2000 = ΔE00 = 2.38911055674

' L1 = 42.7397        a1 = -59.258        b1 = 95.15
' L2 = 40.0           a2 = -99.5685       b2 = 117.79
' CIE ΔE2000 = ΔE00 = 8.57257084924

' L1 = 95.23          a1 = 62.94          b1 = -89.6352
' L2 = 99.0           a2 = 26.0           b2 = -54.026
' CIE ΔE2000 = ΔE00 = 10.86505433217

' L1 = 13.34          a1 = -105.3282      b1 = 43.2
' L2 = 9.1            a2 = -71.4497       b2 = 62.8111
' CIE ΔE2000 = ΔE00 = 11.66627110281

' L1 = 6.765          a1 = 72.5           b1 = 16.6407
' L2 = 24.0           a2 = 85.1           b2 = -32.92
' CIE ΔE2000 = ΔE00 = 21.42475061492

' L1 = 21.8           a1 = -60.69         b1 = -21.43
' L2 = 29.21          a2 = -16.81         b2 = 7.1492
' CIE ΔE2000 = ΔE00 = 22.92825185458

' L1 = 88.0           a1 = 59.0           b1 = 12.799
' L2 = 58.872         a2 = 121.06         b2 = 15.94
' CIE ΔE2000 = ΔE00 = 24.95279644558

'''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''                         ''''''''''''
''''''''''''    CIEDE2000 Driver     ''''''''''''
''''''''''''                         ''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''

' Reads a CSV file specified as the first command-line argument. For each line, the program
' outputs the original line with the computed Delta E 2000 color difference appended.

'  Example of a CSV input line : 67.24,-14.22,70,65,8,46
'    Corresponding output line : 67.24,-14.22,70,65,8,46,15.46723547943141064

Sub split(Byref s1 As String, Byref s2 As String, splits(Any) As String)
	Dim As Integer n, n0 = 1
	Do
		Redim Preserve splits(Ubound(splits) + 1)
		n = Instr(n0, s1, s2)
		If n > 0 Then
			splits(Ubound(splits)) = Mid(s1, n0, n - n0)
			n0 = n + Len(s2)
		Else
			splits(Ubound(splits)) = Mid(s1, n0)
			Exit Do
		End If
	Loop
End Sub

Sub Main(filename As String)
	Dim f As Integer = FreeFile()
	Dim buffer As String
	If Open(filename For Input As #f) <> 0 Then
		Print "Can't open file: " & filename
		End 1
	End If
	While Not Eof(f)
		Line Input #f, buffer
		Dim As String parts(Any)
		split(buffer, ",", parts())
		Dim L1 As Double = Val(parts(0))
		Dim a1 As Double = Val(parts(1))
		Dim b1 As Double = Val(parts(2))
		Dim L2 As Double = Val(parts(3))
		Dim a2 As Double = Val(parts(4))
		Dim b2 As Double = Val(parts(5))
		Dim deltaE As Double = ciede_2000(L1, a1, b1, L2, a2, b2)
		Print buffer & "," & Str(deltaE)
	Wend
	Close #f
End Sub

If Command(1) <> "" Then
	Main(Command(1))
End If
