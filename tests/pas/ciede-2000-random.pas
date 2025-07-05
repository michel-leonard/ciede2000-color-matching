// This function written in Pascal is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

program ciede2000;

uses
	SysUtils, Math;

// The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
// "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
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
	// Returns the square root so that the DeltaE 2000 reflects the actual geometric
	// distance within the color space, which ranges from 0 to approximately 185.
	Exit(sqrt(l * l + h * h + c * c + c * h * r_t));
end;

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

// L1 = 74.0           a1 = 66.072         b1 = 31.63
// L2 = 74.0           a2 = 67.4           b2 = 31.63
// CIE ΔE2000 = ΔE00 = 0.40117636194

///////////////////////////////////////////////
///////////////////////////////////////////////
///////                                 ///////
///////           CIEDE 2000            ///////
///////      Testing Random Colors      ///////
///////                                 ///////
///////////////////////////////////////////////
///////////////////////////////////////////////

// This Pascal program outputs a CSV file to standard output, with its length determined by the first CLI argument.
// Each line contains seven columns :
// - Three columns for the random standard L*a*b* color
// - Three columns for the random sample L*a*b* color
// - And the seventh column for the precise Delta E 2000 color difference between the standard and sample
// The output will be correct, this can be verified :
// - With the C driver, which provides a dedicated verification feature
// - By using the JavaScript validator at https://michel-leonard.github.io/ciede2000-color-matching

function RoundToDecimals(Value: Double; Decimals: Integer): Double;
var
	Factor: Double;
begin
	Factor := Power(10.0, Decimals);
	Exit(Round(Value * Factor) / Factor);
end;

function MyRound(Value: Double): Double;
begin
	if Random(2) = 0 then
		Exit(RoundToDecimals(Value, 0))
	else
		Exit(RoundToDecimals(Value, 1));
end;

function Uniform(MinVal, MaxVal: Double): Double;
begin
	Exit(MinVal + (MaxVal - MinVal) * Random);
end;

var
	nIterations, i: LongInt;
	l1, a1, b1, l2, a2, b2, deltaE: Double;
begin
	Randomize;

	if ParamCount >= 1 then
		nIterations := StrToInt(ParamStr(1))
  	else
   		nIterations := 10000;

	for i := 1 to nIterations do
	begin
		l1 := Uniform(0.0, 100.0);
		a1 := Uniform(-128.0, 128.0);
		b1 := Uniform(-128.0, 128.0);
		l2 := Uniform(0.0, 100.0);
		a2 := Uniform(-128.0, 128.0);
		b2 := Uniform(-128.0, 128.0);

		l1 := MyRound(l1);
		a1 := MyRound(a1);
		b1 := MyRound(b1);
		l2 := MyRound(l2);
		a2 := MyRound(a2);
		b2 := MyRound(b2);

		deltaE := ciede_2000(l1, a1, b1, l2, a2, b2);

		WriteLn(Format('%.1f,%.1f,%.1f,%.1f,%.1f,%.1f,%.17f',
			[l1, a1, b1, l2, a2, b2, deltaE]));
	end;
end.
