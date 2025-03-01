#include <math.h>

#ifndef min
#define min(a, b) ((a) < (b) ? (a) : (b))
#endif
#ifndef max
#define max(a, b) ((a) > (b) ? (a) : (b))
#endif

void rgb_to_xyz(double *color) {
	// Normalize RGB values to the range 0 to 1
	color[0] /= 255.0;
	color[1] /= 255.0;
	color[2] /= 255.0;

	// Apply a gamma correction to each channel
	color[0] = color[0] > 0.04045 ? pow((color[0] + 0.055) / 1.055, 2.4) : color[0] / 12.92;
	color[1] = color[1] > 0.04045 ? pow((color[1] + 0.055) / 1.055, 2.4) : color[1] / 12.92;
	color[2] = color[2] > 0.04045 ? pow((color[2] + 0.055) / 1.055, 2.4) : color[2] / 12.92;

	// Convert to XYZ using the sRGB color space
	double x = 100.0 * (color[0] * 0.4124564 + color[1] * 0.3575761 + color[2] * 0.1804375);
	double y = 100.0 * (color[0] * 0.2126729 + color[1] * 0.7151522 + color[2] * 0.0721750);
	double z = 100.0 * (color[0] * 0.0193339 + color[1] * 0.1191920 + color[2] * 0.9503041);

	color[0] = x;
	color[1] = y;
	color[2] = z;
}
void xyz_to_lab(double *color) {
	// Reference white point (D65)
	double refX = 95.047;
	double refY = 100.000;
	double refZ = 108.883;

	color[0] /= refX;
	color[1] /= refY;
	color[2] /= refZ;

	// Applying the CIE standard transformation
	color[0] = color[0] > 0.008856 ? cbrt(color[0]) : (7.787 * color[0]) + (16.0 / 116.0);
	color[1] = color[1] > 0.008856 ? cbrt(color[1]) : (7.787 * color[1]) + (16.0 / 116.0);
	color[2] = color[2] > 0.008856 ? cbrt(color[2]) : (7.787 * color[2]) + (16.0 / 116.0);

	double l = (116.0 * color[1]) - 16.0;
	double a = 500.0 * (color[0] - color[1]);
	double b = 200.0 * (color[1] - color[2]);

	color[0] = l;
	color[1] = a;
	color[2] = b;
}
void rgb_to_lab(double *color) {
	rgb_to_xyz(color);
	xyz_to_lab(color);
}
void lab_to_xyz(double *color) {
	// Reference white point (D65)
	double refX = 95.047;
	double refY = 100.000;
	double refZ = 108.883;

	double y = (color[0] + 16.0) / 116.0;
	double x = color[1] / 500.0 + y;
	double z = y - color[2] / 200.0;

	double x3 = pow(x, 3.0);
	double y3 = pow(y, 3.0);
	double z3 = pow(z, 3.0);

	x = x3 > 0.008856 ? x3 : (x - 16.0 / 116.0) / 7.787;
	y = color[0] > 7.9996 ? y3 : color[0] / 903.3;
	z = z3 > 0.008856 ? z3 : (z - 16.0 / 116.0) / 7.787;

	color[0] = x * refX;
	color[1] = y * refY;
	color[2] = z * refZ;
}
void xyz_to_rgb(double *color) {
	// Normalize for the sRGB color space
	color[0] /= 100.0;
	color[1] /= 100.0;
	color[2] /= 100.0;

	double r = color[0] *  3.2404542 + color[1] * -1.5371385 + color[2] * -0.4985314;
	double g = color[0] * -0.9692660 + color[1] *  1.8760108 + color[2] * 0.0415560;
	double b = color[0] *  0.0556434 + color[1] * -0.2040259 + color[2] * 1.0572252;

	// Apply gamma correction
	r = r > 0.0031308 ? 1.055 * pow(r, 1.0 / 2.4) - 0.055 : 12.92 * r;
	g = g > 0.0031308 ? 1.055 * pow(g, 1.0 / 2.4) - 0.055 : 12.92 * g;
	b = b > 0.0031308 ? 1.055 * pow(b, 1.0 / 2.4) - 0.055 : 12.92 * b;

	// Convert back to 0-255 range and clamp
	color[0] = floor(min(max(0.0, r * 255.0), 255.0) + 0.5);
	color[1] = floor(min(max(0.0, g * 255.0), 255.0) + 0.5);
	color[2] = floor(min(max(0.0, b * 255.0), 255.0) + 0.5);
}
void lab_to_rgb(double *color) {
	lab_to_xyz(color);
	xyz_to_rgb(color);
}