# Limited Use License – March 1, 2025

# This source code is provided for public use under the following conditions :
# It may be downloaded, compiled, and executed, including in publicly accessible environments.
# Modification is strictly prohibited without the express written permission of the author.

# © Michel Leonard 2025

import math

const M_PI = 3.14159265358979323846264338328

# The generic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
# "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
proc ciede_2000[T: SomeFloat](l_1, a_1, b_1, l_2, a_2, b_2: T): T =
  # Working in Nim with the CIEDE2000 color-difference formula.
  # k_l, k_c, k_h are parametric factors to be adjusted according to
  # different viewing parameters such as textures, backgrounds...
  let k_l = T(1.0);
  let k_c = T(1.0);
  let k_h = T(1.0);
  var n = (sqrt(a_1 * a_1 + b_1 * b_1) + sqrt(a_2 * a_2 + b_2 * b_2)) * T(0.5);
  n = n * n * n * n * n * n * n;
  # A factor involving chroma raised to the power of 7 designed to make
  # the influence of chroma on the total color difference more accurate.
  n = T(1.0) + T(0.5) * (T(1.0) - sqrt(n / (n + T(6103515625.0))));
  # Application of the chroma correction factor.
  let c_1 = sqrt(a_1 * a_1 * n * n + b_1 * b_1);
  let c_2 = sqrt(a_2 * a_2 * n * n + b_2 * b_2);
  # atan2 is preferred over atan because it accurately computes the angle of
  # a point (x, y) in all quadrants, handling the signs of both coordinates.
  var h_1 = arctan2(b_1, a_1 * n);
  var h_2 = arctan2(b_2, a_2 * n);
  if h_1 < T(0.0) :
    h_1 += T(2.0) * T(M_PI);
  if h_2 < T(0.0) :
    h_2 += T(2.0) * T(M_PI);
  n = abs(h_2 - h_1);
  # Cross-implementation consistent rounding.
  if T(M_PI) - T(1E-14) < n and n < T(M_PI) + T(1E-14) :
    n = T(M_PI);
  # When the hue angles lie in different quadrants, the straightforward
  # average can produce a mean that incorrectly suggests a hue angle in
  # the wrong quadrant, the next lines handle this issue.
  var h_m = (h_1 + h_2) * T(0.5);
  var h_d = (h_2 - h_1) * T(0.5);
  if T(M_PI) < n :
    h_d += T(M_PI);
    # 📜 Sharma’s formulation doesn’t use the next line, but the one after it,
    # and these two variants differ by ±0.0003 on the final color differences.
    h_m += T(M_PI);
    # h_m += (if h_m < T(M_PI) : T(M_PI) else : T(-M_PI));
  let p = T(36.0) * h_m - T(55.0) * T(M_PI);
  n = (c_1 + c_2) * T(0.5);
  n = n * n * n * n * n * n * n;
  # The hue rotation correction term is designed to account for the
  # non-linear behavior of hue differences in the blue region.
  let r_t = T(-2.0) * sqrt(n / (n + T(6103515625.0))) *
        sin(T(M_PI) / T(3.0) * exp(p * p / (T(-25.0) * T(M_PI) * T(M_PI))));
  n = (l_1 + l_2) * T(0.5);
  n = (n - T(50.0)) * (n - T(50.0));
  # Lightness.
  let l = (l_2 - l_1) / (k_l * (T(1.0) + T(0.015) * n / sqrt(T(20.0) + n)));
  # These coefficients adjust the impact of different harmonic
  # components on the hue difference calculation.
  let t = T(1.0)   + T(0.24) * sin(T(2.0) * h_m + T(M_PI) * T(0.5)) +
        T(0.32) * sin(T(3.0) * h_m + T(8.0) * T(M_PI) / T(15.0)) -
        T(0.17) * sin(h_m + T(M_PI) / T(3.0)) -
        T(0.20) * sin(T(4.0) * h_m + T(3.0) * T(M_PI) / T(20.0));
  n = c_1 + c_2;
  # Hue.
  let h = T(2.0) * sqrt(c_1 * c_2) *
        sin(h_d) / (k_h * (T(1.0) + T(0.0075) * n * t));
  # Chroma.
  let c = (c_2 - c_1) / (k_c * (T(1.0) + T(0.0225) * n));
  # Returning the square root ensures that dE00 accurately reflects the
  # geometric distance in color space, which can range from 0 to around 185.
  return sqrt(l * l + h * h + c * c + c * h * r_t);

# GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
#   Online Tests : https://michel-leonard.github.io/ciede2000-color-matching

# L1 = 68.8   a1 = 21.6   b1 = -2.4
# L2 = 67.3   a2 = 15.7   b2 = 2.4
# CIE ΔE00 = 5.0609566750 (Bruce Lindbloom, Netflix’s VMAF, ...)
# CIE ΔE00 = 5.0609436595 (Gaurav Sharma, OpenJDK, ...)
# Deviation between implementations ≈ 1.3e-5

# See the source code comments for easy switching between these two widely used ΔE*00 implementation variants.

#################################################
#################################################
############                         ############
############    CIEDE2000 Driver     ############
############                         ############
#################################################
#################################################

## Reads a CSV file specified as the first command-line argument. For each line, this program
## in Nim displays the original line with the computed Delta E 2000 color difference appended.
## The C driver can offer CSV files to process and programmatically check the calculations performed there.

##  Example of a CSV input line : 65,107,1,51.3,58,-18.3
##    Corresponding output line : 65,107,1,51.3,58,-18.3,18.134308412944345843174051109052

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
