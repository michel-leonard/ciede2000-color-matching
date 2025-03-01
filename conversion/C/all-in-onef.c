#include <math.h>

#ifndef min
#define min(a, b) ((a) < (b) ? (a) : (b))
#endif
#ifndef max
#define max(a, b) ((a) > (b) ? (a) : (b))
#endif

void rgb_to_xyzf(float *color) {
	// Normalize RGB values to the range 0 to 1
	color[0] /= 255.0f;
	color[1] /= 255.0f;
	color[2] /= 255.0f;

	// Apply a gamma correction to each channel
	color[0] = color[0] > 0.04045f ? powf((color[0] + 0.055f) / 1.055f, 2.4f) : color[0] / 12.92f;
	color[1] = color[1] > 0.04045f ? powf((color[1] + 0.055f) / 1.055f, 2.4f) : color[1] / 12.92f;
	color[2] = color[2] > 0.04045f ? powf((color[2] + 0.055f) / 1.055f, 2.4f) : color[2] / 12.92f;

	// Convert to XYZ using the sRGB color space
	float x = 100.0f * (color[0] * 0.4124564f + color[1] * 0.3575761f + color[2] * 0.1804375f);
	float y = 100.0f * (color[0] * 0.2126729f + color[1] * 0.7151522f + color[2] * 0.0721750f);
	float z = 100.0f * (color[0] * 0.0193339f + color[1] * 0.1191920f + color[2] * 0.9503041f);

	color[0] = x;
	color[1] = y;
	color[2] = z;
}
void xyz_to_labf(float *color) {
	// Reference white point (D65)
	float refX = 95.047f;
	float refY = 100.000f;
	float refZ = 108.883f;

	color[0] /= refX;
	color[1] /= refY;
	color[2] /= refZ;

	// Applying the CIE standard transformation
	color[0] = color[0] > 0.008856f ? cbrtf(color[0]) : (7.787f * color[0]) + (16.0f / 116.0f);
	color[1] = color[1] > 0.008856f ? cbrtf(color[1]) : (7.787f * color[1]) + (16.0f / 116.0f);
	color[2] = color[2] > 0.008856f ? cbrtf(color[2]) : (7.787f * color[2]) + (16.0f / 116.0f);

	float l = (116.0f * color[1]) - 16.0f;
	float a = 500.0f * (color[0] - color[1]);
	float b = 200.0f * (color[1] - color[2]);

	color[0] = l;
	color[1] = a;
	color[2] = b;
}
void lab_to_xyzf(float *color) {
	// Reference white point (D65)
	float refX = 95.047f;
	float refY = 100.000f;
	float refZ = 108.883f;

	float y = (color[0] + 16.0f) / 116.0f;
	float x = color[1] / 500.0f + y;
	float z = y - color[2] / 200.0f;

	float x3 = powf(x, 3.0f);
	float y3 = powf(y, 3.0f);
	float z3 = powf(z, 3.0f);

	x = x3 > 0.008856f ? x3 : (x - 16.0f / 116.0f) / 7.787f;
	y = color[0] > 7.9996f ? y3 : color[0] / 903.3f;
	z = z3 > 0.008856f ? z3 : (z - 16.0f / 116.0f) / 7.787f;

	color[0] = x * refX;
	color[1] = y * refY;
	color[2] = z * refZ;
}
void xyz_to_rgbf(float *color) {
	// Normalize for the sRGB color space
	color[0] /= 100.0f;
	color[1] /= 100.0f;
	color[2] /= 100.0f;

	float r = color[0] *  3.2404542f + color[1] * -1.5371385f + color[2] * -0.4985314f;
	float g = color[0] * -0.9692660f + color[1] *  1.8760108f + color[2] * 0.0415560f;
	float b = color[0] *  0.0556434f + color[1] * -0.2040259f + color[2] * 1.0572252f;

	// Apply gamma correction
	r = r > 0.0031308f ? 1.055f * powf(r, 1.0f / 2.4f) - 0.055f : 12.92f * r;
	g = g > 0.0031308f ? 1.055f * powf(g, 1.0f / 2.4f) - 0.055f : 12.92f * g;
	b = b > 0.0031308f ? 1.055f * powf(b, 1.0f / 2.4f) - 0.055f : 12.92f * b;

	// Convert back to 0-255 range and clamp
	color[0] = floorf(min(max(0.0f, r * 255.0f), 255.0f) + 0.5f);
	color[1] = floorf(min(max(0.0f, g * 255.0f), 255.0f) + 0.5f);
	color[2] = floorf(min(max(0.0f, b * 255.0f), 255.0f) + 0.5f);
}