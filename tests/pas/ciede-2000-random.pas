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
	// Returns the square root so that the Delta E 2000 reflects the actual geometric
	// distance within the color space, which ranges from 0 to approximately 185.
	Exit(sqrt(l * l + h * h + c * c + c * h * r_t));
end;

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

// L1 = 80.207         a1 = 123.634        b1 = 107.88
// L2 = 80.207         a2 = 123.63         b2 = 107.88
// CIE ΔE2000 = ΔE00 = 0.00102851245

// L1 = 23.5           a1 = -23.0          b1 = -75.5
// L2 = 23.5           a2 = -23.0          b2 = -76.0
// CIE ΔE2000 = ΔE00 = 0.09310528021

// L1 = 74.0           a1 = 66.072         b1 = 31.63
// L2 = 74.0           a2 = 67.4           b2 = 31.63
// CIE ΔE2000 = ΔE00 = 0.40117636194

// L1 = 65.25          a1 = 45.5           b1 = -90.0
// L2 = 65.25          a2 = 45.5           b2 = -88.4
// CIE ΔE2000 = ΔE00 = 0.61542042257

// L1 = 93.0           a1 = 19.0           b1 = 91.78
// L2 = 93.1           a2 = 16.709         b2 = 92.0
// CIE ΔE2000 = ΔE00 = 1.26562543115

// L1 = 39.3           a1 = 32.75          b1 = -110.4
// L2 = 39.3           a2 = 32.75          b2 = -118.0
// CIE ΔE2000 = ΔE00 = 2.25378508098

// L1 = 2.54           a1 = 118.0          b1 = -15.477
// L2 = 2.54           a2 = 114.0          b2 = -6.603
// CIE ΔE2000 = ΔE00 = 2.57884431581

// L1 = 69.6           a1 = -51.0          b1 = 123.755
// L2 = 59.7           a2 = -43.4          b2 = 98.997
// CIE ΔE2000 = ΔE00 = 9.15824475179

// L1 = 73.9           a1 = -56.291        b1 = -120.12
// L2 = 74.0           a2 = -97.54         b2 = -102.7686
// CIE ΔE2000 = ΔE00 = 10.54171758854

// L1 = 47.0           a1 = 111.52         b1 = 14.0
// L2 = 53.084         a2 = 67.0139        b2 = -46.6
// CIE ΔE2000 = ΔE00 = 23.63326634309

///////////////////////////////////////////////
///////////////////////////////////////////////
///////                                 ///////
///////           CIEDE 2000            ///////
///////      Testing Random Colors      ///////
///////                                 ///////
///////////////////////////////////////////////
///////////////////////////////////////////////

// This program outputs a CSV file to standard output, with its length determined by the first CLI argument.
// Each line contains seven columns:
// - Three columns for the standard L*a*b* color
// - Three columns for the sample L*a*b* color
// - One column for the Delta E 2000 color difference between the standard and sample
// The output can be verified in two ways:
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
