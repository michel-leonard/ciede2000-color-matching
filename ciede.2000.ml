(*
 * This function written in C is not affiliated with the CIE (International Commission on Illumination),
 * and is released into the public domain. It is provided "as is" without any warranty, express or implied.
 *)

module ColorspaceLAB = struct
  (* "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127. *)
  type t = { mutable l : float; mutable a : float; mutable b : float }
end

(* The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference. *)
let ciede2000 (lab1: ColorspaceLAB.t) (lab2:ColorspaceLAB.t) =
  match lab1 with {l = l_1; a = a_1; b = b_1} ->
    match lab2 with {l = l_2; a = a_2; b = b_2} ->
      (* Defining pi and a pow7 function for ease of use *)
      let pi = Float.pi in
      let pow7 v = v *. v *. v *. v *. v *. v *. v in
      (*
       * Working in Ocaml with the CIEDE2000 color-difference formula.
       * k_l, k_c, k_h are parametric factors to be adjusted according to
       * different viewing parameters such as textures, backgrounds...
       *)
      let k_l = 1.0 in
      let k_c = 1.0 in
      let k_h = 1.0 in

      let n = ((sqrt (a_1 *. a_1 +. b_1 *. b_1)) +. (sqrt (a_2 *. a_2 +. b_2 *. b_2))) *. 0.5 in
      let n = pow7 n in
      (*
       * A factor involving chroma raised to the power of 7 designed to make
	     * the influence of chroma on the total color difference more accurate.
       *)
      let n = 1.0 +. 0.5 *. (1.0 -. (sqrt (n /. (n +. 6103515625.0)))) in
      (*Application of the chroma correction factor.*)
      let c_1 = sqrt (a_1 *. a_1 *. n *. n +. b_1 *. b_1) in
      let c_2 = sqrt (a_2 *. a_2 *. n *. n +. b_2 *. b_2) in
      (*
       * atan2 is preferred over atan because it accurately computes the angle of
       * a point (x, y) in all quadrants, handling the signs of both coordinates.
      *)
      let h_1 = atan2 b_1 (a_1 *. n) in
      let h_2 = atan2 b_2 (a_2 *. n) in
      let h_1 = if h_1 < 0.0 then h_1 +. 2.0 *. pi else h_1 in
      let h_2 = if h_2 < 0.0 then h_2 +. 2.0 *. pi else h_2 in

      let n = abs_float (h_2 -. h_1) in
      (* Cross-implementation consistent rounding. *)
      let n = if (pi -. 1E-14 < n) && (n < pi +. 1E-14) then pi else n in
      (*
       * When the hue angles lie in different quadrants, the straightforward
       * average can produce a mean that incorrectly suggests a hue angle in
       * the wrong quadrant, the next lines handle this issue
       *)
      let h_m = (h_1 +. h_2) *. 0.5 in
      let h_d = (h_2 -. h_1) *. 0.5 in
      
      let h_d = if pi < n then h_d +. pi else h_d in
      (*
       * 📜 Sharma’s formulation doesn’t use the next line, but the one after it,
       * and these two variants differ by ±0.0003 on the final color differences.
       *)
      let h_m = if pi < n then h_m +. pi else h_m in
      (* let h_m = h_m +. (
        if pi < n then
          if (h_m < pi) then pi
          else (-. pi)
        else 0.
      ) in
      *)
      let p = 36.0 *. h_m -. 55.0 *. pi in
      let n = (c_1 +. c_2) *. 0.5 in
      let n = pow7 n in
      (*
       * The hue rotation correction term is designed to account for the
       * non-linear behavior of hue differences in the blue region.
       *)
      let r_t = -2.0 *. (sqrt (n /. (n +. 6103515625.0))) *. (sin (pi /. 3.0 *. exp (p *. p /. (-25.0 *. pi *. pi)))) in
      let n = (l_1 +. l_2) *. 0.5 in
      let n = (n -. 50.0) *. (n -. 50.0) in
      (* Lightness. *)
      let l = (l_2 -. l_1) /. (k_l *. (1.0 +. 0.015 *. n /. sqrt (20.0 +. n))) in
      (*
       * These coefficients adjust the impact of different harmonic
       * components on the hue difference calculation.
       *)
      let t = 1.0
        +. 0.24 *. sin (2.0 *. h_m +. pi /. 2.0)
        +. 0.32 *. sin (3.0 *. h_m +. 8.0 *. pi /. 15.0)
        -. 0.17 *. sin (h_m +. pi /. 3.0)
        -. 0.20 *. sin (4.0 *. h_m +. 3.0 *. pi /. 20.0)
      in
      let n = c_1 +. c_2 in
      (* Hue. *)
      let h = 2.0 *. (sqrt (c_1 *. c_2)) *. (sin h_d) /. (k_h *. (1.0 +. 0.0075 *. n *. t)) in
      (* Chroma. *)
      let c = (c_2 -. c_1) /. (k_c *. (1.0 +. 0.0225 *. n)) in
      (*
       * Returning the square root ensures that dE00 accurately reflects the
       * geometric distance in color space, which can range from 0 to around 185.
       *)
      sqrt (l *. l +. h *. h +. c *. c +. c *. h *. r_t)

(*
 * Ocaml implementation by rex0515
 *
 * L1 = 65.4   a1 = 32.8   b1 = -3.5
 * L2 = 64.1   a2 = 26.8   b2 = 4.2
 * CIE ΔE00 = 5.5643553151 (Bruce Lindbloom, Netflix’s VMAF, ...)
 * CIE ΔE00 = 5.5643412178 (Gaurav Sharma, OpenJDK, ...)
 * Deviation between implementations ≈ 1.4e-5
 *
 * See the source code comments for easy switching between these two widely used ΔE*00 implementation variants.
 *)