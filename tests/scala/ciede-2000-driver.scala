// Limited Use License – March 1, 2025

// This source code is provided for public use under the following conditions :
// It may be downloaded, compiled, and executed, including in publicly accessible environments.
// Modification is strictly prohibited without the express written permission of the author.

// © Michel Leonard 2025

object Main extends App {

	import scala.math._

	// The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
	// "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
	def ciede_2000(l_1: Double, a_1: Double, b_1: Double, l_2: Double, a_2: Double, b_2: Double): Double = {
		// Working in Scala with the CIEDE2000 color-difference formula.
		// k_l, k_c, k_h are parametric factors to be adjusted according to
		// different viewing parameters such as textures, backgrounds...
		val k_l: Double = 1.0
		val k_c: Double = 1.0
		val k_h: Double = 1.0
		var n: Double = (sqrt(a_1 * a_1 + b_1 * b_1) + sqrt(a_2 * a_2 + b_2 * b_2)) * 0.5
		n = n * n * n * n * n * n * n
		// A factor involving chroma raised to the power of 7 designed to make
		// the influence of chroma on the total color difference more accurate.
		n = 1.0 + 0.5 * (1.0 - sqrt(n / (n + 6103515625.0)))
		// Application of the chroma correction factor.
		val c_1: Double = sqrt(a_1 * a_1 * n * n + b_1 * b_1)
		val c_2: Double = sqrt(a_2 * a_2 * n * n + b_2 * b_2)
		// atan2 is preferred over atan because it accurately computes the angle of
		// a point (x, y) in all quadrants, handling the signs of both coordinates.
		var h_1: Double = atan2(b_1, a_1 * n)
		var h_2: Double = atan2(b_2, a_2 * n)
		if (h_1 < 0.0) h_1 += 2.0 * scala.math.Pi
		if (h_2 < 0.0) h_2 += 2.0 * scala.math.Pi
		n = abs(h_2 - h_1)
		// Cross-implementation consistent rounding.
		if (scala.math.Pi - 1E-14 < n && n < scala.math.Pi + 1E-14)
			n = scala.math.Pi
		// When the hue angles lie in different quadrants, the straightforward
		// average can produce a mean that incorrectly suggests a hue angle in
		// the wrong quadrant, the next lines handle this issue.
		var h_m: Double = (h_1 + h_2) * 0.5
		var h_d: Double = (h_2 - h_1) * 0.5
		if (scala.math.Pi < n) {
			h_d += scala.math.Pi
			// Sharma's implementation delete the next line and uncomment the one after it,
			// this can lead to a discrepancy of ±0.0003 in the final color difference.
			h_m += scala.math.Pi
			// if (h_m < scala.math.Pi) h_m += scala.math.Pi else h_m -= scala.math.Pi
		}
		val p: Double = 36.0 * h_m - 55.0 * scala.math.Pi
		n = (c_1 + c_2) * 0.5
		n = n * n * n * n * n * n * n
		// The hue rotation correction term is designed to account for the
		// non-linear behavior of hue differences in the blue region.
		val r_t: Double = -2.0 * sqrt(n / (n + 6103515625.0)) *
			sin(scala.math.Pi / 3.0 * exp(p * p / (-25.0 * scala.math.Pi * scala.math.Pi)))
		n = (l_1 + l_2) * 0.5
		n = (n - 50.0) * (n - 50.0)
		// Lightness.
		val l: Double = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / sqrt(20.0 + n)))
		// These coefficients adjust the impact of different harmonic
		// components on the hue difference calculation.
		val t:Double = 1.0 +	0.24 * sin(2.0 * h_m + scala.math.Pi / 2.0) +
					0.32 * sin(3.0 * h_m + 8.0 * scala.math.Pi / 15.0) -
					0.17 * sin(h_m + scala.math.Pi / 3.0) -
					0.20 * sin(4.0 * h_m + 3.0 * scala.math.Pi / 20.0)
		n = c_1 + c_2
		// Hue.
		val h: Double = 2.0 * sqrt(c_1 * c_2) * sin(h_d) / (k_h * (1.0 + 0.0075 * n * t))
		// Chroma.
		val c: Double = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n))
		// Returns the square root so that the DeltaE 2000 reflects the actual geometric
		// distance within the color space, which ranges from 0 to approximately 185.
		sqrt(l * l + h * h + c * c + c * h * r_t)
	}

	// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
	//  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

	// L1 = 25.5106        a1 = 31.972         b1 = 37.0
	// L2 = 32.2           a2 = 45.0           b2 = 31.7276
	// CIE ΔE2000 = ΔE00 = 9.8298073631

	/////////////////////////////////////////////////
	/////////////////////////////////////////////////
	////////////                         ////////////
	////////////    CIEDE2000 Driver     ////////////
	////////////                         ////////////
	/////////////////////////////////////////////////
	/////////////////////////////////////////////////

	// This file is renamed "Main.scala" when it is used for compiling.

	// Reads a CSV file specified as the first command-line argument. For each line, this program
	// in Scala displays the original line with the computed Delta E 2000 color difference appended.
	// The C driver can offer CSV files to process and programmatically check the calculations performed there.

	//  Example of a CSV input line : 67.24,-14.22,70,65,8,46
	//    Corresponding output line : 67.24,-14.22,70,65,8,46,15.46723547943141064

	if (args.length < 1) {
		println("Usage : scala Main <filename>")
		sys.exit(1)
	}

	val source = scala.io.Source.fromFile(args(0))
	try {
		for (line <- source.getLines()) {
			val v: Array[String] = line.split(",")
			if (v.length == 6) {
				val dE: Double = ciede_2000(	v(0).toDouble, v(1).toDouble, v(2).toDouble,
								v(3).toDouble, v(4).toDouble, v(5).toDouble)
				printf("%s,%.15f\n", line.trim(), dE)
			}
		}
	} finally {
		source.close()
	}

}
