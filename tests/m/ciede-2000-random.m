%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%                                 %%%%%%%
%%%%%%%           CIEDE 2000            %%%%%%%
%%%%%%%      Testing Random Colors      %%%%%%%
%%%%%%%                                 %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% This MATLAB program outputs a CSV file to standard output, with its length determined by the first CLI argument.
%% Each line contains seven columns :
%% - Three columns for the random standard L*a*b* color
%% - Three columns for the random sample L*a*b* color
%% - And the seventh column for the precise Delta E 2000 color difference between the standard and sample
%% The output will be correct, this can be verified :
%% - With the C driver, which provides a dedicated verification feature
%% - By using the JavaScript validator at https://michel-leonard.github.io/ciede2000-color-matching

function run_ciede2000_random(varargin)
	n_iterations = 10000;
	if nargin >= 1
		n = varargin{1};
		if !isnan(n) && n > 0
			n_iterations = n;
		end
	end
	chunk_size = 10000;
	for start_idx = 1:chunk_size:n_iterations
		end_idx = min(start_idx + chunk_size - 1, n_iterations);
		current_chunk_size = end_idx - start_idx + 1;
		l_1 = randi([0, 10000], current_chunk_size, 1) / 100.0;
		a_1 = randi([-12800, 12800], current_chunk_size, 1) / 100.0;
		b_1 = randi([-12800, 12800], current_chunk_size, 1) / 100.0;
		l_2 = randi([0, 10000], current_chunk_size, 1) / 100.0;
		a_2 = randi([-12800, 12800], current_chunk_size, 1) / 100.0;
		b_2 = randi([-12800, 12800], current_chunk_size, 1) / 100.0;
		delta_e = ciede_2000(l_1, a_1, b_1, l_2, a_2, b_2);
		output = [l_1, a_1, b_1, l_2, a_2, b_2, delta_e];
		fprintf('%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.17f\n', output');
	end
end

% This function written in MATLAB is not affiliated with the CIE (International Commission on Illumination),
% and is released into the public domain. It is provided "as is" without any warranty, express or implied.

function delta_e = ciede_2000_classic(l_1, a_1, b_1, l_2, a_2, b_2)
	% This scalar expansion wrapper works with numbers, not vectors.
	delta_e = ciede_2000([l_1], [a_1], [b_1], [l_2], [a_2], [b_2]);
	delta_e = delta_e(1);
end

% The classic vectorized CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
% "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
function delta_e = ciede_2000(l_1, a_1, b_1, l_2, a_2, b_2)
	% Working in MATLAB with the CIEDE2000 color-difference formula.
	% k_l, k_c, k_h are parametric factors to be adjusted according to
	% different viewing parameters such as textures, backgrounds...
	k_l = 1.0; k_c = 1.0; k_h = 1.0;
	n = (hypot(a_1, b_1) + hypot(a_2, b_2)) * 0.5;
	n = n .* n .* n .* n .* n .* n .* n;
	% A factor involving chroma raised to the power of 7 designed to make
	% the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - sqrt(n ./ (n + 6103515625.0)));
	% hypot calculates the Euclidean distance while avoiding overflow/underflow.
	c_1 = hypot(a_1 .* n, b_1);
	c_2 = hypot(a_2 .* n, b_2);
	% atan2 is preferred over atan because it accurately computes the angle of
	% a point (x, y) in all quadrants, handling the signs of both coordinates.
	h_1 = atan2(b_1, a_1 .* n);
	h_2 = atan2(b_2, a_2 .* n);
	% Vectorized conditionals
	m_1 = h_1 < 0.0;
	m_2 = h_2 < 0.0;
	h_1(m_1) = h_1(m_1) + 2.0 * pi;
	h_2(m_2) = h_2(m_2) + 2.0 * pi;
	n = abs(h_2 - h_1);
	% Cross-implementation consistent rounding.
	n((pi - 1E-14 < n) & (n < pi + 1E-14)) = pi;
	% When the hue angles lie in different quadrants, the straightforward
	% average can produce a mean that incorrectly suggests a hue angle in
	% the wrong quadrant, the next lines handle this issue.
	h_m = (h_1 + h_2) * 0.5;
	h_d = (h_2 - h_1) * 0.5;
	% Vectorized conditionals
	m_1 = pi < n;
	m_2 = 0.0 < h_d;
	m_3 = m_1 & m_2;
	h_d(m_3) = h_d(m_3) - pi;
	m_3 = m_1 & ~m_2;
	h_d(m_3) = h_d(m_3) + pi;
	h_m(m_1) = h_m(m_1) + pi;
	p = 36.0 * h_m - 55.0 * pi;
	n = (c_1 + c_2) * 0.5;
	n = n .* n .* n .* n .* n .* n .* n;
	% The hue rotation correction term is designed to account for the
	% non-linear behavior of hue differences in the blue region.
	r_t = -2.0 * sqrt(n ./ (n + 6103515625.0)) .* sin(pi / 3.0 * exp((p .* p) / (-25.0 * pi * pi)));
	n = (l_1 + l_2) * 0.5;
	n = (n - 50.0) .* (n - 50.0);
	% Lightness.
	l = (l_2 - l_1) ./ (k_l .* (1.0 + 0.015 * n ./ sqrt(20.0 + n)));
	% These coefficients adjust the impact of different harmonic
	% components on the hue difference calculation.
	t = 1.0	+ 0.24 * sin(2.0 * h_m + pi * 0.5) ...
 		+ 0.32 * sin(3.0 * h_m + 8.0 * pi / 15.0) ...
	 		- 0.17 .* sin(h_m + pi / 3.0) ...
		 		- 0.20 * sin(4.0 * h_m + 3.0 * pi / 20.0);
	n = c_1 + c_2;
	% Hue.
	h = 2.0 * sqrt(c_1 .* c_2) .* sin(h_d) ./ (k_h .* (1.0 + 0.0075 * n .* t));
	% Chroma.
	c = (c_2 - c_1) ./ (k_c .* (1.0 + 0.0225 * n));
	% Returns the square root so that the DeltaE 2000 reflects the actual geometric
	% distance within the color space, which ranges from 0 to approximately 185.
	delta_e = sqrt(l .* l + h .* h + c .* c + c .* h .* r_t);
end

% GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
%  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

% L1 = 94.397         a1 = 52.349         b1 = 24.0
% L2 = 94.397         a2 = 45.6           b2 = 24.0
% CIE ΔE2000 = ΔE00 = 2.47595172721
