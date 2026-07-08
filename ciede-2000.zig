// This function written in Zig is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

const std = @import("std");
const math = std.math;

// The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
// "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
pub fn ciede_2000(l_1: f64, a_1: f64, b_1: f64, l_2: f64, a_2: f64, b_2: f64) f64 {
    // Working in Zig with the CIEDE2000 color-difference formula.
    // k_l, k_c, k_h are parametric factors to be adjusted according to
    // different viewing parameters such as textures, backgrounds...
    const k_l = @as(f64, 1.0);
    const k_c = @as(f64, 1.0);
    const k_h = @as(f64, 1.0);
    // Expressly defining pi ensures that the code works on different platforms.
    const m_pi = @as(f64, 3.14159265358979323846264338327950288);
    var n = (math.sqrt(a_1 * a_1 + b_1 * b_1) + math.sqrt(a_2 * a_2 + b_2 * b_2)) * @as(f64, 0.5);
    n = n * n * n * n * n * n * n;
    // A factor involving chroma raised to the power of 7 designed to make
    // the influence of chroma on the total color difference more accurate.
    n = @as(f64, 1.0) + @as(f64, 0.5) * (@as(f64, 1.0) - math.sqrt(n / (n + @as(f64, 6103515625.0))));
    // Application of the chroma correction factor.
    const c_1 = math.sqrt(a_1 * a_1 * n * n + b_1 * b_1);
    const c_2 = math.sqrt(a_2 * a_2 * n * n + b_2 * b_2);
    // atan2 is preferred over atan because it accurately computes the angle of
    // a point (x, y) in all quadrants, handling the signs of both coordinates.
    var h_1 = math.atan2(b_1, a_1 * n);
    var h_2 = math.atan2(b_2, a_2 * n);
    if (h_1 < @as(f64, 0.0)) h_1 += @as(f64, 2.0) * m_pi;
    if (h_2 < @as(f64, 0.0)) h_2 += @as(f64, 2.0) * m_pi;
    if (h_2 < h_1) { n = h_1 - h_2; } else {  n = h_2 - h_1; }
    // Cross-implementation consistent rounding.
    if (m_pi - @as(f64, 1E-14) < n and n < m_pi + @as(f64, 1E-14)) n = m_pi;
    // When the hue angles lie in different quadrants, the straightforward
    // average can produce a mean that incorrectly suggests a hue angle in
    // the wrong quadrant, the next lines handle this issue.
    var h_m = (h_1 + h_2) * @as(f64, 0.5);
    var h_d = (h_2 - h_1) * @as(f64, 0.5);
    if (m_pi < n) {
        h_d += m_pi;
        // 📜 Sharma’s formulation doesn’t use the next line, but the one after it,
        // and these two variants differ by ±0.0003 on the final color differences.
        h_m += m_pi;
        // if (h_m < m_pi) { h_m += m_pi; } else { h_m -= m_pi; }
    }
    const p = @as(f64, 36.0) * h_m - @as(f64, 55.0) * m_pi;
    n = (c_1 + c_2) * @as(f64, 0.5);
    n = n * n * n * n * n * n * n;
    // The hue rotation correction term is designed to account for the
    // non-linear behavior of hue differences in the blue region.
    const r_t = @as(f64, -2.0) * math.sqrt(n / (n + @as(f64, 6103515625.0)))
                  * math.sin(m_pi / @as(f64, 3.0) * math.exp(p * p / (@as(f64, -25.0) * m_pi * m_pi)));
    n = (l_1 + l_2) * @as(f64, 0.5);
    n = (n - @as(f64, 50.0)) * (n - @as(f64, 50.0));
    // Lightness.
    const l = (l_2 - l_1) / (k_l * (@as(f64, 1.0) + @as(f64, 0.015)
                * n / math.sqrt(@as(f64, 20.0) + n)));
    // These coefficients adjust the impact of different harmonic
    // components on the hue difference calculation.
    const t = @as(f64, 1.0)
                + @as(f64, 0.24) * math.sin(@as(f64, 2.0) * h_m + m_pi / @as(f64, 2.0))
                + @as(f64, 0.32) * math.sin(@as(f64, 3.0) * h_m + @as(f64, 8.0) * m_pi / @as(f64, 15.0))
                - @as(f64, 0.17) * math.sin(h_m + m_pi / @as(f64, 3.0))
                - @as(f64, 0.20) * math.sin(@as(f64, 4.0) * h_m + @as(f64, 3.0) * m_pi / @as(f64, 20.0));
    n = c_1 + c_2;
    // Hue.
    const h = @as(f64, 2.0) * math.sqrt(c_1 * c_2)
                * math.sin(h_d) / (k_h * (@as(f64, 1.0) + @as(f64, 0.0075) * n * t));
    // Chroma.
    const c = (c_2 - c_1) / (k_c * (@as(f64, 1.0) + @as(f64, 0.0225) * n));
    // Returning the square root ensures that dE00 accurately reflects the
    // geometric distance in color space, which can range from 0 to around 185.
    return math.sqrt(l * l + h * h + c * c + c * h * r_t);
}

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//   Online Tests : https://michel-leonard.github.io/ciede2000-color-matching

// L1 = 18.9   a1 = 31.0   b1 = -3.8
// L2 = 20.9   a2 = 25.0   b2 = 4.5
// CIE ΔE00 = 6.0764044777 (Bruce Lindbloom, Netflix’s VMAF, ...)
// CIE ΔE00 = 6.0763907209 (Gaurav Sharma, OpenJDK, ...)
// Deviation between implementations ≈ 1.4e-5

// See the source code comments for easy switching between these two widely used ΔE*00 implementation variants.
