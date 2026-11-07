-- This function written in Haskell is not affiliated with the CIE (International Commission on Illumination),
-- and is released into the public domain. It is provided "as is" without any warranty, express or implied.

import System.Environment (getArgs)
import System.Random
import Text.Printf (printf)

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
        -- 📜 Sharma’s formulation doesn’t use the next line, but the one after it,
        -- and these two variants differ by ±0.0003 on the final color differences.
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
    -- Returning the square root ensures that dE00 accurately reflects the
    -- geometric distance in color space, which can range from 0 to around 185.
    in sqrt(l * l + h * h + c * c + c * h * r_t)

-- GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
--   Online Tests : https://michel-leonard.github.io/ciede2000-color-matching

-- L1 = 12.1   a1 = 32.6   b1 = -4.0
-- L2 = 13.7   a2 = 27.0   b2 = 4.7
-- CIE ΔE00 = 6.0199657517 (Bruce Lindbloom, Netflix’s VMAF, ...)
-- CIE ΔE00 = 6.0199522437 (Gaurav Sharma, OpenJDK, ...)
-- Deviation between implementations ≈ 1.4e-5

-- See the source code comments for easy switching between these two widely used ΔE*00 implementation variants.

-----------------------------------------------
-----------------------------------------------
-------                                 -------
-------           CIEDE 2000            -------
-------      Testing Random Colors      -------
-------                                 -------
-----------------------------------------------
-----------------------------------------------

-- This Haskell program outputs a CSV file to standard output, with its length determined by the first CLI argument.
-- Each line contains seven columns :
-- - Three columns for the random standard L*a*b* color
-- - Three columns for the random sample L*a*b* color
-- - And the seventh column for the precise Delta E 2000 color difference between the standard and sample
-- The output will be correct, this can be verified :
-- - With the C driver, which provides a dedicated verification feature
-- - By using the JavaScript validator at https://michel-leonard.github.io/ciede2000-color-matching

roundTo :: Int -> Double -> Double
roundTo 0 x = fromIntegral (round x :: Int)
roundTo _ x = fromIntegral (round (x * 10) :: Int) / 10

randomRound :: StdGen -> (Int, StdGen)
randomRound gen = randomR (0, 1) gen

randomInRange :: (Double, Double) -> StdGen -> (Double, StdGen)
randomInRange (low, high) gen = randomR (low, high) gen

randomRoundedInRange :: (Double, Double) -> StdGen -> (Double, StdGen)
randomRoundedInRange range gen0 =
  let (x, gen1) = randomInRange range gen0
      (n, gen2) = randomRound gen1
      y = roundTo n x
  in (y, gen2)

main :: IO ()
main = do
  args <- getArgs
  let nIterations = case args of
        (x:_) -> case reads x :: [(Int,String)] of
          [(v,"")] | v > 0 -> v
          _ -> 10000
        _ -> 10000

  gen0 <- newStdGen

  let loop 0 _ = return ()
      loop n gen = do
        let (l1, gen1) = randomRoundedInRange (0, 100) gen
            (a1, gen2) = randomRoundedInRange (-128, 128) gen1
            (b1, gen3) = randomRoundedInRange (-128, 128) gen2
            (l2, gen4) = randomRoundedInRange (0, 100) gen3
            (a2, gen5) = randomRoundedInRange (-128, 128) gen4
            (b2, gen6) = randomRoundedInRange (-128, 128) gen5
            dE = ciede_2000 l1 a1 b1 l2 a2 b2
        putStrLn $ printf "%g,%g,%g,%g,%g,%g,%.17g" l1 a1 b1 l2 a2 b2 dE
        loop (n-1) gen6

  loop nIterations gen0
