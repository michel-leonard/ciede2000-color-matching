// This function written in Java is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

import static java.lang.Math.PI;
import static java.lang.Math.sqrt;
import static java.lang.Math.hypot;
import static java.lang.Math.atan2;
import static java.lang.Math.abs;
import static java.lang.Math.sin;
import static java.lang.Math.exp;

public class Main {

	// The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
	// "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
	static double ciede_2000(final double l_1, final double a_1, final double b_1, final double l_2, final double a_2, final double b_2) {
		// Working in Java with the CIEDE2000 color-difference formula.
		// k_l, k_c, k_h are parametric factors to be adjusted according to
		// different viewing parameters such as textures, backgrounds...
		final double k_l = 1.0, k_c = 1.0, k_h = 1.0;
		double n = (hypot(a_1, b_1) + hypot(a_2, b_2)) * 0.5;
		n = n * n * n * n * n * n * n;
		// A factor involving chroma raised to the power of 7 designed to make
		// the influence of chroma on the total color difference more accurate.
		n = 1.0 + 0.5 * (1.0 - sqrt(n / (n + 6103515625.0)));
		// hypot calculates the Euclidean distance while avoiding overflow/underflow.
		final double c_1 = hypot(a_1 * n, b_1), c_2 = hypot(a_2 * n, b_2);
		// atan2 is preferred over atan because it accurately computes the angle of
		// a point (x, y) in all quadrants, handling the signs of both coordinates.
		double h_1 = atan2(b_1, a_1 * n), h_2 = atan2(b_2, a_2 * n);
		h_1 += 2.0 * PI * Boolean.compare(h_1 < 0.0, false);
		h_2 += 2.0 * PI * Boolean.compare(h_2 < 0.0, false);
		n = abs(h_2 - h_1);
		// Cross-implementation consistent rounding.
		if (PI - 1E-14 < n && n < PI + 1E-14)
			n = PI;
		// When the hue angles lie in different quadrants, the straightforward
		// average can produce a mean that incorrectly suggests a hue angle in
		// the wrong quadrant, the next lines handle this issue.
		double h_m = (h_1 + h_2) * 0.5, h_d = (h_2 - h_1) * 0.5;
		if (PI < n) {
			if (0.0 < h_d)
				h_d -= PI;
			else
				h_d += PI;
			h_m += PI;
		}
		final double p = 36.0 * h_m - 55.0 * PI;
		n = (c_1 + c_2) * 0.5;
		n = n * n * n * n * n * n * n;
		// The hue rotation correction term is designed to account for the
		// non-linear behavior of hue differences in the blue region.
		final double r_t = -2.0 * sqrt(n / (n + 6103515625.0))
				* sin(PI / 3.0 * exp(p * p / (-25.0 * PI * PI)));
		n = (l_1 + l_2) * 0.5;
		n = (n - 50.0) * (n - 50.0);
		// Lightness.
		final double l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / sqrt(20.0 + n)));
		// These coefficients adjust the impact of different harmonic
		// components on the hue difference calculation.
		final double t = 1.0 + 0.24 * sin(2.0 * h_m + PI * 0.5)
				+ 0.32 * sin(3.0 * h_m + 8.0 * PI / 15.0)
				- 0.17 * sin(h_m + PI / 3.0)
				- 0.20 * sin(4.0 * h_m + 3.0 * PI / 20.0);
		n = c_1 + c_2;
		// Hue.
		final double h = 2.0 * sqrt(c_1 * c_2) * sin(h_d) / (k_h * (1.0 + 0.0075 * n * t));
		// Chroma.
		final double c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
		// Returns the square root so that the Delta E 2000 reflects the actual geometric
		// distance within the color space, which ranges from 0 to approximately 185.
		return sqrt(l * l + h * h + c * c + c * h * r_t);
	}

	// These color conversion functions written in Java are released into the public domain.
	// They are provided "as is" without any warranty, express or implied.

	// rgb in 0..1
	public static double[] rgb_to_xyz(double r, double g, double b) {
		// Apply a gamma correction to each channel.
		r = r < 0.040448236276933 ? r / 12.92 : Math.pow((r + 0.055) / 1.055, 2.4);
		g = g < 0.040448236276933 ? g / 12.92 : Math.pow((g + 0.055) / 1.055, 2.4);
		b = b < 0.040448236276933 ? b / 12.92 : Math.pow((b + 0.055) / 1.055, 2.4);

		// Applying linear transformation using RGB to XYZ transformation matrix.
		final double x = r * 41.24564390896921145 + g * 35.75760776439090507 + b * 18.04374830853290341;
		final double y = r * 21.26728514056222474 + g * 71.51521552878181013 + b * 7.21749933075596513;
		final double z = r * 1.93338955823293176 + g * 11.91919550818385936 + b * 95.03040770337479886;

		return new double[]{x, y, z};
	}

	public static double[] xyz_to_lab(double x, double y, double z) {
		// Reference white point (D65)
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
		// Reference white point (D65)
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
		r = r < 0.0031306684424956 ? 12.92 * r : 1.055 * Math.pow(r, 1.0 / 2.4) - 0.055;
		g = g < 0.0031306684424956 ? 12.92 * g : 1.055 * Math.pow(g, 1.0 / 2.4) - 0.055;
		b = b < 0.0031306684424956 ? 12.92 * b : 1.055 * Math.pow(b, 1.0 / 2.4) - 0.055;

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

	public static double[] conv(String[] s) {
		final int[] rgb = hex_to_rgb(s[0]);
		return rgb_to_lab(rgb[0] / 255.0, rgb[1] / 255.0, rgb[2] / 255.0);
	}

	public static void main(String[] args) {

		//////////////////////////////////////////////////
		///////////                      /////////////////
		///////////   CIE ΔE2000 Demo    /////////////////
		///////////                      /////////////////
		//////////////////////////////////////////////////

		// The goal of this demo is to use the CIEDE2000 function to identify,
		// for each hexadecimal color in set 1, the closest hexadecimal color in set 2.

		final String[][] hex_set_1 = {{"#ffe4c4", "bisque"}, {"#9acd32", "yellowgreen"}, {"#808080", "gray"}, {"#ff69b4", "hotpink"}, {"#add8e6", "lightblue"}, {"#483d8b", "darkslateblue"}, {"#789", "lightslategray"}, {"#6495ed", "cornflowerblue"}, {"#fffacd", "lemonchiffon"}, {"#ffa07a", "lightsalmon"}, {"#a52a2a", "brown"}, {"#bc8f8f", "rosybrown"}, {"#f5deb3", "wheat"}, {"#48d1cc", "mediumturquoise"}, {"#ffdab9", "peachpuff"}, {"#ffb6c1", "lightpink"}, {"#3cb371", "mediumseagreen"}, {"#228b22", "forestgreen"}, {"#fffaf0", "floralwhite"}, {"#fafad2", "lightgoldenrodyellow"}, {"#90ee90", "lightgreen"}, {"#bdb76b", "darkkhaki"}, {"#daa520", "goldenrod"}, {"#8fbc8f", "darkseagreen"}, {"#ff6347", "tomato"}, {"#ff1493", "deeppink"}, {"#00bfff", "deepskyblue"}, {"#556b2f", "darkolivegreen"}, {"#ff7f50", "coral"}, {"#b22222", "firebrick"}, {"#fffff0", "ivory"}, {"#9400d3", "darkviolet"}, {"#ffffe0", "lightyellow"}, {"#008080", "teal"}, {"#000", "black"}, {"#faf0e6", "linen"}, {"#e9967a", "darksalmon"}, {"#ff8c00", "darkorange"}, {"#2f4f4f", "darkslategray"}, {"#006400", "darkgreen"}, {"#cd5c5c", "indianred"}, {"#808000", "olive"}, {"#6b8e23", "olivedrab"}, {"#4b0082", "indigo"}, {"#ba55d3", "mediumorchid"}, {"#d8bfd8", "thistle"}, {"#00008b", "darkblue"}, {"#ffefd5", "papayawhip"}, {"#7b68ee", "mediumslateblue"}, {"#fdf5e6", "oldlace"}, {"#0ff", "aqua"}, {"#4169e1", "royalblue"}, {"#9932cc", "darkorchid"}, {"#f0f", "fuchsia"}, {"#8b4513", "saddlebrown"}, {"#008b8b", "darkcyan"}, {"#800080", "purple"}, {"#ffebcd", "blanchedalmond"}, {"#00ff7f", "springgreen"}, {"#ffc0cb", "pink"}, {"#20b2aa", "lightseagreen"}, {"#6a5acd", "slateblue"}, {"#98fb98", "palegreen"}, {"#dda0dd", "plum"}, {"#00f", "blue"}, {"#f4a460", "sandybrown"}, {"#0f0", "lime"}, {"#40e0d0", "turquoise"}, {"#dc143c", "crimson"}, {"#fff8dc", "cornsilk"}};
		final String[][] hex_set_2 = {{"#faebd7", "antiquewhite"}, {"#fff", "white"}, {"#9370db", "mediumpurple"}, {"#a9a9a9", "darkgray"}, {"#ffa500", "orange"}, {"#1e90ff", "dodgerblue"}, {"#191970", "midnightblue"}, {"#f5fffa", "mintcream"}, {"#a0522d", "sienna"}, {"#deb887", "burlywood"}, {"#e6e6fa", "lavender"}, {"#8a2be2", "blueviolet"}, {"#ffe4e1", "mistyrose"}, {"#ff4500", "orangered"}, {"#afeeee", "paleturquoise"}, {"#f0fff0", "honeydew"}, {"#66cdaa", "mediumaquamarine"}, {"#fff0f5", "lavenderblush"}, {"#32cd32", "limegreen"}, {"#0000cd", "mediumblue"}, {"#c0c0c0", "silver"}, {"#800000", "maroon"}, {"#8b0000", "darkred"}, {"#d2b48c", "tan"}, {"#ffd700", "gold"}, {"#5f9ea0", "cadetblue"}, {"#00ced1", "darkturquoise"}, {"#ff0", "yellow"}, {"#db7093", "palevioletred"}, {"#b8860b", "darkgoldenrod"}, {"#708090", "slategray"}, {"#00fa9a", "mediumspringgreen"}, {"#f08080", "lightcoral"}, {"#dcdcdc", "gainsboro"}, {"#ee82ee", "violet"}, {"#d3d3d3", "lightgray"}, {"#fff5ee", "seashell"}, {"#d2691e", "chocolate"}, {"#f00", "red"}, {"#f5f5dc", "beige"}, {"#b0e0e6", "powderblue"}, {"#cd853f", "peru"}, {"#7fffd4", "aquamarine"}, {"#adff2f", "greenyellow"}, {"#f0e68c", "khaki"}, {"#b0c4de", "lightsteelblue"}, {"#f0f8ff", "aliceblue"}, {"#7fff00", "chartreuse"}, {"#ffdead", "navajowhite"}, {"#2e8b57", "seagreen"}, {"#8b008b", "darkmagenta"}, {"#eee8aa", "palegoldenrod"}, {"#fa8072", "salmon"}, {"#e0ffff", "lightcyan"}, {"#f8f8ff", "ghostwhite"}, {"#da70d6", "orchid"}, {"#696969", "dimgray"}, {"#87cefa", "lightskyblue"}, {"#87ceeb", "skyblue"}, {"#ffe4b5", "moccasin"}, {"#000080", "navy"}, {"#4682b4", "steelblue"}, {"#008000", "green"}, {"#c71585", "mediumvioletred"}, {"#f0ffff", "azure"}, {"#7cfc00", "lawngreen"}, {"#639", "rebeccapurple"}, {"#fffafa", "snow"}};

		// Converts the hexadecimal colors to L*a*b* colors.
		final double[][] lab_set_1 = java.util.Arrays.stream(hex_set_1).map(Main::conv).toArray(double[][]::new);
		final double[][] lab_set_2 = java.util.Arrays.stream(hex_set_2).map(Main::conv).toArray(double[][]::new);

		for (int i = 0, k = 0; i < lab_set_1.length; ++i) {
			double min_delta_e = Double.MAX_VALUE;
			// For each color of the set 1.
			final double[] color_1 = lab_set_1[i];
			for (int j = 0; j < lab_set_2.length; ++j) {
				final double[] color_2 = lab_set_2[j];
				// We optionally ignore strictly equal colors, they have a color difference of 0.
				if (color_1[0] == color_2[0] && color_1[1] == color_2[1] && color_1[2] == color_2[2])
					continue;
				// We calculate the color difference.
				final double delta_e = ciede_2000(color_1[0], color_1[1], color_1[2], color_2[0], color_2[1], color_2[2]);
				if (delta_e < min_delta_e) {
					// Based on the difference, we identify the closest color from the set 2.
					min_delta_e = delta_e;
					k = j;
				}
			}
			// And we display the results.
			final String[] hex_1 = hex_set_1[i];
			final String[] hex_2 = hex_set_1[k];
			String str = "The closest color from " + hex_1[1] + " = " + hex_1[0] + " ";
			str += "is " + hex_2[1] + " = " + hex_2[0] + " ";
			str += "with a distance of " + String.format("%.05f", min_delta_e);
			System.out.println(str);
		}
	}

	// javac 22 was used to compile this java source.

}
