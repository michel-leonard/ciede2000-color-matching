-- This function written in Ada is not affiliated with the CIE (International Commission on Illumination),
-- and is released into the public domain. It is provided "as is" without any warranty, express or implied.

with Ada.Numerics.Generic_Elementary_Functions;

-- The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
-- "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
function ciede_2000 (l_1, a_1, b_1, l_2, a_2, b_2 : Long_Float) return Long_Float is
	package Math is new Ada.Numerics.Generic_Elementary_Functions (Long_Float);
	-- Working in Ada 2005 with the CIEDE2000 color-difference formula.
	-- k_l, k_c, k_h are parametric factors to be adjusted according to
	-- different viewing parameters such as textures, backgrounds...
	k_l : constant Long_Float := 1.0;
	k_c : constant Long_Float := 1.0;
	k_h : constant Long_Float := 1.0;
	m_pi : constant Long_Float := Ada.Numerics.Pi;
	n, c_1, c_2, h_1, h_2, h_m, h_d, p, r_t, l, t, h, c: Long_Float;
begin
	n := (Math.Sqrt(a_1 * a_1 + b_1 * b_1) + Math.Sqrt(a_2 * a_2 + b_2 * b_2)) * 0.5;
	n := n * n * n * n * n * n * n;
	-- A factor involving chroma raised to the power of 7 designed to make
	-- the influence of chroma on the total color difference more accurate.
	n := 1.0 + 0.5 * (1.0 - Math.Sqrt(n / (n + 6103515625.0)));
	-- Application of the chroma correction factor.
	c_1 := Math.Sqrt(a_1 * a_1 * n * n + b_1 * b_1);
	c_2 := Math.Sqrt(a_2 * a_2 * n * n + b_2 * b_2);
	-- atan2 is preferred over atan because it accurately computes the angle of
	-- a point (x, y) in all quadrants, handling the signs of both coordinates.
	if (a_1 /= 0.0) or (b_1 /= 0.0) then
		h_1 := Math.Arctan(b_1, a_1 * n);
		if h_1 < 0.0 then h_1 := h_1 + 2.0 * m_pi; end if;
	else h_1 := 0.0; end if;
	if (a_2 /= 0.0) or (b_2 /= 0.0) then
		h_2 := Math.Arctan(b_2, a_2 * n);
		if h_2 < 0.0 then h_2 := h_2 + 2.0 * m_pi; end if;
	else h_2 := 0.0; end if;
	if h_1 < h_2 then n := h_2 - h_1; else n := h_1 - h_2; end if;
	-- Cross-implementation consistent rounding.
	if m_pi - 1.0E-14 < n and n < m_pi + 1.0E-14 then
		n := m_pi;
	end if;
	-- When the hue angles lie in different quadrants, the straightforward
	-- average can produce a mean that incorrectly suggests a hue angle in
	-- the wrong quadrant, the next lines handle this issue.
	h_m := (h_1 + h_2) * 0.5;
	h_d := (h_2 - h_1) * 0.5;
	if m_pi < n then
		h_d := h_d + m_pi;
		-- 📜 Sharma’s formulation doesn’t use the next line, but the one after it,
		-- and these two variants differ by ±0.0003 on the final color differences.
		h_m := h_m + m_pi;
		-- if h_m < m_pi then h_m := h_m + m_pi; else h_m := h_m - m_pi; end if;
	end if;
	p := 36.0 * h_m - 55.0 * m_pi;
	n := (c_1 + c_2) * 0.5;
	n := n * n * n * n * n * n * n;
	-- The hue rotation correction term is designed to account for the
	-- non-linear behavior of hue differences in the blue region.
	r_t := -2.0 *	Math.Sqrt(n / (n + 6103515625.0)) *
			Math.Sin(m_pi / 3.0 *
			Math.Exp(p * p / (-25.0 * m_pi * m_pi)));
	n := (l_1 + l_2) * 0.5;
	n := (n - 50.0) * (n - 50.0);
	-- Lightness.
	l := (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / Math.Sqrt(20.0 + n)));
	-- These coefficients adjust the impact of different harmonic
	-- components on the hue difference calculation.
	t := 1.0 +	0.24 * Math.Sin(2.0 * h_m + m_pi / 2.0) +
			0.32 * Math.Sin(3.0 * h_m + 8.0 * m_pi / 15.0) -
			0.17 * Math.Sin(h_m + m_pi / 3.0) -
			0.20 * Math.Sin(4.0 * h_m + 3.0 * m_pi / 20.0);
	n := c_1 + c_2;
	-- Hue.
	h := 2.0 * Math.Sqrt(c_1 * c_2) *
			Math.Sin(h_d) / (k_h * (1.0 + 0.0075 * n * t));
	-- Chroma.
	c := (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
	-- Returning the square root ensures that dE00 accurately reflects the
	-- geometric distance in color space, which can range from 0 to around 185.
	return Math.Sqrt(l * l + h * h + c * c + c * h * r_t);
end ciede_2000;

-- GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
--   Online Tests : https://michel-leonard.github.io/ciede2000-color-matching

-- L1 = 74.5   a1 = 47.9   b1 = 4.1
-- L2 = 74.8   a2 = 53.8   b2 = -4.2
-- CIE ΔE00 = 4.5097679907 (Bruce Lindbloom, Netflix’s VMAF, ...)
-- CIE ΔE00 = 4.5097525960 (Gaurav Sharma, OpenJDK, ...)
-- Deviation between implementations ≈ 1.5e-5

-- See the source code comments for easy switching between these two widely used ΔE*00 implementation variants.
