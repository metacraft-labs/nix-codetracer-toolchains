# Native Ada compiler and GPRBuild; preserve existing producers elsewhere.
{ pkgs }:
let
  nativeAppleSilicon = pkgs.stdenv.hostPlatform.system == "aarch64-darwin";
  bootstrapCompiler = pkgs.callPackage ./native-bootstrap.nix { majorVersion = "13"; };
  bootstrap = pkgs.wrapCCWith {
    cc = bootstrapCompiler;
    bintools = pkgs.bintoolsDualAs;
    # Darwin GCC already searches these native installation prefixes; adding
    # them through -B makes its %P specs emit duplicate LC_RPATH commands.
    extraBuildCommands = pkgs.lib.optionalString nativeAppleSilicon ''
      supportFile="$out/nix-support/cc-cflags"
      test -f "$supportFile" && test ! -L "$supportFile"
      basePath="${bootstrapCompiler}/lib/gcc/aarch64-apple-darwin23.2.0/${bootstrapCompiler.gccVersion}"
      expected=" -B${bootstrapCompiler}/lib -B$basePath -I$basePath/adainclude "
      if ! printf '%s' "$expected" | cmp -s - "$supportFile"; then
        printf '%s\n' 'GNAT bootstrap cc-cflags changed; refusing prefix removal' >&2
        exit 1
      fi
      flags="$expected"
      genericPrefix="-B${bootstrapCompiler}/lib"
      flags="''${flags/ $genericPrefix/}"
      flags="''${flags/ -B$basePath/}"
      printf '%s' "$flags" > "$supportFile"
    '';
  };
  # These are the exact pinned nixpkgs gnat13 producer arguments. The
  # existing Darwin x86 stdenv override does not apply on Apple Silicon.
  compiler = pkgs.wrapCC (
    (pkgs.gcc13.cc.override {
      name = "gnat";
      langC = true;
      langCC = false;
      langAda = true;
      profiledCompiler = false;
      gnat-bootstrap = bootstrap;
      stdenv = pkgs.stdenv;
    }).overrideAttrs
      (
        old:
        let
          targetName = "gcc-13-darwin-aarch64-support.patch";
          matching = builtins.filter (
            patch:
            builtins.baseNameOf (toString patch)
            == "primbvxya494zf2b4zpbh7qaygijw1vk-gcc-13-darwin-aarch64-support.patch"
          ) old.patches;
          originalPatch =
            assert builtins.length matching == 1;
            builtins.head matching;
          originalText =
            assert
              builtins.hashFile "sha256" originalPatch
              == "c6a9010c5619e9f768c2da91de457b6d1f1ae02bb5d510e8912cc69f59376b5c";
            builtins.readFile originalPatch;
          # Only unchanged context follows the preceding install-name patch.
          composedPatch = pkgs.writeText targetName (
            builtins.replaceStrings
              [ "-Wl,-install_name,@rpath/libgnat" "-Wl,-install_name,@rpath/libgnarl" ]
              [ "-Wl,-install_name,$(ADA_RTL_DSO_DIR)/libgnat" "-Wl,-install_name,$(ADA_RTL_DSO_DIR)/libgnarl" ]
              originalText
          );
        in
        {
          # Dependency setup hooks reset CC before preConfigure.
          preConfigure = (old.preConfigure or "") + ''
            export CC=${bootstrap}/bin/gcc
          '';
          # Preserve failed configure status while exposing its real probe log.
          failureHook = (old.failureHook or "") + ''
            if [ -f config.log ] && [ ! -L config.log ]; then
              printf '%s\n' 'GNAT native configure diagnostic: first 240 config.log lines'
              sed -n '1,240p' config.log
              printf '%s\n' 'GNAT native bootstrap wrapper: exact generated flags'
              for supportFile in cc-cflags cc-ldflags gnat-cflags gnat-ldflags; do
                supportPath=${bootstrap}/nix-support/$supportFile
                if [ -f "$supportPath" ] && [ ! -L "$supportPath" ]; then
                  printf '%s\n' "$supportPath"
                  sed -n '1,40p' "$supportPath"
                fi
              done
              printf '%s\n' 'GNAT native bootstrap: original C conftest link dry run'
              ${bootstrap}/bin/gcc -### -o conftest conftest.c 2>&1
            fi
            for component in fixincludes libcpp libiberty; do
              subconfigureLog="build-arm64-apple-darwin/$component/config.log"
              if [ -f "$subconfigureLog" ] && [ ! -L "$subconfigureLog" ]; then
                printf '%s\n' "GNAT native subconfigure diagnostic: $subconfigureLog first 240 lines"
                sed -n '1,240p' "$subconfigureLog"
              fi
            done
          '';
          patches = map (
            patch:
            if
              builtins.baseNameOf (toString patch)
              == "primbvxya494zf2b4zpbh7qaygijw1vk-gcc-13-darwin-aarch64-support.patch"
            then
              composedPatch
            else
              patch
          ) old.patches;
          # Scope tracing to the original hook and restore inherited shell options.
          postPatch =
            "_ct_gnat_native_postpatch_trace() {\nlocal -\nset -x\n"
            + (old.postPatch or "")
            + "\n}\n_ct_gnat_native_postpatch_trace\n";
        }
      )
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
