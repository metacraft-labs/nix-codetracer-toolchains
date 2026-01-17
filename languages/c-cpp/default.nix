# C/C++ toolchain support
#
# Provides GCC and Clang toolchains with various versions.
#
# Usage:
#   ccppToolchains = import ./languages/c-cpp { inherit pkgs; };
#   # Then use ccppToolchains.gcc, ccppToolchains.clang, etc.

{pkgs}:
{
  # GCC toolchains
  gcc = pkgs.gcc;
  gcc13 = pkgs.gcc13 or pkgs.gcc;
  gcc14 = pkgs.gcc14 or pkgs.gcc;

  # Clang toolchains
  clang = pkgs.clang;
  clang18 = pkgs.clang_18 or pkgs.clang;
  clang19 = pkgs.clang_19 or pkgs.clang;

  # LLVM toolchain
  llvm = pkgs.llvm;
  lldb = pkgs.lldb;

  # Build tools
  cmake = pkgs.cmake;
  ninja = pkgs.ninja;
  gnumake = pkgs.gnumake;
  pkg-config = pkgs.pkg-config;

  # Testing frameworks
  gtest = pkgs.gtest;
  criterion = pkgs.criterion or null;

  # Analysis tools
  valgrind = pkgs.valgrind;

  # Default compilers
  default-c = pkgs.gcc;
  default-cpp = pkgs.gcc;
}
