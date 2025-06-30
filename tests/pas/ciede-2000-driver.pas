{$mode objfpc}

// Limited Use License – March 1, 2025

// This source code is provided for public use under the following conditions :
// It may be downloaded, compiled, and executed, including in publicly accessible environments.
// Modification is strictly prohibited without the express written permission of the author.

// © Michel Leonard 2025

program DeltaE2000Driver;

uses
	SysUtils, StrUtils, Math;

function ciede_2000(l_1, a_1, b_1, l_2, a_2, b_2: Double): Double;
var
	k_l, k_c, k_h, n, c_1, c_2, h_1, h_2, h_m, h_d, p, r_t, l, t, h, c: Double;
begin
	// Working in Pascal with the CIEDE2000 color-difference formula.
	// k_l, k_c, k_h are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	k_l := 1.0;
	k_c := 1.0;
	k_h := 1.0;
	n := (sqrt(a_1 * a_1 + b_1 * b_1) + sqrt(a_2 * a_2 + b_2 * b_2)) * 0.5;
	n := n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n := 1.0 + 0.5 * (1.0 - sqrt(n / (n + 6103515625.0)));
	// Since hypot is not available, sqrt is used here to calculate the
	// Euclidean distance, without avoiding overflow/underflow.
	c_1 := sqrt(a_1 * a_1 * n * n + b_1 * b_1);
	c_2 := sqrt(a_2 * a_2 * n * n + b_2 * b_2);
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	h_1 := arctan2(b_1, a_1 * n);
	h_2 := arctan2(b_2, a_2 * n);
	if h_1 < 0.0 then
		h_1 += 2.0 * Pi;
	if h_2 < 0.0 then
		h_2 += 2.0 * Pi;
	n := abs(h_2 - h_1);
	// Cross-implementation consistent rounding.
	if abs(Pi - n) < 1E-14 then
		n := Pi;
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	h_m := (h_1 + h_2) * 0.5;
	h_d := (h_2 - h_1) * 0.5;
	if Pi < n then
	begin
		if 0.0 < h_d then
			h_d -= Pi
		else
			h_d += Pi;
		h_m += Pi;
	end;
	p := 36.0 * h_m - 55.0 * Pi;
	n := (c_1 + c_2) * 0.5;
	n := n * n * n * n * n * n * n;
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	r_t := -2.0 * sqrt(n / (n + 6103515625.0))
			* sin(Pi / 3.0 * exp(p * p / (-25.0 * Pi * Pi)));
	n := (l_1 + l_2) * 0.5;
	n := (n - 50.0) * (n - 50.0);
	// Lightness.
	l := (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / sqrt(20.0 + n)));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	t := 1.0 	+ 0.24 * sin(2.0 * h_m + Pi / 2.0)
			+ 0.32 * sin(3.0 * h_m + 8.0 * Pi / 15.0)
			- 0.17 * sin(h_m + Pi / 3.0)
			- 0.20 * sin(4.0 * h_m + 3.0 * Pi / 20.0);
	n := c_1 + c_2;
	// Hue.
	h := 2.0 * sqrt(c_1 * c_2) * sin(h_d) / (k_h * (1.0 + 0.0075 * n * t));
	// Chroma.
	c := (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
	// Returns the square root so that the Delta E 2000 reflects the actual geometric
	// distance within the color space, which ranges from 0 to approximately 185.
	Exit(sqrt(l * l + h * h + c * c + c * h * r_t));
end;

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

// L1 = 75.9           a1 = -88.286        b1 = -0.81
// L2 = 77.0087        a2 = -88.286        b2 = 0.5488
// CIE ΔE2000 = ΔE00 = 0.99285716476

/////////////////////////////////////////////////
/////////////////////////////////////////////////
////////////                         ////////////
////////////    CIEDE2000 Driver     ////////////
////////////                         ////////////
/////////////////////////////////////////////////
/////////////////////////////////////////////////

// Reads a CSV file specified as the first command-line argument. For each line, this program
// in Pascal displays the original line with the computed Delta E 2000 color difference appended.
// The C driver can offer CSV files to process and programmatically check the calculations performed there.

//  Example of a CSV input line : 67.24,-14.22,70,65,8,46
//    Corresponding output line : 67.24,-14.22,70,65,8,46,15.46723547943141064

var
	InputFile: TextFile;
	Line: String;
	D: array[1..6] of Double;
	StartIdx, CommaPos, i: Integer;
	DeltaE: Double;
begin
	if ParamCount < 1 then
	begin
		WriteLn('Usage: ', ParamStr(0), ' <filename>');
		Halt(1);
	end;
	AssignFile(InputFile, ParamStr(1));
	Reset(InputFile);
	while not Eof(InputFile) do
	begin
		ReadLn(InputFile, Line);
		StartIdx := 1;
		for i := 1 to 5 do
		begin
			CommaPos := PosEx(',', Line, StartIdx);
			D[i] := StrToFloat(Copy(Line, StartIdx, CommaPos - StartIdx));
			StartIdx := CommaPos + 1;
		end;
		D[6] := StrToFloat(Copy(Line, StartIdx, Length(Line) - StartIdx + 1));
		DeltaE := ciede_2000(D[1], D[2], D[3], D[4], D[5], D[6]);
		WriteLn(Line, ',', Format('%.17f', [DeltaE]));
	end;
	CloseFile(InputFile);
end.
