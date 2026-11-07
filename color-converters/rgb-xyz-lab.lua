-- These color conversion functions written in Dart are released into the public domain.
-- They are provided "as is" without any warranty, express or implied.

-- rgb in 0..1
function rgb_to_xyz(r, g, b)
	-- Apply a gamma correction to each channel.
	if r < 0.040448236277105097 then r = r / 12.92 else r = ((r + 0.055) / 1.055) ^ 2.4 end
	if g < 0.040448236277105097 then g = g / 12.92 else g =  ((g + 0.055) / 1.055) ^ 2.4 end
	if b < 0.040448236277105097 then b = b / 12.92 else b = ((b + 0.055) / 1.055) ^ 2.4 end

	-- Applying linear transformation using RGB to XYZ transformation matrix.
	local x = r * 41.24564390896921145 + g * 35.75760776439090507 + b * 18.04374830853290341
	local y = r * 21.26728514056222474 + g * 71.51521552878181013 + b * 7.21749933075596513
	local z = r * 1.93338955823293176 + g * 11.91919550818385936 + b * 95.03040770337479886

	return x, y, z
end

function xyz_to_lab(x, y, z)
	-- Reference white point : D65 2° Standard observer
	x = x / 95.047
	y = y / 100.0
	z = z / 108.883

	-- Applying the CIE standard transformation.
	if x < 216.0 / 24389.0 then x = ((841.0 / 108.0) * x) + (4.0 / 29.0) else x = x ^ (1.0 / 3.0) end
	if y < 216.0 / 24389.0 then y = ((841.0 / 108.0) * y) + (4.0 / 29.0) else y = y ^ (1.0 / 3.0) end
	if z < 216.0 / 24389.0 then z = ((841.0 / 108.0) * z) + (4.0 / 29.0) else z = z ^ (1.0 / 3.0) end

	local l = (116.0 * y) - 16.0
	local a = 500.0 * (x - y)
	local b = 200.0 * (y - z)

	return l, a, b
end

-- rgb in 0..1
function rgb_to_lab(r, g, b)
	local x, y, z = rgb_to_xyz(r, g, b)
	return xyz_to_lab(x, y, z)
end

function lab_to_xyz(l, a, b)

	local y = (l + 16.0) / 116.0
	local x = a / 500.0 + y
	local z = y - b / 200.0

	local x3 = x * x * x
	local z3 = z * z * z

	if x3 < 216.0 / 24389.0 then x = (x - 4.0 / 29.0) / (841.0 / 108.0) else x = x3 end
	if l < 8.0 then y = l / (24389.0 / 27.0) else y = y * y * y end
	if z3 < 216.0 / 24389.0 then z = (z - 4.0 / 29.0) / (841.0 / 108.0) else z = z3 end

	-- Reference white point : D65 2° Standard observer
	return x * 95.047, y * 100.0, z * 108.883
end

-- rgb in 0..1
function xyz_to_rgb(x, y, z)
	-- Applying linear transformation using the XYZ to RGB transformation matrix.
	local r = x * 0.032404541621141049051 + y * -0.015371385127977165753 + z * -0.004985314095560160079
	local g = x * -0.009692660305051867686 + y * 0.018760108454466942288 + z * 0.00041556017530349983
	local b = x * 0.000556434309591145522 + y * -0.002040259135167538416 + z * 0.010572251882231790398

	-- Apply gamma correction.
	if r < 0.003130668442500634 then x = 12.92 * r else x = 1.055 * r ^ (1.0 / 2.4) - 0.055 end
	if g < 0.003130668442500634 then y = 12.92 * g else y = 1.055 * g ^ (1.0 / 2.4) - 0.055 end
	if b < 0.003130668442500634 then z = 12.92 * b else z = 1.055 * b ^ (1.0 / 2.4) - 0.055 end

	return r, g, b
end

-- rgb in 0..1
function lab_to_rgb(l, a, b)
	local x, y, z = lab_to_xyz(l, a, b)
	return xyz_to_rgb(x, y, z)
end

-- rgb in 0..255
function hex_to_rgb(hex)
	hex = hex:sub(2)
	if #hex == 3 then
		-- Also support the short syntax (ie "#FFF") as input.
		local r = tonumber(hex:sub(1,1) .. hex:sub(1,1), 16)
		local g = tonumber(hex:sub(2,2) .. hex:sub(2,2), 16)
		local b = tonumber(hex:sub(3,3) .. hex:sub(3,3), 16)
		return r, g, b
	end
	local r = tonumber(hex:sub(1,2), 16)
	local g = tonumber(hex:sub(3,4), 16)
	local b = tonumber(hex:sub(5,6), 16)
	return r, g, b
end

-- rgb in 0..255
function rgb_to_hex(r, g, b)
	local n = string.format("#%06x", r * 65536 + g * 256 + b)
	if n:sub(2, 2) ==  n:sub(3, 3) and n:sub(4, 4) ==  n:sub(5, 5) and n:sub(6, 6) ==  n:sub(7, 7) then
		-- Also provide the short syntax (ie "#FFF") as output.
		return "#" .. n:sub(2, 2) .. n:sub(4, 4) .. n:sub(6, 6)
	end
	return n
end

-- GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching

-- Constants used in Color Conversion :
-- 216.0 / 24389.0 = 0.0088564516790356308171716757554635286399606379925376194185903481077
-- 841.0 / 108.0 = 7.78703703703703703703703703703703703703703703703703703703703703703703703703
-- 4.0 / 29.0 = 0.13793103448275862068965517241379310344827586206896551724137931034482758620
-- 24389.0 / 27.0 = 903.296296296296296296296296296296296296296296296296296296296296296296296296
-- 1.0 / 2.4 = 0.41666666666666666666666666666666666666666666666666666666666666666666666666
-- To get 0.040448236277105097132567243294938 we perform x/12.92 = ((x+0.055)/1.055)^2.4
-- To get 0.00313066844250063403284123841596 we perform 12.92*x = 1.055*x^(1/2.4)-0.055
