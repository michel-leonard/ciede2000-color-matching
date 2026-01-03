# CIEDE 2000 Function Test

This is to test the consistency and accuracy of **CIEDE2000 formula implementations** across all supported programming languages.

![ΔE2000 — Modern share. No dependencies. Just native code…](https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/docs/assets/images/logo.jpg)

## ΔE2000 Drivers

Each programming language implements, in addition to the `ciede_2000` function, a driver capable of processing a **CSV file** containing L\*a\*b\* color pairs. The driver, minimal but indispensable for **automated tests**, receives the file name as the first parameter, reads the CSV file line by line, adds a seventh column containing the color difference ΔE<sub>00</sub>, then displays the result on its standard output.

The **C99 driver** (and the Julia driver for arbitrary precision) implements additional functions, being able to **generate test cases** in a CSV file, and to check on its standard input (via a pipe) the **ΔE2000 calculations** performed by the other drivers. Details of these test procedures can be found in the `.yml` files for each programming language in the GitHub Actions workflows.

<details>
<summary>Show an example !</summary>

Let’s open the console, switch to the repository root directory, and quickly see how to implement the test process.

#### Compilation

On Linux, Windows and macOS, GCC or Clang can be used to produce the `ciede-2000-driver` executable :

```sh
gcc -std=c99 -Wall -pedantic -O2 -g tests/c/ciede-2000-driver.c -o ciede-2000-driver -lm
```

#### Generate Test Cases

Let’s generate `1000` test lines in the file `test-cases.csv` with seed `1` of the XorShift64 generator for reproducibility :

```sh
./ciede-2000-driver --rand-seed 1 --generate 1000 --output-file test-cases.csv
```

The `test-cases.csv` file will have been created or replaced, and will begin with the following lines, each representing two L\*a\*b\* colors :

```text
31,115.9,77,25.2,54.03,1.000021
25.2,54.03,1.000021,31,115.9,77
15,120,31.01,43.9999999461,-58,-3.39999999999999
43.9999999461,-58,-3.39999999999999,15,120,31.01
```

#### Calculate and Check Color Differences

Let’s test the Python implementation :

```sh
python3 tests/py/ciede-2000-driver.py test-cases.csv | ./ciede-2000-driver
```

Once all the lines have been processed, the C99 driver will display :

```
CIEDE2000 Verification Summary :
  First Verified Line : 31,115.9,77,25.2,54.03,1.000021,25.790174075222602
             Duration : 0.01 s
            Successes : 1000
               Errors : 0
      Average Delta E : 44.9222
    Average Deviation : 3.2e-15
    Maximum Deviation : 2.8e-14
```

The fact that we see `Successes : 1000` and `Errors : 0` means that no deviation greater than 10<sup>-10</sup> has been found, and that on a larger scale, with millions of error-free lines, the tested implementation is production-ready. Otherwise, details of the first 5 errors would be displayed.
</details>

## Symmetry Property of the CIEDE 2000 Functions

The `ciede_2000` functions produce the same result regardless of the order in which the two colors are supplied. This **symmetry property**, essential for comparators, is carefully considered by the C test driver, which always generates the random color pairs together with their permutations. All programming languages are tested in this way to ensure that the function is indeed symmetrical.

## Correct Implementation of Parametric Factors

The correct implementation of the parametric factors `k_l`, `k_c` and `k_h` was considered from the start of this project, and is still considered in the GitHub Actions workflows, in Java against OpenJDK and in MATLAB against Gaurav Sharma’s original implementation, with zero errors.

> Usually, developers rarely do this test, and the ΔE\*<sub>00</sub> standard does not allow these parametric factors to be zero or negative.

## Dynamic Tests with Established Libraries

These reference implementations of the CIE2000 ΔE color difference formula are validated using billions of color pairs, and show exceptional numerical accuracy and stability. Compared with the well-established libraries **VMAF** in C99 (2016), **chroma-js** on npm (2011), **OpenIMAJ** in Java (2011), and **colormath** in Python (2008), they show a deviation of no more than 10<sup>-12</sup>, confirming their interoperability in general.

[View details](../.github/workflows#dynamic-tests)

## Static Tests

The 40+ programming languages are tested individually and automatically using workflows, each with a driver in its directory that can interact with the C driver to run the tests. The ΔE2000 [test driver in C99](c/ciede-2000-driver.c) checks itself using over 250 static references before starting up, and injects these references into the tests it submits to each language via a CSV file containing 10,000,000 fresh L\*a\*b\* color pairs every month.

[View details](../.github/workflows#static-tests) - [Download Michel Leonard’s CIEDE2000 tests](datasets/reference-data-3.txt)

### Comparison with Fogra Quality Evaluation Data

To validate implementations of the ΔE2000 function, **104 color pairs** from the reference data of the German-based research institute for the graphic arts are included in static tests. The 40+ programming languages we support pass these tests, each independently.

|L1|a1|b1|L2|a2|b2|Reference ΔE<sub>00</sub> (Excel)|Computed Value|Deviation|
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| 88.94 | -4.04 | 92.37 | 88.407 | -5.5 | 92.607 | 0.8385874 | [0.8385874](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=88.94&a1=-4.04&b1=92.37&L2=88.407&a2=-5.5&b2=92.607) | 0% |
| 76.04 | -27.46 | 75.95 | 76.111 | -26.998 | 70.914 | 1.257076 | [1.257076](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=76.04&a1=-27.46&b1=75.95&L2=76.111&a2=-26.998&b2=70.914) | 0% |
| 51.64 | -46.86 | -39.77 | 50.224 | -48.022 | -40.685 | 1.4648351 | [1.4648351](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=51.64&a1=-46.86&b1=-39.77&L2=50.224&a2=-48.022&b2=-40.685) | 0% |
| 45.69 | -61.51 | -24.28 | 44.214 | -58.828 | -25.712 | 1.8741005 | [1.8741005](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=45.69&a1=-61.51&b1=-24.28&L2=44.214&a2=-58.828&b2=-25.712) | 0% |
| 59.91 | 5.85 | 1.88 | 58.002 | 4.874 | 2.069 | 2.0310657 | [2.0310657](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=59.91&a1=5.85&b1=1.88&L2=58.002&a2=4.874&b2=2.069) | 0% |
| 44.79 | 3.14 | 1.87 | 42.135 | 2.763 | 2.589 | 2.6010828 | [2.6010828](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=44.79&a1=3.14&b1=1.87&L2=42.135&a2=2.763&b2=2.589) | 0% |
| 91.12 | 8.1 | 0.63 | 89.531 | 6.056 | 2.111 | 2.6677626 | [2.6677626](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=91.12&a1=8.1&b1=0.63&L2=89.531&a2=6.056&b2=2.111) | 0% |
| 69.91 | -47.0 | -2.13 | 66.424 | -47.05 | -4.316 | 3.0487671 | [3.0487671](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=69.91&a1=-47.0&b1=-2.13&L2=66.424&a2=-47.05&b2=-4.316) | 0% |
| 22.0 | 47.0 | -56.0 | 16.862 | 41.966 | -58.784 | 4.8594857 | [4.8594857](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=22.0&a1=47.0&b1=-56.0&L2=16.862&a2=41.966&b2=-58.784) | 0% |
| 17.04 | 32.75 | -39.36 | 11.798 | 39.554 | -52.579 | 5.8074288 | [5.8074288](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=17.04&a1=32.75&b1=-39.36&L2=11.798&a2=39.554&b2=-52.579) | 0% |

Fogra is a world-renowned authority on characterization data, which means that ΔE<sub>00</sub> implementations are ready to go into production.

### Comparison with ICC HDR Working Group Reference Data

When validating ΔE2000 implementations, the reference values of the ICC HDR working group [document](https://www.color.org/groups/hdr/HDRWG-Summer2020.pdf) are in use. The ΔE00 functions available in this repository reproduce them exactly, as shown in the following table, confirming the correctness of the implementations.

|L1|a1|b1|L2|a2|b2|Reference ΔE<sub>00</sub> (PDF)|Computed Value|Deviation|
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
|100.0|0.0|0.0|100.0|0.0|0.0|0.0|[0.0](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=100&a1=0&b1=0&L2=100&a2=0&b2=0)|0%|
|84.25|5.74|96.0|84.52|5.75|93.09|0.5887|[0.5887](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=84.25&a1=5.74&b1=96&L2=84.52&a2=5.75&b2=93.09)|0%|
|84.25|5.74|96.0|84.37|5.86|99.42|0.6395|[0.6395](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=84.25&a1=5.74&b1=96&L2=84.37&a2=5.86&b2=99.42)|0%|
|84.25|5.74|96.0|84.46|8.88|96.49|1.6743|[1.6743](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=84.25&a1=5.74&b1=96&L2=84.46&a2=8.88&b2=96.49)|0%|
|50.0|2.5|0.0|58.0|24.0|15.0|19.4535|[19.4535](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=50&a1=2.5&b1=0&L2=58&a2=24&b2=15)|0%|
|50.0|2.5|0.0|61.0|-5.0|29.0|22.8977|[22.8977](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=50&a1=2.5&b1=0&L2=61&a2=-5&b2=29)|0%|
|50.0|2.5|0.0|73.0|25.0|-18.0|27.1492|[27.1492](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=50&a1=2.5&b1=0&L2=73&a2=25&b2=-18)|0%|
|50.0|2.5|0.0|56.0|-27.0|-3.0|31.903|[31.903](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=50&a1=2.5&b1=0&L2=56&a2=-27&b2=-3)|0%|
|100.0|0.0|0.0|0.0|0.0|0.0|100.0|[100.0](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=100&a1=0&b1=0&L2=0&a2=0&b2=0)|0%|


**Note** : The HDR working group plays a key role in promoting the adoption of **high dynamic range** by both industry and the general public.

#### Roundings

The rounding method consists of multiplying the ΔE<sub>00</sub> at function output by 10,000, then rounding to the nearest integer and dividing by 10,000. This is to avoid any discrepancies in comparisons with reference values which, as above, are usually given with moderate precision.

### Comparison with Curve4 Example Calculations

<!-- http://www.hutchcolor.com/PDF/Curve4Guide.pdf -->

Curve4 is HutchColor’s specialist printing calibration and linearization software, renowned for its technical expertise and precise calculations. The ΔE<sub>00</sub> associated with **22 L\*a\*b\* color pairs** in its documentation  are included in the standard tests that every implementation passes.

|L1|a1|b1|L2|a2|b2|Reference ΔE<sub>00</sub> (PDF)|Computed Value|Deviation|
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| 27.0 | -0.01 | 0.0 | 27.0 | 0.0 | 0.0 | 0.01 | [0.01](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=27&a1=-0.01&b1=0&L2=27&a2=0&b2=0) | 0% |
| 47.97 | 75.06 | -4.03 | 48.0 | 75.0 | -4.0 | 0.03 | [0.03](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=47.97&a1=75.06&b1=-4.03&L2=48&a2=75&b2=-4) | 0% |
| 50.07 | -65.99 | 26.0 | 50.0 | -66.0 | 26.0 | 0.07 | [0.07](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=50.07&a1=-65.99&b1=26&L2=50&a2=-66&b2=26) | 0% |
| 9.03 | 0.21 | 0.49 | 9.05 | .2 | .39 | 0.1 | [0.1](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=9.03&a1=0.21&b1=0.49&L2=9.05&a2=0.2&b2=0.39) | 0% |
| 51.09 | -61.98 | 25.98 | 50.0 | -66.0 | 26.0 | 1.56 | [1.56](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=51.09&a1=-61.98&b1=25.98&L2=50&a2=-66&b2=26) | 0% |
| 91.99 | 0.01 | 0.01 | 95.00 | 1.0 | -4.0 | 4.31 | [4.31](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=91.99&a1=0.01&b1=0.01&L2=95&a2=1&b2=-4) | 0% |

### Comparison with X-Rite Software Calculations

<!-- https://www.xrite.com/-/media/xrite/files/training-detail-pdfs/exact2-webinar07.pdf -->

XRite is the US leader in colorimetry equipment, and **28 real color pairs** associated with their ΔE<sub>00</sub> ranging from 0.05 to 6.71, taken from a webinar introducing their portable spectrophotometer, are included in the static tests that every implementation passes automatically.

|L1|a1|b1|L2|a2|b2|Reference ΔE<sub>00</sub> (PDF)|Computed Value|Deviation|
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| 68.65 | 27.21 | 68.45 | 68.7 | 26.97 | 68.47 | 0.15 | [0.15](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=68.65&a1=27.21&b1=68.45&L2=68.7&a2=26.97&b2=68.47) | 0% |
| 68.65 | 27.21 | 68.45 | 68.61 | 25.02 | 64.08 | 1.19 | [1.19](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=68.65&a1=27.21&b1=68.45&L2=68.61&a2=25.02&b2=64.08) | 0% |
| 68.65 | 27.21 | 68.45 | 69.62 | 22.92 | 63.1 | 2.17 | [2.17](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=68.65&a1=27.21&b1=68.45&L2=69.62&a2=22.92&b2=63.1) | 0% |
| 68.65 | 27.21 | 68.45 | 66.73 | 31.73 | 64.39 | 3.85 | [3.85](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=68.65&a1=27.21&b1=68.45&L2=66.73&a2=31.73&b2=64.39) | 0% |
| 68.65 | 27.21 | 68.45 | 66.59 | 34.41 | 65.1 | 5.05 | [5.05](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=68.65&a1=27.21&b1=68.45&L2=66.59&a2=34.41&b2=65.1) | 0% |
| 68.65 | 27.21 | 68.45 | 68.64 | 29.76 | 52.2 | 6.71 | [6.71](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=68.65&a1=27.21&b1=68.45&L2=68.64&a2=29.76&b2=52.2) | 0% |

### Comparison with University of Rochester Worked Examples

CIE ΔE2000 implementations are also validated by systematic comparison with academic reference values from the [University of Rochester](https://hajim.rochester.edu/ece/sites/gsharma/ciede2000/ciede2000noteCRNA.pdf). Understanding the algorithm is made easier by hyperlinks to the ΔE2000 calculator, which show the intermediate steps in the calculation.

|L1|a1|b1|L2|a2|b2|Reference ΔE<sub>00</sub> (PDF)|Computed Value|Deviation|
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
|6.7747|-0.2908|-2.4247|5.8714|-0.0985|-2.2286|0.6377|[0.6377](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=6.7747&a1=-0.2908&b1=-2.4247&L2=5.8714&a2=-0.0985&b2=-2.2286)|0%|
|2.0776|0.0795|-1.135|0.9033|-0.0636|-0.5514|0.9082|[0.9082](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=2.0776&a1=0.0795&b1=-1.135&L2=0.9033&a2=-0.0636&b2=-0.5514)|0%|
|50.0|-1.3802|-84.2814|50.0|0.0|-82.7485|1.0|[1.0](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=50&a1=-1.3802&b1=-84.2814&L2=50&a2=0&b2=-82.7485)|0%|
|50.0|-1.1848|-84.8006|50.0|0.0|-82.7485|1.0|[1.0](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=50&a1=-1.1848&b1=-84.8006&L2=50&a2=0&b2=-82.7485)|0%|
|50.0|-0.9009|-85.5211|50.0|0.0|-82.7485|1.0|[1.0](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=50&a1=-0.9009&b1=-85.5211&L2=50&a2=0&b2=-82.7485)|0%|
|50.0|2.5|0.0|50.0|3.1736|0.5854|1.0|[1.0](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=50&a1=2.5&b1=0&L2=50&a2=3.1736&b2=0.5854)|0%|
|50.0|2.5|0.0|50.0|3.2972|0.0|1.0|[1.0](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=50&a1=2.5&b1=0&L2=50&a2=3.2972&b2=0)|0%|
|50.0|2.5|0.0|50.0|1.8634|0.5757|1.0|[1.0](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=50&a1=2.5&b1=0&L2=50&a2=1.8634&b2=0.5757)|0%|
|50.0|2.5|0.0|50.0|3.2592|0.335|1.0|[1.0](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=50&a1=2.5&b1=0&L2=50&a2=3.2592&b2=0.335)|0%|
|63.0109|-31.0961|-5.8663|62.8187|-29.7946|-4.0864|1.263|[1.263](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=63.0109&a1=-31.0961&b1=-5.8663&L2=62.8187&a2=-29.7946&b2=-4.0864)|0%|
|60.2574|-34.0099|36.2677|60.4626|-34.1751|39.4387|1.2644|[1.2644](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=60.2574&a1=-34.0099&b1=36.2677&L2=60.4626&a2=-34.1751&b2=39.4387)|0%|
|36.4612|47.858|18.3852|36.2715|50.5065|21.2231|1.4146|[1.4146](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=36.4612&a1=47.858&b1=18.3852&L2=36.2715&a2=50.5065&b2=21.2231)|0%|
|90.8027|-2.0831|1.441|91.1528|-1.6435|0.0447|1.4441|[1.4441](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=90.8027&a1=-2.0831&b1=1.441&L2=91.1528&a2=-1.6435&b2=0.0447)|0%|
|90.9257|-0.5406|-0.9208|88.6381|-0.8985|-0.7239|1.5381|[1.5381](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=90.9257&a1=-0.5406&b1=-0.9208&L2=88.6381&a2=-0.8985&b2=-0.7239)|0%|
|35.0831|-44.1164|3.7933|35.0232|-40.0716|1.5901|1.8645|[1.8645](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=35.0831&a1=-44.1164&b1=3.7933&L2=35.0232&a2=-40.0716&b2=1.5901)|0%|
|61.2901|3.7196|-5.3901|61.4292|2.248|-4.962|1.8731|[1.8731](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=61.2901&a1=3.7196&b1=-5.3901&L2=61.4292&a2=2.248&b2=-4.962)|0%|
|22.7233|20.0904|-46.694|23.0331|14.973|-42.5619|2.0373|[2.0373](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=22.7233&a1=20.0904&b1=-46.694&L2=23.0331&a2=14.973&b2=-42.5619)|0%|
|50.0|2.6772|-79.7751|50.0|0.0|-82.7485|2.0425|[2.0425](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=50&a1=2.6772&b1=-79.7751&L2=50&a2=0&b2=-82.7485)|0%|
|50.0|0.0|0.0|50.0|-1.0|2.0|2.3669|[2.3669](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=50&a1=0&b1=0&L2=50&a2=-1&b2=2)|0%|
|50.0|-1.0|2.0|50.0|0.0|0.0|2.3669|[2.3669](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=50&a1=-1&b1=2&L2=50&a2=0&b2=0)|0%|
|50.0|3.1571|-77.2803|50.0|0.0|-82.7485|2.8615|[2.8615](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=50&a1=3.1571&b1=-77.2803&L2=50&a2=0&b2=-82.7485)|0%|
|50.0|2.8361|-74.02|50.0|0.0|-82.7485|3.4412|[3.4412](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=50&a1=2.8361&b1=-74.02&L2=50&a2=0&b2=-82.7485)|0%|
|50.0|2.5|0.0|50.0|0.0|-2.5|4.3065|[4.3065](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=50&a1=2.5&b1=0&L2=50&a2=0&b2=-2.5)|0%|
|50.0|-0.001|2.49|50.0|0.0011|-2.49|4.7461|[4.7461](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=50&a1=-0.001&b1=2.49&L2=50&a2=0.0011&b2=-2.49)|0%|
|50.0|-0.001|2.49|50.0|0.0009|-2.49|4.8045|[4.8045](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=50&a1=-0.001&b1=2.49&L2=50&a2=0.0009&b2=-2.49)|0%|
|50.0|-0.001|2.49|50.0|0.001|-2.49|4.8045|[4.8045](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=50&a1=-0.001&b1=2.49&L2=50&a2=0.001&b2=-2.49)|0%|
|50.0|2.49|-0.001|50.0|-2.49|0.0009|7.1792|[7.1792](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=50&a1=2.49&b1=-0.001&L2=50&a2=-2.49&b2=0.0009)|0%|
|50.0|2.49|-0.001|50.0|-2.49|0.001|7.1792|[7.1792](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=50&a1=2.49&b1=-0.001&L2=50&a2=-2.49&b2=0.001)|0%|
|50.0|2.49|-0.001|50.0|-2.49|0.0011|7.2195|[7.2195](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=50&a1=2.49&b1=-0.001&L2=50&a2=-2.49&b2=0.0011)|0%|
|50.0|2.49|-0.001|50.0|-2.49|0.0012|7.2195|[7.2195](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=50&a1=2.49&b1=-0.001&L2=50&a2=-2.49&b2=0.0012)|0%|

## Conclusion

The ΔE<sub>00</sub> calculated are in perfect agreement, both statically with the reference values and dynamically with the recognized libraries. They also match the results from [brucelindbloom.com](http://www.brucelindbloom.com/index.html?ColorDifferenceCalc.html), guaranteeing the correct implementation of this cross-language CIEDE2000 formula.

> [!TIP]
> A web-based [generator](https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html) to discover more examples is available, and a [large-scale validator](https://michel-leonard.github.io/ciede2000-color-matching) is in use to validate your implementations.
