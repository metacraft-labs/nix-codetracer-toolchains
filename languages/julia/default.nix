# Julia toolchain multi-version support
#
# Provides Julia interpreter versions from nixpkgs.
# Julia uses JIT compilation via LLVM; no separate build step is needed.
# For debug value extraction, run with `-g2` for full DWARF debug info.
#
# Usage:
#   juliaVersions = import ./languages/julia { inherit pkgs; };
#   # Then use juliaVersions.default, juliaVersions.julia_111-bin, etc.

{ pkgs }:
{
  # Default Julia version (latest stable binary)
  default = pkgs.julia-bin;
  latest = pkgs.julia-bin;

  # Specific versions (binary distributions, most reliable on NixOS)
  julia_111-bin = pkgs.julia_111-bin; # Julia 1.11.x LTS
  julia_112-bin = pkgs.julia_112-bin; # Julia 1.12.x

  # Built-from-source variants (may have linking issues on NixOS)
  julia = pkgs.julia;

  # Convenient alias
  julia-bin = pkgs.julia-bin;
}
