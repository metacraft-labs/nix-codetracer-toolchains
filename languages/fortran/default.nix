# Fortran toolchain support
#
# Provides GFortran compiler.
#
# Usage:
#   fortranToolchains = import ./languages/fortran { inherit pkgs; };
#   # Then use fortranToolchains.gfortran

{ pkgs }:
{
  # GFortran compiler
  gfortran = pkgs.gfortran;
  default = pkgs.gfortran;
}
