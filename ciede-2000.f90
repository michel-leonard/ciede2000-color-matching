! This function written in Fortran is not affiliated with the CIE (International Commission on Illumination),
! and is released into the public domain. It is provided "as is" without any warranty, express or implied.

module ciede_2000_module
  use iso_fortran_env, only: real64
  implicit none
  private
  public :: ciede_2000
  real(kind=real64), parameter :: M_PI = 3.14159265358979323846264338328_real64
    ! k_l, k_c, k_h are parametric factors to be adjusted according to
    ! different viewing parameters such as textures, backgrounds...
  real(kind=real64), parameter :: k_l = 1.0_real64, k_c = 1.0_real64, k_h = 1.0_real64
contains
  ! The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
  ! "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
  function ciede_2000(l_1, a_1, b_1, l_2, a_2, b_2) result(delta_e)
    implicit none
    real(kind=real64), intent(in) :: l_1, a_1, b_1, l_2, a_2, b_2
    real(kind=real64) :: n, c_1, c_2, h_1, h_2, h_m, h_d, p, r_t, l, t, h, c, delta_e
    ! Working in Fortran with the CIEDE2000 color-difference formula.
    n = (sqrt(a_1 * a_1 + b_1 * b_1) + sqrt(a_2 * a_2 + b_2 * b_2)) * 0.5_real64
    n = n * n * n * n * n * n * n
    ! A factor involving chroma raised to the power of 7 designed to make
    ! the influence of chroma on the total color difference more accurate.
    n = 1.0_real64 + 0.5_real64 * (1.0_real64 - sqrt(n / (n + 6103515625.0_real64)))
    ! Since hypot is not available, sqrt is used here to calculate the
    ! Euclidean distance, without avoiding overflow/underflow.
    c_1 = sqrt(a_1 * a_1 * n * n + b_1 * b_1)
    c_2 = sqrt(a_2 * a_2 * n * n + b_2 * b_2)
    ! atan2 is preferred over atan because it accurately computes the angle of
    ! a point (x, y) in all quadrants, handling the signs of both coordinates.
    h_1 = atan2(b_1, a_1 * n)
    h_2 = atan2(b_2, a_2 * n)
    if (h_1 < 0.0_real64) h_1 = h_1 + 2.0_real64 * M_PI
    if (h_2 < 0.0_real64) h_2 = h_2 + 2.0_real64 * M_PI
    n = abs(h_2 - h_1)
    ! Cross-implementation consistent rounding.
    if (M_PI - 1D-14 < n .and. n < M_PI + 1D-14) n = M_PI
    ! When the hue angles lie in different quadrants, the straightforward
    ! average can produce a mean that incorrectly suggests a hue angle in
    ! the wrong quadrant, the next lines handle this issue.
    h_m = (h_1 + h_2) * 0.5_real64
    h_d = (h_2 - h_1) * 0.5_real64
    if (M_PI < n) then
      if (0.0_real64 < h_d) then
        h_d = h_d - M_PI
      else
        h_d = h_d + M_PI
      endif
      h_m = h_m + M_PI
    endif
    p = 36.0_real64 * h_m - 55.0_real64 * M_PI
    n = (c_1 + c_2) * 0.5_real64
    n = n * n * n * n * n * n * n
    ! The hue rotation correction term is designed to account for the
    ! non-linear behavior of hue differences in the blue region.
    r_t = -2.0_real64 * sqrt(n / (n + 6103515625.0_real64)) &
                        * sin(M_PI / 3.0_real64 * exp(p * p / (-25.0_real64 * M_PI * M_PI)))
    n = (l_1 + l_2) * 0.5_real64
    n = (n - 50.0_real64) * (n - 50.0_real64)
    ! Lightness.
    l = (l_2 - l_1) / (k_l * (1.0_real64 + 0.015_real64 * n / sqrt(20.0_real64 + n)))
    ! These coefficients adjust the impact of different harmonic
    ! components on the hue difference calculation.
    t = 1.0_real64   + 0.24_real64 * sin(2.0_real64 * h_m + M_PI / 2.0_real64) &
                     + 0.32_real64 * sin(3.0_real64 * h_m + 8.0_real64 * M_PI / 15.0_real64) &
                     - 0.17_real64 * sin(h_m + M_PI / 3.0_real64) &
                     - 0.20_real64 * sin(4.0_real64 * h_m + 3.0_real64 * M_PI / 20.0_real64)
    n = c_1 + c_2
    ! Hue.
    h = 2.0_real64 * sqrt(c_1 * c_2) * sin(h_d) / (k_h * (1.0_real64 + 0.0075_real64 * n * t))
    ! Chroma.
    c = (c_2 - c_1) / (k_c * (1.0_real64 + 0.0225_real64 * n))
    ! Returns the square root so that the Delta E 2000 reflects the actual geometric
    ! distance within the color space, which ranges from 0 to approximately 185.
    delta_e = sqrt(l * l + h * h + c * c + c * h * r_t)
  end function ciede_2000
end module ciede_2000_module

! GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
!  More Examples : https://michel-leonard.github.io/ciede2000-color-matching/discovery-generator.html

! L1 = 18.0           a1 = -39.8987       b1 = 56.8
! L2 = 18.02          a2 = -39.8987       b2 = 56.8
! CIE ΔE2000 = ΔE00 = 0.01355722031

! L1 = 91.83          a1 = 89.1897        b1 = -72.12
! L2 = 91.83          a2 = 89.1897        b2 = -72.24
! CIE ΔE2000 = ΔE00 = 0.03620253845

! L1 = 61.386         a1 = -120.0413      b1 = 14.887
! L2 = 61.386         a2 = -120.0413      b2 = 11.1
! CIE ΔE2000 = ΔE00 = 1.29792653441

! L1 = 41.0           a1 = 100.0          b1 = -22.7
! L2 = 44.6862        a2 = 88.8           b2 = -49.8837
! CIE ΔE2000 = ΔE00 = 9.8804682589

! L1 = 80.521         a1 = -62.0          b1 = -30.9
! L2 = 70.42          a2 = -93.557        b2 = -31.0
! CIE ΔE2000 = ΔE00 = 10.79954789222

! L1 = 49.3           a1 = -53.5875       b1 = 36.712
! L2 = 40.33          a2 = -86.0          b2 = 94.0
! CIE ΔE2000 = ΔE00 = 16.06060528326

! L1 = 39.604         a1 = -1.7           b1 = 85.5536
! L2 = 21.0           a2 = -24.2          b2 = 101.4
! CIE ΔE2000 = ΔE00 = 18.04965260601

! L1 = 37.0           a1 = 58.91          b1 = -112.86
! L2 = 16.3553        a2 = 22.0           b2 = -102.9679
! CIE ΔE2000 = ΔE00 = 22.89129144281

! L1 = 34.0           a1 = -122.181       b1 = 66.2
! L2 = 84.1           a2 = 90.0           b2 = -11.0
! CIE ΔE2000 = ΔE00 = 119.06360362871

! L1 = 24.8           a1 = -89.064        b1 = -36.424
! L2 = 59.2022        a2 = 114.0          b2 = 14.103
! CIE ΔE2000 = ΔE00 = 129.94579019201
