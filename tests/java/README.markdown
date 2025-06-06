# ΔE2000 — Accurate. Fast. Java-powered.

This reference ΔE2000 implementation written in Java provides reliable and accurate perceptual **color difference** calculation.

## Source Code

The full source code is available [here](../../ciede-2000.java#L14), and is archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.java).

Kotlin, Groovy, Scala, Clojure and JRuby can all seamlessly integrate this classic source code.

## Example usage in Java

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```java
// Example usage of the CIEDE2000 function within the L*a*b* color space in Java

// L1 = 19.3166        a1 = 73.5           b1 = 122.428
// L2 = 19.0           a2 = 76.2           b2 = 91.372

double deltaE = ciede_2000(l1, a1, b1, l2, a2, b2);
System.out.println(deltaE);

// This shows a ΔE2000 of 9.60876174564
```

**Note**: L\* is usually between 0 and 100, a\* and b\* between -128 and +127.

To compare **hexadecimal** (e.g., "#FFF") or **RGB colors** using the CIEDE2000 function, follow these examples :
- [compare-hex-colors.java](compare-hex-colors.java#L187)
- [compare-rgb-colors.java](compare-rgb-colors.java#L186)

## Verification

[![Java CIEDE2000 Testing](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-java.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-java.yml)

<details>
<summary>What is the testing procedure ?</summary>

 1. `cp -p tests/java/ciede-2000-testing.java Main.java && javac Main.java`
 2. `gcc -O3 tests/c/stdin-verifier.c -o verifier -lm`
 3. `java Main 10000000 | ./verifier > test-output.txt`
</details>

The test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
CIEDE2000 Verification Summary :
- Last Verified Line : 78.0300,-115.160,-53.1600,96.2500,-8.91000,20.1800,41.0667682716048
- Duration : 186.28 s
- Successes : 10000000
- Errors : 0
- Maximum Difference : 7.1054273576010019e-13
```

### Computational Speed

This function was measured at a speed of 4,264,445 calls per second.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **GCC** : 13.3.0
- **JDK** : 17.0.15

## Conclusion

With over 20 years serving developers, this **trusted color comparison** routine developed in Java brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=78.03&a1=-115.16&b1=-53.16&L2=96.25&a2=-8.91&b2=20.18) — [Workflow Details](../../.github/workflows#workflow-details) — [Across 30+ programming languages](../../#implementations)

