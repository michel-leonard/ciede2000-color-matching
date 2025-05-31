// These color conversion functions written in Java are released into the public domain.
// They are provided "as is" without any warranty, express or implied.

public class Main {

	// rgb in 0..1
	public static double[] rgb_to_xyz(double r, double g, double b) {
		// Apply a gamma correction to each channel.
		r = r < 0.0404482362771082 ? r / 12.92 : Math.pow((r + 0.055) / 1.055, 2.4);
		g = g < 0.0404482362771082 ? g / 12.92 : Math.pow((g + 0.055) / 1.055, 2.4);
		b = b < 0.0404482362771082 ? b / 12.92 : Math.pow((b + 0.055) / 1.055, 2.4);

		// Applying linear transformation using RGB to XYZ transformation matrix.
		final double x = r * 41.24564390896921 + g * 35.7576077643909 + b * 18.043748326639894;
		final double y = r * 21.267285140562248 + g * 71.5152155287818 + b * 7.217499330655958;
		final double z = r * 1.9333895582329317 + g * 11.9192025881303 + b * 95.03040785363677;

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
		double r = x * 0.032404541621141054 + y * -0.015371385127977166 + z * -0.004985314095560162;
		double g = x * -0.009692660305051868 + y * 0.018760108454466942 + z * 0.0004155601753034984;
		double b = x * 0.0005564343095911469 + y * -0.0020402591351675387 + z * 0.010572251882231791;

		// Apply gamma correction.
		r = r < 0.0031306684425005883 ? 12.92 * r : 1.055 * Math.pow(r, 1.0 / 2.4) - 0.055;
		g = g < 0.0031306684425005883 ? 12.92 * g : 1.055 * Math.pow(g, 1.0 / 2.4) - 0.055;
		b = b < 0.0031306684425005883 ? 12.92 * b : 1.055 * Math.pow(b, 1.0 / 2.4) - 0.055;

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

	// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching

	// Constants used in Color Conversion :
	// 216.0 / 24389.0 = 0.0088564516790356308171716757554635286399606379925376194185903481077
	// 841.0 / 108.0 = 7.78703703703703703703703703703703703703703703703703703703703703703703703703
	// 4.0 / 29.0 = 0.13793103448275862068965517241379310344827586206896551724137931034482758620
	// 24389.0 / 27.0 = 903.296296296296296296296296296296296296296296296296296296296296296296296296
	// 1.0 / 2.4 = 0.41666666666666666666666666666666666666666666666666666666666666666666666666

}
