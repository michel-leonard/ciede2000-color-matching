// This function written in Java is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

public class Main {

	// The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
	// "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
	static double ciede_2000(final double l_1, final double a_1, final double b_1, final double l_2, final double a_2, final double b_2) {
		// Working in Java with the CIEDE2000 color-difference formula.
		// k_l, k_c, k_h are parametric factors to be adjusted according to
		// different viewing parameters such as textures, backgrounds...
		final double k_l = 1.0, k_c = 1.0, k_h = 1.0;
		double n = (Math.sqrt(a_1 * a_1 + b_1 * b_1) + Math.sqrt(a_2 * a_2 + b_2 * b_2)) * 0.5;
		n = n * n * n * n * n * n * n;
		// A factor involving chroma raised to the power of 7 designed to make
		// the influence of chroma on the total color difference more accurate.
		n = 1.0 + 0.5 * (1.0 - Math.sqrt(n / (n + 6103515625.0)));
		// Application of the chroma correction factor.
		final double c_1 = Math.sqrt(a_1 * a_1 * n * n + b_1 * b_1);
		final double c_2 = Math.sqrt(a_2 * a_2 * n * n + b_2 * b_2);
		// atan2 is preferred over atan because it accurately computes the angle of
		// a point (x, y) in all quadrants, handling the signs of both coordinates.
		double h_1 = Math.atan2(b_1, a_1 * n), h_2 = Math.atan2(b_2, a_2 * n);
		h_1 += 2.0 * Math.PI * Boolean.compare(h_1 < 0.0, false);
		h_2 += 2.0 * Math.PI * Boolean.compare(h_2 < 0.0, false);
		n = Math.abs(h_2 - h_1);
		// Cross-implementation consistent rounding.
		if (Math.PI - 1E-14 < n && n < Math.PI + 1E-14)
			n = Math.PI;
		// When the hue angles lie in different quadrants, the straightforward
		// average can produce a mean that incorrectly suggests a hue angle in
		// the wrong quadrant, the next lines handle this issue.
		double h_m = (h_1 + h_2) * 0.5, h_d = (h_2 - h_1) * 0.5;
		if (Math.PI < n) {
			h_d += Math.PI;
			// 📜 Sharma’s formulation doesn’t use the next line, but the one after it,
			// and these two variants differ by ±0.0003 on the final color differences.
			h_m += Math.PI;
			// h_m += h_m < Math.PI ? Math.PI : -Math.PI;
		}
		final double p = 36.0 * h_m - 55.0 * Math.PI;
		n = (c_1 + c_2) * 0.5;
		n = n * n * n * n * n * n * n;
		// The hue rotation correction term is designed to account for the
		// non-linear behavior of hue differences in the blue region.
		final double r_t = -2.0 * Math.sqrt(n / (n + 6103515625.0))
				* Math.sin(Math.PI / 3.0 * Math.exp(p * p / (-25.0 * Math.PI * Math.PI)));
		n = (l_1 + l_2) * 0.5;
		n = (n - 50.0) * (n - 50.0);
		// Lightness.
		final double l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / Math.sqrt(20.0 + n)));
		// These coefficients adjust the impact of different harmonic
		// components on the hue difference calculation.
		final double t = 1.0 + 0.24 * Math.sin(2.0 * h_m + Math.PI * 0.5)
				+ 0.32 * Math.sin(3.0 * h_m + 8.0 * Math.PI / 15.0)
				- 0.17 * Math.sin(h_m + Math.PI / 3.0)
				- 0.20 * Math.sin(4.0 * h_m + 3.0 * Math.PI / 20.0);
		n = c_1 + c_2;
		// Hue.
		final double h = 2.0 * Math.sqrt(c_1 * c_2) * Math.sin(h_d) / (k_h * (1.0 + 0.0075 * n * t));
		// Chroma.
		final double c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
		// Returning the square root ensures that dE00 accurately reflects the
		// geometric distance in color space, which can range from 0 to around 185.
		return Math.sqrt(l * l + h * h + c * c + c * h * r_t);
	}

	// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
	//   Online Tests : https://michel-leonard.github.io/ciede2000-color-matching

	// L1 = 64.6   a1 = 27.2   b1 = 5.0
	// L2 = 64.5   a2 = 22.7   b2 = -3.1
	// CIE ΔE00 = 5.6076197612 (Bruce Lindbloom, Netflix’s VMAF, ...)
	// CIE ΔE00 = 5.6076328718 (Gaurav Sharma, OpenJDK, ...)
	// Deviation between implementations ≈ 1.3e-5

	// See the source code comments for easy switching between these two widely used ΔE*00 implementation variants.

	// These color conversion functions written in Java are released into the public domain.
	// They are provided "as is" without any warranty, express or implied.

	// rgb in 0..1
	public static double[] rgb_to_xyz(double r, double g, double b) {
		// Apply a gamma correction to each channel.
		r = r < 0.040448236277105097 ? r / 12.92 : Math.pow((r + 0.055) / 1.055, 2.4);
		g = g < 0.040448236277105097 ? g / 12.92 : Math.pow((g + 0.055) / 1.055, 2.4);
		b = b < 0.040448236277105097 ? b / 12.92 : Math.pow((b + 0.055) / 1.055, 2.4);

		// Applying linear transformation using RGB to XYZ transformation matrix.
		final double x = r * 41.24564390896921145 + g * 35.75760776439090507 + b * 18.04374830853290341;
		final double y = r * 21.26728514056222474 + g * 71.51521552878181013 + b * 7.21749933075596513;
		final double z = r * 1.93338955823293176 + g * 11.91919550818385936 + b * 95.03040770337479886;

		return new double[]{x, y, z};
	}

	public static double[] xyz_to_lab(double x, double y, double z) {
		// Reference white point : D65 2° Standard observer
		final double refX = 95.047;
		final double refY = 100.000;
		final double refZ = 108.883;

		x /= refX;
		y /= refY;
		z /= refZ;

		// Applying the CIE standard transformation.
		x = x < 216.0 / 24389.0 ? ((841.0 / 108.0) * x) + (4.0 / 29.0) : Math.cbrt(x);
		y = y < 216.0 / 24389.0 ? ((841.0 / 108.0) * y) + (4.0 / 29.0) : Math.cbrt(y);
		z = z < 216.0 / 24389.0 ? ((841.0 / 108.0) * z) + (4.0 / 29.0) : Math.cbrt(z);

		final double l = (116.0 * y) - 16.0;
		final double a = 500.0 * (x - y);
		final double b = 200.0 * (y - z);

		return new double[]{l, a, b};
	}

	// rgb in 0..1
	public static double[] rgb_to_lab(final double r, final double g, final double b) {
		final double[] xyz = rgb_to_xyz(r, g, b);
		return xyz_to_lab(xyz[0], xyz[1], xyz[2]);
	}

	public static double[] lab_to_xyz(final double l, final double a, final double b) {
		// Reference white point : D65 2° Standard observer
		final double refX = 95.047;
		final double refY = 100.000;
		final double refZ = 108.883;

		double y = (l + 16.0) / 116.0;
		double x = a / 500.0 + y;
		double z = y - b / 200.0;

		final double x3 = x * x * x;
		final double z3 = z * z * z;

		x = x3 < 216.0 / 24389.0 ? (x - 4.0 / 29.0) / (841.0 / 108.0) : x3;
		y = l < 8.0 ? l / (24389.0 / 27.0) : y * y * y;
		z = z3 < 216.0 / 24389.0 ? (z - 4.0 / 29.0) / (841.0 / 108.0) : z3;

		return new double[]{x * refX, y * refY, z * refZ};
	}

	// rgb in 0..1
	public static double[] xyz_to_rgb(final double x, final double y, final double z) {
		// Applying linear transformation using the XYZ to RGB transformation matrix.
		double r = x * 0.032404541621141049051 + y * -0.015371385127977165753 + z * -0.004985314095560160079;
		double g = x * -0.009692660305051867686 + y * 0.018760108454466942288 + z * 0.00041556017530349983;
		double b = x * 0.000556434309591145522 + y * -0.002040259135167538416 + z * 0.010572251882231790398;

		// Apply gamma correction.
		r = r < 0.003130668442500634 ? 12.92 * r : 1.055 * Math.pow(r, 1.0 / 2.4) - 0.055;
		g = g < 0.003130668442500634 ? 12.92 * g : 1.055 * Math.pow(g, 1.0 / 2.4) - 0.055;
		b = b < 0.003130668442500634 ? 12.92 * b : 1.055 * Math.pow(b, 1.0 / 2.4) - 0.055;

		return new double[]{r, g, b};
	}

	// rgb in 0..1
	public static double[] lab_to_rgb(final double l, final double a, final double b) {
		final double[] xyz = lab_to_xyz(l, a, b);
		return xyz_to_rgb(xyz[0], xyz[1], xyz[2]);
	}

	// rgb in 0..255
	public static int[] hex_to_rgb(String s) {
		// Also support the short syntax (ie "#FFF") as input.
		final int n = Integer.parseInt((s.length() == 4 ? "#" + s.charAt(1) + s.charAt(1) + s.charAt(2) + s.charAt(2) + s.charAt(3) + s.charAt(3) : s).substring(1), 16);
		return new int[]{n >> 16 & 0xff, n >> 8 & 0xff, n & 0xff};
	}

	// rgb in 0..255
	public static String rgb_to_hex(int r, int g, int b) {
		// Also provide the short syntax (ie "#FFF") as output.
		final String s = "#" + String.format("%02X", r) + String.format("%02X", g) + String.format("%02X", b);
		return s.charAt(1) == s.charAt(2) && s.charAt(3) == s.charAt(4) && s.charAt(5) == s.charAt(6) ? "#" + s.charAt(1) + s.charAt(3) + s.charAt(5) : s;
	}


	// Constants used in Color Conversion :
	// 216.0 / 24389.0 = 0.0088564516790356308171716757554635286399606379925376194185903481077
	// 841.0 / 108.0 = 7.78703703703703703703703703703703703703703703703703703703703703703703703703
	// 4.0 / 29.0 = 0.13793103448275862068965517241379310344827586206896551724137931034482758620
	// 24389.0 / 27.0 = 903.296296296296296296296296296296296296296296296296296296296296296296296296
	// 1.0 / 2.4 = 0.41666666666666666666666666666666666666666666666666666666666666666666666666
	// To get 0.040448236277105097132567243294938 we perform x/12.92 = ((x+0.055)/1.055)^2.4
	// To get 0.00313066844250063403284123841596 we perform 12.92*x = 1.055*x^(1/2.4)-0.055

	//////////////////////////////////////////////////
	///////////                      /////////////////
	///////////   CIE ΔE2000 Demo    /////////////////
	///////////                      /////////////////
	//////////////////////////////////////////////////

	// The goal of this demo in Java is to use the CIEDE2000 function to compare two hexadecimal colors.

	public static void main(String[] args) {
		String hex1 = "#00f";       // blue
		String hex2 = "#483D8B";    // darkslateblue

		// 1. hex -> RGB (0..255)
		int[] rgb1 = hex_to_rgb(hex1);
		int[] rgb2 = hex_to_rgb(hex2);
		System.out.printf("%-8s -> RGB(%d, %d, %d)%n", hex1, rgb1[0], rgb1[1], rgb1[2]);
		System.out.printf("%-8s -> RGB(%d, %d, %d)%n", hex2, rgb2[0], rgb2[1], rgb2[2]);

		// 2. RGB -> LAB
		double[] lab1 = rgb_to_lab(rgb1[0] / 255.0, rgb1[1] / 255.0, rgb1[2] / 255.0);
		double[] lab2 = rgb_to_lab(rgb2[0] / 255.0, rgb2[1] / 255.0, rgb2[2] / 255.0);
		System.out.printf("%-8s -> LAB(L: %.4f, a: %.4f, b: %.4f)%n", hex1, lab1[0], lab1[1], lab1[2]);
		System.out.printf("%-8s -> LAB(L: %.4f, a: %.4f, b: %.4f)%n", hex2, lab2[0], lab2[1], lab2[2]);

		// 3. Delta E 2000
		double deltaE = ciede_2000(lab1[0], lab1[1], lab1[2], lab2[0], lab2[1], lab2[2]);
		System.out.printf("ΔE2000 between %s and %s: %.2f%n", hex1, hex2, deltaE);

		// This shows a ΔE2000 of 15.91
		// javac 22 was used to compile this java source.
	}
}
