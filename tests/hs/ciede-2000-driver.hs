-- Limited Use License – March 1, 2025

-- This source code is provided for public use under the following conditions :
-- It may be downloaded, compiled, and executed, including in publicly accessible environments.
-- Modification is strictly prohibited without the express written permission of the author.

-- © Michel Leonard 2025

import System.Environment (getArgs)
import Text.Printf (printf)
import Data.List.Split (splitOn)

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

-- L1 = 40.8   a1 = 20.8   b1 = -5.0
-- L2 = 42.5   a2 = 15.1   b2 = 3.7
-- CIE ΔE00 = 7.0432086590 (Bruce Lindbloom, Netflix’s VMAF, ...)
-- CIE ΔE00 = 7.0431887067 (Gaurav Sharma, OpenJDK, ...)
-- Deviation between implementations ≈ 2.0e-5

-- See the source code comments for easy switching between these two widely used ΔE*00 implementation variants.

-------------------------------------------------
-------------------------------------------------
------------                         ------------
------------    CIEDE2000 Driver     ------------
------------                         ------------
-------------------------------------------------
-------------------------------------------------

-- Reads a CSV file specified as the first command-line argument. For each line, this program
-- in Haskell displays the original line with the computed Delta E 2000 color difference appended.
-- The C driver can offer CSV files to process and programmatically check the calculations performed there.

--  Example of a CSV input line : 60,74,-34,61.8,75,2.6
--    Corresponding output line : 60,74,-34,61.8,75,2.6,13.570329363915312294540682936777


processLine :: String -> String
processLine line =
  case splitOn "," line of
    [s1,s2,s3,s4,s5,s6] ->
      case map read [s1,s2,s3,s4,s5,s6] of
        [l1,a1,b1,l2,a2,b2] ->
          let deltaE = ciede_2000 l1 a1 b1 l2 a2 b2
          in line ++ "," ++ printf "%.17f" deltaE
        _ -> error "Unexpected parse error on numeric values"
    _ -> error "Line does not contain exactly 6 comma-separated values"

main :: IO ()
main = do
  args <- getArgs
  case args of
    (filename:_) -> do
      content <- readFile filename
      let results = map processLine (lines content)
      mapM_ putStrLn results
    _ -> return ()
