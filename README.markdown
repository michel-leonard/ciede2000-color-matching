# CIEDE2000 Color-Difference

This [source code](https://bit.ly/ΔE) is not affiliated with the CIE (International Commission on Illumination), has not been validated by it, and is released into the **public domain**. It is provided "as is" without any warranty.

## Status

Fully tested — Ready to be deployed in **production** environments.

## Version

This document describes the **CIE ΔE00** functions v1.0.0, released on March 1, 2025.

![the CIEDE2000 formula, based on CIE Technical Report 142-2001](docs/images/delta-e-2000.jpg)

**Overview**: The formula is a modern metric for comparing two colors in the CIELAB color space, which improves on the earlier CIE76 formula by integrating new perceptual factors, resulting in more accurate **color comparisons**.

## Implementations

The reference ΔE2000 implementation is a single function that produces consistent results to **10 decimal places** across multiple programming languages :

- **Enterprise and Web Development** (ΔE00):
	- [Java](ciede-2000.java#L14), [Kotlin](ciede-2000.kt#L8)
	- [C#](ciede-2000.cs#L6)
	- [JavaScript](ciede-2000.js#L6), [TypeScript](ciede-2000.ts#L6)
	- [PHP](ciede-2000.php#L8)
	- [Python](ciede-2000.py#L6)
	- [Ruby](ciede-2000.rb#L6)
	- [Dart](ciede-2000.dart#L8)
	- [ASP](ciede-2000.asp#L10), VBScript
	- [Lua](ciede-2000.lua#L6), LuaJIT
	- [Haxe](ciede-2000.hx#L9)
	- [Perl](ciede-2000.pl#L10)
	- [SQL](ciede-2000.sql#L8)
	- [Pascal](ciede-2000.pas#L9)

- **Scientific Computing and Data Analysis** (ΔE00):
	- [MATLAB](ciede-2000.m#L12)
	- [Mathematica](ciede-2000.wls#L6), Wolfram Language
	- [R](ciede-2000.r#L12)
	- [Julia](ciede-2000.jl#L9)
	- [F#](ciede-2000.fs#L8)
	- [Racket](ciede-2000.rkt#L8)
	- [Excel](ciede-2000.xls)
	- [VBA](ciede-2000.bas#L9)

- **Systems and Performance-Critical Programming** (ΔE00):
	- [C](ciede-2000.c#L13), C++
	- [D](ciede-2000.d#L8)
	- [Rust](ciede-2000.rs#L8)
	- [Go](ciede-2000.go#L10)
	- [Swift](ciede-2000.swift#L8)
	- [Nim](ciede-2000.nim#L10)
	- [Zig](ciede-2000.zig#L9)
	- [Wren](ciede-2000.wren#L6)

These classical implementations of the CIEDE2000 **color difference formula** are [completely](tests#comparison-with-university-of-rochester-worked-examples) consistent with the samples studied by Gaurav Sharma, Wencheng Wu, and Edul N. Dalal at the University of Rochester.

## Usage

To compare **hexadecimal** (e.g., "#FFF") or **RGB** colors using the CIEDE2000 function, follow these examples :
|Programming Language|Compare hexadecimal colors|Compare RGB colors|
|:--:|:--:|:--:|
|Python|[compare-hex-colors.py](tests/py/compare-hex-colors.py#L166)|[compare-rgb-colors.py](tests/py/compare-rgb-colors.py#L166)|
|JavaScript|[compare-hex-colors.js](tests/js/compare-hex-colors.js#L169)|[compare-rgb-colors.js](tests/js/compare-rgb-colors.js#L169)|
|PHP|[compare-hex-colors.php](tests/php/compare-hex-colors.php#L177)|[compare-rgb-colors.php](tests/php/compare-rgb-colors.php#L177)|
|C|[compare-hex-colors.c](tests/c/compare-hex-colors.c#L216)|[compare-rgb-colors.c](tests/c/compare-rgb-colors.c#L208)|
|Java|[compare-hex-colors.java](tests/java/compare-hex-colors.java#L187)|[compare-rgb-colors.java](tests/java/compare-rgb-colors.java#L186)|
|Dart|[compare-hex-colors.dart](tests/dart/compare-hex-colors.dart#L174)|[compare-rgb-colors.dart](tests/dart/compare-rgb-colors.dart#L174)|

**Note** : A [all-in-one](#rgb-and-hexadecimal-color-comparison-for-the-web-in-javascript) color comparison function is available in JavaScript, accepting both hexadecimal and RGB inputs.

### The calculation of ΔE ...

The typical calculation of the ΔE between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function, which is available in the language-specific implementation file, by operating as follows.

#### Java
```java
// Example usage of the CIEDE2000 function within the L*a*b* color space in Java

// L1 = 19.3166        a1 = 73.5           b1 = 122.428
// L2 = 19.0           a2 = 76.2           b2 = 91.372

double deltaE = ciede_2000(l1, a1, b1, l2, a2, b2);
System.out.println(deltaE);

// This shows a ΔE2000 of 9.60876174564
```

#### Kotlin
```kt
// Example usage of the CIEDE2000 function in Kotlin
val deltaE = ciede_2000(l1, a1, b1, l2, a2, b2)
println(deltaE)
```

#### C#
```csharp
// Example usage of the CIEDE2000 function in C# (.NET Core)
double deltaE = ciede_2000(l1, a1, b1, l2, a2, b2);
Console.WriteLine(deltaE);
```

#### JavaScript - TypeScript
```javascript
// Example usage of the CIEDE2000 function in JavaScript
const deltaE = ciede_2000(l1, a1, b1, l2, a2, b2);
console.log(deltaE);
```

#### PHP
```php
// Example usage of the CIEDE2000 function in PHP
$deltaE = ciede_2000($l1, $a1, $b1, $l2, $a2, $b2);
echo $deltaE;
```

#### Python
```python
# Example usage of the CIEDE2000 function in Python
delta_e = ciede_2000(l1, a1, b1, l2, a2, b2)
print(delta_e)
```

#### Ruby
```ruby
# Example usage of the CIEDE2000 function in Ruby
delta_e = ciede_2000(l1, a1, b1, l2, a2, b2)
puts delta_e
```

#### Dart
```dart
// Example usage of the CIEDE2000 function in Dart
final double delta_e = ciede_2000(l1, a1, b1, l2, a2, b2)
print(delta_e)
```

#### ASP - VBScript
```vbscript
' Example usage of the CIEDE2000 function in ASP
Dim deltaE
deltaE = ciede_2000(l1, a1, b1, l2, a2, b2)
Response.Write(deltaE)
```

#### Lua - LuaJIT
```lua
-- Example usage of the CIEDE2000 function in Lua
local deltaE = ciede_2000(l1, a1, b1, l2, a2, b2);
print(deltaE);
```

#### Haxe
```hx
// Example usage of the CIEDE2000 function in Haxe
var deltaE = ciede_2000(l1, a1, b1, l2, a2, b2);
trace(deltaE);
```

#### Perl
```pl
# Example usage of the CIEDE2000 function in Perl
my $deltaE = ciede_2000($l1, $a1, $b1, $l2, $a2, $b2);
print $deltaE;
```

#### SQL
```SQL
-- Example usage of the CIEDE2000 function in SQL
SELECT ciede_2000(l1, a1, b1, l2, a2, b2) AS delta_e;
```

#### Pascal
```pas
// Example usage of the CIEDE2000 function in Pascal
deltaE := ciede_2000(l1, a1, b1, l2, a2, b2);
writeln(deltaE);
```

#### MATLAB
```matlab
% Example usage of the CIEDE2000 function in MATLAB
deltaE = ciede_2000(l1, a1, b1, l2, a2, b2);
disp(deltaE);
```

#### Mathematica - Wolfram Language
```mathematica
(* Example usage of the CIEDE2000 function in Mathematica *)
deltaE = ciede2000[l1, a1, b1, l2, a2, b2];
Print[deltaE];
```

#### R
```r
# Example usage of the CIEDE2000 function in R
delta_e <- ciede_2000(l1, a1, b1, l2, a2, b2)
print(delta_e)
```

#### Julia
```jl
# Example usage of the CIEDE2000 function in Julia
deltaE = ciede_2000(l1, a1, b1, l2, a2, b2)
println(deltaE)
```

#### F#
```fs
// Example usage of the CIEDE2000 function in F#
let deltaE = ciede_2000 l1 a1 b1 l2 a2 b2
printfn "%f" deltaE
```

#### Racket
```racket
; Example usage of the CIEDE2000 function in Racket
(define delta-e (ciede_2000 l1 a1 b1 l2 a2 b2))
(displayln delta-e)
```

#### Excel
When it comes to displaying color differences in **Microsoft Excel**, we update the six columns containing the color values (L\*, a\*, b\*) and drag the formula down to calculate as many ΔE 2000 values as necessary.

#### VBA
```vba
' Example usage of the CIEDE2000 function in VBA
Dim deltaE As Double
deltaE = ciede_2000(l1, a1, b1, l2, a2, b2)
Debug.Print deltaE
```

#### C - C++
For these programming languages, see the original [full example](#source-code-in-c).

#### D
```d
// Example usage of the CIEDE2000 function in D
double deltaE = ciede_2000(l1, a1, b1, l2, a2, b2);
writeln(format("%.12f", deltaE));
```

#### Rust
```rs
// Example usage of the CIEDE2000 function in Rust
let delta_e = ciede_2000(l1, a1, b1, l2, a2, b2);
println!("{}", delta_e);
```

#### Go
```go
// Example usage of the CIEDE2000 function in Go
deltaE := ciede_2000(l1, a1, b1, l2, a2, b2);
fmt.Printf("%f\n", deltaE);
```

#### Swift
```swift
// Example usage of the CIEDE2000 function in Swift
let delta_e = ciede_2000(l_1: l1, a_1: a1, b_1: b1, l_2: l2, a_2: a2, b_2: b2)
print(delta_e)
```

#### Nim
```nim
# Example usage of the CIEDE2000 function in Nim
let delta_e = ciede_2000(l1, a1, b1, l2, a2, b2)
echo delta_e
```

#### Zig
```zig
// Example usage of the CIEDE2000 function in Zig
const delta_e = ciede_2000(l1, a1, b1, l2, a2, b2);
std.debug.print("{}\n", .{delta_e});
```

#### Wren
```wren
// Example usage of the CIEDE2000 function in Wren
var delta_e = ciede_2000(l1, a1, b1, l2, a2, b2)
System.print(delta_e)
```

## RGB and Hexadecimal Color Comparison for the Web in JavaScript

[Just 3kb](docs/ciede-2000.min.js) - Simple. Fast. Reliable. This JavaScript function accepts both RGB and hexadecimal color formats and computes the color difference using the CIE ΔE2000 formula :
```js
// This function written in JavaScript is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.
function ciede_2000(a,b,c,d,e,f){"use strict";var g,h,i,j,k,l,m,n;return"string"==typeof a?(g=parseInt((4===a.length?a[0]+a[1]+a[1]+a[2]+a[2]+a[3]+a[3]:a).substring(1),16),"string"==typeof b?(d=(n=parseInt((4===b.length?b[0]+b[1]+b[1]+b[2]+b[2]+b[3]+b[3]:b).substring(1),16))>>16&255,e=n>>8&255,f=255&n):(f=d,e=c,d=b),a=g>>16&255,b=g>>8&255,c=255&g):"string"==typeof d&&(d=(g=parseInt((4===d.length?d[0]+d[1]+d[1]+d[2]+d[2]+d[3]+d[3]:d).substring(1),16))>>16&255,e=g>>8&255,f=255&g),b/=255,c/=255,g=41.24564390896921*(a=(a/=255)<.0404482362771082?a/12.92:Math.pow((a+.055)/1.055,2.4))+35.7576077643909*(b=b<.0404482362771082?b/12.92:Math.pow((b+.055)/1.055,2.4))+18.043748326639893*(c=c<.0404482362771082?c/12.92:Math.pow((c+.055)/1.055,2.4)),h=1.9333895582329317*a+11.9192025881303*b+95.03040785363677*c,b=(n=21.267285140562247*a+71.5152155287818*b+7.217499330655958*c)/100,c=h/108.883,a=(a=g/95.047)<216/24389?841/108*a+4/29:Math.cbrt(a),g=116*(b=b<216/24389?841/108*b+4/29:Math.cbrt(b))-16,n=500*(a-b),h=200*(b-(c=c<216/24389?841/108*c+4/29:Math.cbrt(c))),e/=255,f/=255,i=41.24564390896921*(d=(d/=255)<.0404482362771082?d/12.92:Math.pow((d+.055)/1.055,2.4))+35.7576077643909*(e=e<.0404482362771082?e/12.92:Math.pow((e+.055)/1.055,2.4))+18.043748326639893*(f=f<.0404482362771082?f/12.92:Math.pow((f+.055)/1.055,2.4)),l=1.9333895582329317*d+11.9192025881303*e+95.03040785363677*f,e=(m=21.267285140562247*d+71.5152155287818*e+7.217499330655958*f)/100,f=l/108.883,d=(d=i/95.047)<216/24389?841/108*d+4/29:Math.cbrt(d),i=116*(e=e<216/24389?841/108*e+4/29:Math.cbrt(e))-16,m=500*(d-e),l=200*(e-(f=f<216/24389?841/108*f+4/29:Math.cbrt(f))),d=.5*(Math.hypot(n,h)+Math.hypot(m,l)),d*=d*d*d*d*d*d,d=1+.5*(1-Math.sqrt(d/(d+6103515625))),j=Math.hypot(n*d,h),k=Math.hypot(m*d,l),n=Math.atan2(h,n*d),l=Math.atan2(l,m*d),n+=2*Math.PI*(n<0),l+=2*Math.PI*(l<0),d=Math.abs(l-n),Math.PI-1e-14<d&&d<Math.PI+1e-14&&(d=Math.PI),m=.5*(n+l),n=.5*(l-n),Math.PI<d&&(0<n?n-=Math.PI:n+=Math.PI,m+=Math.PI),e=36*m-55*Math.PI,d=.5*(j+k),d*=d*d*d*d*d*d,e=-2*Math.sqrt(d/(d+6103515625))*Math.sin(Math.PI/3*Math.exp(e*e/(-25*Math.PI*Math.PI))),f=(i-g)/(1+.015*(d=((d=.5*(g+i))-50)*(d-50))/Math.sqrt(20+d)),a=1+.24*Math.sin(2*m+.5*Math.PI)+.32*Math.sin(3*m+8*Math.PI/15)-.17*Math.sin(m+Math.PI/3)-.2*Math.sin(4*m+3*Math.PI/20),d=j+k,b=2*Math.sqrt(j*k)*Math.sin(n)/(1+.0075*d*a),c=(k-j)/(1+.0225*d),Math.sqrt(f*f+b*b+c*c+c*b*e)}
```

For reference, the maximum possible contrast, between white (#fff) and black (#000), yields a ΔE2000 value of 100.

### Use Cases

These [examples](https://michel-leonard.github.io/ciede2000-color-matching/compare-hex-rgb-colors.html) show how to compare different combinations of RGB and Hex color formats :

#### Example 1 : Compare Hex vs Hex
```js
// blue compared to darkslateblue 
var delta_e = ciede_2000('#00F', '#483D8B')
// ΔE2000 ≈ 15.91 — noticeable difference
```

#### Example 2 : Compare Hex vs RGB
```js
// darkslateblue compared to indigo
var delta_e = ciede_2000('#483d8b', 75,0,130)
// ΔE2000 ≈ 12.19 — distinct difference
```

#### Example 3 : Compare RGB vs Hex
```js
// indigo compared to darkblue 
var delta_e = ciede_2000(75, 0, 130, '#00008b')
// ΔE2000 ≈ 7.72 — moderate difference
```

#### Example 4 : Compare RGB vs RGB
```js
// darkblue compared to navy
var delta_e = ciede_2000(0, 0, 139, 0, 0, 128)
// ΔE2000 ≈ 1.56 — slight difference
```

### ⚡ Performance

This JavaScript ΔE2000 color difference function works with RGB and hex colors and can compute around **1,000,000 values in ~500 ms** on modern browsers, making it suitable for real-time tasks.

## Possible Usage

- **Precision**: [Medical](docs#where-to-use-the-cie-δe-2000-metric) image processing (shade differences between healthy and diseased tissues).
- **Efficiency**: Machine vision (color-based quality control).
- **Everywhere**: Colorimetry in scientific research (studies on color perception).

The textile industry usually adjusts `k_l` to `2.0` in the source code for its needs.

#### Common Tasks Requiring ΔE 2000

- Compare two hex colors
- Find the nearest match in a color palette
- Calibrate printers using ΔE 2000
- Ensure display color fidelity
- Compare digital vs. printed color
- Create color-true AR experiences
- Track color fading over time
- Gauge fruit ripeness

### Live Examples

Based on our JavaScript implementation, you can see the CIEDE2000 color difference formula in action here :
- A [tool](https://michel-leonard.github.io/ciede2000-color-matching) that identify the name of the selected color based on a picture.
- A [discovery generator](https://michel-leonard.github.io/ciede2000-color-matching/samples.html) for quick, small-scale testing and exploration.
- A [large-scale generator](https://michel-leonard.github.io/ciede2000-color-matching/batch.html) used to validate new implementations.
- A [simple calculator](https://michel-leonard.github.io/ciede2000-color-matching/calculator.html) of the **ΔE 2000**, given two L\*a\*b\* colors.

## Source Code in C

Here is the **C99** source code from Michel Leonard to implement the **CIE ΔE2000** function :
```c
// This function written in C is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

#include <math.h>

// Expressly defining pi ensures that the code works on different platforms.
#ifndef M_PI
#define M_PI 3.14159265358979323846264338328
#endif

// The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
// "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 128.
static double ciede_2000(const double l_1, const double a_1, const double b_1, const double l_2, const double a_2, const double b_2) {
	// Working in C with the CIEDE2000 color-difference formula.
	// k_l, k_c, k_h are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	const double k_l = 1.0;
	const double k_c = 1.0;
	const double k_h = 1.0;
	double n = (hypot(a_1, b_1) + hypot(a_2, b_2)) * 0.5;
	n = n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - sqrt(n / (n + 6103515625.0)));
	// hypot calculates the Euclidean distance while avoiding overflow/underflow.
	const double c_1 = hypot(a_1 * n, b_1);
	const double c_2 = hypot(a_2 * n, b_2);
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	double h_1 = atan2(b_1, a_1 * n);
	double h_2 = atan2(b_2, a_2 * n);
	if (h_1 < 0.0)
		h_1 += 2.0 * M_PI;
	if (h_2 < 0.0)
		h_2 += 2.0 * M_PI;
	n = fabs(h_2 - h_1);
	// Cross-implementation consistent rounding.
	if (M_PI - 1E-14 < n && n < M_PI + 1E-14)
		n = M_PI;
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	double h_m = (h_1 + h_2) * 0.5;
	double h_d = (h_2 - h_1) * 0.5;
	if (M_PI < n) {
		if (0.0 < h_d)
			h_d -= M_PI;
		else
			h_d += M_PI;
		h_m += M_PI;
	}
	const double p = 36.0 * h_m - 55.0 * M_PI;
	n = (c_1 + c_2) * 0.5;
	n = n * n * n * n * n * n * n;
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	const double r_t = -2.0 * sqrt(n / (n + 6103515625.0))
				* sin(M_PI / 3.0 * exp(p * p / (-25.0 * M_PI * M_PI)));
	n = (l_1 + l_2) * 0.5;
	n = (n - 50.0) * (n - 50.0);
	// Lightness.
	const double l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / sqrt(20.0 + n)));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	const double t = 1.0 	+ 0.24 * sin(2.0 * h_m + M_PI / 2.0)
				+ 0.32 * sin(3.0 * h_m + 8.0 * M_PI / 15.0)
				- 0.17 * sin(h_m + M_PI / 3.0)
				- 0.20 * sin(4.0 * h_m + 3.0 * M_PI / 20.0);
	n = c_1 + c_2;
	// Hue.
	const double h = 2.0 * sqrt(c_1 * c_2) * sin(h_d) / (k_h * (1.0 + 0.0075 * n * t));
	// Chroma.
	const double c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
	// Returning the square root ensures that the result reflects the actual geometric
	// distance within the color space, which ranges from 0 to approximately 185.
	return sqrt(l * l + h * h + c * c + c * h * r_t);
}

#include <stdio.h>

int main(void) {
	// Compute the Delta E (CIEDE2000) color difference between two Lab colors.
	const double l_1 = 22.7233, a_1 = 20.0904, b_1 = -46.694;
	const double l_2 = 23.0331, a_2 = 14.973, b_2 = -42.5619;
	const double delta_e = ciede_2000(l_1, a_1, b_1, l_2, a_2, b_2);
	printf("l_1 = %g\na_1 = %g\nb_1 = %g\nl_2 = %g\na_2 = %g\nb_2 = %g\ndelta_e = %.15g\n",
		l_1, a_1, b_1, l_2, a_2, b_2, delta_e);
}
```

### Quick Online Demo

You can use an [online compiler](https://www.google.com/search?q=Online+C+Compiler) to set up this quick demo by **copy/paste** and get the same results as below.

### Compilation Demo

Once you've placed the source code in the `ciede-2000.c` file, and after navigating (using Terminal in Linux/Mac or PowerShell in Windows) to the appropriate directory, run one of the following compilation commands :
- `gcc -std=c99 -Wall -Wextra -pedantic -Ofast -o ciede-2000-compiled ciede-2000.c -lm`
- `clang -std=c99 -Wall -Wextra -pedantic -Ofast -o ciede-2000-compiled ciede-2000.c -lm`

Running the program via `./ciede-2000-compiled` then results in the following display :
```
l_1 = 22.7233
a_1 = 20.0904
b_1 = -46.694
l_2 = 23.0331
a_2 = 14.973
b_2 = -42.5619
delta_e = 2.037258269709
```

## Testing and Validation

To ensure accurate color evaluation, [extensive testing](tests#ciede-2000-function-test) involving **1,365,000,000** comparisons has been conducted. Correctness and consistency of ΔE00 implementations across all programming languages ​​are essential in this project :

- **Test Cases**: Each programming language generates a CSV file containing **7,500,000** random samples.
- **Tolerance**: All programming languages reproduce every sample, except their own, with a tolerance of 1e-10.
- **Cross-Language Consistency**: This procedure could be respected and extended to new programming languages.

In other words, the absolute value of the difference between any two implementations does not exceed 1e-10.

**Correctness**: AI systems and developers are encouraged to perform tests that identify subtleties related to each language. This should help discover what is actually breaking consistency across all implementations.

### Numerical Stability in CIEDE2000

To confirm its exceptional accuracy, the JavaScript implementation was compared to an old and reliable reference, with no deviations greater than **1e-12** detected in ΔE00s across **80,000,000,000** random color pairs tested. Minor differences were attributed to degree-to-radian conversions in the reference calculations.

#### Angle Conversions

The professional approach in software is to use radians for mathematical calculations, because angle conversions, while theoretically valid, result in a loss of precision due to rounding errors in floating-point numbers. Here, only radians are used, without conversion, but this can be a source of inconsistencies for an external implementation.

As an example, we rely on `value > π` in radians, which is the same as `value > 180` in degrees. Due to conversions, an implementation [using degrees](http://www.brucelindbloom.com/index.html?ColorDifferenceCalc.html) may obtain `180.00000000000003`, while its equivalent [in radians](https://michel-leonard.github.io/ciede2000-color-matching/calculator.html?L1=88&a1=-124&b1=56&L2=97&a2=62&b2=-28) would have given exactly `π = 3.141592653589793`, leading to different [branching](ciede-2000.js#L32) and discrepancies in the calculated ΔE 2000.

#### Angle Computations

In most environments, when **a\*** and **b\*** are both zero, `atan2(0, 0)` correctly evaluates to `0`, following mathematical convention, as in [JavaScript](https://michel-leonard.github.io/ciede2000-color-matching/calculator.html?L1=1&a1=0&b1=0&L2=2&a2=0&b2=0). However, some programming languages may instead throw an exception or return `NaN` or `NULL`, and so patches (e.g., [null coalescing](ciede-2000.sql#L30)) may be necessary to ensure fully reliable implementations.

#### IEEE 754 floating-point Limitations

Minor discrepancies can arise between programming languages, for instance, `atan2(-49.2, -34.9)` evaluates to `-2.1877696633888672` in Python and `-2.1877696633888677` in JavaScript, while `-2.187769663388867475...` is correct. Here, tolerated deviation for a cross-language exact color match is set to `1e-10`, linking sufficiency and achievability.

#### Numerical Precision: 32-bit vs 64-bit

Current implementations, which emphasize precision, use **64-bit floating point numbers**. However, it has been noted that using 32-bit numbers results in an almost always negligible difference of ±0.0002 in the calculated ΔE 2000.

#### Debugging

Rounding L\*a\*b\* components and ΔE 2000 to [4 decimal places](tests#roundings) can be a solution for realistic color comparisons.

### Performance Overview

Runtimes were recorded while calculating 100 million iterations of the color difference formula ΔE 2000.

| Language | Compilation Type | Duration (mm:ss) | Performance factor compared to C |
|:--:|:--:|:--:|:--:|
| C | Compiled| 00:45 | 1× ([Reference](https://bit.ly/ΔE2000)) |
| Rust | Compiled | 00:52 | 1.15× slower |
| Go | Compiled | 00:52 | 1.15× slower |
| LuaJIT | Just-In-Time Compiled | 00:53 | 1.18× slower |
| Java | Just-In-Time Compiled | 00:57 | 1.25× slower |
| Kotlin |  Just-In-Time Compiled | 00:57 | 1.26× slower |
| MATLAB | Interpreted | 01:06 | 1.46× slower |
| TypeScript | Just-In-Time Compiled| 01:17 | 1.7× slower |
| JavaScript | Just-In-Time Compiled | 01:18 | 1.73× slower |
| PHP | Interpreted | 03:28 | 4.57× slower |
| Lua | Interpreted | 07:03 | 9.36× slower |
| Ruby | Interpreted | 07:20 | 9.65× slower |
| Perl | Interpreted | 08:20 | 12.44× slower |
| Python | Interpreted | 10:13 | 13.45× slower |
| SQL | Database Query Language | 22:17 | 29.71× slower |
| VBA | Interpreted | 11:35:00 | 935.56× slower |

## Contributing

Here are some examples of programming languages that could be used to expand the `ciede_2000` function :
- Haskell
- OCaml
- Crystal
- Fortran
- V

### Methodology

To ensure consistency across implementations, please follow these guidelines :
1. **Base your implementation** on an existing one, copy-pasting and adapting is encouraged.
2. **Validate correctness** basically using the [discovery generator](https://michel-leonard.github.io/ciede2000-color-matching/samples.html), and formally using the [large-scale generator](https://michel-leonard.github.io/ciede2000-color-matching/batch.html) :
   - Generate 1,000,000 samples, or 10,000 if you encounter technical limitations.
   - Verify that the computed ΔE 2000 values do not deviate by more than **1e-10** from reference values.
3. **Submit a pull request** with your implementation.

To enhance your contribution, consider writing documentation, as done for other programming languages. Your source code, along with the others, will then be reviewed and made available in this public domain repository.

> [!NOTE]
> If the `atan2` function is not available in your chosen language, you can use the polyfill provided in the [ASP](ciede-2000.asp#L25) and [VBA](ciede-2000.bas#L26) versions. Similarly, when `hypot` is not available, the polyfill template can be found in the [Lua](ciede-2000.lua#L16) version.

### Other way to contribute

Purchase the original CIE Technical Report [142-2001](https://store.accuristech.com/cie/standards/cie-142-2001?product_id=1210060). This document, without which this repository would not exist, specifically presents and formalizes the ΔE 2000 formula, providing guidelines on how to implement it.

## Internet Archive

For these CIE ΔE2000 functions, an archived version of the source code is available at `https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.c`. To access a different version, simply replace the `.c` extension in the URL with the desired file extension.

## Short URL
Quickly share this GitHub project permanently using [bit.ly/color-difference](https://bit.ly/color-difference).
