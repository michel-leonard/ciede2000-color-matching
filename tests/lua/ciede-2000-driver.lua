-- Limited Use License – March 1, 2025

-- This source code is provided for public use under the following conditions :
-- It may be downloaded, compiled, and executed, including in publicly accessible environments.
-- Modification is strictly prohibited without the express written permission of the author.

-- © Michel Leonard 2025

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
	-- hypot from Lua 5.4, rather than sqrt used here can calculate
	-- Euclidean distance while avoiding overflow/underflow.
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
		if 0.0 < h_d then
			h_d = h_d - math.pi;
		else
			h_d = h_d + math.pi;
		end
		h_m = h_m + math.pi;
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
	-- Returns the square root so that the Delta E 2000 reflects the actual geometric
	-- distance within the color space, which ranges from 0 to approximately 185.
	return math.sqrt(l * l + h * h + c * c + c * h * r_t);
end

-- GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
--  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

-- L1 = 35.0188        a1 = 114.0          b1 = 64.0
-- L2 = 68.917         a2 = -81.65         b2 = -57.11
-- CIE ΔE2000 = ΔE00 = 126.01007120932

-------------------------------------------------
-------------------------------------------------
------------                         ------------
------------    CIEDE2000 Driver     ------------
------------                         ------------
-------------------------------------------------
-------------------------------------------------

-- Reads a CSV file specified as the first command-line argument. For each line, the program
-- outputs the original line with the computed Delta E 2000 color difference appended.

--  Example of a CSV input line : 67.24,-14.22,70,65,8,46
--    Corresponding output line : 67.24,-14.22,70,65,8,46,15.46723547943141064

local input_filename = arg[1]
if input_filename then
	local file = io.open(input_filename, "r")
	-- Old Lua may not support 'io.lines(file)', so we use this form.
	for line in file:lines() do
		local L1, a1, b1, L2, a2, b2 = line:match("([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+)")
		L1, a1, b1 = tonumber(L1), tonumber(a1), tonumber(b1)
		L2, a2, b2 = tonumber(L2), tonumber(a2), tonumber(b2)
		local delta_e = ciede_2000(L1, a1, b1, L2, a2, b2)
		io.write(string.format("%s,%.17g\n", line, delta_e))
	end
	file:close()
end
