# ΔE2000 — Accurate. Fast. bc-powered.

ΔE<sub>00</sub> is the industry standard for quantifying color differences in a way that precisely matches human perception.

This classic **bc** (Basic Calculator) implementation offers a portable and easy way to calculate these differences accurately.
## Overview

This algorithm measures color similarities (or differences) with high portability and scientific precision.

As a general rule, navy blue and yellow, which are very different colors, generally have a ΔE<sub>00</sub> of around 115.

Values such as 5 indicate greater closeness, making this both a simple and advanced method of color comparison.

## Implementation Details

The full `bc` source code, released on March 1, 2025, is available [here](../../ciede-2000.bc#L8) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.bc).


## Example usage in `bc`

The classic calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```sh
# Compute the Delta E (CIEDE2000) color difference between two Lab colors with bc
# Arguments: L1, a1, b1, L2, a2, b2

echo 'ciede_2000(19.3166, 73.5, 122.428, 19.0, 76.2, 91.372)' | bc -l ciede-2000.bc
# Outputs: 9.60876174563897527353
```

**Note** : L\* is nominally between 0 and 100, a\* and b\* usually between -128 and +127.

### Arbitrary Precision

Basic Calculator produces ΔE<sub>00</sub> results with arbitrary precision. Set `scale=50` before calling the `ciede_2000` function to get 50 digits :

```sh
echo 'scale=50;ciede_2000(19.3166, 73.5, 122.428, 19.0, 76.2, 91.372)' | bc -l ciede-2000.bc
# Outputs: 9.60876174563897527525891018144528620539738482882878
```

## Verification

[![bc CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-bc.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-bc.yml)

<details>
<summary>What is the testing procedure ?</summary>

The [C driver](../c/ciede-2000-driver.c) generates color pairs, and the [Julia driver](ciede-2000-driver.jl#L92) checks the **CIE2000** color differences **measured by bc**, like this :

1. `command -v bc > /dev/null || { sudo apt-get update && sudo apt-get install bc ; }`
2.
```sh
if ! command -v julia > /dev/null; then
	########################################################################################
	####  STEP 1:            Download & Extract the latest version of Julia             ####
	########################################################################################
	URL=$(wget -qO- https://julialang.org/downloads/ | grep 'linux/x64' |
	grep '\.tar\.gz' | grep -o 'https://[^"]*' | head -n 1)
	if [ -z "$URL" ]; then
		URL="https://julialang-s3.julialang.org/bin/linux/x64/1.11/julia-1.11.5-linux-x86_64.tar.gz"
	fi
	rm -rf /opt/julia
	mkdir /opt/julia
	wget -q -T5 -t3 -O- "$URL" | tar -xz --strip-components=1 -C /opt/julia
	########################################################################################
	####  STEP 2:                       Add Julia to System PATH                        ####
	########################################################################################
	sudo ln -sf /opt/julia/bin/julia /usr/local/bin/julia
	########################################################################################
	####  CONCLUSION:                    Julia Installed in Under 15s                   ####
	########################################################################################
fi
julia --version
```
3. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install gcc ; }`
4. `gcc -std=c99 -Wall -pedantic -Ofast -ffast-math -g tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
5. `./ciede-2000-driver --generate 100000 --output-file test-cases.csv`
6.
```sh
decimal_digits=40

# Prevent line breaks in bc output.
export BC_LINE_LENGTH=0

awk -F ',' '                                                   \
BEGIN {                                                        \
    # Define the scale.                                        \
    print "scale=5+'$decimal_digits'";                         \
                                                               \
    # Includes the ciede-2000.bc file.                         \
    while ((getline line < "ciede-2000.bc") > 0) print line;   \
                                                               \
} {                                                            \
                                                               \
    # Convert CSV lines into bc input format.                  \
    gsub(/[eE]/, "*10^", $0);                                  \
    printf("ciede_2000(%s)\n", $0);                            \
                                                               \
}' test-cases.csv | bc -ql > bc-answer.raw
```
7. `paste -d ',' test-cases.csv bc-answer.raw | julia tests/jl/ciede-2000-driver.jl --tolerance 1e-$decimal_digits`

Where the main files involved are [ciede-2000.bc](../../ciede-2000.bc#L9) for calculations and [arbitrary-precision.yml](../../.github/workflows/arbitrary-precision.yml) for automation.
</details>

The color differences are compared to those obtained with a generic-precision implementation. This setup makes the [Julia](../jl#δe2000--accurate-fast-julia-powered) driver display :

```
CIEDE2000 Verification Summary :
  First Verified Line : 54,-36,113,26.7,-68,69,30.235347010336340592690823613105801202125430652
             Duration : 16076.94 s
            Successes : 10000000
               Errors : 0
      Average Delta E : 63.1092
    Average Deviation : 4.4e-43
    Maximum Deviation : 3.9e-42
```

With zero errors detected to infinitesimal tolerance, this confirms that the CIE ΔE<sub>00</sub> algorithm is correctly implemented in `bc`.

### Performance and Environment

The measured speed of the `ciede_2000` function in `bc` decreases significantly as the scale increases :

| Scale | Duration (s) | Calls | Throughput (calls/s) |
| :--: | :--: | :--: | :--: |
| 20 | 7.47 | 10,000 | ≈ 1339 |
| 40 | 15.51 | 10,000 | ≈ 645 |
| 60 | 35.65 | 10,000 | ≈ 281 |

Tested environment :

- **Ubuntu** 24.04.2 LTS
- **GCC** 13.3
- **bc** 1.07.1
- **Julia** 1.11.5

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in bc** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=54&a1=-36&b1=113&L2=26.7&a2=-68&b2=69) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Suitable in 30+ Languages](../../#implementations)
