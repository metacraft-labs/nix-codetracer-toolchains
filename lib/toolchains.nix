# Toolchains aggregation module
#
# This module provides a unified interface to all language toolchains,
# making it easy to access any toolchain from a single import.

{
  pkgs,
  fenix,
  zig-overlay,
}:
let
  nim = import ../languages/nim {inherit pkgs;};
  rust = import ../languages/rust {inherit pkgs fenix;};
  zig = import ../languages/zig {inherit pkgs zig-overlay;};
  go = import ../languages/go {inherit pkgs;};
  python = import ../languages/python {inherit pkgs;};
  c-cpp = import ../languages/c-cpp {inherit pkgs;};
  d = import ../languages/d {inherit pkgs;};
  pascal = import ../languages/pascal {inherit pkgs;};
  crystal = import ../languages/crystal {inherit pkgs;};
  ruby = import ../languages/ruby {inherit pkgs;};
  swift = import ../languages/swift {inherit pkgs;};
  fortran = import ../languages/fortran {inherit pkgs;};
  ada = import ../languages/ada {inherit pkgs;};
  cobol = import ../languages/cobol {inherit pkgs;};
  asm = import ../languages/asm {inherit pkgs;};
in {
  # Export all language modules
  inherit nim rust zig go python c-cpp d pascal crystal ruby swift fortran ada cobol asm;

  # All packages flattened for easy access
  allPackages = {
    # Nim
    nim-1_6 = nim.nim-1_6;
    nim-2_0 = nim.nim-2_0;
    nim-2_2 = nim.nim-2_2;
    nimble = nim.nimble;

    # Rust
    rust-stable = rust.stable;
    rust-nightly = rust.nightly;
    rust-1_75 = rust.rust-1_75;
    rust-1_80 = rust.rust-1_80;
    rust-1_82 = rust.rust-1_82;
    rust-analyzer = rust.rust-analyzer;

    # Zig
    zig-default = zig.default;
    zig-master = zig.master;
    zls = zig.zls;

    # Go
    go-default = go.default;
    gopls = go.gopls;
    delve = go.delve;

    # Python
    python-default = python.default;
    python311 = python.python311;
    python312 = python.python312;

    # C/C++
    gcc = c-cpp.gcc;
    clang = c-cpp.clang;
    llvm = c-cpp.llvm;
    lldb = c-cpp.lldb;
    cmake = c-cpp.cmake;

    # D
    ldc = d.ldc;
    dub = d.dub;

    # Pascal
    fpc = pascal.fpc;

    # Crystal
    crystal = crystal.default;

    # Ruby
    ruby = ruby.default;

    # Swift
    swift = swift.default;

    # Fortran
    gfortran = fortran.gfortran;

    # Ada
    gnat = ada.gnat;

    # COBOL
    gnucobol = cobol.gnucobol;

    # Assembly
    nasm = asm.nasm;
    qemu = asm.qemu;
  };
}
