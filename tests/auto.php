<?php

// Driver for the tests of the CIE ΔE00 Color-Difference formula, must display a log file.

// Each programming language generates a random file "values-XXX.txt" using the "ciede_2000" function.
// Each language then compares its results with those of the others, tolerating a maximum difference of 1e-10.
// In case of cross-language result mismatch, up to 10 error messages may be displayed before the program stops.

$lang = [
  'c'    =>  [ 'C',          '',                          './hokey-pokey'      ],
  'rs'   =>  [ 'Rust',       'cargo run -q --bin',        'hokey-pokey'        ],
  'go'   =>  [ 'Go',         'go run',                    'hokey-pokey.go'     ],
  'java' =>  [ 'Java',       'java',                      'hokeyPokey'         ],
  'kt'   =>  [ 'Kotlin',     'java -jar',                 'hokeyPokey.jar'     ],
  'js'   =>  [ 'JavaScript', 'node',                      'hokey-pokey.js'     ],
  'ts'   =>  [ 'TypeScript', 'node',                      'hokey-pokey.js'     ],
  'lua'  =>  [ 'LuaJIT',     'luajit -O3',                'hokey-pokey.lua'    ],
  'm'    =>  [ 'MATLAB',     'octave --no-window-system', 'hokey-pokey.m'      ],
  'pl'   =>  [ 'Perl',       'perl',                      'hokey-pokey.pl'     ],
  'php'  =>  [ 'PHP',        'php',                       'hokey-pokey.php'    ],
  'py'   =>  [ 'Python',     'python3',                   'hokey-pokey.py'     ],
  'rb'   =>  [ 'Ruby',       'ruby',                      'hokey-pokey.rb'     ],
  'sql'   => [ 'SQL',        'php',                       'hokey-pokey.php'    ],
] ;

// Function used to execute the cross-language sub-programs.
function proc($cmd, $print = false){
	$res = '' ;
	$fp = popen("$cmd 2>&1", 'r');
	if ($fp)
		while(!feof($fp)) {
			$s = fread($fp, 2096) ;
			$res .= $s ;
			if ($print)
				echo $s ;
		}
	pclose($fp);
	return trim($res) ;
}

$n_lines = (int)($argv[1] ?? 10000) ;
if ($n_lines < 1 || $n_lines > 100000000)
	die("The first '$n_lines' parameter should be in [1, 100000000]\n");

$n_lang = count($lang) ;
$n_comparisons = $n_lang * $n_lines * ($n_lang - 1) ;

if (!file_exists(__DIR__ . '/c/hokey-pokey')) {
	// Setup Michel Leonard's test environments (third-party software like GCC must be installed).
	chdir(__DIR__ . '/c') ;
	proc('gcc -std=c99 -Wall -Wextra -pedantic -Ofast -o hokey-pokey hokey-pokey.c -lm');
	chdir(__DIR__ . '/java') ;
	proc('javac hokeyPokey.java');
	chdir(__DIR__ . '/kt') ;
	proc('kotlinc hokey-pokey.kt -include-runtime -d hokeyPokey.jar');
	chdir(__DIR__ . '/rs') ;
	proc("cargo init --vcs none --bin");
	file_put_contents('Cargo.toml', "rand = \"0.8.5\"\n\n[[bin]]\nname = \"hokey-pokey\"\npath = \"hokey-pokey.rs\"", FILE_APPEND);
	proc("cargo build");
	chdir(__DIR__ . '/ts') ;
	proc('npm init -y; npm install --save-dev @types/node; tsc --init; tsc hokey-pokey.ts');
}

echo 'Test of the CIEDE2000 function involving ', number_format($n_comparisons, 0, '', ',') ," comparisons between $n_lang programming languages :\n" ;
foreach($lang as $id => [ $name ])
	echo " - $name ... $id\n" ;

echo "\n" ;

$t_0 = microtime(true) ;

foreach($lang as $id_1 => [ $name_1, $cmd_1_1, $cmd_1_2 ]) {
	echo "\n\n", str_repeat('-', 30), "\n" ;
	echo str_repeat('-', 10), " [ $id_1 ] ", str_repeat('-', 14 - strlen($id_1)), "\n" ;
	echo str_repeat('-', 30), "\n" ;
	chdir(__DIR__ . "/$id_1") ;
	$t_1 = microtime(true) ;
	// Produces a file containing samples.
	$cmd_out = proc("$cmd_1_1 $cmd_1_2 $n_lines");
	$t_2 = microtime(true) ;
	$cmd_out = preg_replace('#\s*\.{10,}\s*#', ' ' . str_repeat('.', 37 - strlen("$id_1|$name_1|$n_lines")), $cmd_out) ;
	printf(" - $name_1 prepare the CSV file : $cmd_out took %.01fs\n", $t_2 - $t_1);
	//
	$stats = [ ] ;
	$data_path = __DIR__ . "/$id_1/values-$id_1.txt" ;
	$fp = fopen($data_path, 'r') ;
	if ($fp)
		while(!feof($fp))
			foreach(count_chars(fread($fp, 2096), 1) as $i => $n)
				$stats[$i] = ($stats[$i] ?? 0) + $n ;
	fclose($fp);
	foreach($stats as $k => $v)
		$stats[$k] = [chr($k), $v];
	$stats = array_values($stats);
	// Displays the statistics to ensure that the entropy of each dataset is well distributed.
	echo " - $name_1 CSV file character set is ", substr(str_replace('],[','] [', json_encode($stats)), 1, -1), "\n" ;
	//
	foreach($lang as $id_2 => [ $name_2, $cmd_2_1, $cmd_2_2 ])
		if ($id_1 != $id_2) {
			chdir(__DIR__ . "/$id_2");
			$t_1 = microtime(true) ;
			// All languages check their results against the file.
			$cmd_out = proc("$cmd_2_1 $cmd_2_2 $id_1");
			$t_2 = microtime(true) ;
			$cmd_out = preg_replace('#\s*\.{10,}\s*#', ' ' . str_repeat('.', 40 - strlen("$id_1|$id_1|$name_1|$name_2")), $cmd_out) ;
			printf("   - $name_2 test the $name_1 file : $cmd_out took %.01fs\n", $t_2 - $t_1);
		}
	unlink($data_path);
}

$t = round ((microtime(true) - $t_0) / 60.) ;
echo "\nResult: after ", $t ," minute" , $t < 2 ? '' : 's' , ", the $n_lang languages produce the same output with a tolerance of 1e-10.\n" ;

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

// L1 = 21.4834        a1 = -48.98         b1 = 28.4
// L2 = 28.7           a2 = -53.011        b2 = 27.2
// CIE ΔE2000 = ΔE00 = 5.51125504145

