// This function written in Pascal is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

uses
	Math;

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

// L1 = 11.0           a1 = 22.0           b1 = 125.1282
// L2 = 11.0           a2 = 22.0           b2 = 125.08
// CIE ΔE2000 = ΔE00 = 0.0081046919

// L1 = 18.607         a1 = 57.44          b1 = 112.056
// L2 = 18.607         a2 = 57.03          b2 = 110.418
// CIE ΔE2000 = ΔE00 = 0.30653159312

// L1 = 52.653         a1 = 91.36          b1 = -52.0
// L2 = 52.653         a2 = 82.05          b2 = -52.0
// CIE ΔE2000 = ΔE00 = 2.18443567211

// L1 = 73.1233        a1 = -114.0         b1 = -62.9235
// L2 = 75.3493        a2 = -114.0         b2 = -72.7
// CIE ΔE2000 = ΔE00 = 3.02303386089

// L1 = 41.79          a1 = 30.35          b1 = -95.9405
// L2 = 45.3819        a2 = 30.35          b2 = -95.9405
// CIE ΔE2000 = ΔE00 = 3.32915912326

// L1 = 92.65          a1 = 107.941        b1 = -4.6
// L2 = 98.9302        a2 = 100.0          b2 = -4.6
// CIE ΔE2000 = ΔE00 = 3.984440899

// L1 = 70.3           a1 = 8.48           b1 = 6.3
// L2 = 75.8924        a2 = 7.0            b2 = 6.3
// CIE ΔE2000 = ΔE00 = 4.43869027399

// L1 = 22.0           a1 = 59.58          b1 = 43.85
// L2 = 21.0           a2 = 91.8           b2 = 64.0
// CIE ΔE2000 = ΔE00 = 7.44109086742

// L1 = 59.598         a1 = 97.413         b1 = -92.3
// L2 = 72.0           a2 = 112.4236       b2 = -49.9
// CIE ΔE2000 = ΔE00 = 16.80496525812

// L1 = 98.0           a1 = 74.4142        b1 = -45.84
// L2 = 18.5232        a2 = -97.7571       b2 = 124.1
// CIE ΔE2000 = ΔE00 = 127.12448483782
