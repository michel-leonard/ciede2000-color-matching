# This function written in Nim is not affiliated with the CIE (International Commission on Illumination),
# and is released into the public domain. It is provided "as is" without any warranty, express or implied.

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

# L1 = 92.1           a1 = 115.0          b1 = -106.9752
# L2 = 92.1           a2 = 115.0          b2 = -107.0
# CIE ΔE2000 = ΔE00 = 0.00626505177

# L1 = 4.0737         a1 = 113.0          b1 = 40.8
# L2 = 4.0737         a2 = 113.0          b2 = 32.3015
# CIE ΔE2000 = ΔE00 = 2.94990322945

# L1 = 4.2511         a1 = -74.0          b1 = -83.0
# L2 = 8.77           a2 = -64.78         b2 = -83.0
# CIE ΔE2000 = ΔE00 = 3.56560025389

# L1 = 28.4           a1 = -105.2         b1 = 106.192
# L2 = 33.0054        a2 = -120.9         b2 = 84.9
# CIE ΔE2000 = ΔE00 = 7.42363325076

# L1 = 55.58          a1 = -104.3         b1 = -6.2
# L2 = 51.0           a2 = -126.44        b2 = -28.32
# CIE ΔE2000 = ΔE00 = 9.25674629677

# L1 = 75.7           a1 = -117.0         b1 = 72.0
# L2 = 72.3115        a2 = -71.0          b2 = 32.2
# CIE ΔE2000 = ΔE00 = 11.23551607902

# L1 = 42.0           a1 = -49.7          b1 = 43.0
# L2 = 42.7           a2 = -20.363        b2 = 52.03
# CIE ΔE2000 = ΔE00 = 14.19940926883

# L1 = 92.893         a1 = -100.5711      b1 = -54.3
# L2 = 94.7           a2 = -56.8          b2 = -91.0
# CIE ΔE2000 = ΔE00 = 16.50590200039

# L1 = 44.0           a1 = 113.8          b1 = -90.8
# L2 = 31.1           a2 = 44.0           b2 = -24.326
# CIE ΔE2000 = ΔE00 = 21.48988175337

# L1 = 45.0           a1 = -96.0          b1 = 87.0961
# L2 = 96.187         a2 = 75.259         b2 = -26.4319
# CIE ΔE2000 = ΔE00 = 108.96574502106
