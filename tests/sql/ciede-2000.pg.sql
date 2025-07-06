-- This function written in SQL is not affiliated with the CIE (International Commission on Illumination),
-- and is released into the public domain. It is provided "as is" without any warranty, express or implied.

-- The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
-- "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
CREATE OR REPLACE FUNCTION ciede_2000(
  l_1 DOUBLE PRECISION,
  a_1 DOUBLE PRECISION,
  b_1 DOUBLE PRECISION,
  l_2 DOUBLE PRECISION,
  a_2 DOUBLE PRECISION,
  b_2 DOUBLE PRECISION
)
RETURNS DOUBLE PRECISION
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
	-- Working in PostgreSQL with the CIEDE2000 color-difference formula.
	-- k_l, k_c, k_h are parametric factors to be adjusted according to
	-- different viewing parameters such as textures, backgrounds...
	k_l DOUBLE PRECISION := 1.0;
	k_c DOUBLE PRECISION := 1.0;
	k_h DOUBLE PRECISION := 1.0;
	n DOUBLE PRECISION;
	c_1 DOUBLE PRECISION;
	c_2 DOUBLE PRECISION;
	h_1 DOUBLE PRECISION;
	h_2 DOUBLE PRECISION;
	h_m DOUBLE PRECISION;
	h_d DOUBLE PRECISION;
	r_t DOUBLE PRECISION;
	p DOUBLE PRECISION;
	t DOUBLE PRECISION;
	l DOUBLE PRECISION;
	c DOUBLE PRECISION;
	h DOUBLE PRECISION;
BEGIN
	n := (SQRT(a_1 * a_1 + b_1 * b_1) + SQRT(a_2 * a_2 + b_2 * b_2)) * 0.5;
	n := n * n * n * n * n * n * n;
	-- A factor involving chroma raised to the power of 7 designed to make
	-- the influence of chroma on the total color difference more accurate.
	n := 1.0 + 0.5 * (1.0 - SQRT(n / (n + 6103515625.0)));
	-- Since hypot is not available, sqrt is used here to calculate the
	-- Euclidean distance, without avoiding overflow/underflow.
	c_1 := SQRT(a_1 * a_1 * n * n + b_1 * b_1);
	c_2 := SQRT(a_2 * a_2 * n * n + b_2 * b_2);
	-- atan2 is preferred over atan because it accurately computes the angle of
	-- a point (x, y) in all quadrants, handling the signs of both coordinates.
	h_1 := COALESCE(ATAN2(b_1, a_1 * n), 0);
	h_2 := COALESCE(ATAN2(b_2, a_2 * n), 0);
	IF h_1 < 0 THEN h_1 := h_1 + 2 * PI(); END IF;
	IF h_2 < 0 THEN h_2 := h_2 + 2 * PI(); END IF;
	n := ABS(h_2 - h_1);
	-- Cross-implementation consistent rounding.
	IF PI() - 1E-14 < n AND n < PI() + 1E-14 THEN n := PI(); END IF;
	-- When the hue angles lie in different quadrants, the straightforward
	-- average can produce a mean that incorrectly suggests a hue angle in
	-- the wrong quadrant, the next lines handle this issue.
	h_m := (h_1 + h_2) * 0.5;
	h_d := (h_2 - h_1) * 0.5;
	IF PI() < n THEN
		IF 0.0 < h_d THEN
			h_d := h_d - PI();
		ELSE
			h_d := h_d + PI();
		END IF;
		h_m := h_m + PI();
	END IF;
	p := 36.0 * h_m - 55.0 * PI();
	n := (c_1 + c_2) * 0.5;
	n := n * n * n * n * n * n * n;
	-- The hue rotation correction term is designed to account for the
	-- non-linear behavior of hue differences in the blue region.
	r_t := -2.0 * SQRT(n / (n + 6103515625.0)) * SIN(PI() / 3.0 * EXP(p * p / (-25.0 * PI() * PI())));
	n := (l_1 + l_2) * 0.5;
	n := (n - 50.0) * (n - 50.0);
	-- Lightness.
	l := (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / SQRT(20.0 + n)));
	-- These coefficients adjust the impact of different harmonic
	-- components on the hue difference calculation.
	t := 1.0	+ 0.24 * SIN(2.0 * h_m + PI() * 0.5)
			+ 0.32 * SIN(3.0 * h_m + 8.0 * PI() / 15.0)
			- 0.17 * SIN(h_m + PI() / 3.0)
			- 0.20 * SIN(4.0 * h_m + 3.0 * PI() / 20.0);
	n := c_1 + c_2;
	-- Hue.
	h := 2.0 * SQRT(c_1 * c_2) * SIN(h_d) / (k_h * (1.0 + 0.0075 * n * t));
	-- Chroma.
	c := (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
	-- Returns the square root so that the DeltaE 2000 reflects the actual geometric
	-- distance within the color space, which ranges from 0 to approximately 185.
	RETURN SQRT(l * l + h * h + c * c + c * h * r_t);
END;
$$;

-- GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
--  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

-- L1 = 4.9957         a1 = -101.8049      b1 = 4.383
-- L2 = 20.9781        a2 = -96.14         b2 = -50.0756
-- CIE ΔE2000 = ΔE00 = 24.0682668901
