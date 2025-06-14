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

% Reads a CSV file specified as the first command-line argument. For each line, the program
% outputs the original line with the computed Delta E 2000 color difference appended.

%  Example of a CSV input line : 67.24,-14.22,70,65,8,46
%    Corresponding output line : 67.24,-14.22,70,65,8,46,15.46723547943141064

function main(filename)
    fid = fopen(filename,'r');
    chunk_size = 100000;
    while true
        data = textscan(fid, '%f%f%f%f%f%f', chunk_size, 'Delimiter', ',','CollectOutput',true);
        if isempty(data{1}) || isempty(data{1})
            break;
        end
        lab = data{1}; % Nx6 double matrix
        deltaE = ciede_2000(lab(:,1), lab(:,2), lab(:,3), lab(:,4), lab(:,5), lab(:,6));
        % Write chunk to stdout, formatting with max precision
        % Format: L1,a1,b1,L2,a2,b2,deltaE
        fmt = '%g,%g,%g,%g,%g,%g,%.17g\n';
        fprintf(fmt, [lab'; deltaE']);
    end
    fclose(fid);
end

% GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
%  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

% L1 = 32.1178        a1 = 58.163         b1 = 35.0
% L2 = 32.1178        a2 = 58.143         b2 = 35.0
% CIE ΔE2000 = ΔE00 = 0.00709566868

% L1 = 88.9           a1 = 1.912          b1 = 114.1407
% L2 = 89.0           a2 = 1.912          b2 = 114.442
% CIE ΔE2000 = ΔE00 = 0.0800872175

% L1 = 65.249         a1 = 64.1           b1 = 97.0
% L2 = 65.249         a2 = 62.18          b2 = 95.0
% CIE ΔE2000 = ΔE00 = 0.50421708598

% L1 = 38.2           a1 = -36.8879       b1 = 86.62
% L2 = 42.751         a2 = -36.8879       b2 = 90.1167
% CIE ΔE2000 = ΔE00 = 4.11554064253

% L1 = 58.6882        a1 = -54.0          b1 = -31.69
% L2 = 64.2           a2 = -55.151        b2 = -30.23
% CIE ΔE2000 = ΔE00 = 4.82995702002

% L1 = 34.505         a1 = 89.3           b1 = -34.66
% L2 = 37.8           a2 = 114.718        b2 = -43.0
% CIE ΔE2000 = ΔE00 = 5.30460851127

% L1 = 40.4           a1 = -5.54          b1 = -89.27
% L2 = 29.6           a2 = -22.801        b2 = -77.2503
% CIE ΔE2000 = ΔE00 = 11.32081353479

% L1 = 74.3452        a1 = 49.193         b1 = 61.1
% L2 = 88.6           a2 = 42.9           b2 = 82.2
% CIE ΔE2000 = ΔE00 = 13.76529914791

% L1 = 66.04          a1 = 111.24         b1 = -7.2
% L2 = 76.9           a2 = 27.0           b2 = 3.0
% CIE ΔE2000 = ΔE00 = 22.44684617926

% L1 = 30.9           a1 = -45.0          b1 = 81.415
% L2 = 5.6            a2 = -16.0          b2 = 25.697
% CIE ΔE2000 = ΔE00 = 23.95646945626

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
