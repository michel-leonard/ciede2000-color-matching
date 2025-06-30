// This function written in C# is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

///////////////////////////////////////////////////////////////////////////////////////////
//////                                                                               //////
//////                    Measured at 5,797,179 calls per second.                    //////
//////               💡 This function is up to 30% faster than 64-bit.               //////
//////                                                                               //////
//////          Using 32-bit numbers results in an almost always negligible          //////
//////             difference of ±0.0002 in the calculated Delta E 2000.             //////
//////                                                                               //////
///////////////////////////////////////////////////////////////////////////////////////////

// The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
// "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
static float ciede_2000(float l_1, float a_1, float b_1, float l_2, float a_2, float b_2) {
	// Working in C# (.NET Core) with the CIEDE2000 color-difference formula.
	// k_l, k_c, k_h are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	const float k_l = 1.0f, k_c = 1.0f, k_h = 1.0f;
	float n = (MathF.Sqrt(a_1 * a_1 + b_1 * b_1)
		+ MathF.Sqrt(a_2 * a_2 + b_2 * b_2)) * 0.5f;
	n = n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = 1.0f + 0.5f * (1.0f - MathF.Sqrt(n / (n + 6103515625.0f)));
	// Since hypot is not available, sqrt is used here to calculate the
	// Euclidean distance, without avoiding overflow/underflow.
	float c_1 = MathF.Sqrt(a_1 * a_1 * n * n + b_1 * b_1);
	float c_2 = MathF.Sqrt(a_2 * a_2 * n * n + b_2 * b_2);
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	float h_1 = MathF.Atan2(b_1, a_1 * n), h_2 = MathF.Atan2(b_2, a_2 * n);
	if (h_1 < 0.0f) h_1 += 2.0f * MathF.PI;
	if (h_2 < 0.0f) h_2 += 2.0f * MathF.PI;
	// 32-bit implementations do not have consistent rounding between implementations.
	n = MathF.Abs(h_2 - h_1);
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	float h_m = (h_1 + h_2) * 0.5f, h_d = (h_2 - h_1) * 0.5f;
	if (MathF.PI < n) {
		if (0.0f < h_d)
			h_d -= MathF.PI;
		else
			h_d += MathF.PI;
		h_m += MathF.PI;
	}
	float p = 36.0f * h_m - 55.0f * MathF.PI;
	n = (c_1 + c_2) * 0.5f;
	n = n * n * n * n * n * n * n;
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	float r_t = -2.0f * MathF.Sqrt(n / (n + 6103515625.0f))
			* MathF.Sin(MathF.PI / 3.0f
				* MathF.Exp(p * p / (-25.0f * MathF.PI * MathF.PI)));
	n = (l_1 + l_2) * 0.5f;
	n = (n - 50.0f) * (n - 50.0f);
	// Lightness.
	float l = (l_2 - l_1) / (k_l * (1.0f + 0.015f * n / MathF.Sqrt(20.0f + n)));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	float t = 1.0f	+ 0.24f * MathF.Sin(2.0f * h_m + MathF.PI * 0.5f)
			+ 0.32f * MathF.Sin(3.0f * h_m + 8.0f * MathF.PI / 15.0f)
			- 0.17f * MathF.Sin(h_m + MathF.PI / 3.0f)
			- 0.20f * MathF.Sin(4.0f * h_m + 3.0f * MathF.PI / 20.0f);
	n = c_1 + c_2;
	// Hue.
	float h = 2.0f * MathF.Sqrt(c_1 * c_2)
		* MathF.Sin(h_d) / (k_h * (1.0f + 0.0075f * n * t));
	// Chroma.
	float c = (c_2 - c_1) / (k_c * (1.0f + 0.0225f * n));
	// Returns the square root so that the Delta E 2000 reflects the actual geometric
	// distance within the color space, which ranges from 0 to approximately 185.
	return MathF.Sqrt(l * l + h * h + c * c + c * h * r_t);
}

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

// L1 = 12.67          a1 = -35.4133       b1 = -122.61
// L2 = 98.6791        a2 = 126.198        b2 = 118.716
// CIE ΔE2000 = ΔE00 = 110.71914729388
