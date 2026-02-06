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
    ! Application of the chroma correction factor.
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
    if (M_PI - 0.00000000000001_real64 < n .and. n < M_PI + 0.00000000000001_real64) n = M_PI
    ! When the hue angles lie in different quadrants, the straightforward
    ! average can produce a mean that incorrectly suggests a hue angle in
    ! the wrong quadrant, the next lines handle this issue.
    h_m = (h_1 + h_2) * 0.5_real64
    h_d = (h_2 - h_1) * 0.5_real64
    if (M_PI < n) then
      h_d = h_d + M_PI
      ! 📜 Sharma’s formulation doesn’t use the next line, but the one after it,
      ! and these two variants differ by ±0.0003 on the final color differences.
      h_m = h_m + M_PI
      ! h_m = h_m + MERGE(M_PI, -M_PI, h_m < M_PI)
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
    ! Returning the square root ensures that dE00 accurately reflects the
    ! geometric distance in color space, which can range from 0 to around 185.
    delta_e = sqrt(l * l + h * h + c * c + c * h * r_t)
  end function ciede_2000
end module ciede_2000_module

! GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
!   Online Tests : https://michel-leonard.github.io/ciede2000-color-matching

! L1 = 60.6   a1 = 17.4   b1 = 5.1
! L2 = 62.5   a2 = 12.6   b2 = -3.6
! CIE ΔE00 = 7.1512209855 (Bruce Lindbloom, Netflix’s VMAF, ...)
! CIE ΔE00 = 7.1512354287 (Gaurav Sharma, OpenJDK, ...)
! Deviation between implementations ≈ 1.4e-5

! See the source code comments for easy switching between these two widely used ΔE*00 implementation variants.

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!                                 !!!!!!!
!!!!!!!           CIEDE 2000            !!!!!!!
!!!!!!!      Testing Random Colors      !!!!!!!
!!!!!!!                                 !!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! This Fortran program outputs a CSV file to standard output, with its length determined by the first CLI argument.
! Each line contains seven columns :
! - Three columns for the random standard L*a*b* color
! - Three columns for the random sample L*a*b* color
! - And the seventh column for the precise Delta E 2000 color difference between the standard and sample
! The output will be correct, this can be verified :
! - With the C driver, which provides a dedicated verification feature
! - By using the JavaScript validator at https://michel-leonard.github.io/ciede2000-color-matching

program test_ciede_2000
  use iso_fortran_env, only: real64
  use ciede_2000_module
  implicit none
  integer :: n_iterations, i, cmd_stat
  real(kind=real64) :: l_1, a_1, b_1, l_2, a_2, b_2, delta_e
  character(len=32) :: arg
  integer :: arg_int
  call random_seed()

  n_iterations = 10000.0

  if (command_argument_count() >= 1) then
    call get_command_argument(1, arg)
    read(arg, *, iostat=cmd_stat) arg_int
    if (cmd_stat == 0 .and. arg_int > 0) n_iterations = arg_int
  endif

  do i = 1, n_iterations
    call generate_value(0.0_real64, 100.0_real64, l_1)
    call generate_value(-128.0_real64, 128.0_real64, a_1)
    call generate_value(-128.0_real64, 128.0_real64, b_1)
    call generate_value(0.0_real64, 100.0_real64, l_2)
    call generate_value(-128.0_real64, 128.0_real64, a_2)
    call generate_value(-128.0_real64, 128.0_real64, b_2)

    delta_e = ciede_2000(l_1, a_1, b_1, l_2, a_2, b_2)
    write(*,'(6(f0.6,","),f0.15)') l_1, a_1, b_1, l_2, a_2, b_2, delta_e
  end do
contains
  subroutine generate_value(min_val, max_val, result)
    real(kind=real64), intent(in) :: min_val, max_val
    real(kind=real64), intent(out) :: result
    real(kind=real64) :: r
    integer :: decimals

    call random_number(r)
    result = min_val + r * (max_val - min_val)

    call random_number(r)
    decimals = int(r * 3)

    select case (decimals)
    case (0)
      result = dble(nint(result))
    case (1)
      result = nint(result * 10_real64) / 10_real64
    case (2)
      result = nint(result * 100_real64) / 100_real64
    end select
  end subroutine generate_value
end program test_ciede_2000

! Compiled using :
! - gfortran-14 -std=f2008 -Wall -Wextra -pedantic -O3 -o ciede-2000-test ciede-2000-random.f90
