# Ada toolchain support
#
# Provides GNAT Ada compiler and GPRBuild.
#
# Usage:
#   adaToolchains = import ./languages/ada { inherit pkgs; };
#   # Then use adaToolchains.gnat

{pkgs}:
{
  # GNAT Ada compiler (part of GCC)
  gnat = pkgs.gnat or pkgs.gnatPackages.gnat or null;
  default = pkgs.gnat or pkgs.gnatPackages.gnat or null;

  # GPRBuild project manager
  gprbuild = pkgs.gprbuild or pkgs.gnatPackages.gprbuild or null;
}
