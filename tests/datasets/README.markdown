# ΔE2000 Datasets

The similarity between named colors using the ΔE CIE2000 metric, a state-of-the-art formula for color difference.

The [PHP implementation](../php#δe2000--accurate-fast-php-powered) of the `ciede_2000` function was used here, with the illuminant [D65](../../color-converters/rgb-xyz-lab.js#L20) for RGB to Lab conversions.

**Note** : The RGB gamut is smaller than that of L\*a\*b\*, so many L\*a\*b\* colors are not representable in RGB.

## RGB-Based Color Similarity

|RGB 1|RGB 2|Delta E 2000|Name 1| Name 2|
|:--:|:--:|:--:|:--:|:--:|
rgb(127, 255, 0)|rgb(124, 252, 0)|[0.6517594792](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=89.872705385219&a1=-68.066121977355&b1=85.780000715718&L2=88.876479138845&a2=-67.856062021998&b2=84.952487056851)|chartreuse|lawngreen
rgb(0, 0, 139)|rgb(0, 0, 128)|[1.5602006465](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=14.753605459894&a1=50.423446350611&b1=-68.681041117975&L2=12.971965961954&a2=47.502279798036&b2=-64.702162746299)|darkblue|navy
rgb(240, 255, 255)|rgb(245, 255, 250)|[2.7849516611](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=98.93241151981&a1=-4.8803802839757&b1=-1.6882772872508&L2=99.156391428976&a2=-4.1629224898209&b2=1.2463794826834)|azure|mintcream
rgb(0, 128, 0)|rgb(34, 139, 34)|[4.5749163333](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=46.227430171918&a1=-51.698494452474&b1=49.896850974593&L2=50.593071647397&a2=-49.585380559442&b2=45.015967987594)|green|forestgreen
rgb(0, 0, 128)|rgb(25, 25, 112)|[5.5514129921](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=12.971965961954&a1=47.502279798036&b1=-64.702162746299&L2=15.857599578707&a2=31.713343645441&b2=-49.574635301643)|navy|midnightblue
rgb(0, 0, 139)|rgb(75, 0, 130)|[7.7177685438](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=14.753605459894&a1=50.423446350611&b1=-68.681041117975&L2=20.469441015201&a2=51.685580705478&b2=-53.312625444996)|darkblue|indigo
rgb(0, 128, 0)|rgb(0, 100, 0)|[9.4327981304](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=46.227430171918&a1=-51.698494452474&b1=49.896850974593&L2=36.202354613291&a2=-43.369670464058&b2=41.858278599423)|green|darkgreen
rgb(144, 238, 144)|rgb(0, 255, 0)|[12.3810128191](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=86.548212198024&a1=-46.327946988652&b1=36.949102347808&L2=87.734720190924&a2=-86.182714624452&b2=83.179328793712)|lightgreen|lime
rgb(128, 128, 128)|rgb(169, 169, 169)|[13.5011153959](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=53.585013452192&a1=-1.9146462193476E-8&b1=2.6556066901051E-6&L2=69.237795605605&a2=-2.3453350372904E-8&b2=3.2529714255602E-6)|gray|darkgray
rgb(0, 0, 139)|rgb(0, 0, 255)|[15.038772425](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=14.753605459894&a1=50.423446350611&b1=-68.681041117975&L2=32.297009440068&a2=79.187517300112&b2=-107.86016278821)|darkblue|blue
rgb(128, 128, 128)|rgb(47, 79, 79)|[24.0173340844](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=53.585013452192&a1=-1.9146462193476E-8&b1=2.6556066901051E-6&L2=31.255233651888&a2=-11.719851566354&b2=-3.7236402867665)|gray|darkslategray
rgb(0, 128, 0)|rgb(144, 238, 144)|[32.8523665065](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=46.227430171918&a1=-51.698494452474&b1=49.896850974593&L2=86.548212198024&a2=-46.327946988652&b2=36.949102347808)|green|lightgreen

## Hexadecimal-Based Color Similarity

|Hex 1|Hex 2|Delta E 2000|Name 1| Name 2|
|:--:|:--:|:--:|:--:|:--:|
#ffebcd|#ffefd5|[1.8387495196](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=93.920257802804&a1=2.1301812107726&b1=17.026143821677&L2=95.076070073597&a2=1.270750351744&b2=14.52543348386)|blanchedalmond|papayawhip
#ffebcd|#ffe4c4|[2.8611059571](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=93.920257802804&a1=2.1301812107726&b1=17.026143821677&L2=92.013427019443&a2=4.4308922390399&b2=19.012005008363)|blanchedalmond|bisque
#ffebcd|#faebd7|[3.3631848433](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=93.920257802804&a1=2.1301812107726&b1=17.026143821677&L2=93.731328430441&a2=1.8386948238517&b2=11.52616351337)|blanchedalmond|antiquewhite
#ffebcd|#f5deb3|[4.7253364449](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=93.920257802804&a1=2.1301812107726&b1=17.026143821677&L2=89.351632593606&a2=1.5115431330177&b2=24.007855328618)|blanchedalmond|wheat
#ffebcd|#fff8dc|[5.932451375](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=93.920257802804&a1=2.1301812107726&b1=17.026143821677&L2=97.455672097282&a2=-2.217655067305&b2=14.293523034378)|blanchedalmond|cornsilk
#ffebcd|#f5f5dc|[8.5887460242](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=93.920257802804&a1=2.1301812107726&b1=17.026143821677&L2=95.949084826769&a2=-4.1928522283243&b2=12.048993860793)|blanchedalmond|beige
#ffebcd|#f5f5f5|[12.5600222278](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=93.920257802804&a1=2.1301812107726&b1=17.026143821677&L2=96.537489614274&a2=-3.0964897312913E-8&b2=4.2948229195261E-6)|blanchedalmond|whitesmoke
#ffebcd|#f0ffff|[16.6893146537](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=93.920257802804&a1=2.1301812107726&b1=17.026143821677&L2=98.93241151981&a2=-4.8803802839757&b2=-1.6882772872508)|blanchedalmond|azure
#ffebcd|#bdb76b|[18.6345616167](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=93.920257802804&a1=2.1301812107726&b1=17.026143821677&L2=73.381977794619&a2=-8.7876863907531&b2=39.291672210653)|blanchedalmond|darkkhaki
#ffebcd|#a9a9a9|[20.9195013725](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=93.920257802804&a1=2.1301812107726&b1=17.026143821677&L2=69.237795605605&a2=-2.3453350372904E-8&b2=3.2529714255602E-6)|blanchedalmond|darkgray
#ffebcd|#8fbc8f|[25.201036376](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=93.920257802804&a1=2.1301812107726&b1=17.026143821677&L2=72.086674174887&a2=-23.819546498099&b2=18.037752234254)|blanchedalmond|darkseagreen
#ffebcd|#40e0d0|[30.6671099558](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=93.920257802804&a1=2.1301812107726&b1=17.026143821677&L2=81.264431181808&a2=-44.081880532502&b2=-4.0283855331044)|blanchedalmond|turquoise

## L\*a\*b\*-Based Color Similarity

A web-based [discovery generator](https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html) is available for exploration, and a [large-scale validator](https://michel-leonard.github.io/ciede2000-color-matching) is in use to validate implementations.

## Benchmarking Color Differences in UI Design Contexts

Over 5,000 color shades, representative of both minimalist and highly colorful palettes, were converted into the CIELAB color space using the standard illuminant D65. Color differences were calculated using the [ΔE2000 implementation in C99](../c#δe2000--accurate-fast-c-powered), for a total of **27,331,921 measurements**.

> The algorithm compares the colors `L1`, `a1`, `b1` and `L2`, `a2`, `b2` with `pi = 3.141592653589793` and factors `k_L`, `k_C` and `k_H` to `1`.

### ΔE2000 Algorithm Statistics

Each expression is statistically characterized (min, max, mean, std dev) to facilitate model inspection.

#### 1. Compute C*ab (original chroma)

| Constant | Expression | Minimum | Maximum | Average | Standard Deviation |
|:--:|:--:|:--:|:--:|:--:|:--:|
| a1_sq | `a1 * a1` | 0 | 9650 | 892.09 | 1320.9 |
| b1_sq | `b1 * b1` | 0 | 11634 | 981.02 | 1557.9 |
| c_orig_1 | `sqrt(a1_sq + b1_sq)` | 0 | 133.81 | 35.658 | 24.528 |
| a2_sq | `a2 * a2` | 1.8439e-18 | 9650 | 1108.9 | 1701.5 |
| b2_sq | `b2 * b2` | 3.5473e-14 | 11634 | 1393.8 | 1887.4 |
| c_orig_2 | `sqrt(a2_sq + b2_sq)` | 1.8835e-7 | 133.81 | 41.822 | 27.452 |

#### 2. Compute average C*, apply G factor

| Constant | Expression | Minimum | Maximum | Average | Standard Deviation |
|:--:|:--:|:--:|:--:|:--:|:--:|
| c_avg | `0.5 * (c_orig_1 + c_orig_2)` | 9.4174e-8 | 132.52 | 38.74 | 18.534 |
| c_avg_3 | `c_avg * c_avg * c_avg` | 8.352e-22 | 2.3272e+6 | 1.0077e+5 | 1.3305e+5 |
| c_avg_7 | `c_avg_3 * c_avg_3 * c_avg` | 6.5691e-50 | 7.1772e+14 | 2.0544e+12 | 8.0681e+12 |
| g_denom | `c_avg_7 + 6103515625.0` | 6.1035e+9 | 7.1772e+14 | 2.0605e+12 | 8.0681e+12 |
| g_ratio | `c_avg_7 / g_denom` | 1.0763e-59 | 0.99999 | 0.71957 | 0.36669 |
| g_sqrt | `sqrt(g_ratio)` | 3.2807e-30 | 1 | 0.78779 | 0.31456 |
| g_factor | `1.0 + 0.5 * (1.0 - g_sqrt)` | 1 | 1.5 | 1.1061 | 0.15728 |

#### 3. Compute a' components and adjusted C'

| Constant | Expression | Minimum | Maximum | Average | Standard Deviation |
|:--:|:--:|:--:|:--:|:--:|:--:|
| a1_prime | `a1 * g_factor` | -86.23 | 98.304 | 3.4471 | 30.591 |
| a2_prime | `a2 * g_factor` | -86.23 | 98.304 | 15.698 | 30.079 |
| c1_prime_sq | `a1_prime * a1_prime + b1 * b1` | 0 | 17908 | 1928.7 | 2403.2 |
| c2_prime_sq | `a2_prime * a2_prime + b2 * b2` | 3.5475e-14 | 17908 | 2545 | 2641.8 |
| c1_prime | `sqrt(c1_prime_sq)` | 0 | 133.82 | 36.613 | 24.253 |
| c2_prime | `sqrt(c2_prime_sq)` | 1.8835e-7 | 133.82 | 42.55 | 27.101 |

#### 4.1 Compute h' (adjusted hue angles)

| Constant | Expression | Minimum | Maximum | Average | Standard Deviation |
|:--:|:--:|:--:|:--:|:--:|:--:|
| safe_1 | `1e30 * (b1 == 0.0 && a1_prime == 0.0)` | 0 | 1.0e+30 | 2.7049e+26 | 1.6444e+28 |
| safe_2 | `1e30 * (b2 == 0.0 && a2_prime == 0.0)` | 0 | 0 | 0 | 0 |
| h1_raw | `atan2(b1, a1_prime + safe_1)` | -3.1408 | 3.14 | 0.2441 | 1.769 |
| h2_raw | `atan2(b2, a2_prime + safe_2)` | -3.1408 | 3.14 | 0.75388 | 1.2726 |
| h1_adj | `h1_raw + (h1_raw < 0.0) * 2.0 * pi` | 0 | 6.2825 | 2.925 | 1.826 |
| h2_adj | `h2_raw + (h2_raw < 0.0) * 2.0 * pi` | 0.00070622 | 6.2825 | 2.1264 | 1.7654 |
| delta_h | `fabs(h1_adj - h2_adj)` | 0 | 6.2825 | 2.0609 | 1.5889 |
| h_mean_raw | `0.5 * (h1_adj + h2_adj)` | 0.00035311 | 6.2823 | 2.5257 | 1.3008 |
| h_diff_raw | `0.5 * (h2_adj - h1_adj)` | -3.1407 | 3.1412 | -0.39934 | 1.2383 |

#### 4.2 Handle hue angle wrapping

About 27% of cases require wrapping, proof that the space is well covered.

| Constant | Expression | Minimum | Maximum | Average | Standard Deviation |
|:--:|:--:|:--:|:--:|:--:|:--:|
| wrap_dist | `fabs(pi - delta_h)` | 2.1019e-8 | 3.1416 | 1.6971 | 0.90134 |
| hue_wrap | `1e-14 < wrap_dist && pi < delta_h` | 0 | 1 | 0.26948 | 0.44369 |
| h_mean | `h_mean_raw + hue_wrap * pi` | 0.00035311 | 7.8527 | 3.3723 | 2.2005 |
| h_diff_hi | `(hue_wrap && h_diff_raw < 0.0) * pi` | 0 | 3.1416 | 0.62426 | 1.2536 |
| h_diff_lo | `(hue_wrap && h_diff_hi == 0.0) * pi` | 0 | 3.1416 | 0.22235 | 0.80566 |
| h_diff | `h_diff_raw + h_diff_hi - h_diff_lo` | -1.5708 | 1.5708 | 0.0025735 | 0.85132 |

#### 5. Compute ΔL', ΔC', ΔH'

| Constant | Expression | Minimum | Maximum | Average | Standard Deviation |
|:--:|:--:|:--:|:--:|:--:|:--:|
| l_delta | `L2 - L1` | -93.514 | 100 | 16.302 | 29.209 |
| c_delta | `c2_prime - c1_prime` | -133.82 | 133.82 | 5.9374 | 37.212 |
| c_product | `c1_prime * c2_prime` | 0 | 17560 | 1526.9 | 1576.7 |
| c_geo_mean | `sqrt(c_product)` | 0 | 132.51 | 34.293 | 18.73 |
| sin_h_diff | `sin(h_diff)` | -1 | 1 | 0.00071587 | 0.67126 |
| h_delta | `2.0 * c_geo_mean * sin_h_diff` | -252.28 | 251.24 | 0.63339 | 50.206 |

#### 6. Compute average L', C', and h'

The light center of gravity of the dataset is located around L* = 60.

| Constant | Expression | Minimum | Maximum | Average | Standard Deviation |
|:--:|:--:|:--:|:--:|:--:|:--:|
| l_avg | `0.5 * (L1 + L2)` | 0.068204 | 99.975 | 60.332 | 16.723 |
| c_sum | `c1_prime + c2_prime` | 1.8835e-7 | 265.04 | 79.163 | 35.506 |

#### 7. Compute weighting functions S_L, S_C, S_H and T

`S_C` has a high variation, which reflects the diversity of saturations in the dataset.

| Constant | Expression | Minimum | Maximum | Average | Standard Deviation |
|:--:|:--:|:--:|:--:|:--:|:--:|
| l_delta_sq | `(l_avg - 50.0) * (l_avg - 50.0)` | 3.738e-22 | 2497.5 | 386.4 | 444.89 |
| s_l_num | `0.015 * l_delta_sq` | 5.607e-24 | 37.463 | 5.796 | 6.6734 |
| s_l_denom | `sqrt(20.0 + l_delta_sq)` | 4.4721 | 50.175 | 17.286 | 10.373 |
| **S_L** | `1.0 + s_l_num / s_l_denom` | 1 | 1.7466448 | 1.2330749 | 0.17061962 |
| **S_C** | `1.0 + 0.0225 * c_sum` | 1 | 6.9633712 | 2.7811621 | 0.79887662 |
| trig_1 | `0.17 * sin(h_mean + pi_over_3)` | -0.17 | 0.17 | 0.055799 | 0.10895 |
| trig_2 | `0.24 * sin(2.0 * h_mean + 0.5 * pi)` | -0.24 | 0.24 | -0.014735 | 0.16933 |
| trig_3 | `0.32 * sin(3.0 * h_mean + 1.6 * pi_over_3)` | -0.32 | 0.32 | -0.0073616 | 0.22615 |
| trig_4 | `0.2 * sin(4.0 * h_mean + 0.15 * pi)` | -0.2 | 0.2 | -0.00045509 | 0.14185 |
| **T** | `1.0 - trig_1 + trig_2 + trig_3 - trig_4` | 0.36205537 | 1.5724717 | 0.92255973 | 0.31404999 |
| **S_H** | `1.0 + 0.0075 * c_sum * T` | 1 | 3.743464 | 1.5400018 | 0.30197822 |

#### 8. Compute rotation term R_T

| Constant | Expression | Minimum | Maximum | Average | Standard Deviation |
|:--:|:--:|:--:|:--:|:--:|:--:|
| c_bar | `0.5 * (c1_prime + c2_prime)` | 9.4177e-8 | 132.52 | 39.581 | 17.753 |
| c_bar_3 | `c_bar * c_bar * c_bar` | 8.3528e-22 | 2.3272e+6 | 1.0218e+5 | 1.3229e+5 |
| c_bar_7 | `c_bar_3 * c_bar_3 * c_bar` | 6.5706e-50 | 7.1772e+14 | 2.0584e+12 | 8.0683e+12 |
| rc_denom | `c_bar_7 + 6103515625.0` | 6.1035e+9 | 7.1773e+14 | 2.0645e+12 | 8.0683e+12 |
| **R_C** | `sqrt(c_bar_7 / rc_denom)` | 3.2810444e-30 | 0.99999575 | 0.82171765 | 0.27953331 |
| theta | `36.0 * h_mean - 55.0 * pi` | -172.77 | 109.91 | -51.385 | 79.218 |
| theta_denom | `-25.0 * pi * pi` | -246.74 | -246.74 | -246.74 | 0 |
| exp_argument | `theta * theta / theta_denom` | -120.98 | -1.582e-12 | -36.135 | 28.935 |
| exp_term | `exp(exp_argument)` | 2.8714e-53 | 1 | 0.054219 | 0.18603 |
| delta_theta | `pi_over_3 * exp_term` | 3.007e-53 | 1.0472 | 0.056778 | 0.19481 |
| sin_term | `sin(delta_theta)` | 3.007e-53 | 0.86603 | 0.05119 | 0.17084 |
| **R_T** | `-2.0 * R_C * sin_term` | -1.7318411 | -1.5043399e-66 | -0.078805176 | 0.28154703 |

#### 9. Normalize ΔL', ΔC', ΔH'

| Constant | Expression | Minimum | Maximum | Average | Standard Deviation |
|:--:|:--:|:--:|:--:|:--:|:--:|
| **L_term** | `l_delta / (k_L * S_L)` | -91.092038 | 100 | 14.110445 | 25.850673 |
| **C_term** | `c_delta / (k_C * S_C)` | -33.363637 | 33.363637 | 1.7503807 | 12.979453 |
| **H_term** | `h_delta / (k_H * S_H)` | -109.55863 | 107.4634 | 0.051742109 | 30.154709 |

#### 10. Combine terms

`H_part` becomes the main contributor to ΔE2000 in many cases, with an average higher than `L_part` and `C_part`.

| Constant | Expression | Minimum | Maximum | Average | Standard Deviation |
|:--:|:--:|:--:|:--:|:--:|:--:|
| **L_part** | `L_term * L_term` | 5.901633e-12 | 10000 | 867.36192 | 1231.7986 |
| **C_part** | `C_term * C_term` | 1.739719e-16 | 1113.1323 | 171.53003 | 188.67964 |
| **H_part** | `H_term * H_term` | 0 | 12003.094 | 909.3091 | 1107.0826 |
| interaction | `C_term * H_term * R_T` | -2022.9 | 1136.6 | -21.092 | 135.9 |
| delta_e_squared | `L_part + C_part + H_part + interaction` | 0.00020596 | 14131 | 1927.1 | 1658.6 |
| **delta_e_2000** | `sqrt(delta_e_squared)` | 0.014351342 | 118.87267 | 39.987305 | 18.114198 |

**Note** : The average value of ΔE2000 around 40 is relatively high, because the benchmark includes very distant color pairs.

### About the Dataset

The data set studied comes from a number of unique palettes that reflect suitable patterns for user interfaces, with neutral tones like gray and beige, bright and saturated colors like red, green and blue, as well as nuanced pastels and intermediate hues like pale and pink.

### Conclusion

This real-world benchmark about color differences offers a way to understand ΔE<sub>00</sub>, it’s relevant to designers, developers, and researchers.

## Hexadecimal Colors ΔE2000's

The following color differences were calculated with the standard illuminant **D65**.

| ΔE<sub>00</sub> | Hex Standard | Hex Sample | RGB Standard | RGB Sample | L\*a\*b\* Standard | L\*a\*b\* Sample |
|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| [0.1](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=90.691&a1=-52.473&b1=-5.9324&L2=90.636&a2=-52.849&b2=-6.019) | #1fe | #0fe | 17, 255, 238 | 0, 255, 238 |  91, -52, -6 | 91, -53, -6 |
| [0.2](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=77.499&a1=-72.336&b1=52.983&L2=77.57&a2=-71.717&b2=53.082) | #0d5 | #1d5 | 0, 221, 85 | 17, 221, 85 |  77, -72, 53 | 78, -72, 53 |
| [0.4](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=28.436&a1=57.179&b1=-85.123&L2=28.12&a2=56.893&b2=-85.658) | #12c | #02c | 17, 34, 204 | 0, 34, 204 |  28, 57, -85 | 28, 57, -86 |
| [0.8](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=77.907&a1=-70.002&b1=70.927&L2=77.551&a2=-73.257&b2=73.486) | #4d2 | #3d1 | 68, 221, 34 | 51, 221, 17 |  78, -70, 71 | 78, -73, 73 |
| [1.6](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=33.565&a1=73.552&b1=-96.081&L2=34.196&a2=76.881&b2=-94.991) | #41e | #50e | 68, 17, 238 | 85, 0, 238 |  34, 74, -96 | 34, 77, -95 |
| [3.2](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=84.052&a1=-62.732&b1=19.865&L2=83.675&a2=-66.803&b2=28.065) | #1ea | #0e9 | 17, 238, 170 | 0, 238, 153 |  84, -63, 20 | 84, -67, 28 |
| [6.4](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=93.877&a1=-36.489&b1=34.039&L2=91.529&a2=-51.514&b2=30.484) | #bfa | #8fa | 187, 255, 170 | 136, 255, 170 |  94, -36, 34 | 92, -52, 30 |
| [12.8](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=69.151&a1=-7.0609&b1=60.022&L2=54.91&a2=-13.509&b2=59.214) | #ba3 | #880 | 187, 170, 51 | 136, 136, 0 |  69, -7, 60 | 55, -14, 59 |
| [25.6](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=58.185&a1=2.2259&b1=63.056&L2=88.349&a2=-1.7752&b2=27.201) | #a80 | #eda | 170, 136, 0 | 238, 221, 170 |  58, 2, 63 | 88, -2, 27 |
| [51.2](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=73.77&a1=38.091&b1=16.478&L2=34.589&a2=65.661&b2=-84.631) | #f99 | #52d | 255, 153, 153 | 85, 34, 221 |  74, 38, 16 | 35, 66, -85 |
| [102.4](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=50.051&a1=84.132&b1=-58.689&L2=78.773&a2=-63.094&b2=76.685) | #c1d | #6d0 | 204, 17, 221 | 102, 221, 0 |  50, 84, -59 | 79, -63, 77 |
| [119.2](https://michel-leonard.github.io/ciede2000-color-matching/lab-color-calculator.html?L1=8.6449&a1=40.408&b1=-55.039&L2=90.912&a2=-60.192&b2=87.037) | #006 | #9f0 | 0, 0, 102 | 153, 255, 0 |  9, 40, -55 | 91, -60, 87 |


