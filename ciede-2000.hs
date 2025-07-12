-- This function written in Haskell is not affiliated with the CIE (International Commission on Illumination),
-- and is released into the public domain. It is provided "as is" without any warranty, express or implied.

-- The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
-- "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
ciede_2000 :: Double -> Double -> Double -> Double -> Double -> Double -> Double
ciede_2000 l_1 a_1 b_1 l_2 a_2 b_2 =
  -- Working in Haskell with the CIEDE2000 color-difference formula.
  -- k_l, k_c, k_h are parametric factors to be adjusted according to
  -- different viewing parameters such as textures, backgrounds...
  let
    k_l = 1.0
    k_c = 1.0
    k_h = 1.0
    n = (\() ->
      let
        x = (sqrt(a_1 * a_1 + b_1 * b_1) + sqrt(a_2 * a_2 + b_2 * b_2)) * 0.5
      -- A factor involving chroma raised to the power of 7 designed to make
      -- the influence of chroma on the total color difference more accurate.
        y = x * x * x * x * x * x * x
      in 1.0 + 0.5 * (1.0 - sqrt(y / (y + 6103515625.0)))
      )()
    -- Application of the chroma correction factor.
    -- Euclidean distance while avoiding overflow/underflow.
    c_1 = sqrt(a_1 * a_1 * n * n + b_1 * b_1)
    c_2 = sqrt(a_2 * a_2 * n * n + b_2 * b_2)
    -- atan2 is preferred over atan because it accurately computes the angle of
    -- a point (x, y) in all quadrants, handling the signs of both coordinates.
    h_1 = (\() -> let x = atan2 b_1 (a_1 * n) in if x < 0.0 then x + 2.0 * pi else x)()
    h_2 = (\() -> let x = atan2 b_2 (a_2 * n) in if x < 0.0 then x + 2.0 * pi else x)()
    -- Cross-implementation consistent rounding.
    n_0 = (\() -> let x = abs(h_2 - h_1) in if pi - 1E-14 < x && x < pi + 1E-14 then pi else x)()
    -- When the hue angles lie in different quadrants, the straightforward
    -- average can produce a mean that incorrectly suggests a hue angle in
    -- the wrong quadrant, the next lines handle this issue.
    h_m = (\() ->
      let
        x = (h_1 + h_2) * 0.5
        -- Sharma's implementation delete the next line and uncomment the one after it,
        -- this can lead to a discrepancy of ±0.0003 in the final color difference.
        in if pi < n_0 then x + pi else x
        -- in if pi < n_0 then if x < pi then x + pi else x - pi else x
      )()
    h_d = (\() ->
      let
        x = (h_2 - h_1) * 0.5
        in if pi < n_0 then x + pi else x
      )()
    p = 36.0 * h_m - 55.0 * pi
    n_2 = (\() -> let x = (c_1 + c_2) * 0.5 in x * x * x * x * x * x * x)()
    -- The hue rotation correction term is designed to account for the
    -- non-linear behavior of hue differences in the blue region.
    r_t = -2.0 * sqrt(n_2 / (n_2 + 6103515625.0))
                    * sin(pi / 3.0 * exp(p * p / (-25.0 * pi * pi)))
    n_3 = (\() -> let x = (l_1 + l_2) * 0.5 in (x - 50.0) * (x - 50.0))()
    -- Lightness.
    l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n_3 / sqrt(20.0 + n_3)))
    -- These coefficients adjust the impact of different harmonic
    -- components on the hue difference calculation.
    t = 1.0 + 0.24 * sin(2.0 * h_m + pi * 0.5)
            + 0.32 * sin(3.0 * h_m + 8.0 * pi / 15.0)
            - 0.17 * sin(h_m + pi / 3.0)
            - 0.20 * sin(4.0 * h_m + 3.0 * pi / 20.0)
    n_4 = c_1 + c_2
    -- Hue.
    h = 2.0 * sqrt(c_1 * c_2) * sin(h_d) / (k_h * (1.0 + 0.0075 * n_4 * t))
    -- Chroma.
    c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n_4))
    -- Returns the square root so that the DeltaE 2000 reflects the actual geometric
    -- distance within the color space, which ranges from 0 to approximately 185.
    in sqrt(l * l + h * h + c * c + c * h * r_t)

-- GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
--  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

-- L1 = 35.83          a1 = -28.9          b1 = -98.33
-- L2 = 35.83          a2 = -21.6542       b2 = -98.33
-- CIE ΔE2000 = ΔE00 = 2.66540202112
