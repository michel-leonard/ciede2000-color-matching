local socket = require("socket")
local start_time = socket.gettime()

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
		-- Sharma's implementation delete the next line and uncomment the one after it,
		-- this can lead to a discrepancy of ±0.0003 in the final color difference.
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
	-- Returns the square root so that the DeltaE 2000 reflects the actual geometric
	-- distance within the color space, which ranges from 0 to approximately 185.
	return math.sqrt(l * l + h * h + c * c + c * h * r_t);
end

-- GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
--  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

-- L1 = 41.1779        a1 = -101.8         b1 = -41.14
-- L2 = 46.0           a2 = -98.16         b2 = -41.14
-- CIE ΔE2000 = ΔE00 = 4.53475639259

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-----------------------                        ---------------------------
-----------------------        TESTING         ---------------------------
-----------------------                        ---------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------

-- The verification is performed here in LuaJIT.
-- It reads the CSV data from STDIN and prints a completion message.

local tolerance = 1e-10
local success, error_count, max_diff = 0, 0, 0.0
local error_lines = {}
local line, last_line = nil, nil

for line in io.lines() do
	last_line = line
	local l1, a1, b1, l2, a2, b2, ref = line:match("^([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),(.+)$")
	l1, a1, b1, l2, a2, b2, ref = tonumber(l1), tonumber(a1), tonumber(b1), tonumber(l2), tonumber(a2), tonumber(b2), tonumber(ref)
	local result = ciede_2000(l1, a1, b1, l2, a2, b2)
	local diff = math.abs(result - ref)
	if diff > -math.huge and diff < math.huge then
		if diff > max_diff then max_diff = diff end
		if diff > tolerance then
			error_count = error_count + 1
			if #error_lines < 10 then
				table.insert(error_lines, string.format("Error: expected %.17g, got %.17g (diff = %.17g)", ref, result, diff))
			end
		else
			success = success + 1
		end
	end
end

local duration = socket.gettime() - start_time

if #error_lines > 0 then
	for _, msg in ipairs(error_lines) do print(msg) end
end

print(string.format("\nCIEDE2000 Verification Summary :"))
print(string.format("- Last Verified Line : %s", last_line or "N/A"))
print(string.format("- Duration : %.2f s", duration))
print(string.format("- Successes : %d", success))
print(string.format("- Errors : %d", error_count))
print(string.format("- Maximum Difference : %.17g", max_diff))

-- Dependencies :
-- sudo apt-get update && sudo apt-get install -y luajit luarocks
-- sudo luarocks install luasocket
