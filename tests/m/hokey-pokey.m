% hokey-pokey.m

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
	% Returns the square root so that the Delta E 2000 reflects the actual geometric
	% distance within the color space, which ranges from 0 to approximately 185.
	delta_e = sqrt(l .* l + h .* h + c .* c + c .* h .* r_t);
end

% GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
%  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

% L1 = 31.72          a1 = 118.942        b1 = -76.184
% L2 = 31.72          a2 = 119.0          b2 = -76.184
% CIE ΔE2000 = ΔE00 = 0.01095104353

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%                           %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%          TESTING          %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%                           %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function prepare_values(num_lines)

	if nargin < 1
		num_lines = 10000;
	end

	rand("state", sum(100.0 * clock));

	path = './values-m.txt' ;

	if exist(path, 'file')
		delete(path);
	end

	fprintf("prepare_values('%s', %d)\n", path, num_lines);

	chunk_size = 25000;
	num_chunks = ceil(num_lines / chunk_size);

	for chunk = 1:num_chunks
		start_idx = (chunk - 1) * chunk_size + 1;
		end_idx = min(chunk * chunk_size, num_lines);

		num_in_chunk = end_idx - start_idx + 1;

		l_1 = round_to_random_decimals(rand(num_in_chunk, 1) * 100);
		a_1 = round_to_random_decimals(rand(num_in_chunk, 1) * 256 - 128);
		b_1 = round_to_random_decimals(rand(num_in_chunk, 1) * 256 - 128);
		l_2 = round_to_random_decimals(rand(num_in_chunk, 1) * 100);
		a_2 = round_to_random_decimals(rand(num_in_chunk, 1) * 256 - 128);
		b_2 = round_to_random_decimals(rand(num_in_chunk, 1) * 256 - 128);

		delta_e = ciede_2000(l_1, a_1, b_1, l_2, a_2, b_2);

		dlmwrite(path, [l_1, a_1, b_1, l_2, a_2, b_2, delta_e], '-append');

		for i = 1:chunk_size / 1000
			fprintf('.');
		end
	end
	disp('');
end

function rounded_value = round_to_random_decimals(value)
	switch randi([0, 2])
		case 0
			rounded_value = round(value);
		case 1
			rounded_value = round(value * 10.0) / 10.0;
		otherwise
			rounded_value = round(value * 100.0) / 100.0;
	end
end

function compare_values(arg)

	path = sprintf('./../%s/values-%s.txt', arg, arg);

	fprintf("compare_values('%s')\n", path);

	error_count = 0;
	chunk_size = 25000;
	start_row = 0;

	while true
		try
			chunk_data = dlmread(path, ',', [start_row 0 (start_row + chunk_size - 1) 6]);
		catch
			break;
		end

		if isempty(chunk_data)
			break;
		end

		L1 = chunk_data(:, 1);
		a1 = chunk_data(:, 2);
		b1 = chunk_data(:, 3);
		L2 = chunk_data(:, 4);
		a2 = chunk_data(:, 5);
		b2 = chunk_data(:, 6);
		expected_delta_e = chunk_data(:, 7);

		delta_e = ciede_2000(L1, a1, b1, L2, a2, b2);

		for i = 1:numel(delta_e)
			if abs(delta_e(i) - expected_delta_e(i)) > 1e-10
				fprintf('Error: ΔE = %f, got %f at index %d\n', delta_e(i), expected_delta_e(i), i);
				error_count = error_count + 1;

				if error_count >= 10
					fprintf('More than 10 errors, stopping.\n');
					return;
				end
			end
		end

		for i = 1:chunk_size / 1000
			fprintf('.');
		end

		start_row = start_row + chunk_size;
	end

	disp('');
end

if numel(argv) < 1
	error('A parameter is required.');
end

str = argv{1};
num = str2num(str);

if all(isdigit(str)) && 1 <= num && num <= 10000000
	prepare_values(num);
elseif ischar(str) && all(isletter(str))
	compare_values(str);
else
	disp('Error, the parameter must be well formed.');
end
