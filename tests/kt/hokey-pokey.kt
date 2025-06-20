import kotlin.math.*
import java.io.File
import kotlin.random.Random

// kotlinc hokey-pokey.kt -include-runtime -d hokeyPokey.jar
// java -jar hokeyPokey.jar 100000

// This function written in Kotlin is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

// The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
// "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
fun ciede_2000(l_1: Double, a_1: Double, b_1: Double, l_2: Double, a_2: Double, b_2: Double): Double {
	// Working in Kotlin with the CIEDE2000 color-difference formula.
	// k_l, k_c, k_h are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	val k_l = 1.0;
	val k_c = 1.0;
	val k_h = 1.0;
	var n = (hypot(a_1, b_1) + hypot(a_2, b_2)) * 0.5;
	n = n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - sqrt(n / (n + 6103515625.0)));
	// hypot calculates the Euclidean distance while avoiding overflow/underflow.
	val c_1 = hypot(a_1 * n, b_1);
	val c_2 = hypot(a_2 * n, b_2);
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	var h_1 = atan2(b_1, a_1 * n);
	var h_2 = atan2(b_2, a_2 * n);
	if (h_1 < 0.0)
		h_1 += 2.0 * PI;
	if (h_2 < 0.0)
		h_2 += 2.0 * PI;
	n = abs(h_2 - h_1);
	// Cross-implementation consistent rounding.
	if (PI - 1E-14 < n && n < PI + 1E-14)
		n = PI;
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	var h_m = (h_1 + h_2) * 0.5;
	var h_d = (h_2 - h_1) * 0.5;
	if (PI < n) {
		if (0.0 < h_d)
			h_d -= PI;
		else
			h_d += PI;
		h_m += PI;
	}
	val p = 36.0 * h_m - 55.0 * PI;
	n = (c_1 + c_2) * 0.5;
	n = n * n * n * n * n * n * n;
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	val r_t = -2.0 * sqrt(n / (n + 6103515625.0)) * sin(PI / 3.0 * exp((p * p) / (-25.0 * PI * PI)));
	n = (l_1 + l_2) * 0.5;
	n = (n - 50.0) * (n - 50.0);
	// Lightness.
	val l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / sqrt(20.0 + n)));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	val t = 1.0 +	0.24 * sin(2.0 * h_m + PI * 0.5) +
			0.32 * sin(3.0 * h_m + 8.0 * PI / 15.0) -
			0.17 * sin(h_m + PI / 3.0) -
			0.20 * sin(4.0 * h_m + 3.0 * PI / 20.0);
	n = c_1 + c_2;
	// Hue.
	val h = 2.0 * sqrt(c_1 * c_2) * sin(h_d) / (k_h * (1.0 + 0.0075 * n * t));
	// Chroma.
	val c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
	// Returns the square root so that the Delta E 2000 reflects the actual geometric
	// distance within the color space, which ranges from 0 to approximately 185.
	return sqrt(l * l + h * h + c * c + c * h * r_t);
}

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

// L1 = 26.0           a1 = 28.0           b1 = -47.0654
// L2 = 28.0           a2 = 106.0          b2 = -73.4484
// CIE ΔE2000 = ΔE00 = 21.31365366738

/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
//////////////////                          /////////////////////////
//////////////////                          /////////////////////////
//////////////////         TESTING          /////////////////////////
//////////////////                          /////////////////////////
//////////////////                          /////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////

fun prepare_values(numLines: Int) {
    val filename = "./values-kt.txt"
    println("prepare_values('$filename', $numLines)")

    File(filename).bufferedWriter().use { writer ->
        for (i in 0 until numLines) {
			// Sometimes round to nearest integer
            val L1 = Random.nextDouble(0.0, 100.0).let { if (i % 2 == 1) it.roundToInt().toDouble() else it }
            val a1 = Random.nextDouble(-128.0, 128.0).let { if (i % 4 == 1) it.roundToInt().toDouble() else it }
            val b1 = Random.nextDouble(-128.0, 128.0).let { if (i % 8 == 1) it.roundToInt().toDouble() else it }
            val L2 = Random.nextDouble(0.0, 100.0).let { if (i % 16 == 1) it.roundToInt().toDouble() else it }
            val a2 = Random.nextDouble(-128.0, 128.0).let { if (i % 32 == 1) it.roundToInt().toDouble() else it }
            val b2 = Random.nextDouble(-128.0, 128.0).let { if (i % 64 == 1) it.roundToInt().toDouble() else it }

            if (i % 1000 == 0) print('.')

            val deltaE = ciede_2000(L1, a1, b1, L2, a2, b2)
            writer.write("$L1,$a1,$b1,$L2,$a2,$b2,$deltaE\n")
        }
    }
}

fun compare_values(ext: String) {
    val filename = "./../$ext/values-$ext.txt"
    println("compare_values('$filename')")

	val file = File(filename)
    var count = 0
    val tolerance = 1e-10

    file.forEachLine { line ->
        val values = line.split(",").map { it.toDouble() }
        if (values.size == 7) {
            val res = ciede_2000(values[0], values[1], values[2], values[3], values[4], values[5])
            if (!res.isFinite() || !values[6].isFinite() || abs(res - values[6]) > tolerance) {
                println("Mismatch: expected [${values[0]}, ${values[1]}, ${values[2]}, ${values[3]}, ${values[4]}, ${values[5]}] => ${values[6]}, got $res")
            }
            count++
            if (count % 1000 == 0) print(".")
        }
    }
}

fun main(args: Array<String>) {
    if (args.isNotEmpty()) {
        val param = args[0]
        if (Regex("^[a-z]+$").matches(param)) {
            compare_values(param)
        } else if(Regex("^[1-9][0-9]{0,7}$").matches(param)) {
			prepare_values(param.toInt())
		}else {
            println("Invalid argument format.")
        }
    } else {
        println("Please provide a parameter.")
    }
}
