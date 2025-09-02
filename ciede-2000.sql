-- This function written in SQL is not affiliated with the CIE (International Commission on Illumination),
-- and is released into the public domain. It is provided "as is" without any warranty, express or implied.

DELIMITER //

-- Delete any function of the same name that already exists
DROP FUNCTION IF EXISTS ciede_2000 //

-- The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
-- "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
CREATE FUNCTION ciede_2000(l_1 DOUBLE, a_1 DOUBLE, b_1 DOUBLE, l_2 DOUBLE, a_2 DOUBLE, b_2 DOUBLE)
RETURNS DOUBLE
DETERMINISTIC
NO SQL
BEGIN
	-- Working in SQL/PSM with the CIEDE2000 color-difference formula.
	-- k_l, k_c, k_h are parametric factors to be adjusted according to
	-- different viewing parameters such as textures, backgrounds...
	DECLARE k_l, k_c, k_h DOUBLE DEFAULT 1.0;
	DECLARE n, c_1, c_2, h_1, h_2, h_m, h_d, r_t, p, t, l, c, h DOUBLE;

	SET n = (SQRT(a_1 * a_1 + b_1 * b_1) + SQRT(a_2 * a_2 + b_2 * b_2)) * 0.5;
	SET n = n * n * n * n * n * n * n;
	-- A factor involving chroma raised to the power of 7 designed to make
	-- the influence of chroma on the total color difference more accurate.
	SET n = 1.0 + 0.5 * (1.0 - SQRT(n / (n + 6103515625.0)));
	-- Application of the chroma correction factor.
	SET c_1 = SQRT(a_1 * a_1 * n * n + b_1 * b_1);
	SET c_2 = SQRT(a_2 * a_2 * n * n + b_2 * b_2);
	-- atan2 is preferred over atan because it accurately computes the angle of
	-- a point (x, y) in all quadrants, handling the signs of both coordinates.
	SET h_1 = COALESCE(ATAN2(b_1, a_1 * n), 0);
	SET h_2 = COALESCE(ATAN2(b_2, a_2 * n), 0);
	IF h_1 < 0 THEN SET h_1 = h_1 + 2 * PI(); END IF;
	IF h_2 < 0 THEN SET h_2 = h_2 + 2 * PI(); END IF;
	SET n = ABS(h_2 - h_1);
	-- Cross-implementation consistent rounding.
	IF PI() - 1E-14 < n AND n < PI() + 1E-14 THEN SET n = PI(); END IF;
	-- When the hue angles lie in different quadrants, the straightforward
	-- average can produce a mean that incorrectly suggests a hue angle in
	-- the wrong quadrant, the next lines handle this issue.
	SET h_m = (h_1 + h_2) * 0.5;
	SET h_d = (h_2 - h_1) * 0.5;
	IF PI() < n THEN
		SET h_d = h_d + PI();
		-- 📜 Sharma’s formulation doesn’t use the next line, but the one after it,
		-- and these two variants differ by ±0.0003 on the final color differences.
		SET h_m = h_m + PI();
		-- SET h_m = h_m + CASE WHEN h_m < PI() THEN PI() ELSE -PI() END;
	END IF;
	SET p = 36.0 * h_m - 55.0 * PI();
	SET n = (c_1 + c_2) * 0.5;
	SET n = n * n * n * n * n * n * n;
	-- The hue rotation correction term is designed to account for the
	-- non-linear behavior of hue differences in the blue region.
	SET r_t = -2.0 * SQRT(n / (n + 6103515625.0)) * SIN(PI() / 3.0 * EXP(p * p / (-25.0 * PI() * PI())));
	SET n = (l_1 + l_2) * 0.5;
	SET n = (n - 50.0) * (n - 50.0);
	-- Lightness.
	SET l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / SQRT(20.0 + n)));
	-- These coefficients adjust the impact of different harmonic
	-- components on the hue difference calculation.
	SET t = 1.0	+ 0.24 * SIN(2.0 * h_m + PI() * 0.5)
			+ 0.32 * SIN(3.0 * h_m + 8.0 * PI() / 15.0)
			- 0.17 * SIN(h_m + PI() / 3.0)
			- 0.20 * SIN(4.0 * h_m + 3.0 * PI() / 20.0);
	SET n = c_1 + c_2;
	-- Hue.
	SET h = 2.0 * SQRT(c_1 * c_2) * SIN(h_d) / (k_h * (1.0 + 0.0075 * n * t));
	-- Chroma.
	SET c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
	-- Returning the square root ensures that dE00 accurately reflects the
	-- geometric distance in color space, which can range from 0 to around 185.
	RETURN SQRT(l * l + h * h + c * c + c * h * r_t);
END //

DELIMITER ;

-- GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
--   Online Tests : https://michel-leonard.github.io/ciede2000-color-matching

-- L1 = 52.3   a1 = 21.9   b1 = 2.7
-- L2 = 53.8   a2 = 28.0   b2 = -3.1
-- CIE ΔE00 = 5.0119430211 (Bruce Lindbloom, Netflix’s VMAF, ...)
-- CIE ΔE00 = 5.0119254601 (Gaurav Sharma, OpenJDK, ...)
-- Deviation between implementations ≈ 1.8e-5

-- See the source code comments for easy switching between these two widely used ΔE*00 implementation variants.
