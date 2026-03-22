# Nim compiler multi-version support
#
# Provides multiple Nim compiler versions for testing and development.
# This module is the canonical source for Nim version management in CodeTracer.
#
# Usage:
#   nimVersions = import ./languages/nim { inherit pkgs; };
#   # Then use nimVersions.nim-1_6, nimVersions.nim-2_0, etc.
#
# Or add to shell packages:
#   packages = [ nimVersions.nim-1_6 nimVersions.nim-2_2 ];

{ pkgs }:
let
  # Nim versions and their corresponding hashes
  # To add a new version:
  #   nix-prefetch-url https://nim-lang.org/download/nim-X.Y.Z.tar.xz
  #   nix hash convert --hash-algo sha256 --to sri <hash>
  versions = {
    "1.6.20" = "sha256-/+0EdQTR/K9hDw3Xzz4Ce+kaKSsMnFEWFQTC87mE/7k=";
    "2.0.14" = "sha256-1CC5VYMylLeGHj+2UCHawm0cGcUoxNbhOczTeeLBWkM=";
    "2.2.6" = "sha256-ZXsOPV3veIFI0qh/phI/p1Wy2SytMe9g/SYeRReFUos=";
    "2.2.8" = "sha256-EUGRr6CDxQWdy+XOiNvk9CVCz/BOLDAXZo7kOLwLjPw=";
  };

  # Build Nim for a specific version
  mkNim =
    version: hash:
    pkgs.nim-unwrapped.overrideAttrs (old: {
      inherit version;
      pname = "nim";
      src = pkgs.fetchurl {
        url = "https://nim-lang.org/download/nim-${version}.tar.xz";
        inherit hash;
      };
      # Clear nixpkgs patches - they're version-specific and don't apply to other versions.
      # Add back per-version patches as needed.
      patches = pkgs.lib.optionals (builtins.compareVersions version "2.2.8" >= 0) [
        # Fix cstring-to-string implicit conversion removed in 2.2.8
        ./excpt-cstring.patch
      ];
    });
in
{
  # Specific versions
  nim-1_6 = mkNim "1.6.20" versions."1.6.20";
  nim-1_6_20 = mkNim "1.6.20" versions."1.6.20";
  nim-2_0 = mkNim "2.0.14" versions."2.0.14";
  nim-2_0_14 = mkNim "2.0.14" versions."2.0.14";
  nim-2_2 = mkNim "2.2.8" versions."2.2.8";
  nim-2_2_6 = mkNim "2.2.6" versions."2.2.6";
  nim-2_2_8 = mkNim "2.2.8" versions."2.2.8";

  # Convenient aliases
  nim1 = mkNim "1.6.20" versions."1.6.20";
  nim2 = mkNim "2.2.8" versions."2.2.8";
  latest = mkNim "2.2.8" versions."2.2.8";
  default = mkNim "2.2.8" versions."2.2.8";

  # Nimble package manager (from nixpkgs)
  nimble = pkgs.nimble;

  # For programmatic access
  inherit versions mkNim;
}
