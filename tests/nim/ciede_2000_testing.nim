# This function written in Nim is not affiliated with the CIE (International Commission on Illumination),
# and is released into the public domain. It is provided "as is" without any warranty, express or implied.

import math

const M_PI = 3.14159265358979323846264338328

# The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
proc ciede_2000(l_1: float64, a_1: float64, b_1: float64, l_2: float64, a_2: float64, b_2: float64): float64 =
  # Working in Nim with the CIEDE2000 color-difference formula.
  # k_l, k_c, k_h are parametric factors to be adjusted according to
  # different viewing parameters such as textures, backgrounds...
  let k_l = 1.0;
  let k_c = 1.0;
  let k_h = 1.0;
  var n = (hypot(a_1, b_1) + hypot(a_2, b_2)) * 0.5;
  n = n * n * n * n * n * n * n;
  # A factor involving chroma raised to the power of 7 designed to make
  # the influence of chroma on the total color difference more accurate.
  n = 1.0 + 0.5 * (1.0 - sqrt(n / (n + 6103515625.0)));
  # hypot calculates the Euclidean distance while avoiding overflow/underflow.
  let c_1 = hypot(a_1 * n, b_1);
  let c_2 = hypot(a_2 * n, b_2);
  # atan2 is preferred over atan because it accurately computes the angle of
  # a point (x, y) in all quadrants, handling the signs of both coordinates.
  var h_1 = arctan2(b_1, a_1 * n);
  var h_2 = arctan2(b_2, a_2 * n);
  h_1 += 2.0 * M_PI * (h_1 < 0.0).float;
  h_2 += 2.0 * M_PI * (h_2 < 0.0).float;
  n = abs(h_2 - h_1);
  # Cross-implementation consistent rounding.
  if M_PI - 1E-14 < n and n < M_PI + 1E-14 :
    n = M_PI;
  # When the hue angles lie in different quadrants, the straightforward
  # average can produce a mean that incorrectly suggests a hue angle in
  # the wrong quadrant, the next lines handle this issue.
  var h_m = (h_1 + h_2) * 0.5;
  var h_d = (h_2 - h_1) * 0.5;
  if M_PI < n :
    if 0.0 < h_d :
      h_d -= M_PI;
    else :
      h_d += M_PI;
    h_m += M_PI;
  let p = 36.0 * h_m - 55.0 * M_PI;
  n = (c_1 + c_2) * 0.5;
  n = n * n * n * n * n * n * n;
  # The hue rotation correction term is designed to account for the
  # non-linear behavior of hue differences in the blue region.
  let r_t = -2.0 * sqrt(n / (n + 6103515625.0)) *
        sin(M_PI / 3.0 * exp(p * p / (-25.0 * M_PI * M_PI)));
  n = (l_1 + l_2) * 0.5;
  n = (n - 50.0) * (n - 50.0);
  # Lightness.
  let l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / sqrt(20.0 + n)));
  # These coefficients adjust the impact of different harmonic
  # components on the hue difference calculation.
  let t = 1.0   + 0.24 * sin(2.0 * h_m + M_PI * 0.5) +
        0.32 * sin(3.0 * h_m + 8.0 * M_PI / 15.0) -
        0.17 * sin(h_m + M_PI / 3.0) -
        0.20 * sin(4.0 * h_m + 3.0 * M_PI / 20.0);
  n = c_1 + c_2;
  # Hue.
  let h = 2.0 * sqrt(c_1 * c_2) * sin(h_d) / (k_h * (1.0 + 0.0075 * n * t));
  # Chroma.
  let c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
  # Returning the square root ensures that the result represents
  # the "true" geometric distance in the color space.
  return sqrt(l * l + h * h + c * c + c * h * r_t);

# GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
#  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/samples.html

# L1 = 94.5028        a1 = -107.0         b1 = 51.3
# L2 = 94.5028        a2 = -107.0014      b2 = 51.3
# CIE ΔE2000 = ΔE00 = 0.00026793825

# L1 = 67.814         a1 = 3.72           b1 = -99.0
# L2 = 67.814         a2 = 3.72           b2 = -101.2379
# CIE ΔE2000 = ΔE00 = 0.44247131846

# L1 = 48.13          a1 = 23.0           b1 = -51.7
# L2 = 48.13          a2 = 25.9           b2 = -48.4
# CIE ΔE2000 = ΔE00 = 3.31126127465

# L1 = 79.05          a1 = 38.43          b1 = 13.0
# L2 = 79.05          a2 = 38.43          b2 = 19.8
# CIE ΔE2000 = ΔE00 = 4.08282614301

# L1 = 91.573         a1 = -52.0          b1 = -56.0
# L2 = 98.9           a2 = -52.0          b2 = -56.0
# CIE ΔE2000 = ΔE00 = 4.37366068059

# L1 = 19.0           a1 = -96.456        b1 = 30.7934
# L2 = 28.0           a2 = -96.7367       b2 = 13.3
# CIE ΔE2000 = ΔE00 = 9.04875108668

# L1 = 25.7968        a1 = -24.8258       b1 = -52.12
# L2 = 5.69           a2 = -42.48         b2 = -72.34
# CIE ΔE2000 = ΔE00 = 15.06724700172

# L1 = 4.5265         a1 = -1.27          b1 = -112.8987
# L2 = 30.7           a2 = -11.7          b2 = -103.0
# CIE ΔE2000 = ΔE00 = 18.01920248851

# L1 = 50.4           a1 = 64.85          b1 = 73.7
# L2 = 40.228         a2 = 83.1615        b2 = 36.848
# CIE ΔE2000 = ΔE00 = 22.03788579969

# L1 = 82.897         a1 = 58.0           b1 = 44.34
# L2 = 0.9            a2 = 17.0           b2 = 45.0
# CIE ΔE2000 = ΔE00 = 77.2192079746

#####################################################################
#####################################################################
#####################################################################
####################                         ########################
####################         TESTING         ########################
####################                         ########################
#####################################################################
#####################################################################
#####################################################################
#####################################################################

# The output is intended to be checked by the Large-Scale validator
# at https://michel-leonard.github.io/ciede2000-color-matching/batch.html

import random, strformat, std/os
from std/strutils import parseInt

let default_iterations = 10000
let arguments = commandLineParams()
let n_iterations = if arguments.len > 0:
    try:
        let input = parseInt(arguments[0])
        if input > 0: input else: default_iterations
    except ValueError:
        default_iterations
else:
    default_iterations

proc roundRandom(value: float64): float64 =
  let decimals = rand(1)
  if decimals == 0:
    return round(value)
  else:
    return round(value, 1)

randomize()

for _ in 0 ..< n_iterations:
  let l1 = roundRandom(rand(100.0))
  let a1 = roundRandom(rand(-128.0..128.0))
  let b1 = roundRandom(rand(-128.0..128.0))
  let l2 = roundRandom(rand(100.0))
  let a2 = roundRandom(rand(-128.0..128.0))
  let b2 = roundRandom(rand(-128.0..128.0))

  let delta_e = ciede_2000(l1, a1, b1, l2, a2, b2)
  echo fmt"{l1},{a1},{b1},{l2},{a2},{b2},{delta_e}"
