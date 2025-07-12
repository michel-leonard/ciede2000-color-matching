# ΔE2000 — Accurate. Fast. SQL-powered.

ΔE2000 is the internationally recognized, and still unrivalled, standard for color difference measurements.

This reference **SQL**-based implementation offers an easy way to calculate these differences accurately at the heart of databases.

## Overview

The developed algorithm enables software to evaluate color similarities (or differences) with scientific rigor.

As a general rule, 🔵 navy blue and 🟡 yellow, which are very different colors, have a ΔE\*<sub>00</sub> of around 115.

Values [such as 5](https://michel-leonard.github.io/ciede2000-color-matching/de2000-rgb-pairs.html?seq=50&delta-e=5) indicate greater closeness, making this both a simple and advanced method of color comparison.

## Implementation Details

T-SQL and PL/SQL (Oracle) can both seamlessly integrate this classic source code.

|Database Engine|Source Code|Archive|
|:--:|:--:|:--:|
|MariaDB / MySQL|[Link](../../ciede-2000.sql#L8)|[Link](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.sql)|
|PostgreSQL|[Link](ciede-2000.pg.sql#L6)|[Link](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/tests/sql/ciede-2000.pg.sql)|


## Example usage in SQL

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```SQL
-- Example usage of the ΔE*00 function in SQL

-- L1 = 19.3166        a1 = 73.5           b1 = 122.428
-- L2 = 19.0           a2 = 76.2           b2 = 91.372

SELECT ciede_2000(l1, a1, b1, l2, a2, b2) AS delta_e;

-- This shows a ΔE2000 of 9.60876174564
```

**Note** : L\* is nominally between 0 and 100, a\* and b\* generally between -128 and +127.

For color inputs in **hexadecimal** (e.g., `#FFF`) or **RGB** formats, see examples for other languages :

[AWK](../awk#-flexibility), [C](../c#δe2000--accurate-fast-c-powered), [Dart](../dart#δe2000--accurate-fast-dart-powered), [Java](../java#δe2000--accurate-fast-java-powered), [JavaScript](../js#-flexibility), [Kotlin](../kt#δe2000--accurate-fast-kotlin-powered), [Lua](../lua#-flexibility), [PHP](../php#δe2000--accurate-fast-php-powered), [Python](../py#δe2000--accurate-fast-python-powered), [Ruby](../rb#δe2000--accurate-fast-ruby-powered), [Rust](../rs#δe2000--accurate-fast-rust-powered).

## Verification

[![SQL CIEDE2000 Testing (MariaDB)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-sql-mariadb.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-sql-mariadb.yml) [![SQL CIEDE2000 Testing (PostgreSQL)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-sql-postgresql.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/test-sql-postgresql.yml)

<details>
<summary>What is the MariaDB testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by SQL with MariaDB**, like this :
1. `gcc -std=c99 -Wall -pedantic -Ofast -g tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
2. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
3. `/usr/bin/mariadb -D my-demo < ciede-2000.sql`
4.
```sh
m="/usr/bin/mariadb"
o="-D my-demo -e"
p="Double"
$m $o "CREATE TABLE colors (L1 $p, a1 $p, b1 $p, L2 $p, a2 $p, b2 $p) ENGINE=MyISAM;"
$m --local-infile=1 $o "
  LOAD DATA LOCAL INFILE 'test-cases.csv' INTO TABLE colors
  FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'
  (L1,a1,b1,L2,a2,b2);"
rm test-cases.csv
```
5.
```sh
e="/usr/bin/mariadb -D my-demo -B -N -e "
$e "SELECT CONCAT_WS(',', L1,a1,b1,L2,a2,b2, ciede_2000(L1,a1,b1,L2,a2,b2)) FROM colors;" \
| ./ciede-2000-driver -o summary.txt
```

Where the database is `my-demo`, and the other files involved are [ciede-2000.sql](../../ciede-2000.sql#L-28) for calculations and [test-sql-mariadb.yml](../../.github/workflows/test-sql-mariadb.yml) for automation.
</details>

<details>
<summary>What is the PostgreSQL testing procedure ?</summary>

The [ciede-2000-driver.c](../c/ciede-2000-driver.c) program generates color pairs, and checks the **CIE2000** color differences **measured by SQL with PostgreSQL**, like this :
1. `gcc -std=c99 -Wall -pedantic -Ofast -g tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm`
2. `./ciede-2000-driver --generate 10000000 --output-file test-cases.csv`
3.
```sh
p="double precision"
psql -c "CREATE UNLOGGED TABLE colors (l1 $p, a1 $p, b1 $p, l2 $p, a2 $p, b2 $p);"
psql -c "\copy colors FROM test-cases.csv WITH (FORMAT csv);"
rm test-cases.csv
```
4. `psql -f tests/sql/ciede-2000.pg.sql`
5.
```sh
psql -c "\copy (
  SELECT
    l1, a1, b1, l2, a2, b2,
    ciede_2000(l1,a1,b1,l2,a2,b2) AS delta_e
  FROM colors
) TO STDOUT WITH CSV;" | ./ciede-2000-driver -o summary.txt
```

Where the main files involved are [ciede-2000.pg.sql](ciede-2000.pg.sql#L-30) for calculations and [test-sql-postgresql.yml](../../.github/workflows/test-sql-postgresql.yml) for automation.
</details>

Executed through both **MariaDB** and **PostgreSQL**, the test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
 CIEDE2000 Verification Summary :
  First Verified Line : 57.7,61,95.1,50.49,-53,-91.7,72.48542739412765
             Duration : 44.06 s
            Successes : 10000000
               Errors : 0
      Average Delta E : 62.9405
    Average Deviation : 4.2545206732635951e-15
    Maximum Deviation : 1.1368683772161603e-13
```

> [!IMPORTANT]
> To correct this SQL source code to exact match certain third-party ΔE2000 functions, follow the comments in the source code.

> This formula, "small" in size, is an essential pillar of color management, deserving of this rigorous, tested and reliable industrial treatment.

### Speed Benchmark

This function was measured at a speed of 295,241 calls per second.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **MariaDB Client** : 15.2
- **MariaDB Server** : 11.4.7
- **PostgreSQL** : 17.5
- **GCC** : 13.3

## Conclusion

![The ΔE*00 equation is very effective at predicting perceived color differences](https://github.com/michel-leonard/ciede2000-color-matching/raw/main/docs/assets/images/logo.jpg)

With over 20 years serving developers, this reference color comparison routine **developed in SQL** brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=1.59&a1=71.28&b1=-121.95&L2=93.68&a2=-109.14&b2=-97.84) — [Workflow Details](../../.github/workflows#workflow-details) — 🌐 [Suitable in 40+ Languages](../../#implementations)
