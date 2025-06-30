# ΔE2000 — Accurate. Fast. TypeScript-powered.

ΔE2000 is the standard metric used by industries to evaluate color differences as the human eye would.

This canonical implementation in **TypeScript** offers a simple, accurate and fast way of calculating these differences at the heart of programs.

## Overview

The developed algorithm enables software to evaluate color similarities (or differences) with scientific rigor.

As a general rule, navy blue and yellow, which are very different colors, generally have a ΔE<sub>00</sub> of around 115.

Values such as 5 indicate greater closeness, making this both a simple and advanced method of color comparison.

## Implementation Details

The full source code released on March 1, 2025, is available [here](../../ciede-2000.ts#L6) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.ts).

## Example usage in TypeScript

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```ts
// Example usage of the CIEDE2000 function in TypeScript

const l1 = 19.3166, a1 = 73.5, b1 = 122.428;
const l2 = 19.0, a2 = 76.2, b2 = 91.372;

const deltaE: number = ciede_2000(l1, a1, b1, l2, a2, b2);
console.log(deltaE);

// This shows a ΔE2000 of 9.60876174564
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
7. `gcc -std=c99 -Wall -pedantic -Ofast -ffast-math -g tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
8. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
9. `node dist/ciede-2000-driver.js test-cases.csv | ./ciede-2000-driver`

Where the main files involved are [ciede-2000-driver.ts](ciede-2000-driver.ts#L82) for calculations and [test-ts.yml](../../.github/workflows/test-ts.yml) for automation.
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

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=60&a1=96&b1=115&L2=90.4&a2=104.11&b2=92.88) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Suitable in 30+ Languages](../../#implementations)
