-- This function written in Lua is not affiliated with the CIE (International Commission on Illumination),
-- and is released into the public domain. It is provided "as is" without any warranty, express or implied.

-- The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
-- "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
function ciede_2000(l_1, a_1, b_1, l_2, a_2, b_2)
	-- Working in Lua/LuaJIT with the CIEDE2000 color-difference formula.
	-- k_l, k_c, k_h are parametric factors to be adjusted according to
	-- different viewing parameters such as textures, backgrounds...
	local k_l, k_c, k_h = 1.0, 1.0, 1.0;
	local n = (math.sqrt(a_1 * a_1 + b_1 * b_1) + math.sqrt(a_2 * a_2 + b_2 * b_2)) * 0.5;
	n = n * n * n * n * n * n * n;
	-- A factor involving chroma raised to the power of 7 designed to make
	-- the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - math.sqrt(n / (n + 6103515625.0)));
	-- Application of the chroma correction factor.
	local c_1 = math.sqrt(a_1 * a_1 * n * n + b_1 * b_1);
	local c_2 = math.sqrt(a_2 * a_2 * n * n + b_2 * b_2);
	-- atan2 is preferred over atan because it accurately computes the angle of
	-- a point (x, y) in all quadrants, handling the signs of both coordinates.
	local h_1 = math.atan2(b_1, a_1 * n);
	local h_2 = math.atan2(b_2, a_2 * n);
	if h_1 < 0.0 then h_1 = h_1 + 2.0 * math.pi end;
	if h_2 < 0.0 then h_2 = h_2 + 2.0 * math.pi end;
	n = math.abs(h_2 - h_1);
	-- Cross-implementation consistent rounding.
	if math.pi - 1E-14 < n and n < math.pi + 1E-14 then n = math.pi end;
	-- When the hue angles lie in different quadrants, the straightforward
	-- average can produce a mean that incorrectly suggests a hue angle in
	-- the wrong quadrant, the next lines handle this issue.
	local h_m = (h_1 + h_2) * 0.5;
	local h_d = (h_2 - h_1) * 0.5;
	if math.pi < n then
		h_d = h_d + math.pi;
		-- 📜 Sharma’s formulation doesn’t use the next line, but the one after it,
		-- and these two variants differ by ±0.0003 on the final color differences.
		h_m = h_m + math.pi;
		-- h_m = h_m + (h_m < math.pi and math.pi or -math.pi)
	end
	local p = 36.0 * h_m - 55.0 * math.pi;
	n = (c_1 + c_2) * 0.5;
	n = n * n * n * n * n * n * n;
	-- The hue rotation correction term is designed to account for the
	-- non-linear behavior of hue differences in the blue region.
	local r_t = -2.0 * math.sqrt(n / (n + 6103515625.0)) *
			math.sin(math.pi / 3.0 * math.exp(p * p / (-25.0 * math.pi * math.pi)));
	n = (l_1 + l_2) * 0.5;
	n = (n - 50.0) * (n - 50.0);
	-- Lightness.
	local l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / math.sqrt(20.0 + n)));
	-- These coefficients adjust the impact of different harmonic
	-- components on the hue difference calculation.
	local t = 1.0	+ 0.24 * math.sin(2.0 * h_m + math.pi * 0.5)
			+ 0.32 * math.sin(3.0 * h_m + 8.0 * math.pi / 15.0)
			- 0.17 * math.sin(h_m + math.pi / 3.0)
			- 0.20 * math.sin(4.0 * h_m + 3.0 * math.pi / 20.0);
	n = c_1 + c_2;
	-- Hue.
	local h = 2.0 * math.sqrt(c_1 * c_2) * math.sin(h_d) / (k_h * (1.0 + 0.0075 * n * t));
	-- Chroma.
	local c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
	-- Returning the square root ensures that dE00 accurately reflects the
	-- geometric distance in color space, which can range from 0 to around 185.
	return math.sqrt(l * l + h * h + c * c + c * h * r_t);
end

-- GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
--   Online Tests : https://michel-leonard.github.io/ciede2000-color-matching

-- L1 = 80.4   a1 = 36.9   b1 = 2.0
-- L2 = 80.1   a2 = 31.5   b2 = -1.5
-- CIE ΔE00 = 2.9797302847 (Bruce Lindbloom, Netflix’s VMAF, ...)
-- CIE ΔE00 = 2.9797437485 (Gaurav Sharma, OpenJDK, ...)
-- Deviation between implementations ≈ 1.3e-5

-- See the source code comments for easy switching between these two widely used ΔE*00 implementation variants.

-----------------------------------------------
-----------------------------------------------
-------                                 -------
-------           CIEDE 2000            -------
-------      Testing Random Colors      -------
-------                                 -------
-----------------------------------------------
-----------------------------------------------

-- This Lua/LuaJIT program outputs a CSV file to standard output, with its length determined by the first CLI argument.
-- Each line contains seven columns :
-- - Three columns for the random standard L*a*b* color
-- - Three columns for the random sample L*a*b* color
-- - And the seventh column for the precise Delta E 2000 color difference between the standard and sample
-- The output will be correct, this can be verified :
-- - With the C driver, which provides a dedicated verification feature
-- - By using the JavaScript validator at https://michel-leonard.github.io/ciede2000-color-matching

local n_iterations = 10000.0
if #arg > 0 then
	n_iterations = tonumber(arg[1]) or 10000
end
if n_iterations < 1 then
	n_iterations = 10000.0
end

math.randomseed(os.time())

for i = 1, n_iterations do
	local l_1 = math.random(0, 10000) / 100.0
	local a_1 = math.random(-12800, 12800) / 100.0
	local b_1 = math.random(-12800, 12800) / 100.0
	local l_2 = math.random(0, 10000) / 100.0
	local a_2 = math.random(-12800, 12800) / 100.0
	local b_2 = math.random(-12800, 12800) / 100.0

	local delta_e = ciede_2000(l_1, a_1, b_1, l_2, a_2, b_2)
	print(string.format("%g,%g,%g,%g,%g,%g,%.17g", l_1, a_1, b_1, l_2, a_2, b_2, delta_e))
end
