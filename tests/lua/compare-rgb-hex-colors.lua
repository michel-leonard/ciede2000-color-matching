-- This function written in Lua is not affiliated with the CIE (International Commission on Illumination),
-- and is released into the public domain. It is provided "as is" without any warranty, express or implied.

-- Calculates the CIE ΔE2000 color difference between two RGB or hex colors.
-- Accepts RGB values (0–255) and/or hex strings ("#fff" or "#ffffff").
-- Returns the Delta E 2000 value as a numerical difference.
function ciede_2000(r_1, g_1, b_1, r_2, g_2, b_2)
	-- Begin : Hex -> RGB
	if type(r_1) == "string" then
		if type(g_1) == "string" then
			if #g_1 == 4 then
				r_2 = tonumber(g_1:sub(2, 2) .. g_1:sub(2, 2), 16)
				g_2 = tonumber(g_1:sub(3, 3) .. g_1:sub(3, 3), 16)
				b_2 = tonumber(g_1:sub(4, 4) .. g_1:sub(4, 4), 16)
			else
				r_2 = tonumber(g_1:sub(2, 3), 16)
				g_2 = tonumber(g_1:sub(4, 5), 16)
				b_2 = tonumber(g_1:sub(6, 7), 16)
			end
		else
			b_2, g_2, r_2 = r_2, b_1, g_1
		end
		if #r_1 == 4 then
			b_1 = tonumber(r_1:sub(4, 4) .. r_1:sub(4, 4), 16)
			g_1 = tonumber(r_1:sub(3, 3) .. r_1:sub(3, 3), 16)
			r_1 = tonumber(r_1:sub(2, 2) .. r_1:sub(2, 2), 16)
		else
			b_1 = tonumber(r_1:sub(6, 7), 16)
			g_1 = tonumber(r_1:sub(4, 5), 16)
			r_1 = tonumber(r_1:sub(2, 3), 16)
		end
	elseif type(r_2) == "string" then
		if #r_2 == 4 then
			b_2 = tonumber(r_2:sub(4, 4) .. r_2:sub(4, 4), 16)
			g_2 = tonumber(r_2:sub(3, 3) .. r_2:sub(3, 3), 16)
			r_2 = tonumber(r_2:sub(2, 2) .. r_2:sub(2, 2), 16)
		else
			b_2 = tonumber(r_2:sub(6, 7), 16)
			g_2 = tonumber(r_2:sub(4, 5), 16)
			r_2 = tonumber(r_2:sub(2, 3), 16)
		end
	end
	-- End : Hex -> RGB
	-- Begin : RGB -> Lab
	r_1, g_1, b_1 = r_1 / 255.0, g_1 / 255.0, b_1 / 255.0
	r_2, g_2, b_2 = r_2 / 255.0, g_2 / 255.0, b_2 / 255.0
	if r_1 < 0.040448236277105097 then r_1 = r_1 / 12.92 else r_1 = ((r_1 + 0.055) / 1.055) ^ 2.4 end
	if r_2 < 0.040448236277105097 then r_2 = r_2 / 12.92 else r_2 = ((r_2 + 0.055) / 1.055) ^ 2.4 end
	if g_1 < 0.040448236277105097 then g_1 = g_1 / 12.92 else g_1 = ((g_1 + 0.055) / 1.055) ^ 2.4 end
	if g_2 < 0.040448236277105097 then g_2 = g_2 / 12.92 else g_2 = ((g_2 + 0.055) / 1.055) ^ 2.4 end
	if b_1 < 0.040448236277105097 then b_1 = b_1 / 12.92 else b_1 = ((b_1 + 0.055) / 1.055) ^ 2.4 end
	if b_2 < 0.040448236277105097 then b_2 = b_2 / 12.92 else b_2 = ((b_2 + 0.055) / 1.055) ^ 2.4 end

	-- Applying linear transformation using RGB to XYZ transformation matrix.
	local x_1 = (r_1 * 41.24564390896921145 + g_1 * 35.75760776439090507 + b_1 * 18.04374830853290341) / 95.047
	local x_2 = (r_2 * 41.24564390896921145 + g_2 * 35.75760776439090507 + b_2 * 18.04374830853290341) / 95.047
	local y_1 = (r_1 * 21.26728514056222474 + g_1 * 71.51521552878181013 + b_1 * 7.21749933075596513) / 100.0
	local y_2 = (r_2 * 21.26728514056222474 + g_2 * 71.51521552878181013 + b_2 * 7.21749933075596513) / 100.0
	local z_1 = (r_1 * 1.93338955823293176 + g_1 * 11.91919550818385936 + b_1 * 95.03040770337479886) / 108.883
	local z_2 = (r_2 * 1.93338955823293176 + g_2 * 11.91919550818385936 + b_2 * 95.03040770337479886) / 108.883

	-- Applying the CIE standard transformation.
	if x_1 < 216.0 / 24389.0 then x_1 = ((841.0 / 108.0) * x_1) + (4.0 / 29.0) else x_1 = x_1 ^ (1.0 / 3.0) end
	if x_2 < 216.0 / 24389.0 then x_2 = ((841.0 / 108.0) * x_2) + (4.0 / 29.0) else x_2 = x_2 ^ (1.0 / 3.0) end
	if y_1 < 216.0 / 24389.0 then y_1 = ((841.0 / 108.0) * y_1) + (4.0 / 29.0) else y_1 = y_1 ^ (1.0 / 3.0) end
	if y_2 < 216.0 / 24389.0 then y_2 = ((841.0 / 108.0) * y_2) + (4.0 / 29.0) else y_2 = y_2 ^ (1.0 / 3.0) end
	if z_1 < 216.0 / 24389.0 then z_1 = ((841.0 / 108.0) * z_1) + (4.0 / 29.0) else z_1 = z_1 ^ (1.0 / 3.0) end
	if z_2 < 216.0 / 24389.0 then z_2 = ((841.0 / 108.0) * z_2) + (4.0 / 29.0) else z_2 = z_2 ^ (1.0 / 3.0) end

	local l_1 = (116.0 * y_1) - 16.0
	local l_2 = (116.0 * y_2) - 16.0
	local a_1 = 500.0 * (x_1 - y_1)
	local a_2 = 500.0 * (x_2 - y_2)
	b_1 = 200.0 * (y_1 - z_1)
	b_2 = 200.0 * (y_2 - z_2)
	-- End : RGB -> Lab

	-- Working in Lua/LuaJIT with the CIEDE2000 color-difference formula.
	-- k_l, k_c, k_h are parametric factors to be adjusted according to
	-- different viewing parameters such as textures, backgrounds...
	local k_l, k_c, k_h = 1.0, 1.0, 1.0
	local n = (math.sqrt(a_1 * a_1 + b_1 * b_1) + math.sqrt(a_2 * a_2 + b_2 * b_2)) * 0.5
	n = n * n * n * n * n * n * n
	-- A factor involving chroma raised to the power of 7 designed to make
	-- the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - math.sqrt(n / (n + 6103515625.0)))
	-- Application of the chroma correction factor.
	local c_1 = math.sqrt(a_1 * a_1 * n * n + b_1 * b_1)
	local c_2 = math.sqrt(a_2 * a_2 * n * n + b_2 * b_2)
	-- atan2 is preferred over atan because it accurately computes the angle of
	-- a point (x, y) in all quadrants, handling the signs of both coordinates.
	local h_1 = math.atan2(b_1, a_1 * n)
	local h_2 = math.atan2(b_2, a_2 * n)
	if h_1 < 0.0 then h_1 = h_1 + 2.0 * math.pi end
	if h_2 < 0.0 then h_2 = h_2 + 2.0 * math.pi end
	n = math.abs(h_2 - h_1)
	-- Cross-implementation consistent rounding.
	if math.pi - 1E-14 < n and n < math.pi + 1E-14 then n = math.pi end
	-- When the hue angles lie in different quadrants, the straightforward
	-- average can produce a mean that incorrectly suggests a hue angle in
	-- the wrong quadrant, the next lines handle this issue.
	local h_m = (h_1 + h_2) * 0.5
	local h_d = (h_2 - h_1) * 0.5
	if math.pi < n then
		h_d = h_d + math.pi;
		-- 📜 Sharma’s formulation doesn’t use the next line, but the one after it,
		-- and these two variants differ by ±0.0003 on the final color differences.
		h_m = h_m + math.pi;
		-- h_m = h_m + (h_m < math.pi and math.pi or -math.pi)
	end
	local p = 36.0 * h_m - 55.0 * math.pi
	n = (c_1 + c_2) * 0.5
	n = n * n * n * n * n * n * n
	-- The hue rotation correction term is designed to account for the
	-- non-linear behavior of hue differences in the blue region.
	local r_t = -2.0 * math.sqrt(n / (n + 6103515625.0)) *
			math.sin(math.pi / 3.0 * math.exp(p * p / (-25.0 * math.pi * math.pi)))
	n = (l_1 + l_2) * 0.5
	n = (n - 50.0) * (n - 50.0)
	-- Lightness.
	local l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / math.sqrt(20.0 + n)))
	-- These coefficients adjust the impact of different harmonic
	-- components on the hue difference calculation.
	local t = 1.0	+ 0.24 * math.sin(2.0 * h_m + math.pi * 0.5)
			+ 0.32 * math.sin(3.0 * h_m + 8.0 * math.pi / 15.0)
			- 0.17 * math.sin(h_m + math.pi / 3.0)
			- 0.20 * math.sin(4.0 * h_m + 3.0 * math.pi / 20.0)
	n = c_1 + c_2
	-- Hue.
	local h = 2.0 * math.sqrt(c_1 * c_2) * math.sin(h_d) / (k_h * (1.0 + 0.0075 * n * t))
	-- Chroma.
	local c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n))
	-- Returning the square root ensures that dE00 accurately reflects the
	-- geometric distance in color space, which can range from 0 to around 185.
	return math.sqrt(l * l + h * h + c * c + c * h * r_t)
end

-- GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
--   Online Tests : https://michel-leonard.github.io/ciede2000-color-matching

-- L1 = 5.2    a1 = 17.6   b1 = -4.8
-- L2 = 4.1    a2 = 12.1   b2 = 3.6
-- CIE ΔE00 = 7.1225894510 (Bruce Lindbloom, Netflix’s VMAF, ...)
-- CIE ΔE00 = 7.1225751063 (Gaurav Sharma, OpenJDK, ...)
-- Deviation between implementations ≈ 1.4e-5

-- See the source code comments for easy switching between these two widely used ΔE*00 implementation variants.

----------------------------------------------------------------------
----------------------------------------------------------------------
-------------                                 ------------------------
-------------           RGB and Hex           ------------------------
-------------        Color Comparisons        ------------------------
-------------                                 ------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------

-- For reference, the maximum possible contrast between lime green (#9f0) and dark navy (#006) yields a ΔE2000 value of 119.
-- Lower values indicate more similar colors, making it easy to determine the closest match to a given color.

print(ciede_2000(238, 170, 17, 170, 17, 238))       -- Shows a ΔE2000 of 72.464679518244
print(ciede_2000(238, 170, 17, "#a1e"))             -- Shows a ΔE2000 of 72.464679518244
print(ciede_2000(238, 170, 17, "#aa11ee"))          -- Shows a ΔE2000 of 72.464679518244
print(ciede_2000("#ea1", 170, 17, 238))             -- Shows a ΔE2000 of 72.464679518244
print(ciede_2000("#eeaa11", 170, 17, 238))          -- Shows a ΔE2000 of 72.464679518244
print(ciede_2000("#ea1", "#a1e"))                   -- Shows a ΔE2000 of 72.464679518244
print(ciede_2000("#ea1", "#aa11ee"))                -- Shows a ΔE2000 of 72.464679518244
print(ciede_2000("#eeaa11", "#a1e"))                -- Shows a ΔE2000 of 72.464679518244
print(ciede_2000("#eeaa11", "#aa11ee"))             -- Shows a ΔE2000 of 72.464679518244
