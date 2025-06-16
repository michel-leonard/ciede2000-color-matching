# ΔE2000 — Accurate. Fast. Racket-powered.

ΔE2000 is the widely accepted standard for quantifying color differences in a way that matches human perception.

This canonical **Racket** implementation offers an easy way to calculate these differences accurately and programmatically.

## Overview

The developed algorithm offers a scientifically validated metric that reflects how humans perceive color variations.

For reference, two very distinct colors typically have a ΔE2000 value greater than 12.

Lower values indicate greater closeness, making it a **state-of-the-art method** for comparing colors.

## Implementation Details

The full source code released on March 1, 2025, is available [here](../../ciede-2000.rkt#L8) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.rkt).

## Example usage in Racket

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```racket
; Compute the Delta E (CIEDE2000) color difference between two Lab colors in Racket

; L1 = 19.3166        a1 = 73.5           b1 = 122.428
; L2 = 19.0           a2 = 76.2           b2 = 91.372

(define delta-e (ciede_2000 l1 a1 b1 l2 a2 b2))
(displayln delta-e)

; This shows a ΔE2000 of 9.60876174564
```

**Note**: Here, `L*` typically ranges from 0 to 100, while `a*` and `b*` values are generally between -128 and 127.

For color inputs in **hexadecimal** (e.g., `#FFF`) or **RGB** formats, see examples for other languages :

[AWK](../awk#-flexibility), [C](../c#δe2000--accurate-fast-c-powered), [Dart](../dart#δe2000--accurate-fast-dart-powered), [Java](../java#δe2000--accurate-fast-java-powered), [JavaScript](../js#-flexibility), [Kotlin](../kt#δe2000--accurate-fast-kotlin-powered), [Lua](../lua#-flexibility), [PHP](../php#δe2000--accurate-fast-php-powered), [Python](../py#δe2000--accurate-fast-python-powered), [Ruby](../rb#δe2000--accurate-fast-ruby-powered), [Rust](../rs#δe2000--accurate-fast-rust-powered).

## Verification

[![Racket CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-rkt.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-rkt.yml)

<details>
<summary>What is the testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by Racket**, like this :

1.
```sh
if ! command -v racket > /dev/null; then
	if ! command -v brew > /dev/null; then
		/bin/bash -c "$(wget --timeout=5 --tries=3 -qO- https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
	fi
	brew install minimal-racket
fi
```
2. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install -y gcc ; }`
3. `gcc -std=c99 -Wall -pedantic -Ofast tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
4. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
5. `racket tests/rkt/ciede-2000-driver.rkt test-cases.csv | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.rk](ciede-2000-driver.rk#L126) for calculations and [test-rk.yml](../../.github/workflows/test-rk.yml) for automation.
</details>

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
 CIEDE2000 Verification Summary :
  First Verified Line : 1.99,-114.02,110,27.7,-121,-112.8,67.9143482347745
             Duration : 80.52 s
            Successes : 10000000
               Errors : 0
      Average Delta E : 62.9563
    Average Deviation : 5.2646248055454593e-15
    Maximum Deviation : 2.5579538487363607e-13
```

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **GCC** : 13.3.0
- **Racket** : 8.17

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in Racket** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=67.2&a1=111.7&b1=-81&L2=97.4&a2=108.6&b2=5) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Used in 30+ Languages](../../#implementations)

