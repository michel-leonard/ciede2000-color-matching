% This function written in Prolog is not affiliated with the CIE (International Commission on Illumination),
% and is released into the public domain. It is provided "as is" without any warranty, express or implied.

% The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
% "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
ciede_2000(L1, A1, B1, L2, A2, B2, DeltaE2000) :-
	% Working in Prolog with the CIEDE2000 color-difference formula.
	% K_L, K_C, K_H are parametric factors to be adjusted according to
	% different viewing parameters such as textures, backgrounds...
	K_L is 1.0,
	K_C is 1.0,
	K_H is 1.0,
	Pi_1 is 3.14159265358979323846,
	Pi_3 is 1.04719755119659774615,

	% 1. Compute chroma magnitudes ... a and b usually range from -128 to +127
	A1_sq is A1 * A1,
	B1_sq is B1 * B1,
	C_orig_1 is sqrt(A1_sq + B1_sq),
	A2_sq is A2 * A2,
	B2_sq is B2 * B2,
	C_orig_2 is sqrt(A2_sq + B2_sq),

	% 2. Compute chroma mean and apply G compensation
	C_avg is 0.5 * (C_orig_1 + C_orig_2),
	C_avg_3 is C_avg * C_avg * C_avg,
	C_avg_7 is C_avg_3 * C_avg_3 * C_avg,
	G_denom is C_avg_7 + 6103515625.0,
	G_ratio is C_avg_7 / G_denom,
	G_sqrt is sqrt(G_ratio),
	G_factor is 1.0 + 0.5 * (1.0 - G_sqrt),

	% 3. Apply G correction to a components, compute corrected chroma
	A1_prime is A1 * G_factor,
	C1_prime_sq is A1_prime * A1_prime + B1 * B1,
	C1_prime is sqrt(C1_prime_sq),
	A2_prime is A2 * G_factor,
	C2_prime_sq is A2_prime * A2_prime + B2 * B2,
	C2_prime is sqrt(C2_prime_sq),

	% 4. Compute hue angles in radians, adjust for negatives and wrap
	H1_raw is atan2(B1, A1_prime),
	H2_raw is atan2(B2, A2_prime),
	(H1_raw < 0.0 -> H1_adj is H1_raw + 2.0 * Pi_1 ; H1_adj = H1_raw),
	(H2_raw < 0.0 -> H2_adj is H2_raw + 2.0 * Pi_1 ; H2_adj = H2_raw),
	Delta_h is abs(H1_adj - H2_adj),
	H_mean_raw is 0.5 * (H1_adj + H2_adj),
	H_diff_raw is 0.5 * (H2_adj - H1_adj),

	% Check if hue mean wraps around pi (180 deg)
	Wrap_dist is abs(Pi_1 - Delta_h),
	(1.0e-14 < Wrap_dist, Pi_1 < Delta_h -> Hue_wrap = 1.0 ; Hue_wrap = 0),
	H_diff is H_diff_raw + Hue_wrap * Pi_1,
	% 📜 Sharma’s formulation doesn’t use the next line, but the three after it,
	% and these two variants differ by ±0.0003 on the final color differences.
	H_mean is H_mean_raw + Hue_wrap * Pi_1,
	% (Hue_wrap =:= 1, H_mean_raw < Pi_1 -> H_mean_hi = Pi_1 ; H_mean_hi = 0.0),
	% (Hue_wrap =:= 1, H_mean_hi =:= 0.0 -> H_mean_lo = Pi_1 ; H_mean_lo = 0.0),
	% H_mean is H_mean_raw + H_mean_hi - H_mean_lo,

	% 5. Compute hue rotation correction factor R_T
	C_bar is 0.5 * (C1_prime + C2_prime),
	C_bar_3 is C_bar * C_bar * C_bar,
	C_bar_7 is C_bar_3 * C_bar_3 * C_bar,
	Rc_denom is C_bar_7 + 6103515625.0,
	R_C is sqrt(C_bar_7 / Rc_denom),
	Theta is 36.0 * H_mean - 55.0 * Pi_1,
	Theta_denom is -25.0 * Pi_1 * Pi_1,
	Exp_argument is Theta * Theta / Theta_denom,
	Exp_term is exp(Exp_argument),
	Delta_theta is Pi_3 * Exp_term,
	Sin_term is sin(Delta_theta),

	% Rotation factor ... cross-effect between chroma and hue
	R_T is -2.0 * R_C * Sin_term,

	% 6. Compute lightness term ... L nominally ranges from 0 to 100
	L_avg is 0.5 * (L1 + L2),
	L_delta_sq is (L_avg - 50.0) * (L_avg - 50.0),
	L_delta is L2 - L1,

	% Adaptation to the non-linearity of light perception ... S_L
	S_l_num is 0.015 * L_delta_sq,
	S_l_denom is sqrt(20.0 + L_delta_sq),
	S_L is 1.0 + S_l_num / S_l_denom,
	L_term is L_delta / (K_L * S_L),

	% 7. Compute chroma-related trig terms and factor T
	Trig_1 is 0.17 * sin(H_mean + Pi_3),
	Trig_2 is 0.24 * sin(2.0 * H_mean + 0.5 * Pi_1),
	Trig_3 is 0.32 * sin(3.0 * H_mean + 1.6  * Pi_3),
	Trig_4 is  0.2 * sin(4.0 * H_mean + 0.15 * Pi_1),
	T is 1.0 - Trig_1 + Trig_2 + Trig_3 - Trig_4,
	C_sum is C1_prime + C2_prime,
	C_product is C1_prime * C2_prime,
	C_geo_mean is sqrt(C_product),

	% 8. Compute hue difference and scaling factor S_H
	Sin_h_diff is sin(H_diff),
	S_H is 1.0 + 0.0075 * C_sum * T,
	H_term is 2.0 * C_geo_mean * Sin_h_diff / (K_H * S_H),

	% 9. Compute chroma difference and scaling factor S_C
	C_delta is C2_prime - C1_prime,
	S_C is 1.0 + 0.0225 * C_sum,
	C_term is C_delta / (K_C * S_C),

	% 10. Combine lightness, chroma, hue, and interaction terms
	L_part is L_term * L_term,
	C_part is C_term * C_term,
	H_part is H_term * H_term,
	Interaction is C_term * H_term * R_T,
	Delta_e_squared is L_part + C_part + H_part + Interaction,
	DeltaE2000 is sqrt(Delta_e_squared).

% GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
%   Online Tests : https://michel-leonard.github.io/ciede2000-color-matching

% L1 = 14.8   a1 = 33.5   b1 = 2.4
% L2 = 16.6   a2 = 38.1   b2 = -2.7
% CIE ΔE00 = 3.6462011992 (Bruce Lindbloom, Netflix’s VMAF, ...)
% CIE ΔE00 = 3.6461873926 (Gaurav Sharma, OpenJDK, ...)
% Deviation between implementations ≈ 1.4e-5

% See the source code comments for easy switching between these two widely used ΔE*00 implementation variants.
