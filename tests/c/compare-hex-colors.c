// This function written in C is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

#include <math.h>

// Expressly defining pi ensures that the code works on different platforms.
#ifndef M_PI
#define M_PI 3.14159265358979323846264338328
#endif

// The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
// "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 128.
static double ciede_2000(const double l_1, const double a_1, const double b_1, const double l_2, const double a_2, const double b_2) {
	// Working in C with the CIEDE2000 color-difference formula.
	// k_l, k_c, k_h are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	const double k_l = 1.0;
	const double k_c = 1.0;
	const double k_h = 1.0;
	double n = (hypot(a_1, b_1) + hypot(a_2, b_2)) * 0.5;
	n = n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - sqrt(n / (n + 6103515625.0)));
	// hypot calculates the Euclidean distance while avoiding overflow/underflow.
	const double c_1 = hypot(a_1 * n, b_1);
	const double c_2 = hypot(a_2 * n, b_2);
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	double h_1 = atan2(b_1, a_1 * n);
	double h_2 = atan2(b_2, a_2 * n);
	if (h_1 < 0.0)
		h_1 += 2.0 * M_PI;
	if (h_2 < 0.0)
		h_2 += 2.0 * M_PI;
	n = fabs(h_2 - h_1);
	// Cross-implementation consistent rounding.
	if (M_PI - 1E-14 < n && n < M_PI + 1E-14)
		n = M_PI;
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	double h_m = (h_1 + h_2) * 0.5;
	double h_d = (h_2 - h_1) * 0.5;
	if (M_PI < n) {
		if (0.0 < h_d)
			h_d -= M_PI;
		else
			h_d += M_PI;
		h_m += M_PI;
	}
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
	const double t = 1.0 + 0.24 * sin(2.0 * h_m + M_PI / 2.0)
					 + 0.32 * sin(3.0 * h_m + 8.0 * M_PI / 15.0)
					 - 0.17 * sin(h_m + M_PI / 3.0)
					 - 0.20 * sin(4.0 * h_m + 3.0 * M_PI / 20.0);
	n = c_1 + c_2;
	// Hue.
	const double h = 2.0 * sqrt(c_1 * c_2) * sin(h_d) / (k_h * (1.0 + 0.0075 * n * t));
	// Chroma.
	const double c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
	// Returning the square root ensures that the result reflects the actual geometric
	// distance within the color space, which ranges from 0 to approximately 185.
	return sqrt(l * l + h * h + c * c + c * h * r_t);
}

// These color conversion functions written in C are released into the public domain.
// They are provided "as is" without any warranty, express or implied.

// rgb in 0..1
static void rgb_to_xyz(double r, double g, double b, double *x, double *y, double *z) {
	// Apply a gamma correction to each channel
	r = r > 0.0404482362771082 ? pow((r + 0.055) / 1.055, 2.4) : r / 12.92;
	g = g > 0.0404482362771082 ? pow((g + 0.055) / 1.055, 2.4) : g / 12.92;
	b = b > 0.0404482362771082 ? pow((b + 0.055) / 1.055, 2.4) : b / 12.92;

	// Applying linear transformation using RGB to XYZ transformation matrix.
	*x = r * 41.24564390896921 + g * 35.7576077643909 + b * 18.043748326639894;
	*y = r * 21.267285140562248 + g * 71.5152155287818 + b * 7.217499330655958;
	*z = r * 1.9333895582329317 + g * 11.9192025881303 + b * 95.03040785363677;
}

static void xyz_to_lab(double x, double y, double z, double *l, double *a, double *b) {
	// Reference white point (D65)
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
	// Reference white point (D65)
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
	*r = x * 0.032404541621141054 + y * -0.015371385127977166 + z * -0.004985314095560162;
	*g = x * -0.009692660305051868 + y * 0.018760108454466942 + z * 0.0004155601753034984;
	*b = x * 0.0005564343095911469 + y * -0.0020402591351675387 + z * 0.010572251882231791;

	// Apply gamma correction
	*r = *r > 0.0031306684425005883 ? 1.055 * pow(*r, 1.0 / 2.4) - 0.055 : 12.92 * *r;
	*g = *g > 0.0031306684425005883 ? 1.055 * pow(*g, 1.0 / 2.4) - 0.055 : 12.92 * *g;
	*b = *b > 0.0031306684425005883 ? 1.055 * pow(*b, 1.0 / 2.4) - 0.055 : 12.92 * *b;
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

// hex is a string like #123abc or #FFF that we convert to the L*a*b* color space.
static inline void hex_to_lab(const char *restrict hex, double *l, double *a, double *b) {
	int R, G, B;
	hex_to_rgb(hex, &R, &G, &B);
	rgb_to_float(R, G, B, l, a, b);
	rgb_to_lab(*l, *a, *b, l, a, b);
}

//////////////////////////////////////////////////
///////////                      /////////////////
///////////   CIE ΔE2000 Demo    /////////////////
///////////                      /////////////////
//////////////////////////////////////////////////

// The goal of this demo is to use the CIEDE2000 function to identify,
// for each hexadecimal color in set 1, the closest hexadecimal color in set 2.

struct hex {
	char value[8];
	char name[21];
};

static struct hex hex_set_1[ ] = {{"#ffe4c4", "bisque"}, {"#9acd32", "yellowgreen"}, {"#808080", "gray"}, {"#ff69b4", "hotpink"}, {"#add8e6", "lightblue"}, {"#483d8b", "darkslateblue"}, {"#789", "lightslategray"}, {"#6495ed", "cornflowerblue"}, {"#fffacd", "lemonchiffon"}, {"#ffa07a", "lightsalmon"}, {"#a52a2a", "brown"}, {"#bc8f8f", "rosybrown"}, {"#f5deb3", "wheat"}, {"#48d1cc", "mediumturquoise"}, {"#ffdab9", "peachpuff"}, {"#ffb6c1", "lightpink"}, {"#3cb371", "mediumseagreen"}, {"#228b22", "forestgreen"}, {"#fffaf0", "floralwhite"}, {"#fafad2", "lightgoldenrodyellow"}, {"#90ee90", "lightgreen"}, {"#bdb76b", "darkkhaki"}, {"#daa520", "goldenrod"}, {"#8fbc8f", "darkseagreen"}, {"#ff6347", "tomato"}, {"#ff1493", "deeppink"}, {"#00bfff", "deepskyblue"}, {"#556b2f", "darkolivegreen"}, {"#ff7f50", "coral"}, {"#b22222", "firebrick"}, {"#fffff0", "ivory"}, {"#9400d3", "darkviolet"}, {"#ffffe0", "lightyellow"}, {"#008080", "teal"}, {"#000", "black"}, {"#faf0e6", "linen"}, {"#e9967a", "darksalmon"}, {"#ff8c00", "darkorange"}, {"#2f4f4f", "darkslategray"}, {"#006400", "darkgreen"}, {"#cd5c5c", "indianred"}, {"#808000", "olive"}, {"#6b8e23", "olivedrab"}, {"#4b0082", "indigo"}, {"#ba55d3", "mediumorchid"}, {"#d8bfd8", "thistle"}, {"#00008b", "darkblue"}, {"#ffefd5", "papayawhip"}, {"#7b68ee", "mediumslateblue"}, {"#fdf5e6", "oldlace"}, {"#0ff", "aqua"}, {"#4169e1", "royalblue"}, {"#9932cc", "darkorchid"}, {"#f0f", "fuchsia"}, {"#8b4513", "saddlebrown"}, {"#008b8b", "darkcyan"}, {"#800080", "purple"}, {"#ffebcd", "blanchedalmond"}, {"#00ff7f", "springgreen"}, {"#ffc0cb", "pink"}, {"#20b2aa", "lightseagreen"}, {"#6a5acd", "slateblue"}, {"#98fb98", "palegreen"}, {"#dda0dd", "plum"}, {"#00f", "blue"}, {"#f4a460", "sandybrown"}, {"#0f0", "lime"}, {"#40e0d0", "turquoise"}, {"#dc143c", "crimson"}, {"#fff8dc", "cornsilk"}};
static struct hex hex_set_2[ ] = {{"#faebd7", "antiquewhite"}, {"#fff", "white"}, {"#9370db", "mediumpurple"}, {"#a9a9a9", "darkgray"}, {"#ffa500", "orange"}, {"#1e90ff", "dodgerblue"}, {"#191970", "midnightblue"}, {"#f5fffa", "mintcream"}, {"#a0522d", "sienna"}, {"#deb887", "burlywood"}, {"#e6e6fa", "lavender"}, {"#8a2be2", "blueviolet"}, {"#ffe4e1", "mistyrose"}, {"#ff4500", "orangered"}, {"#afeeee", "paleturquoise"}, {"#f0fff0", "honeydew"}, {"#66cdaa", "mediumaquamarine"}, {"#fff0f5", "lavenderblush"}, {"#32cd32", "limegreen"}, {"#0000cd", "mediumblue"}, {"#c0c0c0", "silver"}, {"#800000", "maroon"}, {"#8b0000", "darkred"}, {"#d2b48c", "tan"}, {"#ffd700", "gold"}, {"#5f9ea0", "cadetblue"}, {"#00ced1", "darkturquoise"}, {"#ff0", "yellow"}, {"#db7093", "palevioletred"}, {"#b8860b", "darkgoldenrod"}, {"#708090", "slategray"}, {"#00fa9a", "mediumspringgreen"}, {"#f08080", "lightcoral"}, {"#dcdcdc", "gainsboro"}, {"#ee82ee", "violet"}, {"#d3d3d3", "lightgray"}, {"#fff5ee", "seashell"}, {"#d2691e", "chocolate"}, {"#f00", "red"}, {"#f5f5dc", "beige"}, {"#b0e0e6", "powderblue"}, {"#cd853f", "peru"}, {"#7fffd4", "aquamarine"}, {"#adff2f", "greenyellow"}, {"#f0e68c", "khaki"}, {"#b0c4de", "lightsteelblue"}, {"#f0f8ff", "aliceblue"}, {"#7fff00", "chartreuse"}, {"#ffdead", "navajowhite"}, {"#2e8b57", "seagreen"}, {"#8b008b", "darkmagenta"}, {"#eee8aa", "palegoldenrod"}, {"#fa8072", "salmon"}, {"#e0ffff", "lightcyan"}, {"#f8f8ff", "ghostwhite"}, {"#da70d6", "orchid"}, {"#696969", "dimgray"}, {"#87cefa", "lightskyblue"}, {"#87ceeb", "skyblue"}, {"#ffe4b5", "moccasin"}, {"#000080", "navy"}, {"#4682b4", "steelblue"}, {"#008000", "green"}, {"#c71585", "mediumvioletred"}, {"#f0ffff", "azure"}, {"#7cfc00", "lawngreen"}, {"#639", "rebeccapurple"}, {"#fffafa", "snow"}};

struct lab {
	double l;
	double a;
	double b;
};

#include <stdio.h>

int main(void) {
	const int len_1 = sizeof(hex_set_1) / sizeof(*hex_set_1);
	const int len_2 = sizeof(hex_set_2) / sizeof(*hex_set_2);

	// Converts the hexadecimal colors to L*a*b* colors.
	struct lab lab_set_1[len_1], lab_set_2[len_2];
	for (int i = 0; i < len_1; ++i)
		hex_to_lab(hex_set_1[i].value, &lab_set_1[i].l, &lab_set_1[i].a, &lab_set_1[i].b);
	for (int i = 0; i < len_2; ++i)
		hex_to_lab(hex_set_2[i].value, &lab_set_2[i].l, &lab_set_2[i].a, &lab_set_2[i].b);

	for (int i = 0, k = 0; i < len_1; ++i) {
		// For each color of the set 1.
		const struct lab *color_1 = lab_set_1 + i;
		double min_delta_e = INFINITY;
		for (int j = 0; j < len_2; ++j) {
			const struct lab *color_2 = lab_set_2 + j;
			// We optionally ignore strictly equal colors, they have a color difference of 0.
			if (color_1->l == color_2->l && color_1->a == color_2->a && color_1->b == color_2->b)
				continue;
			// We calculate the color difference.
			const double delta_e = ciede_2000(color_1->l, color_1->a, color_1->b, color_2->l, color_2->a, color_2->b);
			if (delta_e < min_delta_e) {
				// Based on the difference, we identify the closest color from the set 2.
				min_delta_e = delta_e;
				k = j;
			}
		}
		// And we display the results.
		const struct hex *hex_1 = hex_set_1 + i;
		const struct hex *hex_2 = hex_set_2 + k;
		printf("The closest color from %s = %s ", hex_1->name, hex_1->value);
		printf("is %s = %s ", hex_2->name, hex_2->value);
		printf("with a distance of %.05f\n", min_delta_e);
	}

}

// This file is named "hex-color-difference.c"

// The compilation is done using GCC or CLang :
// - gcc -std=c99 -Wall -Wextra -pedantic -Ofast -o ciede-2000-demo hex-color-difference.c -lm
// - clang -std=c99 -Wall -Wextra -pedantic -Ofast -o ciede-2000-demo hex-color-difference.c -lm

// Finally, the execution is done using ./ciede-2000-demo
