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

function xyz_to_lab(x, y, z) {
	// Reference white point (D65)
	var refX = 95.047
	var refY = 100.000
	var refZ = 108.883

	x /= refX
	y /= refY
	z /= refZ

	// Applying the CIE standard transformation
	x = x > 0.008856 ? Math.cbrt(x) : (7.787 * x) + (16 / 116)
	y = y > 0.008856 ? Math.cbrt(y) : (7.787 * y) + (16 / 116)
	z = z > 0.008856 ? Math.cbrt(z) : (7.787 * z) + (16 / 116)

	var l = (116 * y) - 16
	var a = 500 * (x - y)
	var b = 200 * (y - z)

	return [l, a, b]
}

function rgb_to_lab(r, g, b) {
	var xyz = rgb_to_xyz(r, g, b)
	return xyz_to_lab(...xyz)
}

function lab_to_xyz(l, a, b) {
	// Reference white point (D65)
	var refX = 95.047
	var refY = 100.000
	var refZ = 108.883

	var y = (l + 16) / 116
	var x = a / 500 + y
	var z = y - b / 200

	var x3 = Math.pow(x, 3)
	var y3 = Math.pow(y, 3)
	var z3 = Math.pow(z, 3)

	x = x3 > 0.008856 ? x3 : (x - 16 / 116) / 7.787
	y = l > 7.9996 ? y3 : l / 903.3
	z = z3 > 0.008856 ? z3 : (z - 16 / 116) / 7.787

	return [x * refX, y * refY, z * refZ]
}

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
	g = Math.floor(Math.min(Math.max(0, g * 255), 255) + .5)
	b = Math.floor(Math.min(Math.max(0, b * 255), 255) + .5)

	return [r, g, b]
}

function lab_to_rgb(l, a, b) {
	const xyz = lab_to_xyz(l, a, b)
	return xyz_to_rgb(...xyz)
}
