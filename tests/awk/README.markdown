# ΔE2000 — Accurate. Fast. AWK-powered.

This reference ΔE2000 implementation written in AWK provides reliable and accurate perceptual **color difference** calculation.

## Source Code

The full source code released on March 1, 2025, is available [here](../../ciede-2000.awk#L20) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.awk).

This AWK script can be used in shell environments such as **Bash** on Linux and macOS.

## Example usage in  AWK

The `samples.csv` file contains 2 colors in L\*a\*b\* format on each line :
```txt
47.3,33.0,73.0,47.3,29.2,73.0
69.122,120.821,85.9,74.0,125.7,85.9
58.0,-101.1,-81.4,57.0,-65.44,-84.729
```

The command to calculate the **Delta E 2000** color difference :
```sh
awk -f ciede-2000.awk < samples.csv
```

The result on standard output :
```txt
47.3,33.0,73.0,47.3,29.2,73.0,2.07402875906584
69.122,120.821,85.9,74.0,125.7,85.9,3.88062401552627
58.0,-101.1,-81.4,57.0,-65.44,-84.729,8.44139030696944
```

**Note**: L\* is usually between 0 and 100, a\* and b\* between -128 and +127.

### 🎨 Flexibility

This [all-in-one](compare-rgb-hex-colors.awk#L4) AWK script accepts RGB and hexadecimal color formats to calculate ΔE2000 **color differences**.

<details>
 <summary>Show example !</summary>

The  `samples.csv` file contains colors to be processed :
```text
238,170,17,170,17,238
238,170,17,#a1e
238,170,17,#aa11ee
#ea1,170,17,238
#eeaa11,170,17,238
#ea1,#a1e
#ea1,#AA11EE
#eeaa11,#a1e
#eeaa11,#aa11ee
```

The command to calculate the **Delta E 2000** color difference :
```sh
awk -f ciede-2000-rgb-hex.awk < samples.csv
```

The result on standard output :
```text
238,170,17,170,17,238,72.4646795182437
238,170,17,#a1e,72.4646795182437
238,170,17,#aa11ee,72.4646795182437
#ea1,170,17,238,72.4646795182437
#eeaa11,170,17,238,72.4646795182437
#ea1,#a1e,72.4646795182437
#ea1,#AA11EE,72.4646795182437
#eeaa11,#a1e,72.4646795182437
#eeaa11,#aa11ee,72.4646795182437
```
</details>

<details>
<summary>Want to make the AWK script directly executable ?</summary>

1. Add a shebang `#!/usr/bin/awk -f` or `#!/usr/bin/env awk -f` at the top of your `ciede-2000.awk` file.

2. Make it executable using `chmod 755 ciede-2000.awk`.

3. Move it to a folder in your `$PATH` using `mv ciede-2000.awk /usr/local/bin/ciede_2000`.

Now you can run `ciede_2000 < samples.csv` as in the [test workflow](../../.github/workflows/raw-awk.yml#L19), just like a native command !
</details>

### Precision of Results

You can easily configure the output precision by changing the `%.15g`, for example to `%.02f`, on the line where `printf` is located.

## Verification

[![AWK CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-awk.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-awk.yml)

<details>
<summary>What is the testing procedure ?</summary>

 1. `gcc -O3 tests/c/stdin-verifier.c -o verifier -lm`
 2. `awk -f tests/awk/ciede-2000-testing.awk 10000000 | ./verifier > test-output.txt`

Where the two main files involved are [ciede-2000-testing.awk](ciede-2000-testing.awk#L13) and [raw-awk.yml](../../.github/workflows/raw-awk.yml).
</details>

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
CIEDE2000 Verification Summary :
- Last Verified Line : 16.81,68.99,-34.69,80.61,101.92,98.47,76.6185173248672
- Duration : 67.49 s
- Successes : 10000000
- Errors : 0
- Maximum Difference : 5.6843418860808015e-13
```

### Computational Speed

This function was measured at a speed of 228,571 calls per second.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **GCC** : 13.3.0
- **AWK** : 5.2.1
  - API : 3.2
  - GNU MPFR : 4.2.1
  - GNU MP : 6.3.0

## Conclusion

With over 20 years serving developers, this **trusted color comparison** routine developed in AWK brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=16.81&a1=68.99&b1=-34.69&L2=80.61&a2=101.92&b2=98.47) — [Workflow Details](../../.github/workflows#workflow-details) — [Across 30+ programming languages](../../#implementations)

