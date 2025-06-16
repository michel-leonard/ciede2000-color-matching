<?php

// PHP acts as a driver for SQL tests of the CIE ΔE2000 function.

$sql = '
-- This function written in SQL is not affiliated with the CIE (International Commission on Illumination),
-- and is released into the public domain. It is provided "as is" without any warranty, express or implied.

-- The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
-- "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
CREATE OR REPLACE FUNCTION ciede_2000(l_1 DOUBLE, a_1 DOUBLE, b_1 DOUBLE, l_2 DOUBLE, a_2 DOUBLE, b_2 DOUBLE)
RETURNS DOUBLE
DETERMINISTIC
NO SQL
BEGIN
	-- Working in SQL/PSM with the CIEDE2000 color-difference formula.
	-- k_l, k_c, k_h are parametric factors to be adjusted according to
	-- different viewing parameters such as textures, backgrounds...
	DECLARE k_l, k_c, k_h DOUBLE DEFAULT 1.0;
	DECLARE n, c_1, c_2, h_1, h_2, h_m, h_d, r_t, p, t, l, c, h DOUBLE;

	SET n = (SQRT(a_1 * a_1 + b_1 * b_1) + SQRT(a_2 * a_2 + b_2 * b_2)) * 0.5;
	SET n = n * n * n * n * n * n * n;
	-- A factor involving chroma raised to the power of 7 designed to make
	-- the influence of chroma on the total color difference more accurate.
	SET n = 1.0 + 0.5 * (1.0 - SQRT(n / (n + 6103515625.0)));
	-- Since hypot is not available, sqrt is used here to calculate the
	-- Euclidean distance, without avoiding overflow/underflow.
	SET c_1 = SQRT(a_1 * a_1 * n * n + b_1 * b_1);
	SET c_2 = SQRT(a_2 * a_2 * n * n + b_2 * b_2);
	-- atan2 is preferred over atan because it accurately computes the angle of
	-- a point (x, y) in all quadrants, handling the signs of both coordinates.
	SET h_1 = COALESCE(ATAN2(b_1, a_1 * n), 0);
	SET h_2 = COALESCE(ATAN2(b_2, a_2 * n), 0);
	IF h_1 < 0 THEN SET h_1 = h_1 + 2 * PI(); END IF;
	IF h_2 < 0 THEN SET h_2 = h_2 + 2 * PI(); END IF;
	SET n = ABS(h_2 - h_1);
	-- Cross-implementation consistent rounding.
	IF PI() - 1E-14 < n AND n < PI() + 1E-14 THEN SET n = PI(); END IF;
	-- When the hue angles lie in different quadrants, the straightforward
	-- average can produce a mean that incorrectly suggests a hue angle in
	-- the wrong quadrant, the next lines handle this issue.
	SET h_m = (h_1 + h_2) * 0.5;
	SET h_d = (h_2 - h_1) * 0.5;
	IF PI() < n THEN
		IF 0.0 < h_d THEN
			SET h_d = h_d - PI();
		ELSE
			SET h_d = h_d + PI();
		END IF;
		SET h_m = h_m + PI();
	END IF;
	SET p = 36.0 * h_m - 55.0 * PI();
	SET n = (c_1 + c_2) * 0.5;
	SET n = n * n * n * n * n * n * n;
	-- The hue rotation correction term is designed to account for the
	-- non-linear behavior of hue differences in the blue region.
	SET r_t = -2.0 * SQRT(n / (n + 6103515625.0)) * SIN(PI() / 3.0 * EXP(p * p / (-25.0 * PI() * PI())));
	SET n = (l_1 + l_2) * 0.5;
	SET n = (n - 50.0) * (n - 50.0);
	-- Lightness.
	SET l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / SQRT(20.0 + n)));
	-- These coefficients adjust the impact of different harmonic
	-- components on the hue difference calculation.
	SET t = 1.0	+ 0.24 * SIN(2.0 * h_m + PI() * 0.5)
			+ 0.32 * SIN(3.0 * h_m + 8.0 * PI() / 15.0)
			- 0.17 * SIN(h_m + PI() / 3.0)
			- 0.20 * SIN(4.0 * h_m + 3.0 * PI() / 20.0);
	SET n = c_1 + c_2;
	-- Hue.
	SET h = 2.0 * SQRT(c_1 * c_2) * SIN(h_d) / (k_h * (1.0 + 0.0075 * n * t));
	-- Chroma.
	SET c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
	-- Returns the square root so that the Delta E 2000 reflects the actual geometric
	-- distance within the color space, which ranges from 0 to approximately 185.
	RETURN SQRT(l * l + h * h + c * c + c * h * r_t);
END';

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

// L1 = 61.4305        a1 = -11.755        b1 = -10.729
// L2 = 67.0           a2 = -11.755        b2 = -10.0
// CIE ΔE2000 = ΔE00 = 4.65464705048

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
/////////////////////////                             //////////////////////////
/////////////////////////           TESTING           //////////////////////////
/////////////////////////                             //////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

require '/sur.ovh/tools/prod/php/Network.php' ;

$pdo = Network :: getPDO() ;
$pdo -> exec('DROP FUNCTION IF EXISTS ciede_2000') ;
$pdo -> exec($sql);

function compare_values($ext){
	$fp = fopen("./../$ext/values-$ext.txt", 'r');
	echo "compare_values('./../$ext/values-$ext.txt')" ;
	$i = 0 ;
	$n_err = 0 ;
	$sql = '' ;
	$pdo = Network :: getPDO() ;
	$process = function($sql)use(&$pdo) {
		$row = $pdo -> query('SELECT ' . substr($sql, 0, -1)) -> fetch();
		$n_err = 0 ;
		foreach($row as $e)
			if (!is_finite($e) || 1e-10 < $e) {
				++$n_err ;
				echo "err with $e\n" ;
			}
		return $n_err ;
	};
	while(($s = fgets($fp)) !== false){
		$pos = strrpos($s, ',') ;
		$sql .= 'ciede_2000(' . substr($s, 0, $pos) . ')-' . rtrim(substr($s, $pos + 1)) . ' AS r' . $i . ',' ;
		if (++$i == 1000) {
			$i = 0 ;
			echo '.' ;
			$n_err += $process($sql) ;
			if (10 <= $n_err)
				break ;
			$sql = '' ;
		}
	}
	fclose($fp) ;
	if ($sql)
		$n_err += $process($sql) ;
}

function prepare_values($n){
	$fp = fopen('./values-sql.txt', 'w');
	echo "prepare_values('./values-sql.txt', $n)" ;
	$sql = 'SELECT
	  @l_1 := ROUND(RAND() * 1000000.0) / 10000.0 AS l_1,
	  @a_1 := ROUND(RAND() * 2560000.0 - 1280000.0) / 10000.0 AS a_1,
	  @b_1 := ROUND(RAND() * 2560000.0 - 1280000.0) / 10000.0 AS b_1,
	  @l_2 := ROUND(RAND() * 1000000.0) / 10000.0 AS l_2,
	  @a_2 := ROUND(RAND() * 2560000.0 - 1280000.0) / 10000.0 AS a_2,
	  @b_2 := ROUND(RAND() * 2560000.0 - 1280000.0) / 10000.0 AS b_2,
	  ciede_2000(@l_1, @a_1, @b_1, @l_2, @a_2, @b_2) AS delta_e
	FROM seq_1_to_' . $n ;
	$query = Network :: getPDO() -> query($sql) ;
	$i = 0 ;
	while($row = $query -> fetch()) {
		fwrite($fp, implode(',', $row) . "\n") ;
		if (++$i == 1000) {
			$i = 0;
			echo '.' ;
		}
	}
}

if (ctype_alpha($argv[1] ?? '-'))
	compare_values($argv[1]);
else
	prepare_values((int)($argv[1] ?? 10000));
