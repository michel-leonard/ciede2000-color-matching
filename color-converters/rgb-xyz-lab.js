// These color conversion functions written in JavaScript are released into the public domain.
// They are provided "as is" without any warranty, express or implied.

// rgb in 0..1
function rgb_to_xyz(r, g, b) {
	// Apply a gamma correction to each channel.
	r = r < 0.040448236277105097 ? r / 12.92 : Math.pow((r + 0.055) / 1.055, 2.4)
	g = g < 0.040448236277105097 ? g / 12.92 : Math.pow((g + 0.055) / 1.055, 2.4)
	b = b < 0.040448236277105097 ? b / 12.92 : Math.pow((b + 0.055) / 1.055, 2.4)

	// Applying linear transformation using RGB to XYZ transformation matrix.
	var x = r * 41.24564390896921145 + g * 35.75760776439090507 + b * 18.04374830853290341
	var y = r * 21.26728514056222474 + g * 71.51521552878181013 + b * 7.21749933075596513
	var z = r * 1.93338955823293176 + g * 11.91919550818385936 + b * 95.03040770337479886

	return [x, y, z]
}

function xyz_to_lab(x, y, z) {
	// Reference white point : D65 2° Standard observer
	var refX = 95.047
	var refY = 100.000
	var refZ = 108.883

	x /= refX
	y /= refY
	z /= refZ

	// Applying the CIE standard transformation.
	x = x < 216.0 / 24389.0 ? ((841.0 / 108.0) * x) + (4.0 / 29.0) : Math.cbrt(x)
	y = y < 216.0 / 24389.0 ? ((841.0 / 108.0) * y) + (4.0 / 29.0) : Math.cbrt(y)
	z = z < 216.0 / 24389.0 ? ((841.0 / 108.0) * z) + (4.0 / 29.0) : Math.cbrt(z)

	var l = (116.0 * y) - 16.0
	var a = 500.0 * (x - y)
	var b = 200.0 * (y - z)

	return [l, a, b]
}

// rgb in 0..1
function rgb_to_lab(r, g, b) {
	var xyz = rgb_to_xyz(r, g, b)
	return xyz_to_lab(xyz[0], xyz[1], xyz[2])
}

function lab_to_xyz(l, a, b) {
	// Reference white point : D65 2° Standard observer
	var refX = 95.047
	var refY = 100.000
	var refZ = 108.883

	var y = (l + 16.0) / 116.0
	var x = a / 500.0 + y
	var z = y - b / 200.0

	var x3 = x * x * x
	var z3 = z * z * z

	x = x3 < 216.0 / 24389.0 ? (x - 4.0 / 29.0) / (841.0 / 108.0) : x3
	y = l < 8.0 ? l / (24389.0 / 27.0) : y * y * y
	z = z3 < 216.0 / 24389.0 ? (z - 4.0 / 29.0) / (841.0 / 108.0) : z3

	return [x * refX, y * refY, z * refZ]
}

// rgb in 0..1
function xyz_to_rgb(x, y, z) {
	// Applying linear transformation using the XYZ to RGB transformation matrix.
	var r = x * 0.032404541621141049051 + y * -0.015371385127977165753 + z * -0.004985314095560160079
	var g = x * -0.009692660305051867686 + y * 0.018760108454466942288 + z * 0.00041556017530349983
	var b = x * 0.000556434309591145522 + y * -0.002040259135167538416 + z * 0.010572251882231790398

	// Apply gamma correction.
	r = r < 0.003130668442500634 ? 12.92 * r : 1.055 * Math.pow(r, 1.0 / 2.4) - 0.055
	g = g < 0.003130668442500634 ? 12.92 * g : 1.055 * Math.pow(g, 1.0 / 2.4) - 0.055
	b = b < 0.003130668442500634 ? 12.92 * b : 1.055 * Math.pow(b, 1.0 / 2.4) - 0.055

	return [r, g, b]
}

// rgb in 0..1
function lab_to_rgb(l, a, b) {
	var xyz = lab_to_xyz(l, a, b)
	return xyz_to_rgb(xyz[0], xyz[1], xyz[2])
}

// rgb in 0..255
function hex_to_rgb(s) {
	// Also support the short syntax (ie "#FFF") as input.
	var n = parseInt((s.length === 4 ? s[0] + s[1] + s[1] + s[2] + s[2] + s[3] + s[3] : s).substring(1), 16)
	return [n >> 16 & 0xff, n >> 8 & 0xff, n & 0xff]
}

// rgb in 0..255
function rgb_to_hex(r, g, b) {
	// Also provide the short syntax (ie "#FFF") as output.
	var s = '#' + r.toString(16).padStart(2, '0') + g.toString(16).padStart(2, '0') + b.toString(16).padStart(2, '0')
	return s[1] === s[2] && s[3] === s[4] && s[5] === s[6] ? '#' + s[1] + s[3] + s[5] : s
}

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching

// Constants used in Color Conversion :
// 216.0 / 24389.0 = 0.0088564516790356308171716757554635286399606379925376194185903481077
// 841.0 / 108.0 = 7.78703703703703703703703703703703703703703703703703703703703703703703703703
// 4.0 / 29.0 = 0.13793103448275862068965517241379310344827586206896551724137931034482758620
// 24389.0 / 27.0 = 903.296296296296296296296296296296296296296296296296296296296296296296296296
// 1.0 / 2.4 = 0.41666666666666666666666666666666666666666666666666666666666666666666666666
// To get 0.040448236277105097132567243294938 we perform x/12.92 = ((x+0.055)/1.055)^2.4
// To get 0.00313066844250063403284123841596 we perform 12.92*x = 1.055*x^(1/2.4)-0.055

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
		console.log(`
}xyz_to_lab <=> lab_to_xyz : err_x=${err_x}, err_y=${err_y}, err_z=${err_z}`)
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

function test_hex_and_rgb(iterations) {
	let i = 0
	for (; i < iterations; ++i) {
		const r = Math.floor(256.0 * Math.random())
		const g = Math.floor(256.0 * Math.random())
		const b = Math.floor(256.0 * Math.random())
		const [R, G, B] = hex_to_rgb(rgb_to_hex(r, g, b))
		if (r !== R || g !== G || B !== b)
			break
	}
	if (i === iterations)
		console.log('rgb_to_hex <=> hex_to_rgb : PASS')
	else
		console.log(`rgb_to_hex <=> hex_to_rgb : error after ${i} iteration(s).`)
}

const count = 1000000 //  Select the number of iterations.
const tolerance = 0.00000001 //  Define the tolerance (epsilon) in floating point exact comparisons.
test_xyz_and_lab(count, tolerance)
test_lab_and_xyz(count, tolerance)
test_rgb_and_xyz(count, tolerance)
test_xyz_and_rgb(count, tolerance)
test_rgb_and_lab(count, tolerance)
test_lab_and_rgb(count, tolerance)
test_hex_and_rgb(count)
