(* This function written in Wolfram Language is not affiliated with the CIE (International Commission on Illumination), *)
(* and is released into the public domain. It is provided "as is" without any warranty, express or implied. *)

(* The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference. *)
(* "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127. *)
ciede2000 = Compile[{
		{l1, _Real},
		{a1, _Real},
		{b1, _Real},
		{l2, _Real},
		{a2, _Real},
		{b2, _Real}
	},
	Module[
		(* Working in Mathematica with the CIEDE2000 color-difference formula. *)
		(* kl, kc, kh are parametric factors to be adjusted according to *)
		(* different viewing parameters such as textures, backgrounds... *)
		{kl, kc, kh, n, c1, c2, h1, h2, hm, p, t, h, c},
		kl = 1.0;
		kc = 1.0;
		kh = 1.0;
		n = (Sqrt[a1 * a1 + b1 * b1] + Sqrt[a2 * a2 + b2 * b2]) * 0.5;
		n = n * n * n * n * n * n * n;
		(* A factor involving chroma raised to the power of 7 designed to make *)
		(* the influence of chroma on the total color difference more accurate. *)
		n = 1.0 + 0.5 * (1.0 - Sqrt[n / (n + 6103515625.0)]);
		c1 = Sqrt[a1 * a1 * n * n + b1 * b1];
		c2 = Sqrt[a2 * a2 * n * n + b2 * b2];
		(* atan2 is preferred over atan because it accurately computes the angle of *)
		(* a point (x, y) in all quadrants, handling the signs of both coordinates. *)
		h1 = ArcTan[a1 * n, b1];
		h2 = ArcTan[a2 * n, b2];
		If[h1 < 0.0, h1 += 2.0 * Pi];
		If[h2 < 0.0, h2 += 2.0 * Pi];
		n = Abs[h2 - h1];
		(* Cross-implementation consistent rounding. *)
		If[Pi - 1E-14 < n && n < Pi + 1E-14, n = Pi];
		(* When the hue angles lie in different quadrants, the straightforward *)
		(* average can produce a mean that incorrectly suggests a hue angle in *)
		(* the wrong quadrant, the next lines handle this issue. *)
		hm = (h1 + h2) * 0.5;
		hd = (h2 - h1) * 0.5;
		If[Pi < n, If[0.0 < hd, hd -= Pi, hd += Pi]; hm += Pi];
		p = 36.0 * hm - 55.0 * Pi;
		n = (c1 + c2) * 0.5;
		n = n * n * n * n * n * n * n;
		(* The hue rotation correction term is designed to account for the *)
		(* non-linear behavior of hue differences in the blue region. *)
		rt = -2.0 * Sqrt[n / (n + 6103515625.0)]
				* Sin[Pi / 3.0 * Exp[p * p / (-25.0 * Pi * Pi)]];
		n = (l1 + l2) * 0.5;
		n = (n - 50.0) * (n - 50.0);
		(* Lightness. *)
		l = (l2 - l1) / (kl * (1.0 + 0.015 * n / Sqrt[20.0 + n]));
		(* These coefficients adjust the impact of different harmonic *)
		(* components on the hue difference calculation. *)
		t = 1.0	+ 0.24 * Sin[2.0 * hm + Pi * 0.5]
			+ 0.32 * Sin[3.0 * hm + 8.0 * Pi / 15.0]
			- 0.17 * Sin[hm + Pi / 3.0]
			- 0.20 * Sin[4.0 * hm + 3.0 * Pi / 20.0];
		n = c1 + c2;
		(* Hue. *)
		h = 2.0 * Sqrt[c1 * c2] * Sin[hd] / (kh * (1.0 + 0.0075 * n * t));
		(* Chroma. *)
		c = (c2 - c1) / (kc * (1.0 + 0.0225 * n));
		(* Returns the square root so that the Delta E 2000 reflects the actual geometric *)
		(* distance within the color space, which ranges from 0 to approximately 185. *)
		Sqrt[l * l + h * h + c * c + c * h * rt]
	],
	CompilationTarget -> "C",
	RuntimeOptions -> "Speed",
	RuntimeAttributes -> {Listable},
	Parallelization -> True
]

(* GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
    More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

L1 = 90.8062        a1 = -67.4828       b1 = -14.84
L2 = 90.8062        a2 = -67.393        b2 = -14.84
CIE ΔE2000 = ΔE00 = 0.023460554

L1 = 1.4            a1 = 119.202        b1 = -65.72
L2 = 1.4            a2 = 118.096        b2 = -65.8057
CIE ΔE2000 = ΔE00 = 0.21238884448

L1 = 57.4           a1 = 57.0           b1 = -99.5
L2 = 57.4           a2 = 55.14          b2 = -97.4
CIE ΔE2000 = ΔE00 = 0.44314422243

L1 = 73.1976        a1 = -69.0          b1 = -86.426
L2 = 77.63          a2 = -69.0          b2 = -86.426
CIE ΔE2000 = ΔE00 = 3.22253633705

L1 = 4.15           a1 = 125.906        b1 = -21.0
L2 = 20.683         a2 = 71.9368        b2 = -28.0054
CIE ΔE2000 = ΔE00 = 15.27697673642

L1 = 73.31          a1 = 50.4           b1 = 123.2
L2 = 88.12          a2 = 20.1395        b2 = 114.13
CIE ΔE2000 = ΔE00 = 16.48550329436

L1 = 21.5732        a1 = -41.46         b1 = -25.6169
L2 = 35.38          a2 = -61.7685       b2 = -5.9
CIE ΔE2000 = ΔE00 = 17.57712434843

L1 = 62.4           a1 = -58.43         b1 = 18.0
L2 = 81.0           a2 = -122.3         b2 = 15.9
CIE ΔE2000 = ΔE00 = 19.41937000583

L1 = 93.13          a1 = -125.676       b1 = -59.0
L2 = 80.0           a2 = -72.2577       b2 = 91.7967
CIE ΔE2000 = ΔE00 = 49.94254455934

L1 = 78.0           a1 = 108.174        b1 = -55.18
L2 = 9.779          a2 = 16.4277        b2 = 119.5885
CIE ΔE2000 = ΔE00 = 100.76871269956 *)

(* --------------------------------------------
-----------------------------------------------
-------                                 -------
-------           CIEDE 2000            -------
-------      Testing Random Colors      -------
-------                                 -------
-----------------------------------------------
-------------------------------------------- *)

(*
  This test script works by first creating a dummy CSV file with sample L*a*b* color data,
  then processes it line by line using the ciede2000 function to calculate color differences.
  The results are saved to a new CSV file and displayed at the end.

  When using a real CSV file :
   - comment out the lines that create and export the dummy data (up to and including the Export function).
   - comment out the final Print statement that displays the entire result file (including the Import function).
*)

(* Define the initial data as a list of lists.
Each sublist contains 6 numeric values representing two L*a*b* colors *)
data = {
	{30.169, -76.6, -18.7, 85.541, 25, 8.57},
	{24.224, -127.527, -66.1, 4.3, -2.2, -58.776},
	{65.103, -114.01, 17, 40.344, -94.98, -92.51}
};

(* Export the data to a CSV file named "samples.csv" *)
Export["samples.csv", data]

(* Open the CSV file for reading *)
inputStream = OpenRead["samples.csv"];

(* Open a new CSV file "samples_out.csv" for writing the results *)
outputStream = OpenWrite["samples-out.csv"];

(* Start an infinite loop to read each line from the input file *)
While[True,
	(* Read one line from the input stream *)
	line = ReadLine[inputStream];

	(* If the end of file is reached, exit the loop *)
	If[line === EndOfFile, Break[]];

	(* Split the line by commas, convert each substring to a number *)
	nums = ToExpression /@ StringSplit[line, ","];

	(* Calculate the Delta E 2000 (color difference) using ciede2000 with the six numbers as arguments *)
	deltaE = ciede2000 @@ nums;

	(* Write the original line plus the calculated deltaE value to the output file,
	 converting deltaE to a string with 15 digits of precision,
	 and adding a newline at the end *)
	WriteString[outputStream, line <> "," <> ToString@SetPrecision[deltaE, 15] <> "\n"];
];

(* Close both input and output file streams *)
Close[inputStream];
Close[outputStream];

(* Import the content of the output CSV file as plain text *)
content = Import["samples-out.csv", "Text"];

(* Print the entire content of the output file to the console *)
Print[content]
