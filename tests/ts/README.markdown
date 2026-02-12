# ΔE2000 — Accurate. Fast. TypeScript-powered.

ΔE2000 is the standard metric used by industries to evaluate color differences as the human eye would.

This reference implementation in **TypeScript** offers a simple, accurate and fast way of calculating these differences at the heart of programs.

## Overview

The developed algorithm enables software to evaluate color similarities (or differences) with scientific rigor.

As a general rule, 🔵 navy blue and 🟡 yellow, which are very different colors, have a ΔE\*<sub>00</sub> of around 115.

Values [such as 5](https://michel-leonard.github.io/ciede2000-color-matching/de2000-rgb-pairs.html?seq=50&delta-e=5) indicate greater closeness, making this both a simple and advanced method of color comparison.

## Implementation Details

The full source code released on March 1, 2025, is available [here](../../ciede-2000.ts#L6) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.ts).

<details>
<summary>What two options are available for matching ΔE2000 calculations with existing calculations ?</summary>

#### Option 1 (default)
 This often-used option consists of a coding simplification that is a historical legacy of early implementations :
```ts
h_m += Math.PI;
// h_m += h_m < Math.PI ? Math.PI : -Math.PI;
```

#### Option 2 (compatible with Gaurav Sharma’s precise calculations)
There’s no room for ambiguity, this inversion of the commented line in the source code ensures compliance with the official :
```ts
// h_m += Math.PI;
h_m += h_m < Math.PI ? Math.PI : -Math.PI;
```

**Note** : the difference between the two options is minimal (±0.0003 on the calculated color difference) and usually overlooked.
</details>

## Example usage in TypeScript

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```ts
// Example usage of the CIEDE2000 function in TypeScript

const l1 = 17.6, a1 = 39.4, b1 = -1.7;
const l2 = 17.2, a2 = 45.1, b2 = 2.2;

const deltaE: number = ciede_2000(l1, a1, b1, l2, a2, b2);
console.log(deltaE);

// .................................................. This shows a ΔE2000 of 2.8976025528
// As explained in the comments, compliance with Gaurav Sharma would display 2.8976160989
```

**Note** : L\* is nominally between 0 and 100, a\* and b\* commonly between -128 and +127.

For color inputs in **hexadecimal** (e.g., `#FFF`) or **RGB** formats, see examples for other languages :

[AWK](../awk#-flexibility), [C](../c#δe2000--accurate-fast-c-powered), [Dart](../dart#δe2000--accurate-fast-dart-powered), [Java](../java#δe2000--accurate-fast-java-powered), [JavaScript](../js#-flexibility), [Kotlin](../kt#δe2000--accurate-fast-kotlin-powered), [Lua](../lua#-flexibility), [PHP](../php#δe2000--accurate-fast-php-powered), [Python](../py#δe2000--accurate-fast-python-powered), [Ruby](../rb#δe2000--accurate-fast-ruby-powered), [Rust](../rs#δe2000--accurate-fast-rust-powered).

## Verification

[![TypeScript CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-ts.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-ts.yml)

<details>
<summary>What is the testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by TypeScript**, like this :

1. `command -v node > /dev/null || { sudo apt-get update && sudo apt-get install nodejs npm ; }`
2. `command -v tsc > /dev/null || npm install -g typescript`
3. `command -v gcc > /dev/null || { sudo apt-get update && sudo apt-get install gcc ; }`
4.
```sh
printf '%s\n' \
'{' \
'  "name": "delta-e-2000-ts",' \
'  "version": "1.0.0",' \
'  "type": "commonjs",' \
'  "scripts": {' \
'    "build": "tsc",' \
'    "start": "node dist/ciede-2000-driver.js"' \
'  },' \
'  "devDependencies": {' \
'    "typescript": "^5.4.0",' \
'    "@types/node": "^20.0.0"' \
'  }' \
'}' > package.json
```
5.
```sh
printf '%s\n' '{' \
'  "compilerOptions": {' \
'    "target": "ES2020",' \
'    "module": "CommonJS",' \
'    "strict": true,' \
'    "esModuleInterop": true,' \
'    "outDir": "dist",' \
'    "types": ["node"]' \
'  },' \
'  "include": ["tests/ts/ciede-2000-driver.ts"]' \
'}' > tsconfig.json
```
6. `npm install && npm run build`
7. `gcc -std=c99 -Wall -pedantic -O2 -g tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
8. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
9. `node dist/ciede-2000-driver.js test-cases.csv | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.ts](ciede-2000-driver.ts#L87) for calculations and [test-ts.yml](../../.github/workflows/test-ts.yml) for automation.
</details>

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
CIEDE2000 Verification Summary :
  First Verified Line : 87.51,-44.14,-14,60,53,98.4,58.874366927055824
             Duration : 37.78 s
            Successes : 10000000
               Errors : 0
      Average Delta E : 62.9377
    Average Deviation : 6.0699611337255987e-15
    Maximum Deviation : 2.4158453015843406e-13
```

> [!IMPORTANT]
> To correct this TypeScript source code to exact match certain third-party ΔE2000 functions, follow the comments in the source code.

> This formula, "small" in size, is an essential pillar of color management, deserving of this rigorous, tested and reliable industrial treatment.

### Performance

This function was measured at a speed of 2,865,329 calls per second.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **GCC** : 13.3
- **TypeScript Compiler** : 5.8.2
- **NodeJS** : 20.19.2
- **npm** : 10.8.2

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in TypeScript** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=41.7&a1=47&b1=-24.8&L2=40.7&a2=14.5&b2=7.7) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Suitable in 40+ Languages](../../#implementations)
