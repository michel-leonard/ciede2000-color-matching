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

// L1 = 38.13          a1 = -29.1972       b1 = -25.5468
// L2 = 38.159         a2 = -29.1972       b2 = -25.5468
// CIE ΔE2000 = ΔE00 = 0.02486308193

// L1 = 62.56          a1 = 115.373        b1 = 51.0
// L2 = 62.56          a2 = 121.7163       b2 = 51.0
// CIE ΔE2000 = ΔE00 = 1.2518618965

// L1 = 21.4486        a1 = 83.601         b1 = -14.7
// L2 = 21.4486        a2 = 90.5461        b2 = -14.7
// CIE ΔE2000 = ΔE00 = 1.43363177108

// L1 = 2.8248         a1 = -122.938       b1 = 84.1889
// L2 = 7.47           a2 = -122.938       b2 = 84.1889
// CIE ΔE2000 = ΔE00 = 2.78244086427

// L1 = 33.82          a1 = 61.0           b1 = 3.0
// L2 = 37.82          a2 = 61.0           b2 = 0.7683
// CIE ΔE2000 = ΔE00 = 3.47892233817

// L1 = 47.5562        a1 = -109.0         b1 = 26.0169
// L2 = 47.5562        a2 = -116.0         b2 = 16.3916
// CIE ΔE2000 = ΔE00 = 3.76929351269

// L1 = 74.302         a1 = -64.0          b1 = -52.93
// L2 = 74.71          a2 = -106.117       b2 = -95.0214
// CIE ΔE2000 = ΔE00 = 9.85061334273

// L1 = 29.3461        a1 = -119.268       b1 = -27.8132
// L2 = 10.9           a2 = -53.26         b2 = -4.065
// CIE ΔE2000 = ΔE00 = 19.69305770606

// L1 = 14.8255        a1 = -15.24         b1 = -23.2615
// L2 = 21.18          a2 = -58.0          b2 = -112.2645
// CIE ΔE2000 = ΔE00 = 22.26958766722

// L1 = 19.9           a1 = 115.3644       b1 = 13.3
// L2 = 68.258         a2 = -120.0         b2 = 49.8956
// CIE ΔE2000 = ΔE00 = 123.1230776496

//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
///////////////////////                        ///////////////////////////
///////////////////////        TESTING         ///////////////////////////
///////////////////////                        ///////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////

// The output is intended to be checked by the Large-Scale validator
// at https://michel-leonard.github.io/ciede2000-color-matching

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
		fmt.Printf("%g,%g,%g,%g,%g,%g,%.15g\n", l1, a1, b1, l2, a2, b2, deltaE)
	}
}
