# Zig toolchain multi-version support via zig-overlay
#
# Provides multiple Zig compiler versions using mitchellh/zig-overlay.
# Supports released versions and nightly builds.
#
# Usage:
#   zigVersions = import ./languages/zig { inherit pkgs zig-overlay; };
#   # Then use zigVersions.default, zigVersions.master, etc.

{ pkgs, zig-overlay }:
{
  # Latest stable release
  default = zig-overlay.default;
  latest = zig-overlay.default;

  # Master/nightly (updated daily)
  master = zig-overlay.master;
  nightly = zig-overlay.master;

  # Specific versions (available in zig-overlay)
  # Note: Available versions depend on what zig-overlay provides
  zig-0_11 = zig-overlay."0.11.0" or zig-overlay.default;
  zig-0_12 = zig-overlay."0.12.0" or zig-overlay.default;
  zig-0_13 = zig-overlay."0.13.0" or zig-overlay.default;
  zig-0_14 = zig-overlay."0.14.0" or zig-overlay.default;

  # Zls language server (from nixpkgs)
  zls = pkgs.zls;

  # For programmatic access - raw overlay packages
  overlay = zig-overlay;
}
