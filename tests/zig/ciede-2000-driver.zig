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

// L1 = 10.1   a1 = 39.5   b1 = -2.4
// L2 = 10.8   a2 = 35.0   b2 = 2.4
// CIE ΔE00 = 3.2560522039 (Bruce Lindbloom, Netflix’s VMAF, ...)
// CIE ΔE00 = 3.2560391592 (Gaurav Sharma, OpenJDK, ...)
// Deviation between implementations ≈ 1.3e-5

// See the source code comments for easy switching between these two widely used ΔE*00 implementation variants.

/////////////////////////////////////////////////
/////////////////////////////////////////////////
////////////                         ////////////
////////////    CIEDE2000 Driver     ////////////
////////////                         ////////////
/////////////////////////////////////////////////
/////////////////////////////////////////////////

// Reads a CSV file specified as the first command-line argument. For each line, this program
// in Zig displays the original line with the computed Delta E 2000 color difference appended.
// The C driver can offer CSV files to process and programmatically check the calculations performed there.

//  Example of a CSV input line : 14.3,5,54,25,-15,85.1
//    Corresponding output line : 14.3,5,54,25,-15,85.1,15.265386827261616483824740908382

pub fn main() !void {

    // Read the first parameter on the command line
    var args = std.process.args();
    _ = args.next();

    const filename = args.next() orelse {
        std.debug.print("The first mandatory argument is the path of the CSV file to be processed.\n", .{});
        return;
    };

    // Opens the corresponding CSV file for reading
    const file = std.fs.cwd().openFile(filename, .{}) catch |err| {
        std.debug.print("Opening '{s}' indicates2 ... {}\n", .{filename, err});
        return;
    };

    // Statically allocates a memory buffer for standard output
    var stdout_buffer: [4096]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    // Statically allocates a buffer in memory for reading file lines
    var reader_buffer: [2048]u8 = undefined;
    var reader = file.reader(&reader_buffer);

    // Calculates the ΔE2000 of all color pairs in the file, line by line
    while (reader.interface.takeDelimiterExclusive('\n')) |full_line| {
        const line = std.mem.trim(u8, full_line, &std.ascii.whitespace);
        if (10 < line.len) {
            var parts = std.mem.tokenizeScalar(u8, line, ',');
            const delta_e = ciede_2000(
                try std.fmt.parseFloat(f64, parts.next() orelse continue),
                try std.fmt.parseFloat(f64, parts.next() orelse continue),
                try std.fmt.parseFloat(f64, parts.next() orelse continue),
                try std.fmt.parseFloat(f64, parts.next() orelse continue),
                try std.fmt.parseFloat(f64, parts.next() orelse continue),
                try std.fmt.parseFloat(f64, parts.next() orelse continue),
            );
            try stdout.print("{s},{}\n", .{line, delta_e});
        }
    } else |err| {
        switch (err) {
            error.EndOfStream => {},
            else => return err,
        }
    }

    try stdout.flush();
}

// This source code has been designed and tested on Zig versions 0.15.1 and 0.16.0
