function rgb_to_xyz(r, g, b) {
	// Normalize RGB values to the range 0 to 1
	r /= 255
	g /= 255
	b /= 255

	// Apply a gamma correction to each channel
	r = r > 0.04045 ? Math.pow((r + 0.055) / 1.055, 2.4) : r / 12.92
	g = g > 0.04045 ? Math.pow((g + 0.055) / 1.055, 2.4) : g / 12.92
	b = b > 0.04045 ? Math.pow((b + 0.055) / 1.055, 2.4) : b / 12.92

	// Convert to XYZ using the sRGB color space
	var x = r * 0.4124564 + g * 0.3575761 + b * 0.1804375
	var y = r * 0.2126729 + g * 0.7151522 + b * 0.0721750
	var z = r * 0.0193339 + g * 0.1191920 + b * 0.9503041

	return [x * 100, y * 100, z * 100]
}
