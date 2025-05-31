// This function written in Zig is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

const std = @import("std");
const math = std.math;

// The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
// "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 128.
pub fn ciede_2000(l_1: f64, a_1: f64, b_1: f64, l_2: f64, a_2: f64, b_2: f64) f64 {
    // Working in Zig with the CIEDE2000 color-difference formula.
    // k_l, k_c, k_h are parametric factors to be adjusted according to
    // different viewing parameters such as textures, backgrounds...
    const k_l = 1.0;
    const k_c = 1.0;
    const k_h = 1.0;
    // Expressly defining pi ensures that the code works on different platforms.
    const pi = 3.14159265358979323846264338328;
    var n = (math.hypot(a_1, b_1) + math.hypot(a_2, b_2)) * 0.5;
    n = n * n * n * n * n * n * n;
    // A factor involving chroma raised to the math.power of 7 designed to make
    // the influence of chroma on the total color difference more accurate.
    n = 1.0 + 0.5 * (1.0 - math.sqrt(n / (n + 6103515625.0)));
    // hypot calculates the Euclidean distance while avoiding overflow/underflow.
    const c_1 = math.hypot(a_1 * n, b_1);
    const c_2 = math.hypot(a_2 * n, b_2);
    // atan2 is preferred over atan because it accurately computes the angle of
    // a point (x, y) in all quadrants, handling the signs of both coordinates.
    var h_1 = math.atan2(b_1, a_1 * n);
    var h_2 = math.atan2(b_2, a_2 * n);
    if (h_1 < 0.0) h_1 += 2.0 * pi;
    if (h_2 < 0.0) h_2 += 2.0 * pi;
    if (h_2 < h_1) { n = h_1 - h_2; } else {  n = h_2 - h_1; }
    // Cross-implementation consistent rounding.
    if (pi - 1E-14 < n and n < pi + 1E-14) n = pi;
    // When the hue angles lie in different quadrants, the straightforward
    // average can produce a mean that incorrectly suggests a hue angle in
    // the wrong quadrant, the next lines handle this issue.
    var h_m = (h_1 + h_2) * 0.5;
    var h_d = (h_2 - h_1) * 0.5;
    if (pi < n) {
        if (0.0 < h_d) { h_d -= pi; } else { h_d += pi; }
        h_m += pi;
    }
    const p = 36.0 * h_m - 55.0 * pi;
    n = (c_1 + c_2) * 0.5;
    n = n * n * n * n * n * n * n;
    // The hue rotation correction term is designed to account for the
    // non-linear behavior of hue differences in the blue region.
    const r_t = -2.0 * math.sqrt(n / (n + 6103515625.0))
                        * math.sin(pi / 3.0 * math.exp(p * p / (-25.0 * pi * pi)));
    n = (l_1 + l_2) * 0.5;
    n = (n - 50.0) * (n - 50.0);
    // Lightness.
    const l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / math.sqrt(20.0 + n)));
    // These coefficients adjust the impact of different harmonic
    // components on the hue difference calculation.
    const t = 1.0   + 0.24 * math.sin(2.0 * h_m + pi / 2.0)
                    + 0.32 * math.sin(3.0 * h_m + 8.0 * pi / 15.0)
                    - 0.17 * math.sin(h_m + pi / 3.0)
                    - 0.20 * math.sin(4.0 * h_m + 3.0 * pi / 20.0);
    n = c_1 + c_2;
    // Hue.
    const h = 2.0 * math.sqrt(c_1 * c_2) * math.sin(h_d) / (k_h * (1.0 + 0.0075 * n * t));
    // Chroma.
    const c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
    // Returning the square root ensures that the result reflects the actual geometric
    // distance within the color space, which ranges from 0 to approximately 185.
    return math.sqrt(l * l + h * h + c * c + c * h * r_t);
}

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/samples.html

// L1 = 13.19          a1 = -68.2248       b1 = -78.844
// L2 = 13.2           a2 = -68.2248       b2 = -78.844
// CIE ΔE2000 = ΔE00 = 0.00645976451

// L1 = 71.08          a1 = 92.94          b1 = 20.033
// L2 = 71.0           a2 = 92.94          b2 = 20.033
// CIE ΔE2000 = ΔE00 = 0.06112919947

// L1 = 21.6932        a1 = 2.765          b1 = -35.0
// L2 = 21.6932        a2 = 3.27           b2 = -35.0
// CIE ΔE2000 = ΔE00 = 0.38021141954

// L1 = 19.357         a1 = -21.72         b1 = 61.6
// L2 = 23.318         a2 = -24.0          b2 = 67.9342
// CIE ΔE2000 = ΔE00 = 3.23068480232

// L1 = 27.1           a1 = 118.302        b1 = -107.61
// L2 = 27.1           a2 = 110.6          b2 = -115.6211
// CIE ΔE2000 = ΔE00 = 3.60637591812

// L1 = 36.0181        a1 = -26.337        b1 = 89.0
// L2 = 36.0181        a2 = -18.0          b2 = 89.0
// CIE ΔE2000 = ΔE00 = 3.92063069871

// L1 = 17.896         a1 = 54.0           b1 = 93.7493
// L2 = 24.6122        a2 = 54.0           b2 = 93.7493
// CIE ΔE2000 = ΔE00 = 4.70960888858

// L1 = 2.1            a1 = 3.05           b1 = -106.0
// L2 = 2.66           a2 = 17.0           b2 = -84.536
// CIE ΔE2000 = ΔE00 = 12.49979177727

// L1 = 40.5258        a1 = -117.3         b1 = -96.4645
// L2 = 58.0           a2 = -52.339        b2 = -97.6779
// CIE ΔE2000 = ΔE00 = 22.33485674111

// L1 = 88.492         a1 = -119.09        b1 = -106.3
// L2 = 98.9           a2 = 7.748          b2 = 12.063
// CIE ΔE2000 = ΔE00 = 45.45973566091
