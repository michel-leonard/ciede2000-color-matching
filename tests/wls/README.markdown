# ΔE2000 — Accurate. Fast. Mathematica-powered.

A precise **Mathematica** implementation of the CIEDE2000 formula — the current standard for quantifying perceived color differences.

Measure color similarity and difference with scientific rigor and ease, leveraging a trusted algorithm widely used in color science.

For context, two very distinct colors typically have a ΔE2000 value above 12, while values close to zero indicate nearly indistinguishable colors.

## Implementation Details

The full source code released on March 1, 2025, is available [here](../../ciede-2000.wls#L6) and archived [here](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.wls).

## Example usage in Mathematica (Wolfram Language)

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede2000` function :

```mathematica
(* Example usage of the CIEDE2000 function in Mathematica *)

(* L1 = 19.3166        a1 = 73.5           b1 = 122.428 *)
(* L2 = 19.0           a2 = 76.2           b2 = 91.372 *)

deltaE = ciede2000[l1, a1, b1, l2, a2, b2];
Print[deltaE];

(* This shows a ΔE2000 of 9.60876174564 *)
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

## Online Playground

You could execute the `ciede2000` function on [tio.run](https://tio.run/##lVbfb9s2EH5O/4pDH4o4sR1LjpMWbQcEaYAVaLEgDbCHwBhoira0UKRKUkm6YH979h1FWfY2DNiDLZJH3vG@736wFqFUtQiVFC@yUoXKZ7MZfaRLWzeVVnfPrw4OnnU2pt9ulNB/jnkq9qer/anO9zfvT1fb6asDXvlqixZmIDo8ol@tu6/MhipDX4d70WMVSsKULj9ffbqKF5RWWzcpqvVaOWWkorV1davFlI5Gna57PaZ7iV9JwilqhBO1Cq6StBYyWOcpWFopEsXvrQ@qICGldQWbh6DX0lsI9FCpRxYmRQoKfCuhHIrUU2id8mNaCXm/cbY1hZ9O012eh5uMyYxJAi4JFEp8S/7WY2rGFDCCIKJ0r8FANp2957HcGZfD2GB4@O27C3cioyPC3zGteLTKlhh2kpwlOUt4tMqXI3xm00WvwGD6r7/3nfsXCSww8mD1A/svS2drQU5UHqABKiamsY/KkV3TORXKVxvTiWpxr7ZQ8r7KrHUb@cLepMmaKAo2CN3xSju81hbkgZrWiaASoqZDAW7BFdz2kCeTzmVDJ3RoIDrLZvNFtjjLF9PZaDlih2SGg3uQ9R4P0MV9@XZfAnBnXwIyASSCMDlVnhqncGUHv@0DoOB1RJcUrYfXYeuB/gEX66YNykevhdnoCEaPkgCWFcLt8GlMP0acCUJr@t6KwgkTEGKlMIWOUYrjDLXn4yuLFJE2BjDM@IRUyR5fOHkrTOcz4i85WeY7ojyJOr8@r@9w8APQnXGY0vFHyoHwEV1XW3m@lef/kDM/FyvPmyY432N16az3k6putKqRUchtUC@t8RXyDy7HvIFn6e6wcl1BQXY1yU5hzdCbN/j7ACvgIa4in2AqWeX6UaoumMo2QetJVxx2O4m8g2WEMCCUN2VAAXkUrhiIAI1io0iCyMahSiEYBdVKsAURoBPlwikZQKlvNxvlg8eGrWU2uhv6j86CtN54Z9ugcOCCBteMtCILSsRS5X3bx3pZc54zCUB6J3vLIq53CO@sd6h9YDYxBEMYlwVoKmjCUMXRcQcaSk8/xMkGCudnkUesT2ixSJxuq43kW8j8f9aQ28SHs1vKI248RBmtOXt2iwbX4RY8gZAIUg@isWbCWAmHxCrFQ2VjxWHVQ73wDDufWmk2qTawkpB0AZeddIH6X6UCWw8OsKUyjOQJzeOJq6fmrsG34UOTvMcm/o2W27A/1IyR/jtGMANAwQavD5OE0BeOPwRBn7U6KmJqNaiFPfSDVOW45M2yRYT4pHMjn8V1sxyNBsRRdaRV63WFnm44MGOX62pw3aCmM3RDTpTC1dagN/Zgc5GyJh61Q0rt1GUptES/DQO@oavKB3zF/JQ6BPM@no47sIBJBJg3zfO0aT5setvjekIZMI57J9ibnae9varIy1acz5L4dFA1H1QxRFuKUhQnrH4eMo36MhZhlVwuZb7s7RbLyES5x8TsfJGiPWzRv4xtLSmVMW@YSpmolHsK8jwq2B6@UXhJmK43eBQLx3ljA3nbVR1e/6R0EHRF8SGEtqORTKmbyNCiiW6UTU@d4Rnj0ZBAGz@lUoZ0rdYjGNSYHssKbxlUJtQxWsMBmsVcbFD6nqq661zZ20VyKyLEQam5LjHijCkDlr685gL4WeI9070lY6zcCrdRgSY/0evL1xDdINOrWv3SsNDH9W@NUsWO7CLAlVXsmBA/f2FXVlrxQ@kabzGtla7@6CoL5LeuVa@WLwVjdMVs92/au@zddJ6dnY3pfD5djCnL8@lp/haDd9zGzs@meIu9y6bzc26C1w5N@K7Tsnz/8vIX).

## Verification

All current tests in Wolfram Language indicate that the `ciede2000` function works correctly; however, further testing on a larger scale and in a wider variety of scenarios is still needed to fully validate its accuracy and robustness. The file [ciede-2000-random.wls](ciede-2000-random.wls#L122) is designed for this purpose and is available for anyone who wishes to run more extensive tests.

## Conclusion

![ΔE2000 Logo](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine in **Wolfram Language** brings accuracy into your applications.

🌐 [Used in 30+ Languages](../../#implementations)

