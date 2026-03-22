# Mojo toolchain support
#
# Mojo is distributed by Modular via pixi/conda and is not available in
# nixpkgs (closed-source compiler, proprietary distribution). This module
# provides a helper script that checks for an externally installed Mojo and
# gives installation instructions if not found.
#
# To install Mojo outside of Nix:
#   curl -fsSL https://pixi.sh/install.sh | bash
#   # Create a project with Mojo:
#   mkdir my-mojo-project && cd my-mojo-project
#   pixi init --channel https://conda.modular.com/max-nightly --channel conda-forge
#   pixi add 'max>=26'
#   pixi run mojo --version
#
# On NixOS, the conda-distributed binary requires patchelf or nix-ld.
# When using pixi, set MODULAR_HOME and CONDA_PREFIX for compilation:
#   export CONDA_PREFIX=$PWD/.pixi/envs/default
#   export MODULAR_HOME=$CONDA_PREFIX/share/max
#
# Compile with `--debug-level full` for best debug value extraction.
#
# Usage:
#   mojoToolchains = import ./languages/mojo { inherit pkgs; };
#   # Then use mojoToolchains.default (wrapper that detects external mojo)

{ pkgs }:
let
  mojoWrapper = pkgs.writeShellScriptBin "mojo" ''
    # If CONDA_PREFIX is set (pixi env active), check there first
    if [ -n "$CONDA_PREFIX" ] && [ -x "$CONDA_PREFIX/bin/mojo" ]; then
      exec "$CONDA_PREFIX/bin/mojo" "$@"
    fi

    # Check common Mojo installation locations
    for candidate in \
      "$HOME/.modular/bin/mojo" \
      "$HOME/.magic/bin/mojo" \
      "$(command -v mojo 2>/dev/null || true)"; do
      if [ -x "$candidate" ]; then
        exec "$candidate" "$@"
      fi
    done

    echo "Error: Mojo compiler not found." >&2
    echo "" >&2
    echo "Mojo is not available in nixpkgs. Install it externally:" >&2
    echo "" >&2
    echo "  1. Install pixi (package manager):" >&2
    echo "     curl -fsSL https://pixi.sh/install.sh | bash" >&2
    echo "" >&2
    echo "  2. Create a project with Mojo:" >&2
    echo "     mkdir my-mojo-project && cd my-mojo-project" >&2
    echo "     pixi init --channel https://conda.modular.com/max-nightly --channel conda-forge" >&2
    echo "     pixi add 'max>=26'" >&2
    echo "" >&2
    echo "  3. Use Mojo through pixi:" >&2
    echo "     pixi run mojo --version" >&2
    echo "     pixi run mojo build hello.mojo --debug-level full -o hello" >&2
    echo "" >&2
    echo "  Note: On NixOS, you may need patchelf or nix-ld for the conda binary." >&2
    echo "  Set MODULAR_HOME and CONDA_PREFIX for the compiler to find its stdlib." >&2
    echo "" >&2
    exit 1
  '';
in
{
  # Wrapper that delegates to externally installed Mojo or shows instructions
  default = mojoWrapper;
  latest = mojoWrapper;
  mojo = mojoWrapper;
}
