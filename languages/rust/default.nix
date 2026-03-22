# Rust toolchain multi-version support via fenix
#
# Provides multiple Rust compiler versions using nix-community/fenix.
# Fenix offers stable, nightly, and specific version toolchains.
#
# Usage:
#   rustVersions = import ./languages/rust { inherit pkgs fenix; };
#   # Then use rustVersions.stable, rustVersions.nightly, etc.

{ pkgs, fenix }:
let
  # Create a complete toolchain from a fenix channel
  mkRustToolchain =
    channel:
    channel.withComponents [
      "cargo"
      "clippy"
      "rust-src"
      "rustc"
      "rustfmt"
    ];

  # Specific versions we want to support for testing
  specificVersions = {
    "1.75.0" = fenix.toolchainOf {
      channel = "1.75.0";
      sha256 = "sha256-SXRtAuO4IqNOQq+nLbrsDFbVk+3aVA8NNpSZsKlVH/8=";
    };
    "1.80.0" = fenix.toolchainOf {
      channel = "1.80.0";
      sha256 = "sha256-6eN/GKzjVSjEhGO9FhWObkRFaE1Jf+uqMSdQnb8lcB4=";
    };
    "1.82.0" = fenix.toolchainOf {
      channel = "1.82.0";
      sha256 = "sha256-yMuSb5eQPO/bHv+Bcf/US8LVMbf/G/0MSfiPwBhiPpk=";
    };
  };
in
{
  # Current stable channel
  stable = mkRustToolchain fenix.stable;
  rust-stable = mkRustToolchain fenix.stable;

  # Nightly channel
  nightly = mkRustToolchain fenix.latest;
  rust-nightly = mkRustToolchain fenix.latest;

  # Specific versions for reproducible testing
  rust-1_75 = mkRustToolchain specificVersions."1.75.0";
  rust-1_80 = mkRustToolchain specificVersions."1.80.0";
  rust-1_82 = mkRustToolchain specificVersions."1.82.0";

  # Default to stable
  default = mkRustToolchain fenix.stable;
  latest = mkRustToolchain fenix.stable;

  # Rust analyzer
  rust-analyzer = fenix.rust-analyzer;

  # For programmatic access
  inherit specificVersions mkRustToolchain;

  # Raw fenix access for advanced usage
  fenix = fenix;
}
