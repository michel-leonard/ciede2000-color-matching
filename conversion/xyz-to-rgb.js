function xyz_to_rgb(x, y, z) {
	// Normalize for the sRGB color space
	x /= 100
	y /= 100
	z /= 100

	var r = x * 3.2404542 + y * -1.5371385 + z * -0.4985314
	var g = x * -0.9692660 + y * 1.8760108 + z * 0.0415560
	var b = x * 0.0556434 + y * -0.2040259 + z * 1.0572252

	// Apply gamma correction
	r = r > 0.0031308 ? 1.055 * Math.pow(r, 1 / 2.4) - 0.055 : 12.92 * r
	g = g > 0.0031308 ? 1.055 * Math.pow(g, 1 / 2.4) - 0.055 : 12.92 * g
	b = b > 0.0031308 ? 1.055 * Math.pow(b, 1 / 2.4) - 0.055 : 12.92 * b

	// Convert back to 0-255 range and clamp
	r = Math.floor(Math.min(Math.max(0, r * 255), 255) + .5)
	g = Math.floor(Math.min(Math.max(0, g * 255 ), 255)+ .5)
	b = Math.floor(Math.min(Math.max(0, b * 255), 255) + .5)

	return [r, g, b]
}
