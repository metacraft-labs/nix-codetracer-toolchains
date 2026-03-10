# nix-codetracer-toolchains

A Nix flake providing unified multi-language toolchain management for CodeTracer projects.

## Overview

This flake composes multiple popular language-specific Nix flakes and provides consistent multi-version support for all programming languages used in CodeTracer testing and development.

## Supported Languages

| Language | Source | Multi-version |
|----------|--------|---------------|
| **Rust** | [nix-community/fenix](https://github.com/nix-community/fenix) | Yes (stable, nightly, specific versions) |
| **Zig** | [mitchellh/zig-overlay](https://github.com/mitchellh/zig-overlay) | Yes (releases, master/nightly) |
| **Nim** | Custom (nixpkgs-based) | Yes (1.6, 2.0, 2.2) |
| **Go** | nixpkgs | Yes (1.21-1.24) |
| **Python** | nixpkgs | Yes (3.9-3.13) |
| **Ruby** | nixpkgs | Yes (3.1-3.3) |
| **C/C++** | nixpkgs | Yes (GCC 13/14, Clang 18/19) |
| **D** | nixpkgs | DMD, LDC |
| **Pascal** | nixpkgs | Free Pascal Compiler |
| **Crystal** | nixpkgs | Latest |
| **Swift** | nixpkgs | Latest |
| **Fortran** | nixpkgs | GFortran |
| **Ada** | nixpkgs | GNAT |
| **COBOL** | nixpkgs | GnuCOBOL |
| **Assembly** | nixpkgs | NASM + cross-compilers |
| **Odin** | nixpkgs | Latest |
| **Mojo** | External (Modular magic CLI) | Wrapper with install instructions |

## Usage

### As a Flake Input

Add to your `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    codetracer-toolchains.url = "github:metacraft-labs/nix-codetracer-toolchains";
  };

  outputs = { nixpkgs, codetracer-toolchains, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ codetracer-toolchains.overlays.default ];
      };
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          pkgs.codetracer-toolchains.nim.nim-2_2
          pkgs.codetracer-toolchains.rust.stable
          pkgs.codetracer-toolchains.zig.default
        ];
      };
    };
}
```

### Using the Overlay

The flake provides several overlays:

- `overlays.default` / `overlays.all` - Includes all toolchains and upstream overlays
- `overlays.toolchains` - Only the `codetracer-toolchains` attribute set

### Direct Package Access

```nix
# In your flake
codetracer-toolchains.packages.${system}.nim-2_2
codetracer-toolchains.packages.${system}.rust-stable
codetracer-toolchains.packages.${system}.zig-default
```

### Development Shell

Enter a shell with all toolchains:

```bash
nix develop github:metacraft-labs/nix-codetracer-toolchains
```

## Language Modules

Each language has its own module in `languages/<lang>/default.nix`:

### Nim

```nix
pkgs.codetracer-toolchains.nim.nim-1_6   # Nim 1.6.20
pkgs.codetracer-toolchains.nim.nim-2_0   # Nim 2.0.14
pkgs.codetracer-toolchains.nim.nim-2_2   # Nim 2.2.4
pkgs.codetracer-toolchains.nim.default   # Latest (2.2.4)
pkgs.codetracer-toolchains.nim.nimble    # Nimble package manager
```

### Rust (via fenix)

```nix
pkgs.codetracer-toolchains.rust.stable      # Current stable
pkgs.codetracer-toolchains.rust.nightly     # Latest nightly
pkgs.codetracer-toolchains.rust.rust-1_75   # Specific version
pkgs.codetracer-toolchains.rust.rust-1_80
pkgs.codetracer-toolchains.rust.rust-1_82
pkgs.codetracer-toolchains.rust.rust-analyzer
```

### Zig (via zig-overlay)

```nix
pkgs.codetracer-toolchains.zig.default   # Latest release
pkgs.codetracer-toolchains.zig.master    # Latest nightly
pkgs.codetracer-toolchains.zig.zig-0_13  # Specific version
pkgs.codetracer-toolchains.zig.zls       # Zig language server
```

### C/C++

```nix
pkgs.codetracer-toolchains.c-cpp.gcc      # Default GCC
pkgs.codetracer-toolchains.c-cpp.gcc14    # GCC 14
pkgs.codetracer-toolchains.c-cpp.clang    # Default Clang
pkgs.codetracer-toolchains.c-cpp.clang19  # Clang 19
pkgs.codetracer-toolchains.c-cpp.llvm
pkgs.codetracer-toolchains.c-cpp.lldb
pkgs.codetracer-toolchains.c-cpp.cmake
```

### Assembly (with cross-compilation)

```nix
pkgs.codetracer-toolchains.asm.nasm           # x86/x64 assembler
pkgs.codetracer-toolchains.asm.arm64-cross    # ARM64 cross-compiler
pkgs.codetracer-toolchains.asm.riscv64-cross  # RISC-V cross-compiler
pkgs.codetracer-toolchains.asm.qemu           # Emulator for testing
```

## Adding New Versions

### Nim

Edit `languages/nim/default.nix` and add to the `versions` attribute:

```bash
# Get the hash for a new version
nix-prefetch-url https://nim-lang.org/download/nim-X.Y.Z.tar.xz
nix hash convert --hash-algo sha256 --to sri <hash>
```

### Rust

Add to `specificVersions` in `languages/rust/default.nix`:

```nix
"1.86.0" = fenix.toolchainOf {
  channel = "1.86.0";
  sha256 = "sha256-...";
};
```

## Related Projects

- [nix-nim-development](https://github.com/metacraft-labs/nix-nim-development) - Nim langserver and packages
- [nix-community/fenix](https://github.com/nix-community/fenix) - Rust toolchains
- [mitchellh/zig-overlay](https://github.com/mitchellh/zig-overlay) - Zig toolchains
- [oxalica/rust-overlay](https://github.com/oxalica/rust-overlay) - Alternative Rust overlay

## License

MIT
