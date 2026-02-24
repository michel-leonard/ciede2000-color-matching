(* This function written in Wolfram Language is not affiliated with the CIE (International Commission on Illumination),
and is released into the public domain. It is provided "as is" without any warranty, express or implied. *)

(* The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
"l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127. *)
ciede2000[l1_Real, a1_Real, b1_Real, l2_Real, a2_Real, b2_Real] := Module[
	(* Working in Mathematica with the CIEDE2000 color-difference formula.
	kl, kc, kh are parametric factors to be adjusted according to
	different viewing parameters such as textures, backgrounds... *)
	{kl, kc, kh, n, c1, c2, h1, h2, npi, hm, p, t, h, c},
	kl = 1.0;
	kc = 1.0;
	kh = 1.0;
	npi = N[Pi];
	n = (Sqrt[a1 * a1 + b1 * b1] + Sqrt[a2 * a2 + b2 * b2]) * 0.5;
	n = n * n * n * n * n * n * n;
	(* A factor involving chroma raised to the power of 7 designed to make
	the influence of chroma on the total color difference more accurate. *)
	n = 1.0 + 0.5 * (1.0 - Sqrt[n / (n + 6103515625.0)]);
	(* Application of the chroma correction factor. *)
 	c1 = Sqrt[a1 * a1 * n * n + b1 * b1];
	c2 = Sqrt[a2 * a2 * n * n + b2 * b2];
	(* atan2 is preferred over atan because it accurately computes the angle of
	a point (x, y) in all quadrants, handling the signs of both coordinates. *)
	h1 = If[a1 == 0.0 && b1 == 0.0, 0.0, ArcTan[a1 * n, b1]];
	h2 = If[a2 == 0.0 && b2 == 0.0, 0.0, ArcTan[a2 * n, b2]];
	If[h1 < 0.0, h1 += 2.0 * npi];
	If[h2 < 0.0, h2 += 2.0 * npi];
	n = Abs[h2 - h1];
	(* Cross-implementation consistent rounding. *)
	If[npi - 1E-14 < n && n < npi + 1E-14, n = npi];
	(* When the hue angles lie in different quadrants, the straightforward
	average can produce a mean that incorrectly suggests a hue angle in
	the wrong quadrant, the next lines handle this issue. *)
	hm = (h1 + h2) * 0.5;
	hd = (h2 - h1) * 0.5;
	If[npi < n,
 		hd += npi;
 		(* 📜 Sharma’s formulation doesn’t use the next line, but the one after it,
		and these two variants differ by ±0.0003 on the final color differences. *)
 		hm += npi;
   		(* If[hm < npi, hm += npi, hm -= npi]; *)
   	];
	p = 36.0 * hm - 55.0 * npi;
	n = (c1 + c2) * 0.5;
	n = n * n * n * n * n * n * n;
	(* The hue rotation correction term is designed to account for the
	non-linear behavior of hue differences in the blue region. *)
	rt = -2.0 * Sqrt[n / (n + 6103515625.0)]
			* Sin[npi / 3.0 * Exp[p * p / (-25.0 * npi * npi)]];
	n = (l1 + l2) * 0.5;
	n = (n - 50.0) * (n - 50.0);
	(* Lightness. *)
	l = (l2 - l1) / (kl * (1.0 + 0.015 * n / Sqrt[20.0 + n]));
	(* These coefficients adjust the impact of different harmonic
	components on the hue difference calculation. *)
	t = 1.0	+ 0.24 * Sin[2.0 * hm + npi * 0.5]
		+ 0.32 * Sin[3.0 * hm + 8.0 * npi / 15.0]
		- 0.17 * Sin[hm + npi / 3.0]
		- 0.20 * Sin[4.0 * hm + 3.0 * npi / 20.0];
	n = c1 + c2;
	(* Hue. *)
	h = 2.0 * Sqrt[c1 * c2] * Sin[hd] / (kh * (1.0 + 0.0075 * n * t));
	(* Chroma. *)
	c = (c2 - c1) / (kc * (1.0 + 0.0225 * n));
	(* Returning the square root ensures that dE00 accurately reflects the
	geometric distance in color space, which can range from 0 to around 185. *)
	Sqrt[l * l + h * h + c * c + c * h * rt]
]

(*
   GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
     Online Tests : https://michel-leonard.github.io/ciede2000-color-matching

   L1 = 40.5   a1 = 18.1   b1 = 4.2
   L2 = 41.4   a2 = 22.9   b2 = -4.5
   CIE ΔE00 = 6.4374339937 (Bruce Lindbloom, Netflix’s VMAF, ...)
   CIE ΔE00 = 6.4374187569 (Gaurav Sharma, OpenJDK, ...)
   Deviation between implementations ≈ 1.5e-5

   See the source code comments for easy switching between these two widely used ΔE*00 implementation variants.
*)
