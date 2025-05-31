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

///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
/////////////////                         /////////////////////
/////////////////         TESTING         /////////////////////
/////////////////                         /////////////////////
///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////

// The output is intended to be checked by the Large-Scale validator
// at https://michel-leonard.github.io/ciede2000-color-matching/batch.html

fn xorRandom(seed: *u64) u64 {
    seed.* ^= seed.* << 13;
    seed.* ^= seed.* >> 7;
    seed.* ^= seed.* << 17;
    return seed.*;
}

fn randDouble64(min: f64, max: f64, seed: *u64) f64 {
    const r = xorRandom(seed);
    const normalized = @as(f64, @floatFromInt(r)) / 18446744073709551616.0; // 2^64
    return min + (max - min) * normalized;
}

fn randBit(seed: *u64) u1 {
    if (1 == xorRandom(seed) & 1) { return 0; } else { return 1; }
}

fn roundToDigits(val: f64, digits: u32) f64 {
    const factor = std.math.pow(f64, 10.0, @floatFromInt(digits));
    return @round(val * factor) / factor;
}

fn randomComponent(seed: *u64, range: f64, offset: f64) f64 {
    const digits = randBit(seed);
    const value = randDouble64(offset, offset + range, seed);
    return roundToDigits(value, digits);
}

fn getIterations() usize {
    const args = std.process.argsAlloc(std.heap.page_allocator) catch return 10000;
    if (args.len > 1) {
        const parsed = std.fmt.parseInt(usize, args[1], 10) catch return 10000;
        return if (parsed > 0) parsed else 10000;
    }
    return 10000;
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    var seed: u64 = @intCast(std.time.milliTimestamp());

    const iterations = getIterations();
    var i: usize = 0;
    while (i < iterations) : (i += 1) {
        const l1 = randomComponent(&seed, 100.0, 0.0);
        const a1 = randomComponent(&seed, 256.0, -128.0);
        const b1 = randomComponent(&seed, 256.0, -128.0);
        const l2 = randomComponent(&seed, 100.0, 0.0);
        const a2 = randomComponent(&seed, 256.0, -128.0);
        const b2 = randomComponent(&seed, 256.0, -128.0);

        const delta = ciede_2000(l1, a1, b1, l2, a2, b2);

        try stdout.print("{d},{d},{d},{d},{d},{d},{d}\n",
            .{ l1, a1, b1, l2, a2, b2, delta });
    }
}
