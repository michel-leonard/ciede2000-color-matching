// These color conversion functions written in Kotlin are released into the public domain.
// They are provided "as is" without any warranty, express or implied.

// rgb in 0..1
fun rgb_to_xyz(ra: Double, ga: Double, ba: Double): DoubleArray {
	// Apply a gamma correction to each channel.
	val r = if (ra < 0.040448236277105097) ra / 12.92 else Math.pow((ra + 0.055) / 1.055, 2.4)
	val g = if (ga < 0.040448236277105097) ga / 12.92 else Math.pow((ga + 0.055) / 1.055, 2.4)
	val b = if (ba < 0.040448236277105097) ba / 12.92 else Math.pow((ba + 0.055) / 1.055, 2.4)

	// Applying linear transformation using RGB to XYZ transformation matrix.
	val x = r * 41.24564390896921145 + g * 35.75760776439090507 + b * 18.04374830853290341
	val y = r * 21.26728514056222474 + g * 71.51521552878181013 + b * 7.21749933075596513
	val z = r * 1.93338955823293176 + g * 11.91919550818385936 + b * 95.03040770337479886

	return doubleArrayOf(x, y, z)
}

fun xyz_to_lab(xa: Double, ya: Double, za: Double): DoubleArray {
	// Reference white point : D65 2° Standard observer
	val refX = 95.047
	val refY = 100.000
	val refZ = 108.883

	var x = xa / refX
	var y = ya / refY
	var z = za / refZ

	// Applying the CIE standard transformation.
	x = if (x < 216.0 / 24389.0) ((841.0 / 108.0) * x) + (4.0 / 29.0) else Math.cbrt(x)
	y = if (y < 216.0 / 24389.0) ((841.0 / 108.0) * y) + (4.0 / 29.0) else Math.cbrt(y)
	z = if (z < 216.0 / 24389.0) ((841.0 / 108.0) * z) + (4.0 / 29.0) else Math.cbrt(z)

	val l = (116.0 * y) - 16.0
	val a = 500.0 * (x - y)
	val b = 200.0 * (y - z)

	return doubleArrayOf(l, a, b)
}

// rgb in 0..1
fun rgb_to_lab(r: Double, g: Double, b: Double): DoubleArray {
	val xyz = rgb_to_xyz(r, g, b)
	return xyz_to_lab(xyz[0], xyz[1], xyz[2])
}

fun lab_to_xyz(l: Double, a: Double, b: Double): DoubleArray {
	// Reference white point : D65 2° Standard observer
	val refX = 95.047
	val refY = 100.000
	val refZ = 108.883

	var y = (l + 16.0) / 116.0
	var x = a / 500.0 + y
	var z = y - b / 200.0

	val x3 = x * x * x
	val z3 = z * z * z

	x = if (x3 < 216.0 / 24389.0) (x - 4.0 / 29.0) / (841.0 / 108.0) else x3
	y = if (l < 8.0) l / (24389.0 / 27.0) else y * y * y
	z = if (z3 < 216.0 / 24389.0) (z - 4.0 / 29.0) / (841.0 / 108.0) else z3

	return doubleArrayOf(x * refX, y * refY, z * refZ)
}

// rgb in 0..1
fun xyz_to_rgb(x: Double, y: Double, z: Double): DoubleArray {
	// Applying linear transformation using the XYZ to RGB transformation matrix.
	var r = x * 0.032404541621141049051 + y * -0.015371385127977165753 + z * -0.004985314095560160079
	var g = x * -0.009692660305051867686 + y * 0.018760108454466942288 + z * 0.00041556017530349983
	var b = x * 0.000556434309591145522 + y * -0.002040259135167538416 + z * 0.010572251882231790398

	// Apply gamma correction.
	r = if (r < 0.003130668442500634) 12.92 * r else 1.055 * Math.pow(r, 1.0 / 2.4) - 0.055
	g = if (g < 0.003130668442500634) 12.92 * g else 1.055 * Math.pow(g, 1.0 / 2.4) - 0.055
	b = if (b < 0.003130668442500634) 12.92 * b else 1.055 * Math.pow(b, 1.0 / 2.4) - 0.055

	return doubleArrayOf(r, g, b)
}

// rgb in 0..1
fun lab_to_rgb(l: Double, a: Double, b: Double): DoubleArray {
	val xyz = lab_to_xyz(l, a, b)
	return xyz_to_rgb(xyz[0], xyz[1], xyz[2])
}

// rgb in 0..255
fun hex_to_rgb(s: String): IntArray {
	// Also support the short syntax (ie "#FFF") as input.
	val n = (if (s.length == 4) "#" + s[1].toString().repeat(2) + s[2].toString().repeat(2) + s[3].toString()
		.repeat(2) else s).substring(1).toInt(16)
	return intArrayOf((n shr 16) and 0xFF, (n shr 8) and 0xFF, n and 0xFF)
}

// rgb in 0..255
fun rgb_to_hex(r: Int, g: Int, b: Int): String {
	// Also provide the short syntax (ie "#FFF") as output.
	val s = "#%02X%02X%02X".format(r, g, b)
	return if (s[1] == s[2] && s[3] == s[4] && s[5] == s[6]) "#${s[1]}${s[3]}${s[5]}" else s
}

// Constants used in Color Conversion :
// 216.0 / 24389.0 = 0.0088564516790356308171716757554635286399606379925376194185903481077
// 841.0 / 108.0 = 7.78703703703703703703703703703703703703703703703703703703703703703703703703
// 4.0 / 29.0 = 0.13793103448275862068965517241379310344827586206896551724137931034482758620
// 24389.0 / 27.0 = 903.296296296296296296296296296296296296296296296296296296296296296296296296
// 1.0 / 2.4 = 0.41666666666666666666666666666666666666666666666666666666666666666666666666
// To get 0.040448236277105097132567243294938 we perform x/12.92 = ((x+0.055)/1.055)^2.4
// To get 0.00313066844250063403284123841596 we perform 12.92*x = 1.055*x^(1/2.4)-0.055
