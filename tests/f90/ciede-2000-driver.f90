! Limited Use License – March 1, 2025

! This source code is provided for public use under the following conditions :
! It may be downloaded, compiled, and executed, including in publicly accessible environments.
! Modification is strictly prohibited without the express written permission of the author.

! © Michel Leonard 2025

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

! L1 = 48.36          a1 = -107.453       b1 = -105.8
! L2 = 48.36          a2 = -117.0         b2 = -105.8
! CIE ΔE2000 = ΔE00 = 1.73096511305

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!                         !!!!!!!!!!!!
!!!!!!!!!!!!    CIEDE2000 Driver     !!!!!!!!!!!!
!!!!!!!!!!!!                         !!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

!! Reads a CSV file specified as the first command-line argument. For each line, this program
!! in Fortran displays the original line with the computed Delta E 2000 color difference appended.
!! The C driver can offer CSV files to process and programmatically check the calculations performed there.

!!  Example of a CSV input line : 67.24,-14.22,70,65,8,46
!!    Corresponding output line : 67.24,-14.22,70,65,8,46,15.46723547943141064

program compute_delta_e
  use iso_fortran_env, only: real64
  use ciede_2000_module
  implicit none
  integer, parameter :: dp = kind(1.0d0)
  character(len=256) :: filename
  integer :: iostat, ios
  real(dp) :: lab1(3), lab2(3), delta_e
  character(len=1024) :: line
  integer :: unit
  call get_command_argument(1, filename)
  open(newunit=unit, file=filename, status='old', action='read', iostat=iostat)
  if (iostat /= 0) stop "Error opening file"
  do
    read(unit, '(A)', iostat=ios) line
    if (ios /= 0) exit
    read(line, *) lab1(1), lab1(2), lab1(3), lab2(1), lab2(2), lab2(3)
    delta_e = ciede_2000(lab1(1), lab1(2), lab1(3), lab2(1), lab2(2), lab2(3))
    write(*,'(G0.17,",",G0.17,",",G0.17,",",G0.17,",",G0.17,",",G0.17,",",F0.17)') &
      lab1(1), lab1(2), lab1(3), lab2(1), lab2(2), lab2(3), delta_e
  end do
  close(unit)
end program compute_delta_e
