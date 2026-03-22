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
  nim = import ../languages/nim { inherit pkgs; };
  rust = import ../languages/rust { inherit pkgs fenix; };
  zig = import ../languages/zig { inherit pkgs zig-overlay; };
  go = import ../languages/go { inherit pkgs; };
  python = import ../languages/python { inherit pkgs; };
  c-cpp = import ../languages/c-cpp { inherit pkgs; };
  d = import ../languages/d { inherit pkgs; };
  pascal = import ../languages/pascal { inherit pkgs; };
  crystal = import ../languages/crystal { inherit pkgs; };
  ruby = import ../languages/ruby { inherit pkgs; };
  swift = import ../languages/swift { inherit pkgs; };
  fortran = import ../languages/fortran { inherit pkgs; };
  ada = import ../languages/ada { inherit pkgs; };
  cobol = import ../languages/cobol { inherit pkgs; };
  julia = import ../languages/julia { inherit pkgs; };
  asm = import ../languages/asm { inherit pkgs; };
  odin = import ../languages/odin { inherit pkgs; };
  mojo = import ../languages/mojo { inherit pkgs; };
in
{
  # Export all language modules
  inherit
    nim
    rust
    zig
    go
    python
    c-cpp
    d
    pascal
    crystal
    ruby
    swift
    fortran
    ada
    cobol
    julia
    asm
    odin
    mojo
    ;

  # All packages flattened for easy access
  allPackages = {
    # Nim (multi-version)
    nim-1_6 = nim.nim-1_6;
    nim-2_0 = nim.nim-2_0;
    nim-2_2 = nim.nim-2_2;
    nimble = nim.nimble;

    # Rust (multi-version via fenix)
    rust-stable = rust.stable;
    rust-nightly = rust.nightly;
    rust-1_75 = rust.rust-1_75;
    rust-1_80 = rust.rust-1_80;
    rust-1_82 = rust.rust-1_82;
    rust-analyzer = rust.rust-analyzer;

    # Zig (multi-version via zig-overlay)
    zig-default = zig.default;
    zig-master = zig.master;
    zls = zig.zls;

    # Go (multi-version)
    go-default = go.default;
    go_1_24 = go.go_1_24;
    go_1_25 = go.go_1_25;
    gopls = go.gopls;
    delve = go.delve;

    # Python (multi-version)
    python-default = python.default;
    python311 = python.python311;
    python312 = python.python312;
    python313 = python.python313;

    # Ruby (multi-version)
    ruby-default = ruby.default;
    ruby_3_3 = ruby.ruby_3_3;
    ruby_3_4 = ruby.ruby_3_4;

    # C/C++ (multi-version)
    gcc = c-cpp.gcc;
    gcc13 = c-cpp.gcc13;
    gcc14 = c-cpp.gcc14;
    clang = c-cpp.clang;
    clang18 = c-cpp.clang18;
    clang19 = c-cpp.clang19;
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

    # Swift
    swift = swift.default;

    # Fortran
    gfortran = fortran.gfortran;

    # Ada
    gnat = ada.gnat;
    gprbuild = ada.gprbuild;

    # COBOL
    gnucobol = cobol.gnucobol;

    # Julia
    julia-bin = julia.default;
    julia_111-bin = julia.julia_111-bin;
    julia_112-bin = julia.julia_112-bin;

    # Assembly & cross-compilation
    nasm = asm.nasm;
    qemu = asm.qemu;
    gdb = asm.gdb;

    # Odin
    odin = odin.default;

    # Mojo (wrapper — requires external installation via magic CLI)
    mojo = mojo.default;
  };
}
