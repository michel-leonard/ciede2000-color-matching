# ΔE2000 — Accurate. Fast. Mathematica-powered.

This reference ΔE2000 implementation written in Mathematica provides reliable and accurate perceptual **color difference** calculation.

## Source Code

The full source code is available [here](../../ciede-2000.wls#L6), and is archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.wls).

## Example usage in Mathematica (Wolfram Language)

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```mathematica
(* Example usage of the CIEDE2000 function in Mathematica *)

(* L1 = 19.3166        a1 = 73.5           b1 = 122.428 *)
(* L2 = 19.0           a2 = 76.2           b2 = 91.372 *)

deltaE = ciede2000[l1, a1, b1, l2, a2, b2];
Print[deltaE];

(* This shows a ΔE2000 of 9.60876174564 *)
```

**Note**: L\* is usually between 0 and 100, a\* and b\* between -128 and +127.

To compare **hexadecimal** (e.g., "#FFF") or **RGB colors** using the CIEDE2000 function, examples are available in several languages :
- [AWK](../awk#-flexibility)
- [C](../c#δe2000--accurate-fast-c-powered)
- [Dart](../dart#δe2000--accurate-fast-dart-powered)
- [JavaScript](../js#-flexibility)
- [Java](../java#δe2000--accurate-fast-java-powered)
- [Kotlin](../kt#δe2000--accurate-fast-kotlin-powered)
- [Lua](../lua#-flexibility)
- [PHP](../php#δe2000--accurate-fast-php-powered)
- [Python](../py#δe2000--accurate-fast-python-powered)
- [Ruby](../rb#δe2000--accurate-fast-ruby-powered)
- [Rust](../rs#δe2000--accurate-fast-rust-powered)
