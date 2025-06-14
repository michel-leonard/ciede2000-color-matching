# ΔE2000 Workflows

GitHub Actions workflows are set up, alongside [tests](../../tests#ciede-2000-function-test), to ensure the correctness of implementations. These workflows run scripts that process lines containing 2 colors received in CSV format, rewrite them with ΔE2000 color difference appended to standard output (STDOUT), so that they can be checked by a C99 driver which makes a final report on the calculations.

The current workflows are :
- [![AWK CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-awk.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-awk.yml)
- [![C# CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-cs.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-cs.yml)
- [![C++ CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-cpp.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-cpp.yml)
- [![C99 CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-c.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-c.yml)
- [![D CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-d.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-d.yml)
- [![Dart CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-dart.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-dart.yml)
- [![F# CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-fs.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-fs.yml)
- [![Fortran CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-f90.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-f90.yml)
- [![Go CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-go.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-go.yml)
- [![Haskell CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-hs.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-hs.yml)
- [![Haxe CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-hx.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-hx.yml)
- [![Java CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-java.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-java.yml)
- [![JavaScript CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-js.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-js.yml)
- [![Julia CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-jl.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-jl.yml)
- [![Kotlin CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-kt.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-kt.yml)
- [![LuaJIT CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-lua.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-lua.yml) — *Lua is tested using LuaJIT*
- [![Matlab CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-m.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-m.yml) — *Matlab is tested using GNU Octave*
- [![Nim CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-nim.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-nim.yml)
- [![PHP CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-php.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-php.yml)
- [![Pascal CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-pas.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-pas.yml) — *Pascal is tested using Free Pascal*
- [![Perl CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-pl.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-pl.yml)
- [![Python CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-py.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-py.yml)
- [![R CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-r.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-r.yml)
- [![Racket CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-rkt.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-rkt.yml)
- [![Ruby CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-rb.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-rb.yml)
- [![Rust CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-rs.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-rs.yml)
- [![SQL CIEDE2000 Testing (MariaDB)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-sql-mariadb.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-sql-mariadb.yml)
- [![SQL CIEDE2000 Testing (PostgreSQL)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-sql-postgresql.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-sql-postgresql.yml)
- [![Swift CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-swift.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-swift.yml)
- [![TypeScript CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-ts.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-ts.yml)
- [![VBA CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-bas.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-bas.yml) — *VBA is tested using FreeBASIC*
- [![Wren CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-wren.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-wren.yml)
- [![Zig CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-zig.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-zig.yml)

## Workflow Details

Each workflow executes a language-specific script from the `tests` directory. These scripts compute the ΔE2000 values for 10,000,000 color pairs (in L\*a\*b\* format) provided via CSV files, appending the results as a new column. The output is then passed to a C99-based verifier that is authoritative, accurate, and reliable.

## Verification Process

In each workflow that tests a programming language, the [ciede-2000-driver.c](../../tests/c/ciede-2000-driver.c) program :
- Generates a reproducible CSV file with two colors per line.
- Reads each line from STDIN to retrieve the ΔE2000 value computed by the language under test.
- Compares the computed value against the reference C99 implementation.
- Uses a tolerance of 1e-10 for floating-point comparisons.
- Outputs a summary report.

A JavaScript-based verifier is also [available](../../tests/js/stdin-verifier.js#L112); it behaves like the C99 verifier, runs with Node.js, and is used for cross-verification between C99 and JavaScript implementations.

**Note** : A LuaJIT-based verifier was developed to increase the overall resilience of the project. Just offer it in your preferred language!

## Example Output

The verifier will output a summary similar to this :
```
CIEDE2000 Verification Summary :
  First Verified Line : 69.47,-24,-36,20,-36.8,-94.1,48.6133314128157
             Duration : 56.73 s
            Successes : 10000000
               Errors : 0
      Average Delta E : 62.9396
    Average Deviation : 4.5856684738332374e-14
    Maximum Deviation : 5.6843418860808015e-13
```

## Conclusion

A successful workflow guarantees that the implementation it is testing produces the same ΔE2000 values ​​as all others, when comparing two colors using the `ciede_2000` function.

Our task ? To boost your critical apps with reliable and native code.

