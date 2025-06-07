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

(* GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching *)
(*  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html *)

(* L1 = 22.098         a1 = 27.7           b1 = -12.4868 *)
(* L2 = 22.1           a2 = 27.7           b2 = -12.4868 *)
(* CIE ΔE2000 = ΔE00 = 0.00141518752 *)

(* L1 = 8.0            a1 = 94.0           b1 = -61.545 *)
(* L2 = 8.0            a2 = 94.2           b2 = -63.26 *)
(* CIE ΔE2000 = ΔE00 = 0.47836728336 *)

(* L1 = 42.498         a1 = 105.037        b1 = 3.6 *)
(* L2 = 45.9498        a2 = 105.037        b2 = -4.1227 *)
(* CIE ΔE2000 = ΔE00 = 4.08686268687 *)

(* L1 = 2.5            a1 = 20.6           b1 = 19.367 *)
(* L2 = 11.28          a2 = 27.0           b2 = 26.4371 *)
(* CIE ΔE2000 = ΔE00 = 6.60091376731 *)

(* L1 = 28.3           a1 = -42.709        b1 = -86.45 *)
(* L2 = 18.871         a2 = -61.0          b2 = -104.337 *)
(* CIE ΔE2000 = ΔE00 = 8.43178927705 *)

(* L1 = 60.95          a1 = -13.5344       b1 = 34.2 *)
(* L2 = 60.193         a2 = -14.62         b2 = 15.9 *)
(* CIE ΔE2000 = ΔE00 = 9.54397803781 *)

(* L1 = 73.5           a1 = 107.459        b1 = 13.8174 *)
(* L2 = 81.0           a2 = 68.13          b2 = -6.0 *)
(* CIE ΔE2000 = ΔE00 = 11.80000334465 *)

(* L1 = 15.19          a1 = 2.02           b1 = 53.7 *)
(* L2 = 28.3           a2 = 19.5494        b2 = 91.16 *)
(* CIE ΔE2000 = ΔE00 = 15.0067954555 *)

(* L1 = 36.957         a1 = -83.809        b1 = 111.2763 *)
(* L2 = 50.23          a2 = -29.5482       b2 = 81.5 *)
(* CIE ΔE2000 = ΔE00 = 19.03462737945 *)

(* L1 = 57.5           a1 = -89.5017       b1 = -46.314 *)
(* L2 = 45.58          a2 = -52.1811       b2 = -107.0 *)
(* CIE ΔE2000 = ΔE00 = 23.134589387 *)
