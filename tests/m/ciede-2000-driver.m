% Limited Use License – March 1, 2025

% This source code is provided for public use under the following conditions :
% It may be downloaded, compiled, and executed, including in publicly accessible environments.
% Modification is strictly prohibited without the express written permission of the author.

% © Michel Leonard 2025

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%                         %%%%%%%%%%%%
%%%%%%%%%%%%    CIEDE2000 Driver     %%%%%%%%%%%%
%%%%%%%%%%%%                         %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Reads a CSV file specified as the first command-line argument. For each line, this program
% in MATLAB displays the original line with the computed Delta E 2000 color difference appended.
% The C driver can offer CSV files to process and programmatically check the calculations performed there.

%  Example of a CSV input line : 67.24,-14.22,70,65,8,46
%    Corresponding output line : 67.24,-14.22,70,65,8,46,15.46723547943141064

function main(filename)
    fid = fopen(filename,'r');
    chunk_size = 1000000;
    fmt = '%.17g,%.17g,%.17g,%.17g,%.17g,%.17g,%.17g\n';
    while true
        data = textscan(fid, '%f%f%f%f%f%f', chunk_size, 'Delimiter', ',','CollectOutput',true);
        if isempty(data{1}) || isempty(data{1})
            break;
        end
        lab = data{1}; % Nx6 double matrix
        deltaE = ciede_2000(lab(:,1), lab(:,2), lab(:,3), lab(:,4), lab(:,5), lab(:,6));
        % Write chunk to stdout, formatting with max precision
        fprintf(fmt, [lab'; deltaE']);
    end
    fclose(fid);
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
	% Returns the square root so that the Delta E 2000 reflects the actual geometric
	% distance within the color space, which ranges from 0 to approximately 185.
	delta_e = sqrt(l .* l + h .* h + c .* c + c .* h .* r_t);
end

% GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
%  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

% L1 = 66.04          a1 = 111.24         b1 = -7.2
% L2 = 76.9           a2 = 27.0           b2 = 3.0
% CIE ΔE2000 = ΔE00 = 22.44684617926
