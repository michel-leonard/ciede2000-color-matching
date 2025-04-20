# ΔE2000 Workflows

GitHub Actions workflows are set up, alongside [tests](../../tests#ciede-2000-function-test), to ensure the correctness of the ΔE2000 implementation. These workflows execute scripts that generate CSV-formatted lines to standard output (STDOUT), which are then processed by a JavaScript verification script.

The current workflows are :
- **`raw-bas.yml`** — *VBA is tested using FreeBASIC*
- **`raw-dart.yml`**
- **`raw-julia.yml`**
- **`raw-nim.yml`**
- **`raw-r.yml`**
- **`raw-swift.yml`**
- **`raw-rkt.yml`**
- **`raw-wren.yml`**

## Workflow Details

Each workflow runs a language-specific script located in the `tests` directory. These scripts compute ΔE2000 for a set of color pairs (L\*a\*b\* values) and output the results as CSV lines. The output is piped to a Node.js script, located at `.github/workflows/scripts/stdin-verifier.js`, which performs a verification step.

## Verification Process

The [stdin-verifier.js](scripts/stdin-verifier.js#L111) script:

1. Reads each CSV line from STDIN.
2. Compares the computed ΔE2000 value with the reference JavaScript implementation.
3. Applies a tolerance of `1e-10` in floating-point comparisons.
4. Displays a summary with :
	- The number of successful comparisons.
	- The number of errors.
	- The maximum observed difference in ΔE2000 values.

## Purpose

These workflows are designed to validate that the ΔE2000 calculation produces consistent results across different programming languages. The goal is to ensure that all implementations, no matter the language, return the same result for the same color input.

## Example Output

The verification script will output a summary similar to this :

```
CIEDE2000 Verification Summary :
- Last Verified Line : 34.0,68.0,68.4,11.0,118.0,119.0,19.292688201626444
- Duration (ms) : 37630
- Successes : 5000000
- Errors : 0
- Maximum Difference : 2.2737367544323206e-13
```
