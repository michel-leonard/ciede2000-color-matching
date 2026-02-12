// This function written in C is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

#include <math.h>

// Expressly defining pi ensures that the code works on different platforms.
#ifndef M_PI
#define M_PI 3.14159265358979323846264338328
#endif

// The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
// "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
static double ciede_2000(const double l_1, const double a_1, const double b_1, const double l_2, const double a_2, const double b_2) {
	// Working in C with the CIEDE2000 color-difference formula.
	// k_l, k_c, k_h are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	const double k_l = 1.0;
	const double k_c = 1.0;
	const double k_h = 1.0;
	double n = (sqrt(a_1 * a_1 + b_1 * b_1) + sqrt(a_2 * a_2 + b_2 * b_2)) * 0.5;
	n = n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - sqrt(n / (n + 6103515625.0)));
	// Application of the chroma correction factor.
	const double c_1 = sqrt(a_1 * a_1 * n * n + b_1 * b_1);
	const double c_2 = sqrt(a_2 * a_2 * n * n + b_2 * b_2);
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	double h_1 = atan2(b_1, a_1 * n);
	double h_2 = atan2(b_2, a_2 * n);
	h_1 += (h_1 < 0.0) * 2.0 * M_PI;
	h_2 += (h_2 < 0.0) * 2.0 * M_PI;
	n = fabs(h_2 - h_1);
	// Cross-implementation consistent rounding.
	if (M_PI - 1E-14 < n && n < M_PI + 1E-14)
		n = M_PI;
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	double h_m = (h_1 + h_2) * 0.5;
	double h_d = (h_2 - h_1) * 0.5;
	h_d += (M_PI < n) * M_PI;
	// 📜 Sharma’s formulation doesn’t use the next line, but the one after it,
	// and these two variants differ by ±0.0003 on the final color differences.
	h_m += (M_PI < n) * M_PI;
	// h_m += (M_PI < n) * ((h_m < M_PI) - (M_PI <= h_m)) * M_PI;
	const double p = 36.0 * h_m - 55.0 * M_PI;
	n = (c_1 + c_2) * 0.5;
	n = n * n * n * n * n * n * n;
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	const double r_t = -2.0 * sqrt(n / (n + 6103515625.0))
			* sin(M_PI / 3.0 * exp(p * p / (-25.0 * M_PI * M_PI)));
	n = (l_1 + l_2) * 0.5;
	n = (n - 50.0) * (n - 50.0);
	// Lightness.
	const double l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / sqrt(20.0 + n)));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	const double t = 1.0	+ 0.24 * sin(2.0 * h_m + M_PI / 2.0)
				+ 0.32 * sin(3.0 * h_m + 8.0 * M_PI / 15.0)
				- 0.17 * sin(h_m + M_PI / 3.0)
				- 0.20 * sin(4.0 * h_m + 3.0 * M_PI / 20.0);
	n = c_1 + c_2;
	// Hue.
	const double h = 2.0 * sqrt(c_1 * c_2) * sin(h_d) / (k_h * (1.0 + 0.0075 * n * t));
	// Chroma.
	const double c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
	// Returning the square root ensures that dE00 accurately reflects the
	// geometric distance in color space, which can range from 0 to around 185.
	return sqrt(l * l + h * h + c * c + c * h * r_t);
}

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//   Online Tests : https://michel-leonard.github.io/ciede2000-color-matching

// L1 = 74.4   a1 = 21.0   b1 = 5.4
// L2 = 75.1   a2 = 15.2   b2 = -3.3
// CIE ΔE00 = 6.8850009976 (Bruce Lindbloom, Netflix’s VMAF, ...)
// CIE ΔE00 = 6.8850180947 (Gaurav Sharma, OpenJDK, ...)
// Deviation between implementations ≈ 1.7e-5

// See the source code comments for easy switching between these two widely used ΔE*00 implementation variants.

// These color conversion functions written in C are released into the public domain.
// They are provided "as is" without any warranty, express or implied.

// rgb in 0..1
static void rgb_to_xyz(double r, double g, double b, double *x, double *y, double *z) {
	// Apply a gamma correction to each channel
	r = r > 0.040448236277105097 ? pow((r + 0.055) / 1.055, 2.4) : r / 12.92;
	g = g > 0.040448236277105097 ? pow((g + 0.055) / 1.055, 2.4) : g / 12.92;
	b = b > 0.040448236277105097 ? pow((b + 0.055) / 1.055, 2.4) : b / 12.92;

	// Applying linear transformation using RGB to XYZ transformation matrix.
	*x = r * 41.24564390896921145 + g * 35.75760776439090507 + b * 18.04374830853290341;
	*y = r * 21.26728514056222474 + g * 71.51521552878181013 + b * 7.21749933075596513;
	*z = r * 1.93338955823293176 + g * 11.91919550818385936 + b * 95.03040770337479886;
}

static void xyz_to_lab(double x, double y, double z, double *l, double *a, double *b) {
	// Reference white point : D65 2° Standard observer
	const double refX = 95.047;
	const double refY = 100.0;
	const double refZ = 108.883;

	x /= refX;
	y /= refY;
	z /= refZ;

	// Applying the CIE standard transformation
	x = x > 216.0 / 24389.0 ? cbrt(x) : ((841.0 / 108.0) * x) + (4.0 / 29.0);
	y = y > 216.0 / 24389.0 ? cbrt(y) : ((841.0 / 108.0) * y) + (4.0 / 29.0);
	z = z > 216.0 / 24389.0 ? cbrt(z) : ((841.0 / 108.0) * z) + (4.0 / 29.0);

	*l = (116.0 * y) - 16.0;
	*a = 500.0 * (x - y);
	*b = 200.0 * (y - z);
}

// rgb in 0..1
static inline void rgb_to_lab(double r, double g, double b, double *l, double *a, double *bb) {
	rgb_to_xyz(r, g, b, l, a, bb);
	xyz_to_lab(*l, *a, *bb, l, a, bb);
}

static void lab_to_xyz(double l, double a, double b, double *x, double *y, double *z) {
	// Reference white point : D65 2° Standard observer
	const double refX = 95.047;
	const double refY = 100.000;
	const double refZ = 108.883;

	*y = (l + 16.0) / 116.0;
	*x = a / 500.0 + *y;
	*z = *y - b / 200.0;

	const double x3 = *x * *x * *x;
	const double y3 = *y * *y * *y;
	const double z3 = *z * *z * *z;

	*x = refX * (x3 > 216.0 / 24389.0 ? x3 : (*x - 4.0 / 29.0) / (841.0 / 108.0));
	*y = refY * (l > 8.0 ? y3 : l / (24389.0 / 27.0));
	*z = refZ * (z3 > 216.0 / 24389.0 ? z3 : (*z - 4.0 / 29.0) / (841.0 / 108.0));
}

// rgb in 0..1
static void xyz_to_rgb(double x, double y, double z, double *r, double *g, double *b) {
	// Applying linear transformation using the XYZ to RGB transformation matrix.
	*r = x * 0.032404541621141049051 + y * -0.015371385127977165753 + z * -0.004985314095560160079;
	*g = x * -0.009692660305051867686 + y * 0.018760108454466942288 + z * 0.00041556017530349983;
	*b = x * 0.000556434309591145522 + y * -0.002040259135167538416 + z * 0.010572251882231790398;

	// Apply gamma correction
	*r = *r > 0.003130668442500634 ? 1.055 * pow(*r, 1.0 / 2.4) - 0.055 : 12.92 * *r;
	*g = *g > 0.003130668442500634 ? 1.055 * pow(*g, 1.0 / 2.4) - 0.055 : 12.92 * *g;
	*b = *b > 0.003130668442500634 ? 1.055 * pow(*b, 1.0 / 2.4) - 0.055 : 12.92 * *b;
}

// rgb from 0..1 to 0..255
static inline void float_to_rgb(double r, double g, double b, int *R, int *G, int *B) {
	// Convert to 0-255 range and clamp
	*R = (int) floor(0.5 + (r < 0.0 ? 0.0 : 255.0 < r ? 255.0 : r * 255.0));
	*G = (int) floor(0.5 + (g < 0.0 ? 0.0 : 255.0 < g ? 255.0 : g * 255.0));
	*B = (int) floor(0.5 + (b < 0.0 ? 0.0 : 255.0 < b ? 255.0 : b * 255.0));
}

// rgb from 0..255 to 0..1
static inline void rgb_to_float(int r, int g, int b, double *R, double *G, double *B) {
	// Normalize RGB values to the range 0 to 1
	*R = r / 255.0;
	*G = g / 255.0;
	*B = b / 255.0;
}

// rgb in 0..1
static inline void lab_to_rgb(double l, double a, double b, double *_r, double *_g, double *_b) {
	lab_to_xyz(l, a, b, &l, &a, &b);
	xyz_to_rgb(l, a, b, _r, _g, _b);
}

// Convert from 0..f or 0..F to 0..15 for hexadecimal management.
static inline int hex_char_to_dec(char c) {
	return c >= '0' && c <= '9' ? c - '0' : c >= 'a' && c <= 'f' ? c - 'a' + 10 : c >= 'A' && c <= 'F' ? c - 'A' + 10 : -1;
}

// Convert from 0..15 to 0..f for hexadecimal management.
static inline char dec_to_hex_char(int n) {
	return (char) (n + (n < 10 ? '0' : 'a' - 10));
}

// rgb in 0..255
static void hex_to_rgb(const char *restrict hex, int *r, int *g, int *b) {
	// Also support the short syntax (ie "#FFF") as input.
	*r = hex[4] ? hex_char_to_dec(hex[1]) * 16 + hex_char_to_dec(hex[2]) : hex_char_to_dec(hex[1]) * 16 + hex_char_to_dec(hex[1]);
	*g = hex[4] ? hex_char_to_dec(hex[3]) * 16 + hex_char_to_dec(hex[4]) : hex_char_to_dec(hex[2]) * 16 + hex_char_to_dec(hex[2]);
	*b = hex[4] ? hex_char_to_dec(hex[5]) * 16 + hex_char_to_dec(hex[6]) : hex_char_to_dec(hex[3]) * 16 + hex_char_to_dec(hex[3]);
}

// rgb in 0..255
static void rgb_to_hex(int r, int g, int b, char *restrict hex) {
	// Also provide the short syntax (ie "#FFF") as output.
	*hex++ = '#';
	*hex++ = dec_to_hex_char(r >> 4), *hex++ = dec_to_hex_char(r & 15);
	*hex++ = dec_to_hex_char(g >> 4), *hex++ = dec_to_hex_char(g & 15);
	*hex++ = dec_to_hex_char(b >> 4), *hex++ = dec_to_hex_char(b & 15);
	if (hex[-1] == hex[-2] && hex[-3] == hex[-4] && hex[-5] == hex[-6])
		hex[-5] = hex[-3], hex[-4] = hex[-2], hex[-3] = 0;
	else
		*hex = 0;
}

//////////////////////////////////////////////////
///////////                      /////////////////
///////////   CIE ΔE2000 Demo    /////////////////
///////////                      /////////////////
//////////////////////////////////////////////////

// The goal of this demo in C is to use the CIEDE2000 function to compare two hexadecimal colors.

#include <stdio.h>

int main(void) {
	const char *hex_1 = "#00f"; // blue
	const char *hex_2 = "#483D8B"; // darkslateblue

	// 1. hex -> RGB (0..255)
	int r_1, g_1, b_1, r_2, g_2, b_2;
	hex_to_rgb(hex_1, &r_1, &g_1, &b_1);
	hex_to_rgb(hex_2, &r_2, &g_2, &b_2);
	printf("%8s -> RGB(%-3d, %-3d, %d)\n", hex_1, r_1, g_1, b_1);
	printf("%8s -> RGB(%-3d, %-3d, %d)\n", hex_2, r_2, g_2, b_2);

	// 2. RGB -> LAB
	double l_1, a_1, b_1_lab, l_2, a_2, b_2_lab;
	rgb_to_lab(r_1 / 255.0, g_1 / 255.0, b_1 / 255.0, &l_1, &a_1, &b_1_lab);
	rgb_to_lab(r_2 / 255.0, g_2 / 255.0, b_2 / 255.0, &l_2, &a_2, &b_2_lab);
	printf("%8s -> LAB(L: %-6.4g, a: %-6.4g, b: %.4g)\n", hex_1, l_1, a_1, b_1_lab);
	printf("%8s -> LAB(L: %-6.4g, a: %-6.4g, b: %.4g)\n", hex_2, l_2, a_2, b_2_lab);

	// 3. ΔE2000
	const double delta_e = ciede_2000(l_1, a_1, b_1_lab, l_2, a_2, b_2_lab);
	printf("Delta E 2000 between %s and %s: %.4g", hex_1, hex_2, delta_e);

	// This shows a ΔE2000 of 15.91
}

// This file is named "compare-hex-colors.c"

// The compilation is done using GCC or CLang :
// - gcc -std=c99 -Wall -Wextra -pedantic -Ofast -o ciede-2000-demo compare-hex-colors.c -lm
// - clang -std=c99 -Wall -Wextra -pedantic -Ofast -o ciede-2000-demo compare-hex-colors.c -lm

// Finally, the execution is done using ./ciede-2000-demo
