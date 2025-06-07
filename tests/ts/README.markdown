# ΔE2000 — Accurate. Fast. TypeScript-powered.

This reference ΔE2000 implementation written in TypeScript provides reliable and accurate perceptual **color difference** calculation.

## Source Code

The full source code released on March 1, 2025, is available [here](../../ciede-2000.ts#L6) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.ts).

## Example usage in TypeScript

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```ts
// Example usage of the CIEDE2000 function in TypeScript

// L1 = 19.3166        a1 = 73.5           b1 = 122.428
// L2 = 19.0           a2 = 76.2           b2 = 91.372

const deltaE: number = ciede_2000(l1, a1, b1, l2, a2, b2);
console.log(deltaE);

// This shows a ΔE2000 of 9.60876174564
```

**Note**: L\* is usually between 0 and 100, a\* and b\* between -128 and +127.

To compare **hexadecimal** (e.g., "#FFF") or **RGB colors** using the CIEDE2000 function, examples are available in several languages :
- [AWK](../awk#-flexibility)
- [C](../c#δe2000--accurate-fast-c-powered)
- [Dart](../dart#δe2000--accurate-fast-dart-powered)
- [JavaScript](../js#-flexibility)
- [Java](../java#δe2000--accurate-fast-java-powered)
- [Kotlin](../kt#δe2000--accurate-fast-kotlin-powered)
- [Lua](../lua#-flexibility)
- [PHP](../php#δe2000--accurate-fast-php-powered)
- [Python](../py#δe2000--accurate-fast-python-powered)
- [Ruby](../rb#δe2000--accurate-fast-ruby-powered)
- [Rust](../rs#δe2000--accurate-fast-rust-powered)

## Verification

[![TypeScript CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-ts.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-ts.yml)

<details>
<summary>What is the testing procedure ?</summary>

```sh
cat <<EOF > package.json
{
	"name": "delta-e-2000-ts",
	"version": "1.0.0",
	"type": "commonjs",
	"scripts": {
	"build": "tsc",
	"start": "node dist/ciede-2000-testing.js"
	},
	"devDependencies": {
	"typescript": "^5.4.0",
	"@types/node": "^20.0.0"
	}
}
EOF
```

```sh
cat <<EOF > tsconfig.json
{
	"compilerOptions": {
	"target": "ES2020",
	"module": "CommonJS",
	"strict": true,
	"esModuleInterop": true,
	"outDir": "dist",
	"types": ["node"]
	},
	"include": ["tests/ts/ciede-2000-testing.ts"]
}
EOF
```

 3. `npm run build`
 4. `gcc -O3 tests/c/stdin-verifier.c -o verifier -lm`
 5. `node dist/ciede-2000-testing.js 10000000 | ./verifier > test-output.txt`

Where the two main files involved are [ciede-2000-testing.ts](ciede-2000-testing.ts#L113) and [raw-ts.yml](../../.github/workflows/raw-ts.yml).
</details>

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
CIEDE2000 Verification Summary :
- Last Verified Line : 60,96,115,90.4,104.11,92.88,23.81102636954404
- Duration : 33.09 s
- Successes : 10000000
- Errors : 0
- Maximum Difference : 2.2737367544323206e-13
```

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **GCC** : 13.3.0
- **TypeScript Compiler** : 5.8.2
- **NodeJS** : 20.19.2
- **npm** : 10.8.2

## Conclusion

With over 20 years serving developers, this **trusted color comparison** routine developed in TypeScript brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=60&a1=96&b1=115&L2=90.4&a2=104.11&b2=92.88) — [Workflow Details](../../.github/workflows#workflow-details) — [Across 30+ programming languages](../../#implementations)

