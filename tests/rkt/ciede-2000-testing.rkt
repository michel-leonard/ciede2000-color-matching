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

; L1 = 7.17           a1 = 31.4795        b1 = -45.58
; L2 = 7.17           a2 = 31.5166        b2 = -45.58
; CIE ΔE2000 = ΔE00 = 0.0202758827

; L1 = 59.07          a1 = -94.9109       b1 = -20.0623
; L2 = 59.07          a2 = -94.9109       b2 = -20.17
; CIE ΔE2000 = ΔE00 = 0.04442291343

; L1 = 25.322         a1 = 8.761          b1 = -52.6527
; L2 = 25.322         a2 = 8.761          b2 = -51.0
; CIE ΔE2000 = ΔE00 = 0.66339766633

; L1 = 52.439         a1 = -121.0         b1 = -24.58
; L2 = 52.439         a2 = -121.0         b2 = -33.8831
; CIE ΔE2000 = ΔE00 = 3.25497415581

; L1 = 5.2844         a1 = 119.6937       b1 = 26.0
; L2 = 11.2           a2 = 126.5          b2 = 33.877
; CIE ΔE2000 = ΔE00 = 4.34223587159

; L1 = 34.5           a1 = -23.0          b1 = -53.8781
; L2 = 42.0           a2 = -30.4          b2 = -47.1
; CIE ΔE2000 = ΔE00 = 7.65480254492

; L1 = 74.0           a1 = 55.57          b1 = -51.2682
; L2 = 73.583         a2 = 108.8957       b2 = -82.3
; CIE ΔE2000 = ΔE00 = 11.0814200028

; L1 = 75.48          a1 = -53.0          b1 = -48.7751
; L2 = 92.8616        a2 = -117.5062      b2 = -103.5009
; CIE ΔE2000 = ΔE00 = 17.96939736672

; L1 = 41.795         a1 = -119.8         b1 = -126.2
; L2 = 17.945         a2 = -94.79         b2 = -94.89
; CIE ΔE2000 = ΔE00 = 19.10879433389

; L1 = 11.379         a1 = -51.0          b1 = 74.0
; L2 = 94.0           a2 = -15.0          b2 = 62.18
; CIE ΔE2000 = ΔE00 = 82.19051550006

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;                         ;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;         TESTING         ;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;                         ;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; The output is intended to be checked by the Large-Scale validator
; at https://michel-leonard.github.io/ciede2000-color-matching

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
