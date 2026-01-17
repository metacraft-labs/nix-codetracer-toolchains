# Pascal toolchain support
#
# Provides Free Pascal Compiler.
#
# Usage:
#   pascalToolchains = import ./languages/pascal { inherit pkgs; };
#   # Then use pascalToolchains.fpc

{pkgs}:
{
  # Free Pascal Compiler
  fpc = pkgs.fpc;
  default = pkgs.fpc;

  # Lazarus IDE (optional)
  lazarus = pkgs.lazarus or null;
}
