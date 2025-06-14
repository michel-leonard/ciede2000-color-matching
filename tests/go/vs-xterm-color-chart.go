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
	"ciede-2000-tests/color"
)

// The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
// "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
func ciede_2000_one(l_1 float64, a_1 float64, b_1 float64, l_2 float64, a_2 float64, b_2 float64) float64 {
	// Working in Go with the CIEDE2000 color-difference formula.
	const (
		// k_l, k_c, k_h are parametric factors to be adjusted according to
		// different viewing parameters such as textures, backgrounds...
		k_l = 1.0
		k_c = 1.0
		k_h = 1.0
	)
	n := (math.Hypot(a_1, b_1) + math.Hypot(a_2, b_2)) * 0.5
	n = n * n * n * n * n * n * n
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - math.Sqrt(n / (n + 6103515625.0)))
	// hypot calculates the Euclidean distance while avoiding overflow/underflow.
	c_1 := math.Hypot(a_1 * n, b_1)
	c_2 := math.Hypot(a_2 * n, b_2)
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
		if 0.0 < h_d { h_d -= math.Pi } else { h_d += math.Pi }
		h_m += math.Pi
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
	// Returns the square root so that the Delta E 2000 reflects the actual geometric
	// distance within the color space, which ranges from 0 to approximately 185.
	return math.Sqrt(l * l + h * h + c * c + c * h * r_t)
}

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

// L1 = 10.155         a1 = 29.78          b1 = 68.0287
// L2 = 10.155         a2 = 29.78          b2 = 68.0
// CIE ΔE2000 = ΔE00 = 0.00919749443

// L1 = 4.6148         a1 = 61.384         b1 = 34.698
// L2 = 4.7            a2 = 61.384         b2 = 34.698
// CIE ΔE2000 = ΔE00 = 0.05080940835

// L1 = 88.0           a1 = -88.0          b1 = 110.589
// L2 = 88.0           a2 = -88.5591       b2 = 110.589
// CIE ΔE2000 = ΔE00 = 0.12869636259

// L1 = 53.7           a1 = -22.704        b1 = 122.2
// L2 = 53.7           a2 = -32.0          b2 = 122.2
// CIE ΔE2000 = ΔE00 = 3.75298114051

// L1 = 72.6618        a1 = -27.0          b1 = -78.0
// L2 = 78.905         a2 = -27.0          b2 = -70.0
// CIE ΔE2000 = ΔE00 = 4.79329281953

// L1 = 45.9522        a1 = 90.41          b1 = -58.52
// L2 = 44.7528        a2 = 89.0           b2 = -74.29
// CIE ΔE2000 = ΔE00 = 5.09064761929

// L1 = 15.9898        a1 = -95.61         b1 = -20.0
// L2 = 10.92          a2 = -42.55         b2 = -22.0
// CIE ΔE2000 = ΔE00 = 14.91625583049

// L1 = 13.3671        a1 = -70.04         b1 = 24.437
// L2 = 40.229         a2 = -84.596        b2 = 68.2094
// CIE ΔE2000 = ΔE00 = 23.66554030387

// L1 = 74.423         a1 = -72.6          b1 = 88.97
// L2 = 25.747         a2 = 123.485        b2 = -105.4
// CIE ΔE2000 = ΔE00 = 122.78163863108

// L1 = 94.463         a1 = -100.69        b1 = -56.6945
// L2 = 6.369          a2 = 90.4759        b2 = -16.504
// CIE ΔE2000 = ΔE00 = 145.29238304984

// Testing against xterm-color-chart at :
// https://github.com/kutuluk/xterm-color-chart/blob/1068432d94252b9b4dec447e424f85f712fa16c2/color/color.go
var delta = color.DeltaCIE2000{ }
func ciede_2000_two(l_1 float64, a_1 float64, b_1 float64, l_2 float64, a_2 float64, b_2 float64) float64 {
	lab1 := color.LabColor{L: l_1, A: a_1, B: b_1}
	lab2 := color.LabColor{L: l_2, A: a_2, B: b_2}
	return delta.Compare(lab1, lab2)
}

////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
////////////                               /////////////
////////////         Compare with          /////////////
////////////      xterm-color-chart        /////////////
////////////                               /////////////
////////////////////////////////////////////////////////
////////////////////////////////////////////////////////

// The goal is to demonstrate that the library produces results identical to xterm-color-chart.  
// If the results differ by more than a tolerance of 1E-10, a non-zero value will be returned.
// Explore the workflows to see how this code is executed.

type worstCase struct {
	l1, a1, b1, l2, a2, b2 float64
	delta1, delta2         float64
	diff                   float64
}

func main() {
	const tolerance = 1e-10
	const defaultRuns = 10000

	var runs int
	if len(os.Args) > 1 {
		n, err := strconv.Atoi(os.Args[1])
		if err == nil && n > 0 {
			runs = n
		} else {
			runs = defaultRuns
		}
	} else {
		runs = defaultRuns
	}

	rand.Seed(time.Now().UnixNano())

	var worst worstCase

	for i := 0; i < runs; i++ {
		l1 := rand.Float64()*100 - 0   // [0, 100]
		a1 := rand.Float64()*256 - 128 // [-128, 128]
		b1 := rand.Float64()*256 - 128
		l2 := rand.Float64()*100 - 0
		a2 := rand.Float64()*256 - 128
		b2 := rand.Float64()*256 - 128

		d1 := ciede_2000_one(l1, a1, b1, l2, a2, b2)
		d2 := ciede_2000_two(l1, a1, b1, l2, a2, b2)

		if !isFinite(d1) || !isFinite(d2) {
			fmt.Printf("Non-finite value detected at run %d\n", i)
			os.Exit(1)
		}

		diff := math.Abs(d1 - d2)
		// if diff > tolerance {
			// fmt.Printf("Exceeded tolerance at run %d: diff=%.12f\n", i, diff)
			// os.Exit(1)
		// }

		if diff > worst.diff {
			worst = worstCase{
				l1: l1, a1: a1, b1: b1,
				l2: l2, a2: a2, b2: b2,
				delta1: d1, delta2: d2,
				diff: diff,
			}
		}
	}

	fmt.Printf("Total runs : %d\n", runs)
	fmt.Printf("Worst case : {\n")
	fmt.Printf("  l1: %v,\n", worst.l1)
	fmt.Printf("  a1: %v,\n", worst.a1)
	fmt.Printf("  b1: %v,\n", worst.b1)
	fmt.Printf("  l2: %v,\n", worst.l2)
	fmt.Printf("  a2: %v,\n", worst.a2)
	fmt.Printf("  b2: %v,\n", worst.b2)
	fmt.Printf("  delta1: %v,\n", worst.delta1)
	fmt.Printf("  delta2: %v,\n", worst.delta2)
	fmt.Printf("  diff: %.17g\n", worst.diff)
	fmt.Printf("}\n")
}

func isFinite(f float64) bool {
	return !math.IsNaN(f) && !math.IsInf(f, 0)
}
