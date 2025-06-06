# ΔE2000 Workflows

GitHub Actions workflows are set up, alongside [tests](../../tests#ciede-2000-function-test), to ensure the correctness of the ΔE2000 implementation. These workflows execute scripts that generate CSV-formatted lines to standard output (STDOUT), which are processed by a C99 verification program.

The current workflows are :
- [![AWK CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-awk.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-awk.yml)
- [![C# CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-cs.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-cs.yml)
- [![C99 CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-c.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-c.yml)
- [![D CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-d.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-d.yml)
- [![Dart CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-dart.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-dart.yml)
- [![F# CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-fs.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-fs.yml)
- [![Fortran CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-f90.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-f90.yml)
- [![Go CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-go.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-go.yml)
- [![Haxe CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-hx.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-hx.yml)
- [![Java CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-java.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-java.yml)
- [![JavaScript CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-js.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-js.yml)
- [![Julia CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-jl.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-jl.yml)
- [![Kotlin CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-kt.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-kt.yml)
- [![LuaJIT CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-lua.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-lua.yml) — *Lua is tested using LuaJIT*
- [![Matlab CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-m.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-m.yml) — *Matlab is tested using GNU Octave*
- [![Nim CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-nim.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-nim.yml)
- [![PHP CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-php.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-php.yml)
- [![Pascal CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-pas.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-pas.yml) — *Pascal is tested using Free Pascal*
- [![Perl CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-pl.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-pl.yml)
- [![Python CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-py.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-py.yml)
- [![R CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-r.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-r.yml)
- [![Racket CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-rkt.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-rkt.yml)
- [![Ruby CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-rb.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-rb.yml)
- [![Rust CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-rs.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-rs.yml)
- [![SQL CIEDE2000 Testing (MariaDB)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-sql-mariadb.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-sql-mariadb.yml)
- [![SQL CIEDE2000 Testing (PostgreSQL)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-sql-postgresql.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-sql-postgresql.yml)
- [![Swift CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-swift.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-swift.yml)
- [![TypeScript CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-ts.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-ts.yml)
- [![VBA CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-bas.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-bas.yml) — *VBA is tested using FreeBASIC*
- [![Wren CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-wren.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-wren.yml)
- [![Zig CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-zig.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-zig.yml)

## Workflow Details

Each workflow runs a language-specific script located in the `tests` directory. These scripts compute ΔE2000 for a random set of 10,000,000 color pairs (L\*a\*b\* values) and output the results as CSV lines. The output is piped to a C99 verifier, located at `tests/c/stdin-verifier.c`, which performs verification using the fast, accurate, and reliable C99 version.

## Verification Process

The [stdin-verifier.c](../../tests/c/stdin-verifier.c#L125) program:

1. Reads each CSV line from STDIN.
2. Compares the computed ΔE2000 value with the reference C99 implementation.
3. Applies a tolerance of `1e-10` in floating-point comparisons.
4. Displays a summary with :
	- The number of successful comparisons.
	- The number of errors.
	- The maximum observed difference in ΔE2000 values.

A JavaScript-based verifier is also [available](../../tests/js/stdin-verifier.js#L112); it behaves like the C99 verifier, runs with Node.js, and is used for cross-verification between C99 and JavaScript implementations.

**Note** : A LuaJIT-based verifier was developed to increase the overall resilience of the project. Just offer it in your preferred language!

## Conclusion

A successful workflow guarantees that the implementation it is testing produces the same ΔE2000 values ​​as all others, when comparing two colors using the `ciede_2000` function.

## Example Output

The verification script will output a summary similar to this :

```
CIEDE2000 Verification Summary :
- Last Verified Line : 67,-93.3,120,69,-102.6,61,14.0863156668524
- Duration : 30.77 s
- Successes : 10000000
- Errors : 0
- Maximum Difference : 7.1054273576010019e-13
```
