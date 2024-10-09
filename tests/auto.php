<?php

$lang = [
	'py' => [ 'Python', 'python3', 'hokey-pokey.py' ],
	'php' => [ 'PHP', 'php', 'hokey-pokey.php' ],
	'rb' => [ 'Ruby', 'ruby', 'hokey-pokey.rb' ],
	'java' => [ 'Java', 'java', 'hokeyPokey' ],
	'c' => [ 'C', '', './hokey-pokey' ],
	'js' => [ 'JavaScript', 'node', 'hokey-pokey.js' ],
] ;
echo 'Running the tests', "\n" ;
foreach($lang as $k => [$v])
	echo " - $k ($v)\n" ;

$n_rows = $argv[1] ?? '10000' ;
if ($n_rows < 1 || $n_rows > 100000000)
	$n_rows = '10000' ;

foreach($lang as $l_1 => [$n_1, $i_1, $s_1]){
	echo "\n\n", str_repeat('-', 30), "\n" ;
	echo str_repeat('-', 10), " [ $l_1 ] ", str_repeat('-', 14 - strlen($l_1)), "\n" ;
	echo str_repeat('-', 30), "\n" ;
	echo "$n_1 prepare the CSV file:\n" ;
	chdir(__DIR__ . "/$l_1") ;
	$t_1 = microtime(true) ;
	$fp = popen("$i_1 $s_1 $n_rows 2>&1", 'r');
	 while(!feof($fp))
		echo fread($fp, 2096);
	pclose($fp);
	$t_2 = microtime(true) ;
	echo ' ', round($t_2 - $t_1), "s.\n" ;
	$stats = [ ] ;
	$fp = fopen(__DIR__ . "/$l_1/values-$l_1.txt", 'r') ;
	if ($fp)
		while(!feof($fp))
			foreach(count_chars(fread($fp, 2096), 1) as $i => $n)
				$stats[$i] = ($stats[$i] ?? 0) + $n ;
	fclose($fp);
	foreach($stats as $k => $v)
		$stats[$k] = [chr($k), $v];
	$stats = array_values($stats);
	echo "$n_1 CSV file character set is ", substr(str_replace('],[','] [', json_encode($stats)), 1, -1), "\n" ;
	foreach($lang as $l_2 => [$n_2, $i_2, $s_2]){
		if ($l_1 !== $l_2){
			echo "$n_2 test the $n_1 CSV file:\n" ;
			chdir(__DIR__ . "/$l_2") ;
			$t_1 = microtime(true) ;
			$fp = popen("$i_2 $s_2 $l_1 2>&1", 'r');
			 while(!feof($fp))
				echo fread($fp, 2096);
			pclose($fp);
			$t_2 = microtime(true) ;
			echo ' ', round($t_2 - $t_1), "s.\n" ;
		}
	}
}
