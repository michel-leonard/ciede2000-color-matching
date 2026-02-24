# ΔE2000 — Accurate. Fast. Mathematica-powered.

A precise **Mathematica** implementation of the CIEDE2000 formula - today’s standard for quantifying color differences.

The developed algorithm enables us to evaluate color similarities (or differences) with scientific rigor.

As a general rule, 🔵 navy blue and 🟡 yellow, which are very different colors, have a ΔE\*<sub>00</sub> of around 115.

Values [such as 5](https://michel-leonard.github.io/ciede2000-color-matching/de2000-rgb-pairs.html?seq=50&delta-e=5) indicate greater closeness, making this both a simple and advanced method of color comparison.

## Implementation Details

The full **Mathematica** source code released on March 1, 2025, is available [here](../../ciede-2000.wl#L6) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.wl).

This function operates only on 64-bit floating-point numbers (`Real` type), and works in `MachinePrecision`.

<details>
<summary>What two options are available for matching ΔE2000 calculations with existing calculations ?</summary>

#### Option 1 (default)
 This often-used option consists of a coding simplification that is a historical legacy of early implementations :
```mathematica
hm += npi;
(* If[hm < npi, hm += npi, hm -= npi]; *)
```

#### Option 2 (compatible with Gaurav Sharma’s precise calculations)
There’s no room for ambiguity, this inversion of the commented line in the source code ensures compliance with the official :
```mathematica
(* hm += npi; *)
If[hm < npi, hm += npi, hm -= npi];
```

**Note** : the difference between the two options is minimal (±0.0003 on the calculated color difference) and usually overlooked.
</details>

## Example usage in Mathematica (Wolfram Language)

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede2000` function :

```mathematica
(* Compute the Delta E (CIEDE2000) color difference between two L*a*b* colors in Mathematica

Color 1: l1 = 77.6   a1 = 50.3   b1 = 2.4
Color 2: l2 = 78.3   a2 = 56.0   b2 = -2.5 *)

deltaE = ciede2000[l1, a1, b1, l2, a2, b2];
Print[deltaE];

(* .................................................. This shows a ΔE2000 of 2.9599647256
   As explained in the comments, compliance with Gaurav Sharma would display 2.9599515492 *)
```

**Note** : L\* is nominally between 0 and 100, a\* and b\* typically between -128 and +127.

For color inputs in **hexadecimal** (e.g., `#FFF`) or **RGB** formats, see examples for other languages :

[AWK](../awk#-flexibility), [C](../c#δe2000--accurate-fast-c-powered), [Dart](../dart#δe2000--accurate-fast-dart-powered), [Java](../java#δe2000--accurate-fast-java-powered), [JavaScript](../js#-flexibility), [Kotlin](../kt#δe2000--accurate-fast-kotlin-powered), [Lua](../lua#-flexibility), [PHP](../php#δe2000--accurate-fast-php-powered), [Python](../py#δe2000--accurate-fast-python-powered), [Ruby](../rb#δe2000--accurate-fast-ruby-powered), [Rust](../rs#δe2000--accurate-fast-rust-powered).

## Verification

This implementation of the ΔE2000 function in Mathematica was tested on my local machine, and does not benefit, like other programming languages, from an automated testing workflow on GitHub Actions (because it’s a proprietary language). The [ciede-2000-driver.wl](ciede-2000-driver.wl#L92) file is provided in this directory so that you can perform similar tests yourself by processing a CSV file. Here’s a step-by-step guide to my tests :

- Installation of **GCC** : `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install gcc ; }`
- Driver compiled in **C99** : `gcc -std=c99 -Wall -pedantic -O2 -g tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
- Generates 3 GB of **L\*a\*b\* test colors** in CSV format : `./ciede-2000-driver --generate 100000000 --output-file test-cases.csv`
- Use **wolframscript** : `wolframscript -file tests/wl/ciede-2000-driver.wl test-cases.csv | ciede-2000-driver`

When the 100,000,000 calculated color differences had been verified, the test ended and the C driver displayed :

```
CIEDE2000 Verification Summary :
  First Verified Line : 95.39,17.64,40,6,-115.4,105,102.2384848229073
             Duration : 19535.05 s
            Successes : 100000000
               Errors : 0
      Average Delta E : 63.0889
    Average Deviation : 1.1e-14
    Maximum Deviation : 3.0e-13
```

Confirming that the `ciede2000` function complies with the standard, with zero errors and negligible floating-point deviations.

> [!IMPORTANT]
> To correct this Mathematica source code to exact match certain third-party ΔE2000 functions, follow the comments in the source code.

> This formula, "small" in size, is an essential pillar of color management, deserving of this rigorous, tested and reliable industrial treatment.

## Performance & Environment

<details>
<summary>Can we improve function performance with compilation ?</summary>

Yes, in fact during its development the `ciede2000` function was compiled and successfully tested in this way :

```mathematica
ciede2000 = Compile[{
		{l1, _Real},
		{a1, _Real},
		{b1, _Real},
		{l2, _Real},
		{a2, _Real},
		{b2, _Real}
	},
	Module[
		(* You must place the function’s source code here. *)
	],
	CompilationTarget -> "C",
	RuntimeOptions -> "Speed",
	RuntimeAttributes -> {Listable},
	Parallelization -> True
]
```
</details>

The environment in which the `ciede2000` function was tested is :
- Ubuntu 24.04.2 LTS
- WolframScript 1.13
- Wolfram Language 14.2.1
- GCC 13.3

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in Wolfram Language** brings accuracy into your applications.

🌐 [Suitable in 40+ Languages](../../#implementations)
