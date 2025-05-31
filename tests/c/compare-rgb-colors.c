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

//////////////////////////////////////////////////
///////////                      /////////////////
///////////   CIE ΔE2000 Demo    /////////////////
///////////                      /////////////////
//////////////////////////////////////////////////

// The goal of this demo is to use the CIEDE2000 function to identify,
// for each RGB color in set 1, the closest RGB color in set 2.

struct rgb {
	int r;
	int g;
	int b;
	char name[21];
};

static struct rgb rgb_set_1[ ] = { {255, 228, 196, "bisque"}, {154, 205, 50, "yellowgreen"}, {128, 128, 128, "gray"}, {255, 105, 180, "hotpink"}, {173, 216, 230, "lightblue"}, {72, 61, 139, "darkslateblue"}, {119, 136, 153, "lightslategray"}, {100, 149, 237, "cornflowerblue"}, {255, 250, 205, "lemonchiffon"}, {255, 160, 122, "lightsalmon"}, {165, 42, 42, "brown"}, {188, 143, 143, "rosybrown"}, {245, 222, 179, "wheat"}, {72, 209, 204, "mediumturquoise"}, {255, 218, 185, "peachpuff"}, {255, 182, 193, "lightpink"}, {60, 179, 113, "mediumseagreen"}, {34, 139, 34, "forestgreen"}, {255, 250, 240, "floralwhite"}, {250, 250, 210, "lightgoldenrodyellow"}, {144, 238, 144, "lightgreen"}, {189, 183, 107, "darkkhaki"}, {218, 165, 32, "goldenrod"}, {143, 188, 143, "darkseagreen"}, {255, 99, 71, "tomato"}, {255, 20, 147, "deeppink"}, {0, 191, 255, "deepskyblue"}, {85, 107, 47, "darkolivegreen"}, {255, 127, 80, "coral"}, {178, 34, 34, "firebrick"}, {255, 255, 240, "ivory"}, {148, 0, 211, "darkviolet"}, {255, 255, 224, "lightyellow"}, {0, 128, 128, "teal"}, {0, 0, 0, "black"}, {250, 240, 230, "linen"}, {233, 150, 122, "darksalmon"}, {255, 140, 0, "darkorange"}, {47, 79, 79, "darkslategray"}, {0, 100, 0, "darkgreen"}, {205, 92, 92, "indianred"}, {128, 128, 0, "olive"}, {107, 142, 35, "olivedrab"}, {75, 0, 130, "indigo"}, {186, 85, 211, "mediumorchid"}, {216, 191, 216, "thistle"}, {0, 0, 139, "darkblue"}, {255, 239, 213, "papayawhip"}, {123, 104, 238, "mediumslateblue"}, {253, 245, 230, "oldlace"}, {0, 255, 255, "aqua"}, {65, 105, 225, "royalblue"}, {153, 50, 204, "darkorchid"}, {255, 0, 255, "fuchsia"}, {139, 69, 19, "saddlebrown"}, {0, 139, 139, "darkcyan"}, {128, 0, 128, "purple"}, {255, 235, 205, "blanchedalmond"}, {0, 255, 127, "springgreen"}, {255, 192, 203, "pink"}, {32, 178, 170, "lightseagreen"}, {106, 90, 205, "slateblue"}, {152, 251, 152, "palegreen"}, {221, 160, 221, "plum"}, {0, 0, 255, "blue"}, {244, 164, 96, "sandybrown"}, {0, 255, 0, "lime"}, {64, 224, 208, "turquoise"}, {220, 20, 60, "crimson"}, {255, 248, 220, "cornsilk"} };
static struct rgb rgb_set_2[ ] = { {250, 235, 215, "antiquewhite"}, {255, 255, 255, "white"}, {147, 112, 219, "mediumpurple"}, {169, 169, 169, "darkgray"}, {255, 165, 0, "orange"}, {30, 144, 255, "dodgerblue"}, {25, 25, 112, "midnightblue"}, {245, 255, 250, "mintcream"}, {160, 82, 45, "sienna"}, {222, 184, 135, "burlywood"}, {230, 230, 250, "lavender"}, {138, 43, 226, "blueviolet"}, {255, 228, 225, "mistyrose"}, {255, 69, 0, "orangered"}, {175, 238, 238, "paleturquoise"}, {240, 255, 240, "honeydew"}, {102, 205, 170, "mediumaquamarine"}, {255, 240, 245, "lavenderblush"}, {50, 205, 50, "limegreen"}, {0, 0, 205, "mediumblue"}, {192, 192, 192, "silver"}, {128, 0, 0, "maroon"}, {139, 0, 0, "darkred"}, {210, 180, 140, "tan"}, {255, 215, 0, "gold"}, {95, 158, 160, "cadetblue"}, {0, 206, 209, "darkturquoise"}, {255, 255, 0, "yellow"}, {219, 112, 147, "palevioletred"}, {184, 134, 11, "darkgoldenrod"}, {112, 128, 144, "slategray"}, {0, 250, 154, "mediumspringgreen"}, {240, 128, 128, "lightcoral"}, {220, 220, 220, "gainsboro"}, {238, 130, 238, "violet"}, {211, 211, 211, "lightgray"}, {255, 245, 238, "seashell"}, {210, 105, 30, "chocolate"}, {255, 0, 0, "red"}, {245, 245, 220, "beige"}, {176, 224, 230, "powderblue"}, {205, 133, 63, "peru"}, {127, 255, 212, "aquamarine"}, {173, 255, 47, "greenyellow"}, {240, 230, 140, "khaki"}, {176, 196, 222, "lightsteelblue"}, {240, 248, 255, "aliceblue"}, {127, 255, 0, "chartreuse"}, {255, 222, 173, "navajowhite"}, {46, 139, 87, "seagreen"}, {139, 0, 139, "darkmagenta"}, {238, 232, 170, "palegoldenrod"}, {250, 128, 114, "salmon"}, {224, 255, 255, "lightcyan"}, {248, 248, 255, "ghostwhite"}, {218, 112, 214, "orchid"}, {105, 105, 105, "dimgray"}, {135, 206, 250, "lightskyblue"}, {135, 206, 235, "skyblue"}, {255, 228, 181, "moccasin"}, {0, 0, 128, "navy"}, {70, 130, 180, "steelblue"}, {0, 128, 0, "green"}, {199, 21, 133, "mediumvioletred"}, {240, 255, 255, "azure"}, {124, 252, 0, "lawngreen"}, {102, 51, 153, "rebeccapurple"}, {255, 250, 250, "snow"} };

struct lab {
	double l;
	double a;
	double b;
};

#include <stdio.h>

int main(void) {
	const int len_1 = sizeof(rgb_set_1) / sizeof(*rgb_set_1);
	const int len_2 = sizeof(rgb_set_2) / sizeof(*rgb_set_2);

	// Converts the RGB colors to L*a*b* colors.
	struct lab lab_set_1[len_1], lab_set_2[len_2];
	for (int i = 0; i < len_1; ++i)
		rgb_to_lab(rgb_set_1[i].r / 255.0, rgb_set_1[i].g / 255.0, rgb_set_1[i].b / 255.0, &lab_set_1[i].l, &lab_set_1[i].a, &lab_set_1[i].b);
	for (int i = 0; i < len_2; ++i)
		rgb_to_lab(rgb_set_2[i].r / 255.0, rgb_set_2[i].g / 255.0, rgb_set_2[i].b / 255.0, &lab_set_2[i].l, &lab_set_2[i].a, &lab_set_2[i].b);

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
		const struct rgb *rgb_1 = rgb_set_1 + i;
		const struct rgb *rgb_2 = rgb_set_2 + k;
		printf("The closest color from %s = RGB(%d, %d, %d) ", rgb_1->name, rgb_1->r, rgb_1->g, rgb_1->b);
		printf("is %s = RGB(%d, %d, %d) ", rgb_2->name, rgb_2->r, rgb_2->g, rgb_2->b);
		printf("with a distance of %.05f\n", min_delta_e);
	}

}

// This file is named "rgb-color-difference.c"

// The compilation is done using GCC or CLang :
// - gcc -std=c99 -Wall -Wextra -pedantic -Ofast -o ciede-2000-demo rgb-color-difference.c -lm
// - clang -std=c99 -Wall -Wextra -pedantic -Ofast -o ciede-2000-demo rgb-color-difference.c -lm

// Finally, the execution is done using ./ciede-2000-demo
