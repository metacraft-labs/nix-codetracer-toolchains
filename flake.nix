{
  description = "CodeTracer Toolchains - Multi-language toolchain management for CodeTracer projects";

  nixConfig = {
    extra-substituters = ["https://metacraft-labs-codetracer.cachix.org"];
    extra-trusted-public-keys = ["metacraft-labs-codetracer.cachix.org-1:6p7pd81m6sIh59yr88yGPU9TFYJZkIrFZoFBWj/y4aE="];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    # Rust toolchain management
    # https://github.com/nix-community/fenix
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Alternative Rust overlay (provides rust-bin interface)
    # https://github.com/oxalica/rust-overlay
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Zig toolchain management
    # https://github.com/mitchellh/zig-overlay
    zig-overlay = {
      url = "github:mitchellh/zig-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nim development tools (langserver, packages)
    nix-nim-development = {
      url = "github:metacraft-labs/nix-nim-development";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-parts,
    fenix,
    rust-overlay,
    zig-overlay,
    nix-nim-development,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      flake = {
        # Export overlays for consumers
        overlays = {
          default = self.overlays.all;

          all = nixpkgs.lib.composeManyExtensions [
            rust-overlay.overlays.default
            zig-overlay.overlays.default
            self.overlays.toolchains
          ];

          toolchains = final: prev: {
            codetracer-toolchains = {
              # Nim versions
              nim = import ./languages/nim {pkgs = final;};

              # Rust versions (via fenix)
              rust = import ./languages/rust {
                pkgs = final;
                fenix = fenix.packages.${final.system};
              };

              # Zig versions (via zig-overlay)
              zig = import ./languages/zig {
                pkgs = final;
                zig-overlay = zig-overlay.packages.${final.system};
              };

              # Go versions
              go = import ./languages/go {pkgs = final;};

              # Python versions
              python = import ./languages/python {pkgs = final;};

              # C/C++ toolchains
              c-cpp = import ./languages/c-cpp {pkgs = final;};

              # D language
              d = import ./languages/d {pkgs = final;};

              # Pascal
              pascal = import ./languages/pascal {pkgs = final;};

              # Crystal
              crystal = import ./languages/crystal {pkgs = final;};

              # Ruby
              ruby = import ./languages/ruby {pkgs = final;};

              # Swift
              swift = import ./languages/swift {pkgs = final;};

              # Fortran
              fortran = import ./languages/fortran {pkgs = final;};

              # Ada
              ada = import ./languages/ada {pkgs = final;};

              # COBOL
              cobol = import ./languages/cobol {pkgs = final;};

              # Assembly toolchains
              asm = import ./languages/asm {pkgs = final;};
            };
          };
        };

        # Export the Nim development flake for langserver etc.
        nimDev = nix-nim-development;
      };

      perSystem = {
        pkgs,
        system,
        ...
      }: let
        toolchains = import ./lib/toolchains.nix {
          inherit pkgs;
          fenix = fenix.packages.${system};
          zig-overlay = zig-overlay.packages.${system};
        };
      in {
        # Export all toolchain packages
        packages =
          toolchains.allPackages
          // {
            default = pkgs.writeShellScriptBin "codetracer-toolchains-info" ''
              echo "CodeTracer Toolchains"
              echo "====================="
              echo ""
              echo "Available language toolchains:"
              echo "  - nim: Nim compiler versions (1.6, 2.0, 2.2)"
              echo "  - rust: Rust toolchains via fenix (stable, nightly, specific versions)"
              echo "  - zig: Zig compiler via zig-overlay (latest, master, specific versions)"
              echo "  - go: Go compiler versions"
              echo "  - python: Python interpreter versions"
              echo "  - c-cpp: C/C++ toolchains (gcc, clang)"
              echo "  - d: D language compiler (dmd, ldc)"
              echo "  - pascal: Free Pascal compiler"
              echo "  - crystal: Crystal compiler"
              echo "  - ruby: Ruby interpreter versions"
              echo "  - swift: Swift compiler"
              echo "  - fortran: GFortran compiler"
              echo "  - ada: GNAT Ada compiler"
              echo "  - cobol: GnuCOBOL compiler"
              echo "  - asm: Assembly toolchains (nasm, cross-compilers)"
              echo ""
              echo "Usage:"
              echo "  Add this flake as an input to your project's flake.nix"
              echo "  Use the overlay or import specific language modules"
            '';
          };

        # Development shell with all toolchains available
        devShells.default = pkgs.mkShell {
          packages = with toolchains; [
            # Core toolchains
            nim.default
            rust.stable
            zig.default
            go.default
            python.default

            # C/C++
            c-cpp.gcc
            c-cpp.clang

            # Other languages
            d.ldc
            pascal.fpc
            crystal.default
            ruby.default
            fortran.gfortran
            ada.gnat
            cobol.gnucobol

            # Assembly
            asm.nasm

            # Utilities
            pkgs.just
            pkgs.figlet
          ];

          shellHook = ''
            figlet "CT Toolchains"
            echo "All CodeTracer language toolchains are available"
          '';
        };

        # Minimal shell for specific language testing
        devShells.minimal = pkgs.mkShell {
          packages = [
            toolchains.nim.default
            toolchains.rust.stable
            pkgs.just
          ];
        };
      };
    };
}
