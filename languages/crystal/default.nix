# Crystal toolchain support
#
# Provides Crystal compiler and Shards package manager.
#
# Usage:
#   crystalToolchains = import ./languages/crystal { inherit pkgs; };
#   # Then use crystalToolchains.crystal

{pkgs}:
{
  # Crystal compiler
  crystal = pkgs.crystal;
  default = pkgs.crystal;

  # Shards package manager
  shards = pkgs.shards;
}
