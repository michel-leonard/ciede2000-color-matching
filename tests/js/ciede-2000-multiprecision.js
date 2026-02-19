// This function written in JavaScript is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

///////////////////////////////////////////////////////////////////////////////////////////
//////                                                                               //////
//////                            Works with decimal.js.                             //////
//////    https://cdnjs.cloudflare.com/ajax/libs/decimal.js/10.6.0/decimal.min.js    //////
//////     This function is available for CIEDE2000 arbitrary precision checking.    //////
//////                                                                               //////
///////////////////////////////////////////////////////////////////////////////////////////

var pi = Decimal.acos(-1);
var b_lo = pi.minus(0.00000000000001);
var b_hi = pi.plus(0.00000000000001);
var pi_pi_25 = pi.times(pi).times(-25);
var pi_mul_2 = pi.times(2);
var pi_div_2 = pi.times(0.5);
var pi_mul_55 = pi.times(55)
var pi_div_3 = pi.div(3);
var pi_mul_8_div_15 = pi.times(8).div(15);

// The arbitrary precision CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
// "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
function ciede_2000_arbitrary(l_1, a_1, b_1, l_2, a_2, b_2, k_l = 1.0, k_c = 1.0, k_h = 1.0, canonical = false) {
	l_1 = new Decimal(l_1); a_1 = new Decimal(a_1); b_1 = new Decimal(b_1);
	l_2 = new Decimal(l_2); a_2 = new Decimal(a_2); b_2 = new Decimal(b_2);
	// Working in JavaScript with the CIEDE2000 color-difference formula.
	// k_l, k_c, k_h are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	k_l = new Decimal(k_l); k_c = new Decimal(k_c); k_h = new Decimal(k_h);
	var a_1_squared = a_1.times(a_1), a_2_squared = a_2.times(a_2);
	var b_1_squared = b_1.times(b_1), b_2_squared = b_2.times(b_2);
	var n = a_1_squared.plus(b_1_squared).sqrt();
	n = n.plus(a_2_squared.plus(b_2_squared).sqrt()).times(0.5).pow(7);
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = n.div(n.plus(6103515625)).sqrt().times(-0.5).plus(1.5);
	var n_squared = n.times(n);
	// Application of the chroma correction factor.
	var c_1 = a_1_squared.times(n_squared).plus(b_1_squared).sqrt();
	var c_2 = a_2_squared.times(n_squared).plus(b_2_squared).sqrt();
	// Using 13 lines to simulate atan2, as decimal.js does not have this built-in.
	var h_1, h_2;
	if (a_1.gt(0))
		h_1 = b_1.div(a_1.times(n)).atan().plus(b_1.lt(0) ? pi_mul_2 : 0);
	else if(a_1.lt(0))
		h_1 = b_1.div(a_1.times(n)).atan().plus(pi);
	else
		h_1 = pi.plus(pi_div_2.times(b_1.lt(0) - b_1.gt(0)));
	if (a_2.gt(0))
		h_2 = b_2.div(a_2.times(n)).atan().plus(b_2.lt(0) ? pi_mul_2 : 0);
	else if(a_2.lt(0))
		h_2 = b_2.div(a_2.times(n)).atan().plus(pi);
	else
		h_2 = pi.plus(pi_div_2.times(b_2.lt(0) - b_2.gt(0)));
	// The atan2 polyfill (customized) is complete.
	n = h_2.minus(h_1).abs();
	// Cross-implementation consistent rounding.
	if (b_lo.lt(n) && n.lt(b_hi)) n = pi;
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	var h_m = h_1.plus(h_2).times(0.5);
	var h_d = h_2.minus(h_1).times(0.5);
	if (pi.lt(n)) {
		h_d = h_d.plus(pi);
		if (canonical) // Sharma’s implementation, OpenJDK, ...
			h_m = h_m.lt(pi) ? h_m.plus(pi) : h_m.minus(pi);
		else // Lindbloom’s implementation, Netflix’s VMAF, ...
			h_m = h_m.plus(pi);
	}
	var p = h_m.times(36).minus(pi_mul_55);
	n = c_1.plus(c_2).times(0.5).pow(7);
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	var r_t = n.div(n.plus(6103515625)).sqrt().times(-2)
		.times(pi_div_3.times(p.times(p).div(pi_pi_25).exp()).sin());
	n = l_1.plus(l_2).times(0.5).minus(50);
	n = n.times(n);
	// Lightness.
	var l = l_2.minus(l_1).div(k_l.times(n.times(0.015).div(n.plus(20).sqrt()).plus(1)));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	var t = h_m.times(2).plus(pi_div_2).sin().times(0.24)
		.plus(h_m.times(3).plus(pi_mul_8_div_15).sin().times(0.32))
		.minus(h_m.times(1).plus(pi.div(3)).sin().times(0.17))
		.minus(h_m.times(4).plus(pi.times(3).div(20)).sin().times(0.2)).plus(1);
	n = c_1.plus(c_2);
	// Hue.
	var h = c_1.times(c_2).sqrt().times(2).times(h_d.sin())
		.div(k_h.times(n.times(0.0075).times(t).plus(1)));
	// Chroma.
	var c = c_2.minus(c_1).div(k_c.times(n.times(0.0225).plus(1)));
	// Returns the square root so that the DeltaE 2000 reflects the actual geometric
	// distance within the color space, which ranges from 0 to approximately 185.
	return l.times(l).plus(h.times(h)).plus(c.times(c)).plus(c.times(h).times(r_t)).sqrt();
}

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//   Online Tests : https://michel-leonard.github.io/ciede2000-color-matching

// L1 = 32.3   a1 = 74.3   b1 = 7.9
// L2 = 32.2   a2 = 91.0   b2 = -0.5
// CIE ΔE00 = 4.9512243423 (Bruce Lindbloom, Netflix’s VMAF, ...)
// CIE ΔE00 = 4.9512131925 (Gaurav Sharma, OpenJDK, ...)
// Deviation between implementations ≈ 1.1e-5

// See the source code comments for easy switching between these two widely used ΔE*00 implementation variants.
