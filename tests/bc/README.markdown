# ΔE2000 — Accurate. Fast. bc-powered.

ΔE<sub>00</sub> is the industry standard for quantifying color differences in a way that precisely matches human perception.

This classic **bc** (Basic Calculator) implementation offers a portable and easy way to calculate these differences accurately.
## Overview

This algorithm measures color similarities (or differences) with high portability and **metrological** precision.

As a general rule, 🔵 navy blue and 🟡 yellow, which are very different colors, have a ΔE\*<sub>00</sub> of around 115.

Values [such as 5](https://michel-leonard.github.io/ciede2000-color-matching/de2000-rgb-pairs.html?seq=50&delta-e=5) indicate greater closeness, making this both a simple and advanced method of color comparison.

## Implementation Details

The full `bc` source code, released on March 1, 2025, is available [here](../../ciede-2000.bc#L8) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.bc).

<details>
<summary>What two options are available for matching ΔE2000 calculations with existing calculations ?</summary>

#### Option 1 (default)
 This often-used option consists of a coding simplification that is a historical legacy of early implementations :
```c
h_m = h_m + m_pi
/* h_m = h_m + ((h_m < m_pi) - (m_pi <= h_m)) * m_pi */
```

#### Option 2 (compatible with Gaurav Sharma’s precise calculations)
There’s no room for ambiguity, this inversion of the commented line in the source code ensures compliance with the official :
```c
/* h_m = h_m + m_pi */
h_m = h_m + ((h_m < m_pi) - (m_pi <= h_m)) * m_pi
```

**Note** : the difference between the two options is minimal (±0.0003 on the calculated color difference) and usually overlooked.
</details>

## Example usage in `bc`

The classic calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```sh
# Compute the Delta E (CIEDE2000) color difference between two L*a*b* colors with bc
# Arguments: L1, a1, b1, L2, a2, b2

echo 'ciede_2000(38.7, 35.4, -2.2, 38.8, 40.5, 3.5)' | bc -l ciede-2000.bc

# ...................................... This shows a ΔE2000 of 3.73348132311398018231
# See comments for compliance with Gaurav Sharma for displaying 3.73349464592794694691
```

**Note** : L\* is nominally between 0 and 100, a\* and b\* usually between -128 and +127.

### Arbitrary Precision

Basic Calculator produces ΔE<sub>00</sub> results with arbitrary precision. Set `scale=50` before calling the `ciede_2000` function to get 30+ correct digits :

```sh
echo 'scale=50;ciede_2000(13.1, 11.9, 3.8, 13.0, 17.6, -4.9)' | bc -l ciede-2000.bc

# Outputs: 7.37458016458016885544127036110301868134320454640263
# As explained in the comments, compliance with Gaurav Sharma would display ...
# ........ 7.37456659946646273510289154231355556542867583609039
```

**Note** : This high-precision calculation corresponds to an [example in Julia](../jl#example-usage-in-julia) to facilitate cross-checks.

<details>
<summary>How do I choose the right precision?</summary>

Whatever value you assign to `scale`, the precision of the CIEDE2000 calculation is limited due to the propagation of numerical errors :

| BC Scale | Correct decimals (typical) | Correct decimals (rare, one case in several million) |
|--|--|--|
| `scale=20` (default) | 13 | 6 |
| `scale=30` | 19 | 10 |
| `scale=40` | 26 | 13 |
| `scale=50` | 33 | 16 |
| `scale=60` | 40 | 19 |

**Note**: The increase is **linear** and can be extrapolated; manufacturers rarely need scales above `20`, mainly used in metrology.
</details>

## Verification

[![bc CIEDE2000 Testing (arbitrary prec.)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-bc-arbitrary.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-bc-arbitrary.yml) [![bc CIEDE2000 Testing (standard prec.)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-bc-standard.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-bc-standard.yml)

<details>
<summary>What is the testing procedure ?</summary>

The [C driver](../c/ciede-2000-driver.c) generates color pairs, and the [Julia driver](../jl/ciede-2000-driver.jl#L98) checks the **CIE2000** color differences **measured by bc**, like this :

1. `command -v bc > /dev/null || { sudo apt-get update && sudo apt-get install bc ; }`
2.
```sh
if ! command -v julia > /dev/null; then
	########################################################################################
	####  STEP 1:            Download & Extract the latest version of Julia             ####
	########################################################################################
	URL=$(wget --quiet --no-check-certificate --timeout=5 --tries=2 "https://julialang.org/downloads/manual-downloads/" -O- |
		grep 'linux/x64' | grep '\.tar\.gz' | grep -o 'https://[^"]*' | head -n 1)
	if [ -z "$URL" ]; then
		URL="https://julialang-s3.julialang.org/bin/linux/x64/1.11/julia-1.11.5-linux-x86_64.tar.gz"
	fi
	echo "Download Julia from $URL" && sudo rm -rf /opt/julia && mkdir /opt/julia
	wget --quiet --no-check-certificate --timeout=5 --tries=2 "$URL" -O- | tar -xz --strip-components=1 -C /opt/julia
	########################################################################################
	####  STEP 2:                       Add Julia to System PATH                        ####
	########################################################################################
	sudo ln --backup --symbolic --verbose /opt/julia/bin/julia /usr/local/bin/julia
	########################################################################################
	####  CONCLUSION:                    Julia Installed in Under 15s                   ####
	########################################################################################
fi
julia --version
```
3. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install gcc ; }`
4. `gcc -std=c99 -Wall -pedantic -O2 -g tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
5. `./ciede-2000-driver --generate 100000 --output-file test-cases.csv`
6.
```sh
decimal_digits=30

# Prevent line breaks in bc output.
export BC_LINE_LENGTH=0

awk -F ',' '                                                   \
BEGIN {                                                        \
    # Define the scale.                                        \
    print "scale=" int(1.5 * '$decimal_digits');               \
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

Where the main files involved are [ciede-2000.bc](../../ciede-2000.bc#L8) for calculations and [test-bc.yml](../../.github/workflows/test-bc.yml) for automation.
</details>

The color differences are compared to those obtained with a generic-precision implementation. This setup makes the [Julia](../jl#δe2000--accurate-fast-julia-powered) driver display :

```
CIEDE2000 Verification Summary :
  First Verified Line : 27,-123,101,44,42.0000098,-99,70.204734814936909810694644954670527048474482887
             Duration : 18644.34 s
            Successes : 10000000
               Errors : 0
      Average Delta E : 62.9618
    Average Deviation : 4.0e-38
    Maximum Deviation : 2.2e-35
```

With zero errors detected to infinitesimal tolerance, this confirms that the CIE ΔE<sub>00</sub> algorithm is correctly implemented in `bc`.

> [!IMPORTANT]
> To correct this bc source code to exact match certain third-party ΔE2000 functions, follow the comments in the source code.

> This formula, "small" in size, is an essential pillar of color management, deserving of this rigorous, tested and reliable industrial treatment.

### Performance and Environment

The measured speed of the `ciede_2000` function in `bc` decreases significantly as the scale increases :

| Scale | Duration (s) | Calls | Throughput (calls/s) |
| :--: | :--: | :--: | :--: |
| 20 | 7.47 | 10,000 | ≈ 1339 |
| 40 | 15.51 | 10,000 | ≈ 645 |
| 60 | 35.65 | 10,000 | ≈ 281 |

<details>
<summary>What can improve performance ?</summary>

Gavin D. Howard’s version of `bc` is twice as fast for calculating ΔE2000, works like `bc` and installs as follows :

```sh
# 30-second procedure tested on Ubuntu in August 2025
(
  # In a subshell, define the URL of the latest bc (Basic Calculator) source
  BC_URL="https://github.com/gavinhoward/bc/archive/94dec4dd96adc02abff4f5cf351f0204f05dbb40.tar.gz"
  BC_URL="https://github.com/gavinhoward/bc/archive/refs/heads/master.tar.gz"
  # Create and enter a temporary directory, then download and extract the source
  cd $(mktemp --directory)
  wget --no-verbose --timeout=5 --tries=2 "$BC_URL" -O- | tar -xz --strip-components=1
  # Compile and install bc into the system (adds it to PATH)
  sudo ./configure.sh -O3 && sudo make && sudo make install
  # Remove the temporary directory
  sudo rm -rf "$PWD"
)
# Show the installed bc version
bc --version
```

After that, any legacy version of `bc` is not deleted, but just does not take precedence over the new one in the `PATH`.
</details>

Tested environment :

- **Ubuntu** 24.04.2 LTS
- **GCC** 13.3
- **bc** 1.07.1
- **Julia** 1.11.5

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in bc** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=31.3&a1=38.2&b1=-50.5&L2=44.6&a2=7&b2=9.5) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Suitable in 40+ Languages](../../#implementations)
