; This function written in Racket is not affiliated with the CIE (International Commission on Illumination),
; and is released into the public domain. It is provided "as is" without any warranty, express or implied.

#lang racket

; The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
; "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
(define ciede_2000(lambda (l_1 a_1 b_1 l_2 a_2 b_2)
	; Working in Racket with the CIEDE2000 color-difference formula.
	; k_l, k_c, k_h are parametric factors to be adjusted according to
	; different viewing parameters such as textures, backgrounds...
	(define pi 3.14159265358979323846264338328)
	(define k_l 1.0)
	(define k_c 1.0)
	(define k_h 1.0)
	(define n (* 0.5 (+ (sqrt (+ (* a_1 a_1) (* b_1 b_1))) (sqrt (+ (* a_2 a_2) (* b_2 b_2))))))
	(set! n (* n n n n n n n))
	; A factor involving chroma raised to the power of 7 designed to make
	; the influence of chroma on the total color difference more accurate.
	(set! n (+ 1.0 (* 0.5 (- 1.0 (sqrt (/ n (+ n 6103515625.0)))))))
	; Since hypot is not available, sqrt is used here to calculate the
	; Euclidean distance, without avoiding overflow/underflow.
	(define c_1 (sqrt (+ (* a_1 a_1 n n) (* b_1 b_1))))
	(define c_2 (sqrt (+ (* a_2 a_2 n n) (* b_2 b_2))))
	; atan2 is preferred over atan because it accurately computes the angle of
	; a point (x, y) in all quadrants, handling the signs of both coordinates.
	(define h_1 (atan b_1 (* a_1 n)))
	(define h_2 (atan b_2 (* a_2 n)))
	(if (< h_1 0.0) (set! h_1 (+ h_1 pi pi)) empty)
	(if (< h_2 0.0) (set! h_2 (+ h_2 pi pi)) empty)
	(set! n (abs (- h_2 h_1)))
	; Cross-implementation consistent rounding.
	(if (and (< (- pi 1E-14) n) (< n (+ pi 1E-14))) (set! n pi) empty)
	; When the hue angles lie in different quadrants, the straightforward
	; average can produce a mean that incorrectly suggests a hue angle in
	; the wrong quadrant, the next lines handle this issue.
	(define h_m (* 0.5 (+ h_1 h_2)))
	(define h_d (* 0.5 (- h_2 h_1)))
	(if (< pi n)
		(begin (if (< 0.0 h_d) (set! h_d (- h_d pi)) (set! h_d (+ h_d pi)))
		(set! h_m (+ h_m pi)))
			empty
	)
	(define p (- (* 36.0 h_m) (* 55.0 pi)))
	(set! n (* 0.5 (+ c_1 c_2)))
	(set! n (* n n n n n n n))
	; The hue rotation correction term is designed to account for the
	; non-linear behavior of hue differences in the blue region.
	(define r_t (* -2.0 (sqrt (/ n (+ n 6103515625.0)))
			(sin (* (/ pi 3.0) (exp (/ (* p p) (* -25.0 pi pi)))))))
	(set! n (* 0.5 (+ l_1 l_2)))
	(set! n (* (- n 50.0) (- n 50.0)))
	; Lightness.
	(define l (/ (- l_2 l_1) (* k_l (+ 1.0 (/ (* 0.015 n) (sqrt (+ 20.0 n)))))))
	; These coefficients adjust the impact of different harmonic
	; components on the hue difference calculation.
	(define t (+ 1.0	(* 0.24 (sin (+ (* 2.0 h_m) (/ pi 2.0))))
				(* 0.32 (sin (+ (* 3.0 h_m) (/ (* 8.0 pi) 15.0))))
				(- (* 0.17 (sin (+ h_m (/ pi 3.0)))))
				(- (* 0.20 (sin (+ (* 4.0 h_m) (/ (* 3.0 pi) 20.0)))))))
	(set! n (+ c_1 c_2))
	; Hue.
	(define h (/ (* 2.0 (sqrt (* c_1 c_2)) (sin h_d)) (* k_h (+ 1.0 (* 0.0075 n t)))))
	; Chroma.
	(define c (/ (- c_2 c_1) (* k_c (+ 1.0 (* 0.0225 n)))))
	; Returns the square root so that the Delta E 2000 reflects the actual geometric
	; distance within the color space, which ranges from 0 to approximately 185.
	(sqrt (+ (* l l) (* h h) (* c c) (* c h r_t)))
))

; GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
;  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

; L1 = 45.61          a1 = 49.3           b1 = -113.2
; L2 = 45.61          a2 = 49.3           b2 = -113.171
; CIE ΔE2000 = ΔE00 = 0.00974186307

; L1 = 9.4            a1 = 36.6           b1 = -83.8843
; L2 = 9.4            a2 = 36.47          b2 = -83.6
; CIE ΔE2000 = ΔE00 = 0.05917396271

; L1 = 75.2           a1 = -108.139       b1 = 55.5869
; L2 = 75.2           a2 = -114.6         b2 = 55.5869
; CIE ΔE2000 = ΔE00 = 1.20124057533

; L1 = 65.0           a1 = -5.637         b1 = -83.85
; L2 = 66.263         a2 = -11.3132       b2 = -83.85
; CIE ΔE2000 = ΔE00 = 2.90196712112

; L1 = 54.748         a1 = 35.0911        b1 = 83.5022
; L2 = 54.748         a2 = 40.39          b2 = 78.8
; CIE ΔE2000 = ΔE00 = 3.78318962016

; L1 = 22.0           a1 = 63.4           b1 = -107.4
; L2 = 15.86          a2 = 76.2           b2 = -124.9
; CIE ΔE2000 = ΔE00 = 5.07820016082

; L1 = 83.0           a1 = 120.8709       b1 = 88.31
; L2 = 72.9535        a2 = 106.0          b2 = 76.6
; CIE ΔE2000 = ΔE00 = 7.56491229277

; L1 = 80.9           a1 = -0.9           b1 = -28.2
; L2 = 67.0281        a2 = 29.604         b2 = -86.875
; CIE ΔE2000 = ΔE00 = 13.73685556736

; L1 = 37.6           a1 = -91.9          b1 = -64.5015
; L2 = 18.0           a2 = -29.9671       b2 = -51.7486
; CIE ΔE2000 = ΔE00 = 21.94801178696

; L1 = 84.9025        a1 = 91.08          b1 = 6.26
; L2 = 14.9208        a2 = -120.634       b2 = 15.8
; CIE ΔE2000 = ΔE00 = 127.56041915856

