# Python toolchain multi-version support
#
# Provides multiple Python interpreter versions from nixpkgs.
#
# Usage:
#   pythonVersions = import ./languages/python { inherit pkgs; };
#   # Then use pythonVersions.default, pythonVersions.python311, etc.

{pkgs}:
{
  # Default Python version
  default = pkgs.python3;
  latest = pkgs.python3;

  # Specific versions
  python39 = pkgs.python39 or pkgs.python3;
  python310 = pkgs.python310 or pkgs.python3;
  python311 = pkgs.python311 or pkgs.python3;
  python312 = pkgs.python312 or pkgs.python3;
  python313 = pkgs.python313 or pkgs.python3;

  # Development tools
  black = pkgs.black;
  ruff = pkgs.ruff;
  mypy = pkgs.mypy;
  pytest = pkgs.python3Packages.pytest;

  # Convenient alias
  python = pkgs.python3;
  python3 = pkgs.python3;
}
