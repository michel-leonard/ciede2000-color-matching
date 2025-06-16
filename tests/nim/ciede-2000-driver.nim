# Limited Use License – March 1, 2025

# This source code is provided for public use under the following conditions :
# It may be downloaded, compiled, and executed, including in publicly accessible environments.
# Modification is strictly prohibited without the express written permission of the author.

# © Michel Leonard 2025

import math

const M_PI = 3.14159265358979323846264338328

# The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
# "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
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
  # Returns the square root so that the Delta E 2000 reflects the actual geometric
  # distance within the color space, which ranges from 0 to approximately 185.
  return sqrt(l * l + h * h + c * c + c * h * r_t);

# GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
#  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

# L1 = 47.0           a1 = -78.981        b1 = -8.3
# L2 = 49.0           a2 = -124.002       b2 = -29.2
# CIE ΔE2000 = ΔE00 = 10.13248502807

#################################################
#################################################
############                         ############
############    CIEDE2000 Driver     ############
############                         ############
#################################################
#################################################

## Reads a CSV file specified as the first command-line argument. For each line, the program
## outputs the original line with the computed Delta E 2000 color difference appended.

##  Example of a CSV input line : 67.24,-14.22,70,65,8,46
##    Corresponding output line : 67.24,-14.22,70,65,8,46,15.46723547943141064

import os, strutils, sequtils

proc main() =
  if paramCount() < 1:
    quit("Usage: program filename")

  let filename = paramStr(1)
  for line in lines(filename):
    let parts = line.split(',').mapIt(it.strip())
    let vals = parts.mapIt(parseFloat(it).float64)
    let deltaE = ciede_2000(vals[0], vals[1], vals[2], vals[3], vals[4], vals[5])
    echo line & "," & $(deltaE)

when isMainModule:
  main()
