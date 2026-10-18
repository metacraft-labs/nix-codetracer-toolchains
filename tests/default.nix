{ pkgs }:
let
  ccpp = import ../languages/c-cpp { inherit pkgs; };
  patch = ../languages/c-cpp/gcc13-gettext-order.patch;
in
pkgs.runCommand "gcc13-gettext-order" {
  nativeBuildInputs = [ pkgs.stdenv.cc pkgs.gnutar pkgs.xz pkgs.patch ];
  gccSource = ccpp.gcc13.cc.src;
  gettext = pkgs.gettext;
  gettextOrderPatch =
    if builtins.elem patch ccpp.gcc13.cc.patches then patch else "";
} ''
  export CXX=${pkgs.stdenv.cc}/bin/c++
  bash ${./gcc13-gettext-order.sh}
''
