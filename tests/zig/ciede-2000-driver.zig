// Limited Use License – March 1, 2025

// This source code is provided for public use under the following conditions :
// It may be downloaded, compiled, and executed, including in publicly accessible environments.
// Modification is strictly prohibited without the express written permission of the author.

// © Michel Leonard 2025

const std = @import("std");
const math = std.math;

// The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
// "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
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
    // Returns the square root so that the Delta E 2000 reflects the actual geometric
    // distance within the color space, which ranges from 0 to approximately 185.
    return math.sqrt(l * l + h * h + c * c + c * h * r_t);
}

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

// L1 = 75.2           a1 = 85.4           b1 = 32.0
// L2 = 75.2           a2 = 85.4           b2 = 32.0248
// CIE ΔE2000 = ΔE00 = 0.01026475241

// L1 = 86.0           a1 = 62.404         b1 = 40.5
// L2 = 88.0           a2 = 62.404         b2 = 41.1
// CIE ΔE2000 = ΔE00 = 1.3195320095

// L1 = 23.037         a1 = 84.2           b1 = 17.01
// L2 = 26.0           a2 = 84.2           b2 = 17.01
// CIE ΔE2000 = ΔE00 = 2.15261015423

// L1 = 38.6341        a1 = -92.85         b1 = 89.92
// L2 = 27.5           a2 = -112.3048      b2 = 122.17
// CIE ΔE2000 = ΔE00 = 10.37378168261

// L1 = 55.728         a1 = -50.7812       b1 = -124.3
// L2 = 41.6266        a2 = -54.25         b2 = -120.76
// CIE ΔE2000 = ΔE00 = 14.06820593987

// L1 = 40.0           a1 = -73.4          b1 = 80.6162
// L2 = 54.0           a2 = -83.74         b2 = 61.495
// CIE ΔE2000 = ΔE00 = 15.21545290057

// L1 = 65.7           a1 = 97.287         b1 = -120.0
// L2 = 87.9156        a2 = 48.9           b2 = -75.814
// CIE ΔE2000 = ΔE00 = 19.00957031507

// L1 = 29.2           a1 = -3.2           b1 = -43.135
// L2 = 30.972         a2 = -70.6957       b2 = -78.09
// CIE ΔE2000 = ΔE00 = 25.07954141994

// L1 = 58.089         a1 = 36.0           b1 = 127.8543
// L2 = 25.0           a2 = -10.0          b2 = -71.4903
// CIE ΔE2000 = ΔE00 = 68.50547393835

// L1 = 35.0           a1 = -52.0          b1 = 88.63
// L2 = 90.6           a2 = 84.328         b2 = 14.673
// CIE ΔE2000 = ΔE00 = 95.92542528716

/////////////////////////////////////////////////
/////////////////////////////////////////////////
////////////                         ////////////
////////////    CIEDE2000 Driver     ////////////
////////////                         ////////////
/////////////////////////////////////////////////
/////////////////////////////////////////////////

// Reads a CSV file specified as the first command-line argument. For each line, the program
// outputs the original line with the computed Delta E 2000 color difference appended.

//  Example of a CSV input line : 67.24,-14.22,70,65,8,46
//    Corresponding output line : 67.24,-14.22,70,65,8,46,15.46723547943141064

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var args = std.process.args();
    _ = args.next();

    const filename = args.next() orelse {
        std.debug.print("Usage: program filename\n", .{});
        return;
    };

    var file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var reader = std.io.bufferedReader(file.reader());
    const in_stream = reader.reader();

    var line_buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&line_buf, '\n')) |full_line| {
        const line = std.mem.trim(u8, full_line, " \r\n\t");
        if (5 < line.len) {
            var parts = std.mem.tokenizeScalar(u8, line, ',');
            var values: [6]f64 = undefined;
            var i: usize = 0;
            while (parts.next()) |part| : (i += 1) {
                values[i] = try std.fmt.parseFloat(f64, part);
            }
            const delta_e = ciede_2000(
                values[0], values[1], values[2],
                values[3], values[4], values[5],
            );
            try stdout.print("{s},{d:.15}\n", .{line, delta_e});
        }
    }
}
