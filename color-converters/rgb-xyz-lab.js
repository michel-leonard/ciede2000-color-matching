// These color conversion functions written in JavaScript are released into the public domain.
// They are provided "as is" without any warranty, express or implied.

// rgb in 0..1
function rgb_to_xyz(r, g, b) {

	// Apply a gamma correction to each channel
	r = r > 0.0404482362771082 ? Math.pow((r + 0.055) / 1.055, 2.4) : r / 12.92
	g = g > 0.0404482362771082 ? Math.pow((g + 0.055) / 1.055, 2.4) : g / 12.92
	b = b > 0.0404482362771082 ? Math.pow((b + 0.055) / 1.055, 2.4) : b / 12.92

	// Convert to XYZ using the sRGB color space
	var x = r * 0.4124564390896921 + g * 0.357576077643909 + b * 0.18043748326639894
	var y = r * 0.21267285140562248 + g * 0.715152155287818 + b * 0.07217499330655958
	var z = r * 0.019333895582329317 + g * 0.119192025881303 + b * 0.9503040785363677

	return [x * 100.0, y * 100.0, z * 100.0]
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
	x = x > 216.0 / 24389.0 ? Math.cbrt(x) : ((841.0 / 108.0) * x) + (4.0 / 29.0)
	y = y > 216.0 / 24389.0 ? Math.cbrt(y) : ((841.0 / 108.0) * y) + (4.0 / 29.0)
	z = z > 216.0 / 24389.0 ? Math.cbrt(z) : ((841.0 / 108.0) * z) + (4.0 / 29.0)

	var l = (116.0 * y) - 16.0
	var a = 500.0 * (x - y)
	var b = 200.0 * (y - z)

	return [l, a, b]
}

// rgb in 0..1
function rgb_to_lab(r, g, b) {
	var xyz = rgb_to_xyz(r, g, b)
	return xyz_to_lab(...xyz)
}

function lab_to_xyz(l, a, b) {
	// Reference white point (D65)
	var refX = 95.047
	var refY = 100.000
	var refZ = 108.883

	var y = (l + 16.0) / 116.0
	var x = a / 500.0 + y
	var z = y - b / 200.0

	var x3 = x * x * x
	var y3 = y * y * y
	var z3 = z * z * z

	x = x3 > 216.0 / 24389.0 ? x3 : (x - 4.0 / 29.0) / (841.0 / 108.0)
	y = l > 8.0 ? y3 : l / (24389.0 / 27.0)
	z = z3 > 216.0 / 24389.0 ? z3 : (z - 4.0 / 29.0) / (841.0 / 108.0)

	return [x * refX, y * refY, z * refZ]
}

function xyz_to_rgb(x, y, z) {
	// Normalize for the sRGB color space
	x /= 100.0
	y /= 100.0
	z /= 100.0

	// # The constants are based on the sRGB color primaries in "xy" and D65 whitepoint in "XYZ"
	var r = x * 3.2404541621141054 + y * -1.5371385127977166 + z * -0.4985314095560162
	var g = x * -0.9692660305051868 + y * 1.8760108454466942 + z * 0.04155601753034984
	var b = x * 0.05564343095911469 + y * -0.20402591351675387 + z * 1.0572251882231791

	// Apply gamma correction
	r = r > 0.0031306684425005883 ? 1.055 * Math.pow(r, 1.0 / 2.4) - 0.055 : 12.92 * r
	g = g > 0.0031306684425005883 ? 1.055 * Math.pow(g, 1.0 / 2.4) - 0.055 : 12.92 * g
	b = b > 0.0031306684425005883 ? 1.055 * Math.pow(b, 1.0 / 2.4) - 0.055 : 12.92 * b

	return [r, g, b]
}

function lab_to_rgb(l, a, b) {
	const xyz = lab_to_xyz(l, a, b)
	return xyz_to_rgb(...xyz)
}

// Constants used in Color Conversion :
// 216.0 / 24389.0 = 0.0088564516790356308171716757554635286399606379925376194185903481077
// 841.0 / 108.0 = 7.78703703703703703703703703703703703703703703703703703703703703703703703703
// 4.0 / 29.0 = 0.13793103448275862068965517241379310344827586206896551724137931034482758620
// 24389.0 / 27.0 = 903.296296296296296296296296296296296296296296296296296296296296296296296296
// 1.0 / 2.4 = 0.41666666666666666666666666666666666666666666666666666666666666666666666666

///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////
////////////////////                                   ////////////////////////////
////////////////////              TESTING              ////////////////////////////
////////////////////                                   ////////////////////////////
///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////

function test_xyz_and_lab(iterations, tolerance) {
	let err_x = 0, err_y = 0, err_z = 0
	for (let i = 0; i < iterations; ++i) {
		const X = Math.random() * 95.047
		const Y = Math.random() * 100.0
		const Z = Math.random() * 108.883
		const [x, y, z] = lab_to_xyz(...xyz_to_lab(X, Y, Z))
		if (err_x < Math.abs(X - x))
			err_x = Math.abs(X - x)
		if (err_y < Math.abs(Y - y))
			err_y = Math.abs(Y - y)
		if (err_z < Math.abs(Z - z))
			err_z = Math.abs(Z - z)
	}
	if (err_x < tolerance && err_y < tolerance && err_z < tolerance)
		console.log('xyz_to_lab <=> lab_to_xyz : PASS')
	else
		console.log(`xyz_to_lab <=> lab_to_xyz : err_x=${err_x}, err_y=${err_y}, err_z=${err_z}`)
}

function test_lab_and_xyz(iterations, tolerance) {
	let err_l = 0, err_a = 0, err_b = 0
	for (let i = 0; i < iterations; ++i) {
		const L = Math.random() * 100.0
		const A = Math.random() * 256.0 - 128.0
		const B = Math.random() * 256.0 - 128.0
		const [l, a, b] = lab_to_xyz(...xyz_to_lab(L, A, B))
		if (err_l < Math.abs(L - l))
			err_l = Math.abs(L - l)
		if (err_a < Math.abs(A - a))
			err_a = Math.abs(A - a)
		if (err_b < Math.abs(B - b))
			err_b = Math.abs(B - b)
	}
	if (err_l < tolerance && err_a < tolerance && err_b < tolerance)
		console.log('xyz_to_lab <=> lab_to_xyz : PASS')
	else
		console.log(`xyz_to_lab <=> lab_to_xyz : err_l=${err_l}, err_a=${err_a}, err_b=${err_b}`)
}

function test_rgb_and_xyz(iterations, tolerance) {
	let err_r = 0, err_g = 0, err_b = 0
	for (let i = 0; i < iterations; ++i) {
		const R = Math.random()
		const G = Math.random()
		const B = Math.random()
		const [r, g, b] = xyz_to_rgb(...rgb_to_xyz(R, G, B))
		if (err_r < Math.abs(R - r))
			err_r = Math.abs(R - r)
		if (err_g < Math.abs(G - g))
			err_g = Math.abs(G - g)
		if (err_b < Math.abs(B - b))
			err_b = Math.abs(B - b)
	}
	if (err_r < tolerance && err_g < tolerance && err_b < tolerance)
		console.log('rgb_to_xyz <=> xyz_to_rgb : PASS')
	else
		console.log(`rgb_to_xyz <=> xyz_to_rgb : err_r=${err_r}, err_g=${err_g}, err_b=${err_b}`)
}

function test_xyz_and_rgb(iterations, tolerance) {
	let err_x = 0, err_y = 0, err_z = 0
	for (let i = 0; i < iterations; ++i) {
		const X = Math.random() * 95.047
		const Y = Math.random() * 100.0
		const Z = Math.random() * 108.883
		const [x, y, z] = rgb_to_xyz(...xyz_to_rgb(X, Y, Z))
		if (err_x < Math.abs(X - x))
			err_x = Math.abs(X - x)
		if (err_y < Math.abs(Y - y))
			err_y = Math.abs(Y - y)
		if (err_z < Math.abs(Z - z))
			err_z = Math.abs(Z - z)
	}
	if (err_x < tolerance && err_y < tolerance && err_z < tolerance)
		console.log('xyz_to_rgb <=> rgb_to_xyz : PASS')
	else
		console.log(`xyz_to_rgb <=> rgb_to_xyz : err_x=${err_x}, err_y=${err_y}, err_z=${err_z}`)
}

function test_rgb_and_lab(iterations, tolerance) {
	let err_r = 0, err_g = 0, err_b = 0
	for (let i = 0; i < iterations; ++i) {
		const R = Math.random()
		const G = Math.random()
		const B = Math.random()
		const [r, g, b] = lab_to_rgb(...rgb_to_lab(R, G, B))
		if (err_r < Math.abs(R - r))
			err_r = Math.abs(R - r)
		if (err_g < Math.abs(G - g))
			err_g = Math.abs(G - g)
		if (err_b < Math.abs(B - b))
			err_b = Math.abs(B - b)
	}
	if (err_r < tolerance && err_g < tolerance && err_b < tolerance)
		console.log('rgb_to_lab <=> lab_to_rgb : PASS')
	else
		console.log(`rgb_to_lab <=> lab_to_rgb : err_r=${err_r}, err_g=${err_g}, err_b=${err_b}`)
}


function test_lab_and_rgb(iterations, tolerance) {
	let err_l = 0, err_a = 0, err_b = 0
	for (let i = 0; i < iterations; ++i) {
		const L = Math.random() * 100.0
		const A = Math.random() * 256.0 - 128.0
		const B = Math.random() * 256.0 - 128.0
		const [l, a, b] = lab_to_rgb(...rgb_to_lab(L, A, B))
		if (err_l < Math.abs(L - l))
			err_l = Math.abs(L - l)
		if (err_a < Math.abs(A - a))
			err_a = Math.abs(A - a)
		if (err_b < Math.abs(B - b))
			err_b = Math.abs(B - b)
	}
	if (err_l < tolerance && err_a < tolerance && err_b < tolerance)
		console.log('rgb_to_lab <=> lab_to_rgb : PASS')
	else
		console.log(`rgb_to_lab <=> lab_to_rgb : err_l=${err_l}, err_a=${err_a}, err_b=${err_b}`)
}

const count = 1000000 //  Select the number of iterations.
const tolerance = 0.00000001 //  Define the tolerance (epsilon) in floating point exact comparisons.
test_xyz_and_lab(count, tolerance)
test_lab_and_xyz(count, tolerance)
test_rgb_and_xyz(count, tolerance)
test_xyz_and_rgb(count, tolerance)
test_rgb_and_lab(count, tolerance)
test_lab_and_rgb(count, tolerance)
