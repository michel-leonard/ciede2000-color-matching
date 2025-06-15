// This function written in F# is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

open System

// The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
// "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
let ciede_2000 (l_1: float) (a_1: float) (b_1: float) (l_2: float) (a_2: float) (b_2: float) : float =
    // Working in F# with the CIEDE2000 color-difference formula.
    // k_l, k_c, k_h are parametric factors to be adjusted according to
    // different viewing parameters such as textures, backgrounds...
    let k_l = 1.0
    let k_c = 1.0
    let k_h = 1.0
    let mutable n = (Math.Sqrt(a_1 * a_1 + b_1 * b_1) + Math.Sqrt(a_2 * a_2 + b_2 * b_2)) * 0.5
    n <- n * n * n * n * n * n * n
    // A factor involving chroma raised to the power of 7 designed to make
    // the influence of chroma on the total color difference more accurate.
    n <- 1.0 + 0.5 * (1.0 - Math.Sqrt(n / (n + 6103515625.0)))
    // Since hypot is not available, sqrt is used here to calculate the
    // Euclidean distance, without avoiding overflow/underflow.
    let c_1 = Math.Sqrt(a_1 * a_1 * n * n + b_1 * b_1)
    let c_2 = Math.Sqrt(a_2 * a_2 * n * n + b_2 * b_2)
    // atan2 is preferred over atan because it accurately computes the angle of
    // a point (x, y) in all quadrants, handling the signs of both coordinates.
    let mutable h_1 = Math.Atan2(b_1, a_1 * n)
    let mutable h_2 = Math.Atan2(b_2, a_2 * n)
    if (h_1 < 0.0) then h_1 <- h_1 + 2.0 * Math.PI
    if (h_2 < 0.0) then h_2 <- h_2 + 2.0 * Math.PI
    n <- Math.Abs(h_2 - h_1)
    // Cross-implementation consistent rounding.
    if (Math.PI - 1E-14 < n && n < Math.PI + 1E-14) then n <- Math.PI
    // When the hue angles lie in different quadrants, the straightforward
    // average can produce a mean that incorrectly suggests a hue angle in
    // the wrong quadrant, the next lines handle this issue.
    let mutable h_m = (h_1 + h_2) * 0.5
    let mutable h_d = (h_2 - h_1) * 0.5
    if (Math.PI < n) then
        if (0.0 < h_d) then
            h_d <- h_d - Math.PI
        else
            h_d <- h_d + Math.PI
        h_m <- h_m + Math.PI
    let p = 36.0 * h_m - 55.0 * Math.PI
    n <- (c_1 + c_2) * 0.5
    n <- n * n * n * n * n * n * n
    // The hue rotation correction term is designed to account for the
    // non-linear behavior of hue differences in the blue region.
    let r_t = -2.0 * Math.Sqrt(n / (n + 6103515625.0))
                        * Math.Sin(Math.PI / 3.0 * Math.Exp(p * p / (-25.0 * Math.PI * Math.PI)))
    n <- (l_1 + l_2) * 0.5
    n <- (n - 50.0) * (n - 50.0)
    // Lightness.
    let l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / Math.Sqrt(20.0 + n)))
    // These coefficients adjust the impact of different harmonic
    // components on the hue difference calculation.
    let t = 1.0     + 0.24 * Math.Sin(2.0 * h_m + Math.PI / 2.0)
                    + 0.32 * Math.Sin(3.0 * h_m + 8.0 * Math.PI / 15.0)
                    - 0.17 * Math.Sin(h_m + Math.PI / 3.0)
                    - 0.20 * Math.Sin(4.0 * h_m + 3.0 * Math.PI / 20.0)
    n <- c_1 + c_2
    // Hue.
    let h = 2.0 * Math.Sqrt(c_1 * c_2) * Math.Sin(h_d) / (k_h * (1.0 + 0.0075 * n * t))
    // Chroma.
    let c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n))
    // Returns the square root so that the Delta E 2000 reflects the actual geometric
    // distance within the color space, which ranges from 0 to approximately 185.
    Math.Sqrt(l * l + h * h + c * c + c * h * r_t)

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

// L1 = 45.4           a1 = -123.0         b1 = 35.2
// L2 = 45.4           a2 = -123.0         b2 = 35.22
// CIE ΔE2000 = ΔE00 = 0.00586550057

// L1 = 73.9306        a1 = 60.1355        b1 = -107.08
// L2 = 73.9306        a2 = 57.3           b2 = -107.08
// CIE ΔE2000 = ΔE00 = 1.31581404287

// L1 = 84.4           a1 = 79.64          b1 = -27.0
// L2 = 84.4           a2 = 79.64          b2 = -34.1417
// CIE ΔE2000 = ΔE00 = 2.43147219106

// L1 = 9.0            a1 = 100.7          b1 = 83.6
// L2 = 9.0            a2 = 100.7          b2 = 92.254
// CIE ΔE2000 = ΔE00 = 2.82504941518

// L1 = 98.0           a1 = 8.9            b1 = 18.0
// L2 = 98.0           a2 = 8.9            b2 = 11.52
// CIE ΔE2000 = ΔE00 = 4.39609172765

// L1 = 71.0           a1 = -31.0          b1 = -16.0
// L2 = 83.2969        a2 = -21.0          b2 = -14.0
// CIE ΔE2000 = ΔE00 = 9.9775650084

// L1 = 50.98          a1 = 102.287        b1 = -30.4759
// L2 = 49.1           a2 = 68.0           b2 = -0.264
// CIE ΔE2000 = ΔE00 = 11.70428214087

// L1 = 38.0           a1 = 24.7           b1 = 123.1117
// L2 = 17.88          a2 = 22.65          b2 = 110.268
// CIE ΔE2000 = ΔE00 = 15.33210245831

// L1 = 40.531         a1 = 55.6978        b1 = 58.168
// L2 = 55.22          a2 = 115.2          b2 = 110.0
// CIE ΔE2000 = ΔE00 = 19.15199963917

// L1 = 70.9           a1 = -33.483        b1 = -51.9601
// L2 = 83.52          a2 = -102.5957      b2 = -41.0
// CIE ΔE2000 = ΔE00 = 22.36232716426
