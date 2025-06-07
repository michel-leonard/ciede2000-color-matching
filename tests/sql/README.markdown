# ΔE2000 — Accurate. Fast. SQL-powered.

This reference ΔE2000 implementation written in SQL provides reliable and accurate perceptual **color difference** calculation.

## Source Code

T-SQL and PL/SQL (Oracle) can both seamlessly integrate this classic source code.

|Database Engine|Source Code|Archive|
|:--:|:--:|:--:|
|MariaDB / MySQL|[Link](../../ciede-2000.sql#L8)|[Link](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/ciede-2000.sql)|
|PostgreSQL|[Link](ciede-2000.pg.sql#L6)|[Link](https://web.archive.org/https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/tests/sql/ciede-2000.pg.sql)|


## Example usage in SQL

The typical calculation of the **Delta E 2000** between 2 colors in the **L\*a\*b\* color space** is done using the `ciede_2000` function :

```SQL
-- Example usage of the CIEDE2000 function in SQL

-- L1 = 19.3166        a1 = 73.5           b1 = 122.428
-- L2 = 19.0           a2 = 76.2           b2 = 91.372

SELECT ciede_2000(l1, a1, b1, l2, a2, b2) AS delta_e;

-- This shows a ΔE2000 of 9.60876174564
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

[![SQL CIEDE2000 Testing (MariaDB)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-sql-mariadb.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-sql-mariadb.yml) [![SQL CIEDE2000 Testing (PostgreSQL)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-sql-postgresql.yml/badge.svg)](https://github.com/michel-leonard/ciede2000-color-matching/actions/workflows/raw-sql-postgresql.yml)

<details>
<summary>What is the testing procedure with MariaDB ?</summary>

When the database is `my-demo` :
 1. `/usr/bin/mariadb -D my-demo < ciede-2000.sql`
 2. `gcc -O3 tests/c/stdin-verifier.c -o verifier -lm`
```sql
/usr/bin/mariadb -D my-demo -B -N -e "
SELECT
	l1, a1, b1, l2, a2, b2,
	ciede_2000(l1, a1, b1, l2, a2, b2) AS delta_e
FROM (
  SELECT
	ROUND(RAND() * 100, 2) AS l1,
	ROUND(RAND() * 256 - 128, 2) AS a1,
	ROUND(RAND() * 256 - 128, 2) AS b1,
	ROUND(RAND() * 100, 2) AS l2,
	ROUND(RAND() * 256 - 128, 2) AS a2,
	ROUND(RAND() * 256 - 128, 2) AS b2
  FROM seq_1_to_10000000
) AS params;" | tr "\t" ',' | ./verifier > test-output.txt
```

Where the two main files involved are [ciede-2000.sql](../../ciede-2000.sql) and [raw-sql-mariadb.yml](../../.github/workflows/raw-sql-mariadb.yml).
</details>

<details>
<summary>What is the testing procedure with PostgreSQL ?</summary>

 1. `psql -f tests/sql/ciede-2000.pg.sql`
 2. `gcc -O3 tests/c/stdin-verifier.c -o verifier -lm`
```sql
psql -tA -c "\COPY (
	SELECT
			l1,
			a1,
			b1,
			l2,
			a2,
			b2,
			ciede_2000(l1, a1, b1, l2, a2, b2)::numeric
	FROM (
			SELECT
			  ROUND((RANDOM() * 100)::numeric, 2) AS l1,
			  ROUND((RANDOM() * 256 - 128)::numeric, 2) AS a1,
			  ROUND((RANDOM() * 256 - 128)::numeric, 2) AS b1,
			  ROUND((RANDOM() * 100)::numeric, 2) AS l2,
			  ROUND((RANDOM() * 256 - 128)::numeric, 2) AS a2,
			  ROUND((RANDOM() * 256 - 128)::numeric, 2) AS b2
			FROM generate_series(1, 10000000)
	) AS colors
) TO STDOUT WITH CSV;" | ./verifier > test-output.txt
```

Where the two main files involved are [ciede-2000.pg.sql](ciede-2000.pg.sql) and [raw-sql-postgresql.yml](../../.github/workflows/raw-sql-postgresql.yml).
</details>

Executed through both **MariaDB** and **PostgreSQL**, the test confirms full compliance with the standard, with no observed errors and a negligible maximum floating-point deviation :

```
CIEDE2000 Verification Summary :
- Last Verified Line : 1.59,71.28,-121.95,93.68,-109.14,-97.84,107.167902536957
- Duration : 98.47 s
- Successes : 10000000
- Errors : 0
- Maximum Difference : 5.6843418860808015e-13
```

### Computational Speed

This function was measured at a speed of 295,241 calls per second.

### Software Versions

- **Ubuntu** : 24.04.2 LTS
- **MariaDB Client** : 15.2
- **MariaDB Server** : 11.4.7
- **PostgreSQL** : 17.5
- **GCC** : 13.3.0

## Conclusion

With over 20 years serving developers, this **trusted color comparison** routine developed in SQL brings accuracy into your applications.

[Calculator](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=1.59&a1=71.28&b1=-121.95&L2=93.68&a2=-109.14&b2=-97.84) — [Workflow Details](../../.github/workflows#workflow-details) — [Across 30+ programming languages](../../#implementations)

