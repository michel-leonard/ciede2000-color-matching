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
    -- Since hypot is not available, sqrt is used here to calculate the
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
        in if pi < n_0 then x + pi else x
      )()
    h_d = (\() ->
      let
        x = (h_2 - h_1) * 0.5
        in if pi < n_0 then if 0.0 < x then x - pi else x + pi else x
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
    -- Returns the square root so that the Delta E 2000 reflects the actual geometric
    -- distance within the color space, which ranges from 0 to approximately 185.
    in sqrt(l * l + h * h + c * c + c * h * r_t)

-- GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
--  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

-- L1 = 36.57          a1 = -119.164       b1 = -80.0
-- L2 = 36.59          a2 = -119.164       b2 = -80.0
-- CIE ΔE2000 = ΔE00 = 0.01679296291

-- L1 = 40.198         a1 = -50.493        b1 = 32.3372
-- L2 = 40.198         a2 = -47.58         b2 = 32.3372
-- CIE ΔE2000 = ΔE00 = 0.98352809818

-- L1 = 23.7           a1 = 93.614         b1 = -11.0
-- L2 = 23.7           a2 = 95.9776        b2 = -16.2198
-- CIE ΔE2000 = ΔE00 = 1.69183810269

-- L1 = 35.83          a1 = -28.9          b1 = -98.33
-- L2 = 35.83          a2 = -21.6542       b2 = -98.33
-- CIE ΔE2000 = ΔE00 = 2.66540202112

-- L1 = 47.949         a1 = -58.1          b1 = -32.0
-- L2 = 47.949         a2 = -58.1          b2 = -22.425
-- CIE ΔE2000 = ΔE00 = 4.31000399877

-- L1 = 69.659         a1 = -95.1          b1 = 43.663
-- L2 = 76.6           a2 = -84.89         b2 = 45.0
-- CIE ΔE2000 = ΔE00 = 5.72706568449

-- L1 = 27.0126        a1 = -27.0          b1 = 41.8
-- L2 = 30.3           a2 = -30.0          b2 = 21.987
-- CIE ΔE2000 = ΔE00 = 9.7365360327

-- L1 = 32.4039        a1 = 6.0            b1 = 50.5668
-- L2 = 38.0           a2 = 5.1            b2 = 113.515
-- CIE ΔE2000 = ΔE00 = 14.47302641149

-- L1 = 3.55           a1 = 1.39           b1 = 120.323
-- L2 = 9.0            a2 = -27.6          b2 = 64.1
-- CIE ΔE2000 = ΔE00 = 21.11056342562

-- L1 = 11.98          a1 = 87.0           b1 = 110.0
-- L2 = 45.1           a2 = -42.0          b2 = -14.697
-- CIE ΔE2000 = ΔE00 = 65.13653910588
