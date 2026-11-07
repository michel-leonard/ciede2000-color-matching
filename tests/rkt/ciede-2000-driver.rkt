#lang racket

; Limited Use License – March 1, 2025

; This source code is provided for public use under the following conditions :
; It may be downloaded, compiled, and executed, including in publicly accessible environments.
; Modification is strictly prohibited without the express written permission of the author.

; © Michel Leonard 2025

(require racket/cmdline
	racket/string
	racket/file)

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
	; Application of the chroma correction factor.
	(define c_1 (sqrt (+ (* a_1 a_1 n n) (* b_1 b_1))))
	(define c_2 (sqrt (+ (* a_2 a_2 n n) (* b_2 b_2))))
	; atan2 is preferred over atan because it accurately computes the angle of
	; a point (x, y) in all quadrants, handling the signs of both coordinates.
	(define h_1 (if (and (= b_1 0) (= a_1 0)) 0 (atan b_1 (* a_1 n))))
	(define h_2 (if (and (= b_2 0) (= a_2 0)) 0 (atan b_2 (* a_2 n))))
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
		(begin (set! h_d (+ h_d pi))
		; 📜 Sharma’s formulation doesn’t use the next line, but the one after it,
		; and these two variants differ by ±0.0003 on the final color differences.
		(set! h_m (+ h_m pi)))
		; (if (< h_m pi) (set! h_m (+ h_m pi)) (set! h_m (- h_m pi))))
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
	; Returning the square root ensures that dE00 accurately reflects the
	; geometric distance in color space, which can range from 0 to around 185.
	(sqrt (+ (* l l) (* h h) (* c c) (* c h r_t)))
))

; GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
;   Online Tests : https://michel-leonard.github.io/ciede2000-color-matching

; L1 = 26.1   a1 = 37.0   b1 = 3.2
; L2 = 28.5   a2 = 31.0   b2 = -2.4
; CIE ΔE00 = 4.4508843293 (Bruce Lindbloom, Netflix’s VMAF, ...)
; CIE ΔE00 = 4.4509001636 (Gaurav Sharma, OpenJDK, ...)
; Deviation between implementations ≈ 1.6e-5

; See the source code comments for easy switching between these two widely used ΔE*00 implementation variants.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;                         ;;;;;;;;;;;;
;;;;;;;;;;;;    CIEDE2000 Driver     ;;;;;;;;;;;;
;;;;;;;;;;;;                         ;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Reads a CSV file specified as the first command-line argument. For each line, this program
; in Racket displays the original line with the computed Delta E 2000 color difference appended.
; The C driver can offer CSV files to process and programmatically check the calculations performed there.

;  Example of a CSV input line : 19.2,84,18,28,29,-21.7
;    Corresponding output line : 19.2,84,18,28,29,-21.7,24.723794033534887377608568324188

(define filename
	(command-line
	 #:args (file)
	 file))

(define string-blank?
	(if (procedure? (void 'string-blank?))
		string-blank?
		(lambda (s) (regexp-match? #px"^\\s*$" s))))

(for-each
 (lambda (line)
	 (define cleaned (string-trim line))
	 (unless (string-blank? cleaned)
		 (define values (map string->number (string-split cleaned ",")))
		 (when (= (length values) 6)
			 (define result (apply ciede_2000 values))
			 (printf "~a,~a\n" cleaned result))))
 (file->lines filename))
