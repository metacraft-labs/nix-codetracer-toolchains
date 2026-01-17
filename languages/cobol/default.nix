# COBOL toolchain support
#
# Provides GnuCOBOL compiler.
#
# Usage:
#   cobolToolchains = import ./languages/cobol { inherit pkgs; };
#   # Then use cobolToolchains.gnucobol

{pkgs}:
{
  # GnuCOBOL compiler
  gnucobol = pkgs.gnucobol or null;
  default = pkgs.gnucobol or null;
}
