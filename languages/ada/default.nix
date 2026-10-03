# Native Ada compiler and GPRBuild; preserve existing producers elsewhere.
{ pkgs }:
let
  nativeAppleSilicon = pkgs.stdenv.hostPlatform.system == "aarch64-darwin";
  bootstrap = pkgs.wrapCCWith {
    cc = pkgs.callPackage ./native-bootstrap.nix { majorVersion = "13"; };
    bintools = pkgs.bintoolsDualAs;
  };
  # These are the exact pinned nixpkgs gnat13 producer arguments. The
  # existing Darwin x86 stdenv override does not apply on Apple Silicon.
  compiler = pkgs.wrapCC (
    pkgs.gcc13.cc.override {
      name = "gnat";
      langC = true;
      langCC = false;
      langAda = true;
      profiledCompiler = false;
      gnat-bootstrap = bootstrap;
      stdenv = pkgs.stdenv;
    }
  );
  packages = pkgs.callPackage (pkgs.path + "/pkgs/top-level/ada-packages.nix") {
    gnat = compiler;
  };
in
if nativeAppleSilicon then
  {
    gnat = compiler;
    default = compiler;
    gprbuild = packages.gprbuild;
  }
else
  {
    gnat = pkgs.gnat or pkgs.gnatPackages.gnat or null;
    default = pkgs.gnat or pkgs.gnatPackages.gnat or null;
    gprbuild = pkgs.gprbuild or pkgs.gnatPackages.gprbuild or null;
  }
