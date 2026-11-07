# ΔE2000 Workflows

GitHub Actions workflows are in place, running [tests](../../tests#ciede-2000-function-test) to ensure the correctness of the CIE ΔE<sub>00</sub> implementations. These tests require each programming language to process lines containing two **L\*a\*b\* colors** received in **CSV format**, rewrite these lines to their standard output (STDOUT) adding the ΔE2000, so that the latter can be checked by a C99 driver drawing up a final report on the relatability of the calculations.

## Static Tests

Each of the 40+ programming languages has a workflow presented in a `test-XXX.yml` file, here are the results :

- [![Ada CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-adb.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-adb.yml)
- [![ASP CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-asp.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-asp.yml)
- [![AWK CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-awk.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-awk.yml)
- [![bc CIEDE2000 Testing (arbitrary prec.)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-bc-arbitrary.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-bc-arbitrary.yml)
- [![bc CIEDE2000 Testing (standard prec.)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-bc-standard.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-bc-standard.yml)
- [![C# CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-cs.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-cs.yml)
- [![C++ CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-cpp.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-cpp.yml)
- [![C99 CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-c.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-c.yml)
- [![D CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-d.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-d.yml)
- [![Dart CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-dart.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-dart.yml)
- [![Elixir CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-exs.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-exs.yml)
- [![F# CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-fs.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-fs.yml)
- [![Fortran CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-f90.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-f90.yml)
- [![Go CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-go.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-go.yml)
- [![Haskell CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-hs.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-hs.yml) — *Haskell is tested using all vCPUs*
- [![Haxe CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-hx.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-hx.yml)
- [![Java CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-java.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-java.yml)
- [![JavaScript CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-js.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-js.yml)
- [![JavaScript CIEDE2000 Testing (multiprecision)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-js-multiprecision.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-js-multiprecision.yml)
- [![Julia CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-jl.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-jl.yml)
- [![Kotlin CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-kt.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-kt.yml)
- [![LuaJIT CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-lua.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-lua.yml) — *Lua is tested using LuaJIT*
- [![Matlab CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-m.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-m.yml) — *Matlab is tested using GNU Octave*
- [![Nim CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-nim.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-nim.yml)
- [![PHP CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-php.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-php.yml)
- [![Pascal CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-pas.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-pas.yml) — *Pascal is tested using Free Pascal*
- [![Perl CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-pl.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-pl.yml)
- [![PowerShell CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-ps1.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-ps1.yml)
- [![Prolog CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-pro.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-pro.yml)
- [![Python CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-py.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-py.yml)
- [![R CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-r.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-r.yml)
- [![Racket CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-rkt.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-rkt.yml)
- [![Ruby CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-rb.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-rb.yml)
- [![Rust CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-rs.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-rs.yml)
- [![Scala CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-scala.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-scala.yml)
- [![SQL CIEDE2000 Testing (MariaDB)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-sql-mariadb.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-sql-mariadb.yml)
- [![SQL CIEDE2000 Testing (PostgreSQL)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-sql-postgresql.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-sql-postgresql.yml)
- [![Swift CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-swift.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-swift.yml)
- [![TCL CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-tcl.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-tcl.yml)
- [![TypeScript CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-ts.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-ts.yml)
- [![VBA CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-bas.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-bas.yml) — *VBA is tested using FreeBASIC*
- [![Wren CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-wren.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-wren.yml)
- [![Zig CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-zig.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-zig.yml)

> [!NOTE]
> Some worlflows that are natively slower are accelerated by using all available vCPUs rather than just one, so all finish in about 3 minutes. Schedules are between 02:00 UTC and 06:00 UTC when neither America nor Europe are in peak period on GitHub Actions workflows.

### Workflow Details

Each workflow executes a script specific to the programming language it is testing, based on existing drivers in the `tests` directory. These drivers report the **ΔE2000 values** they calculate for **10,000,000 well-chosen color pairs**, so that the C99 driver, equipped with a verifier, can agree on the results. Precisions above 64 bits are validated in Julia, which has a driver (double-checked in BC) designed for this purpose.

### Verification Process

In each workflow that tests a programming language, the [ciede-2000-driver.c](../../tests/c/ciede-2000-driver.c) program :

- Generates a reproducible CSV file with two colors per line.
- Reads each line from STDIN to retrieve the ΔE<sub>00</sub> value calculated by the language under test.
- Compares the calculated value with the reference C99 implementation.
- Uses a tolerance of **10<sup>-10</sup>** for floating-point comparisons.
- Produces a summary report.

ΔE2000 checkers in [Julia](../../tests/jl/ciede-2000-driver.jl#L98) and [JavaScript](../../tests/js/ciede-2000-driver.js#L86), among others, are available. They behave like the C99 checker, and are used for cross-checking.

### Example Output

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

### Conclusion on Static Tests

A successful workflow guarantees that the implementation in the programming language it tests produces the same ΔE2000 values as any other implementation in another language,  and so that `ciede_2000` functions can share their results and operate consistently together.

> No programming language that fails its tests has a place on the repository home page.

## Dynamic Tests

Some of the programming languages covered also check the interoperability of their `ciede_2000` function with a relevant **external reference** :

- *C99* ... [![ΔE2000 against Netflix VMAF in C99](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-netflix.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-netflix.yml)
- *Java* ... [![ΔE2000 against OpenIMAJ in Java](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-openimaj.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-openimaj.yml)
- *JavaScript* ... [![ΔE2000 against chroma in JavaScript](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-chroma.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-chroma.yml)
- *Java* ... [![ΔE2000 against OpenJDK in Java](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-openjdk.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-openjdk.yml)
- *MATLAB* ... [![ΔE2000 against Gaurav Sharma in Matlab](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-sharma.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-sharma.yml)
- *C#* ... [![ΔE2000 against Masuit.Tools in C#](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-masuit-tools.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-masuit-tools.yml)
- *Python* ... [![ΔE2000 against colormath in Python](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-colormath.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-colormath.yml)
- *Python* ... [![ΔE2000 against Colour Science in Python](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-colour-science.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-colour-science.yml)
- *Kotlin* ... [![ΔE2000 against Shopify in Kotlin](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-shopify.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-shopify.yml)
- *MATLAB* ... [![ΔE2000 against Caltech in Matlab](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-caltech.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-caltech.yml)
- *Rust* ... [![ΔE2000 against palette in Rust](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-palette.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-palette.yml)
- *PHP* ... [![ΔE2000 against color-difference in PHP](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-php-color-difference.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-php-color-difference.yml)
- *PHP* ... [![ΔE2000 against color in PHP](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-php-color.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-php-color.yml)
- *Ruby* ... [![ΔE2000 against colorscore in Ruby](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-colorscore.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-colorscore.yml)
- *Scala* ... [![ΔE2000 against ijp-color in Scala](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-ijp-color.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-ijp-color.yml)
- *Python* ... [![ΔE2000 against Mathics3 in Python](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-mathics.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-mathics.yml)
- *Dart* ... [![ΔE2000 against delta_e in Dart](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-ragepeanut.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-ragepeanut.yml)
- *C++* ... [![ΔE2000 against dvisvgm in C++](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-dvisvgm.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-dvisvgm.yml)
- *JavaScript* ... [![ΔE2000 against npm/delta-e in JavaScript](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-npm-delta-e.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-npm-delta-e.yml)
- *Swift* ... [![ΔE2000 against pretty in Swift](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-pretty.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-pretty.yml)
- *R* ... [![ΔE2000 against shades in R](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-shades.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-shades.yml)
- *Lua* ... [![ΔE2000 against tiny-devicons in Lua](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-tiny-devicons.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-tiny-devicons.yml)
- *Go* ... [![ΔE2000 against go-chromath in Go](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-go-chromath.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-go-chromath.yml)
- *Go* ... [![ΔE2000 against xterm-color-chart in Go](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-xterm-color-chart.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-xterm-color-chart.yml)
- *VBA* ... [![ΔE2000 against My FreeBasic Framework in VBA](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-my-freebasic-framework.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/vs-my-freebasic-framework.yml)

**Note** : All the implementations selected for this test are consistent with each other, with a tolerance of **10<sup>-12</sup>** on the ΔE\*<sub>00</sub> values.

Each run compares the CIEDE2000 color difference function with those of a well-maintained third-party library, using up to 100 million randomly generated L\*a\*b\* colors pairs, depending on language speed, so that the test can be completed within a few minutes.

The validation criterion is that no absolute deviation greater than **10<sup>-10</sup>** should be observed when 64-bit implementations are invoked. Deviations above this threshold indicate, when the two colors being compared are identical, an inaccuracy in one of the implementations.

The workflows, whose file name is `vs-XXX.yml`, are triggered by scheduling twice a month to check the reliability of the implementations.

The results are displayed on the standard output, and no corrective action is required if the ΔE2000 calculations remain consistent. These workflows speed up the production release of the `ciede_2000` functions, by showing that they are consistent with recognized references.

## Consistency Guaranteed

Each of the 60+ workflows had succeeded every week for six consecutive months, serving as Michel Leonard’s guarantee of consistency.

<!-- Our task ? To boost your critical apps with reliable and native code. -->
