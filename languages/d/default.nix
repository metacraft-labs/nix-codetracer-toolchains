# D language toolchain support
#
# Provides DMD and LDC D compilers.
#
# Usage:
#   dToolchains = import ./languages/d { inherit pkgs; };
#   # Then use dToolchains.dmd, dToolchains.ldc, etc.

{pkgs}:
{
  # LDC (LLVM-based D compiler) - recommended
  ldc = pkgs.ldc;
  default = pkgs.ldc;

  # DMD (reference D compiler)
  dmd = pkgs.dmd or pkgs.ldc;

  # Package manager
  dub = pkgs.dub;
}
