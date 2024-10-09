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
