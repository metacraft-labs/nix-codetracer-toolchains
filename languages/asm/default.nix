# Assembly toolchain support
#
# Provides assemblers and cross-compilers for various architectures.
#
# Usage:
#   asmToolchains = import ./languages/asm { inherit pkgs; };
#   # Then use asmToolchains.nasm, asmToolchains.arm64-cross, etc.

{pkgs}:
{
  # x86/x86_64 assemblers
  nasm = pkgs.nasm;
  yasm = pkgs.yasm or pkgs.nasm;

  # Default assembler
  default = pkgs.nasm;

  # Cross-compilation toolchains
  # ARM64
  arm64-cross = pkgs.pkgsCross.aarch64-multiplatform.buildPackages.gcc or null;
  arm64-binutils = pkgs.pkgsCross.aarch64-multiplatform.buildPackages.binutils or null;

  # RISC-V
  riscv64-cross = pkgs.pkgsCross.riscv64.buildPackages.gcc or null;
  riscv64-binutils = pkgs.pkgsCross.riscv64.buildPackages.binutils or null;

  # ARM (32-bit)
  arm-cross = pkgs.pkgsCross.arm-embedded.buildPackages.gcc or null;

  # Emulators for testing
  qemu = pkgs.qemu;
  qemu-user = pkgs.qemu;

  # Debugging
  gdb = pkgs.gdb;
  gdb-multiarch = pkgs.gdb or pkgs.gdb;
}
