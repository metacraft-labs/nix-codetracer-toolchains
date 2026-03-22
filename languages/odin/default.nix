# Odin toolchain support
#
# Provides the Odin compiler from nixpkgs. Odin compiles via LLVM and
# produces native binaries with DWARF debug info.
# Compile with `-debug -o:none` for best debug value extraction.
#
# Usage:
#   odinToolchains = import ./languages/odin { inherit pkgs; };
#   # Then use odinToolchains.default

{ pkgs }:
{
  # Odin compiler (latest from nixpkgs)
  default = pkgs.odin;
  latest = pkgs.odin;
  odin = pkgs.odin;
}
