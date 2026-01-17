# Swift toolchain support
#
# Provides Swift compiler.
# Note: Swift support in nixpkgs is primarily for Linux.
#
# Usage:
#   swiftToolchains = import ./languages/swift { inherit pkgs; };
#   # Then use swiftToolchains.swift

{pkgs}:
{
  # Swift compiler
  swift = pkgs.swift or pkgs.swiftPackages.swift or null;
  default = pkgs.swift or pkgs.swiftPackages.swift or null;

  # Swift package manager
  swiftpm = pkgs.swiftpm or pkgs.swiftPackages.swiftpm or null;
}
