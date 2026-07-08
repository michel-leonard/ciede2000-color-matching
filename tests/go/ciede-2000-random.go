// This function written in Go is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

package main

import (
	"fmt"
	"math"
	"math/rand"
	"os"
	"strconv"
	"time"
)

// The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
// "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
func ciede_2000(l_1 float64, a_1 float64, b_1 float64, l_2 float64, a_2 float64, b_2 float64) float64 {
	// Working in Go with the CIEDE2000 color-difference formula.
	const (
		// k_l, k_c, k_h are parametric factors to be adjusted according to
		// different viewing parameters such as textures, backgrounds...
		k_l = 1.0
		k_c = 1.0
		k_h = 1.0
	)
	n := (math.Sqrt(a_1 * a_1 + b_1 * b_1) + math.Sqrt(a_2 * a_2 + b_2 * b_2)) * 0.5
	n = n * n * n * n * n * n * n
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - math.Sqrt(n / (n + 6103515625.0)))
	// Application of the chroma correction factor.
	c_1 := math.Sqrt(a_1 * a_1 * n * n + b_1 * b_1)
	c_2 := math.Sqrt(a_2 * a_2 * n * n + b_2 * b_2)
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	h_1 := math.Atan2(b_1, a_1 * n)
	h_2 := math.Atan2(b_2, a_2 * n)
	if h_1 < 0.0 { h_1 += 2.0 * math.Pi }
	if h_2 < 0.0 { h_2 += 2.0 * math.Pi }
	n = math.Abs(h_2 - h_1)
	// Cross-implementation consistent rounding.
	if math.Pi - 1E-14 < n && n < math.Pi + 1E-14 { n = math.Pi }
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	h_m := (h_1 + h_2) * 0.5
	h_d := (h_2 - h_1) * 0.5
	if math.Pi < n {
		h_d += math.Pi
		// 📜 Sharma’s formulation doesn’t use the next line, but the one after it,
		// and these two variants differ by ±0.0003 on the final color differences.
		h_m += math.Pi
		// if h_m < math.Pi { h_m += math.Pi } else { h_m -= math.Pi }
	}
	p := 36.0 * h_m - 55.0 * math.Pi
	n = (c_1 + c_2) * 0.5
	n = n * n * n * n * n * n * n
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	r_t :=	-2.0 * math.Sqrt(n / (n + 6103515625.0)) *
			math.Sin(math.Pi / 3.0 * math.Exp(p * p / (-25.0 * math.Pi * math.Pi)))
	n = (l_1 + l_2) * 0.5
	n = (n - 50.0) * (n - 50.0)
	// Lightness.
	l := (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / math.Sqrt(20.0 + n)))
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	t := 1.0 +	0.24 * math.Sin(2.0 * h_m + math.Pi * 0.5) +
			0.32 * math.Sin(3.0 * h_m + 8.0 * math.Pi / 15.0) -
			0.17 * math.Sin(h_m + math.Pi / 3.0) -
			0.20 * math.Sin(4.0 * h_m + 3.0 * math.Pi / 20.0)
	n = c_1 + c_2
	// Hue.
	h := 2.0 * math.Sqrt(c_1 * c_2) * math.Sin(h_d) / (k_h * (1.0 + 0.0075 * n * t))
	// Chroma.
	c := (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n))
	// Returning the square root ensures that dE00 accurately reflects the
	// geometric distance in color space, which can range from 0 to around 185.
	return math.Sqrt(l * l + h * h + c * c + c * h * r_t)
}

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//   Online Tests : https://michel-leonard.github.io/ciede2000-color-matching

// L1 = 25.3   a1 = 34.4   b1 = -3.8
// L2 = 27.8   a2 = 39.4   b2 = 4.5
// CIE ΔE00 = 5.4334495584 (Bruce Lindbloom, Netflix’s VMAF, ...)
// CIE ΔE00 = 5.4334652121 (Gaurav Sharma, OpenJDK, ...)
// Deviation between implementations ≈ 1.6e-5

// See the source code comments for easy switching between these two widely used ΔE*00 implementation variants.

///////////////////////////////////////////////
///////////////////////////////////////////////
///////                                 ///////
///////           CIEDE 2000            ///////
///////      Testing Random Colors      ///////
///////                                 ///////
///////////////////////////////////////////////
///////////////////////////////////////////////

// This Go program outputs a CSV file to standard output, with its length determined by the first CLI argument.
// Each line contains seven columns :
// - Three columns for the random standard L*a*b* color
// - Three columns for the random sample L*a*b* color
// - And the seventh column for the precise Delta E 2000 color difference between the standard and sample
// The output will be correct, this can be verified :
// - With the C driver, which provides a dedicated verification feature
// - By using the JavaScript validator at https://michel-leonard.github.io/ciede2000-color-matching

func randInRange(min, max float64) float64 {
	n := min + (max-min)*rand.Float64()
	switch rand.Intn(3) {
	case 0: return math.Round(n)
	case 1: return math.Round(n*10.0) / 10.0
	default: return math.Round(n*100.0) / 100.0
	}
}

func main() {
	rand.Seed(time.Now().UnixNano())

	nIterations := 10000
	if len(os.Args) > 1 {
		if parsed, err := strconv.Atoi(os.Args[1]); err == nil && parsed > 0 {
			nIterations = parsed
		}
	}

	for i := 0; i < nIterations; i++ {
		l1 := randInRange(0.0, 100.0)
		a1 := randInRange(-128.0, 128.0)
		b1 := randInRange(-128.0, 128.0)
		l2 := randInRange(0.0, 100.0)
		a2 := randInRange(-128.0, 128.0)
		b2 := randInRange(-128.0, 128.0)

		deltaE := ciede_2000(l1, a1, b1, l2, a2, b2)
		fmt.Printf("%g,%g,%g,%g,%g,%g,%.17g\n", l1, a1, b1, l2, a2, b2, deltaE)
	}
}
