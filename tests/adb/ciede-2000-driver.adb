-- Limited Use License – March 1, 2025

-- This source code is provided for public use under the following conditions :
-- It may be downloaded, compiled, and executed, including in publicly accessible environments.
-- Modification is strictly prohibited without the express written permission of the author.

-- © Michel Leonard 2025

with Ada.Numerics.Generic_Elementary_Functions;

with Ada.Text_IO; use Ada.Text_IO;
with Ada.Strings.Fixed;
with Ada.Command_Line; use Ada.Command_Line;

procedure main is
	package Prints is new Ada.Text_IO.Float_IO(Long_Float);
	Length, C1, C2, C3, C4, C5 : Positive;
	Fp : File_Type;
	Line : String (1 .. 255);
	dE : Long_Float;
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
		if m_pi - 1.0E-14 < n and n < m_pi + 1.0E-14 then n := m_pi; end if;
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

-- L1 = 2.8    a1 = 19.5   b1 = -4.8
-- L2 = 0.8    a2 = 13.7   b2 = 3.7
-- CIE ΔE00 = 7.0964533576 (Bruce Lindbloom, Netflix’s VMAF, ...)
-- CIE ΔE00 = 7.0964362951 (Gaurav Sharma, OpenJDK, ...)
-- Deviation between implementations ≈ 1.7e-5

-- See the source code comments for easy switching between these two widely used ΔE*00 implementation variants.

	-------------------------------------------------
	-------------------------------------------------
	------------                         ------------
	------------    CIEDE2000 Driver     ------------
	------------                         ------------
	-------------------------------------------------
	-------------------------------------------------

	-- Reads a CSV file specified as the first command-line argument. For each line, this program
	-- in Ada displays the original line with the computed Delta E 2000 color difference appended.
	-- The C driver can offer CSV files to process and programmatically check the calculations performed there.

	--  Example of a CSV input line : 28,122,15,40.2,125,-37.9
	--    Corresponding output line : 28,122,15,40.2,125,-37.9,17.528835421095888274631273073596

	begin

		if Argument_Count < 1 then
			Put_Line("It takes a CSV filename as first parameter.");
		else
			Open (File => Fp, Mode => In_File, Name => Argument(1));
				while not End_Of_File(Fp) loop
					Get_Line(File => Fp, Item => Line, Last => Length);
					C1 := Ada.Strings.Fixed.Index(Line, ",", 1);
					C2 := Ada.Strings.Fixed.Index(Line, ",", C1 + 1);
					C3 := Ada.Strings.Fixed.Index(Line, ",", C2 + 1);
					C4 := Ada.Strings.Fixed.Index(Line, ",", C3 + 1);
					C5 := Ada.Strings.Fixed.Index(Line, ",", C4 + 1);
					dE := ciede_2000(
						Long_Float'Value(Line(1 .. C1 - 1)),
						Long_Float'Value(Line(C1 + 1 .. C2 - 1)),
						Long_Float'Value(Line(C2 + 1 .. C3 - 1)),
						Long_Float'Value(Line(C3 + 1 .. C4 - 1)),
						Long_Float'Value(Line(C4 + 1 .. C5 - 1)),
						Long_Float'Value(Line(C5 + 1 .. Length))
					);
					Put(Line(1 .. Length) & ",");
					Prints.Put(Item => dE, Fore => 0, Aft => 15, Exp => 0);
					New_Line;
				end loop;
			Close(Fp);
		end if;

end main;
