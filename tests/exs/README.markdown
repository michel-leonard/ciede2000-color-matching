# ΔE2000 — Accurate. Fast. Elixir-powered.

ΔE2000 is the modern standard for quantifying color differences with high accuracy, now interoperable with Erlang.

This reference **Elixir** implementation offers a way of calculating these differences reliably within programs.

## Overview

The algorithm developed in BEAM-native measures color similarity (or difference) with scientific rigor.

As a general rule, 🔵 navy blue and 🟡 yellow, which are very different colors, have a ΔE\*<sub>00</sub> of around 115.

Values [such as 5](https://michel-leonard.github.io/ciede2000-color-matching/de2000-rgb-pairs.html?seq=50&delta-e=5) indicate greater closeness, making this both a simple and advanced method of color comparison.

## Implementation Details

The full source code released on March 1, 2025, is available [here](../../ciede-2000.exs#L6) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.exs).

<details>
<summary>What two options are available for matching ΔE2000 calculations with existing calculations ?</summary>

#### Option 1 (default)
 This often-used option consists of a coding simplification that is a historical legacy of early implementations :
```exs
h_m = if m_pi < n, do: h_m + m_pi, else: h_m
# h_m = if m_pi < n, do: (if h_m < m_pi, do: h_m + m_pi, else: h_m - m_pi), else: h_m
```

#### Option 2 (compatible with Gaurav Sharma’s precise calculations)
There’s no room for ambiguity, this inversion of the commented line in the source code ensures compliance with the official :
```exs
# h_m = if m_pi < n, do: h_m + m_pi, else: h_m
h_m = if m_pi < n, do: (if h_m < m_pi, do: h_m + m_pi, else: h_m - m_pi), else: h_m
```

**Note** : the difference between the two options is minimal (±0.0003 on the calculated color difference) and usually overlooked.
</details>

## Example usage in Elixir

```exs
# Compute the Delta E (CIEDE2000) color difference between two L*a*b* colors in Elixir

{ l1, a1, b1 } = { 57.1, 17.1, 4.9  }
{ l2, a2, b2 } = { 59.2, 10.9, -3.1 }

delta_e = ciede_2000(l1, a1, b1, l2, a2, b2)
IO.puts("#{delta_e}")

# .................................................. This shows a ΔE2000 of 7.5254510508
# As explained in the comments, compliance with Gaurav Sharma would display 7.5254660817
```

**Note** : L\* usually ranges from 0 to 100, while a\* and b\* typically range from –128 to +127.

For color inputs in **hexadecimal** (e.g., `#FFF`) or **RGB** formats, see examples for other languages :

[AWK](../awk#-flexibility), [C](../c#δe2000--accurate-fast-c-powered), [Dart](../dart#δe2000--accurate-fast-dart-powered), [Java](../java#δe2000--accurate-fast-java-powered), [JavaScript](../js#-flexibility), [Kotlin](../kt#δe2000--accurate-fast-kotlin-powered), [Lua](../lua#-flexibility), [PHP](../php#δe2000--accurate-fast-php-powered), [Python](../py#δe2000--accurate-fast-python-powered), [Ruby](../rb#δe2000--accurate-fast-ruby-powered), [Rust](../rs#δe2000--accurate-fast-rust-powered).

## Verification

[![Elixir CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-exs.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-exs.yml)

<details>
<summary>What is the testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates random color pairs, and checks the Delta E 2000 color differences produced in Elixir, like this :
1.

```sh
command -v elixir > /dev/null || {
  # 1. Download and install the latest versions of Elixir and OTP (started with Elixir 1.18.4 and OTP 27.3.4)
  wget --quiet --no-check-certificate --timeout=5 --tries=3 https://elixir-lang.org/install.sh -O- | sh -s -- elixir@latest otp@latest
  # 2. Add installed directories to the PATH
  for DIRECTORY in $HOME/.elixir-install/installs/*/*/bin; do
    LINE="export PATH=\"$PATH:$DIRECTORY\""
    echo "$LINE" >> $HOME/.profile    # For future sessions
    eval "$LINE"                      # For the current session
  done
  # 3. Display current versions of Elixir and OTP
  elixir --version
}
```

2. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install gcc ; }`
3. `gcc -std=c99 -Wall -pedantic -O2 -g tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
4. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
5. `elixir tests/exs/ciede-2000-driver.exs test-cases.csv | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.exs](ciede-2000-driver.exs#L87) for calculations and [test-exs.yml](../../.github/workflows/test-exs.yml) for automation.
</details>

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
 CIEDE2000 Verification Summary :
  First Verified Line : 27,-123,101,44,-30,122,29.989372817453113
             Duration : 157.82 s
            Successes : 10000000
               Errors : 0
      Average Delta E : 63.2072
    Average Deviation : 3.9e-15
    Maximum Deviation : 1.1e-13
```

> [!IMPORTANT]
> To correct the source code to match certain third-party ΔE2000 functions, follow the comments in the source code.

> This formula, "small" in size, is an essential pillar of color management, deserving of this rigorous, tested and reliable industrial treatment.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **Erlang/OTP** : 27
- **Elixir** : 1.18.4
- **GCC** : 13.3

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in Elixir** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=67.9&a1=57.1&b1=-27.9&L2=68.7&a2=13.2&b2=6.7) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Suitable in 40+ Languages](../../#implementations)
