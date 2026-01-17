# Go toolchain multi-version support
#
# Provides multiple Go compiler versions from nixpkgs.
#
# Usage:
#   goVersions = import ./languages/go { inherit pkgs; };
#   # Then use goVersions.default, goVersions.go_1_21, etc.

{pkgs}:
{
  # Default Go version (latest stable in nixpkgs)
  default = pkgs.go;
  latest = pkgs.go;

  # Specific versions available in nixpkgs
  go_1_21 = pkgs.go_1_21 or pkgs.go;
  go_1_22 = pkgs.go_1_22 or pkgs.go;
  go_1_23 = pkgs.go_1_23 or pkgs.go;
  go_1_24 = pkgs.go_1_24 or pkgs.go;

  # Development tools
  gopls = pkgs.gopls;
  delve = pkgs.delve;
  golangci-lint = pkgs.golangci-lint;

  # Convenient alias
  go = pkgs.go;
}
