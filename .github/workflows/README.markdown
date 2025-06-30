# ΔE2000 Workflows

GitHub Actions workflows are in place, running [tests](../../tests#ciede-2000-function-test) to ensure the correctness of the CIE ΔE<sub>00</sub> implementations. These tests require each programming language to process lines containing two L\*a\*b\* colors received in CSV format, rewrite these lines to their standard output (STDOUT) adding the ΔE2000, so that the latter can be checked by a C99 driver drawing up a final report on the relatability of the calculations.

The current workflows are :
- [![AWK CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-awk.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-awk.yml)
- [![bc CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-bc.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-bc.yml)
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
- [![PowerShell CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-ps1.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-ps1.yml)
- [![Python CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-py.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-py.yml)
- [![R CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-r.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-r.yml)
- [![Racket CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-rkt.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-rkt.yml)
- [![Ruby CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-rb.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-rb.yml)
- [![Rust CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-rs.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-rs.yml)
- [![SQL CIEDE2000 Testing (MariaDB)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-sql-mariadb.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-sql-mariadb.yml)
- [![SQL CIEDE2000 Testing (PostgreSQL)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-sql-postgresql.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-sql-postgresql.yml)
- [![Swift CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-swift.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-swift.yml)
- [![TCL CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-tcl.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-tcl.yml)
- [![TypeScript CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-ts.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-ts.yml)
- [![VBA CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-bas.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-bas.yml) — *VBA is tested using FreeBASIC*
- [![Wren CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-wren.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-wren.yml)
- [![Zig CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-zig.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-zig.yml)

## Workflow Details

Each workflow executes a script specific to the programming language it is testing, and brings into action the existing drivers in the `tests` directory. These drivers report the ΔE2000 values they calculate for 10,000,000 well-chosen color pairs, so that the C99 driver, equipped with a verifier, can agree on the results. Precisions exceeding 64 bits are validated in Julia, which has a generic driver equipped to be authoritative.

## Verification Process

In each workflow that tests a programming language, the [ciede-2000-driver.c](../../tests/c/ciede-2000-driver.c) program :
- Generates a reproducible CSV file with two colors per line.
- Reads each line from STDIN to retrieve the ΔE<sub>00</sub> value calculated by the language under test.
- Compares the calculated value with the reference C99 implementation.
- Uses a tolerance of 1e-10 for floating-point comparisons.
- Produces a summary report.

ΔE2000 checkers in [Julia](../../tests/jl/ciede-2000-driver.jl#L95) and [JavaScript](../../tests/js/ciede-2000-driver.js#L81), among others, are available. They behave like the C99 checker, and are used for cross-checking.

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

A successful workflow guarantees that the implementation in the programming language it tests produces the same ΔE2000 values as any other implementation in another language,  and so that `ciede_2000` functions can share their results and operate consistently together.

**Note** : No programming language that fails its tests has a place on the repository home page.

<!-- Our task ? To boost your critical apps with reliable and native code. -->

