#lang racket

(require racket/cmdline)
(require racket/random)

; This function written in Racket is not affiliated with the CIE (International Commission on Illumination),
; and is released into the public domain. It is provided "as is" without any warranty, express or implied.

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
	(define h_1 (if (and (= b_1 0) (= (* a_1 n) 0)) 0 (atan b_1 (* a_1 n))))
	(define h_2 (if (and (= b_2 0) (= (* a_2 n) 0)) 0 (atan b_2 (* a_2 n))))
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
		; Sharma's implementation delete the next line and uncomment the one after it,
		; this can lead to a discrepancy of ±0.0003 in the final color difference.
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
	; Returns the square root so that the DeltaE 2000 reflects the actual geometric
	; distance within the color space, which ranges from 0 to approximately 185.
	(sqrt (+ (* l l) (* h h) (* c c) (* c h r_t)))
))

; GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
;  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

; L1 = 52.439         a1 = -121.0         b1 = -24.58
; L2 = 52.439         a2 = -121.0         b2 = -33.8831
; CIE ΔE2000 = ΔE00 = 3.25497415581

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;                                 ;;;;;;;
;;;;;;;           CIEDE 2000            ;;;;;;;
;;;;;;;      Testing Random Colors      ;;;;;;;
;;;;;;;                                 ;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This Racket program outputs a CSV file to standard output, with its length determined by the first CLI argument.
; Each line contains seven columns :
; - Three columns for the random standard L*a*b* color
; - Three columns for the random sample L*a*b* color
; - And the seventh column for the precise Delta E 2000 color difference between the standard and sample
; The output will be correct, this can be verified :
; - With the C driver, which provides a dedicated verification feature
; - By using the JavaScript validator at https://michel-leonard.github.io/ciede2000-color-matching

(define (random-lab)
  (list (/ (random 10000) 100.0)
        (- (/ (random 25600) 100.0) 128.0)
        (- (/ (random 25600) 100.0) 128.0)))

(define (random-round x)
  (let ([precision (if (zero? (random 2)) 1 0)])
    (if (= precision 1)
        (/ (round (* x 10.0)) 10.0)
        (round x))))

(define (main)
  (define iterations (command-line
                       #:args (n)
                       (if (string->number n)
                           (max 1 (exact-round (string->number n)))
                           10000)))
  (for ([i (in-range iterations)])
    (let* ([color1 (map random-round (random-lab))]
           [color2 (map random-round (random-lab))]
           [delta-e (apply ciede_2000 (append color1 color2))])
      (printf "~a,~a,~a,~a,~a,~a,~a\n"
              (first color1) (second color1) (third color1)
              (first color2) (second color2) (third color2)
              delta-e))))

(main)
