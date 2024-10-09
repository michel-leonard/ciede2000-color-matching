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
