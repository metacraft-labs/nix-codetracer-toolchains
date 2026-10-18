#!/usr/bin/env bash
# Exercise the actual selected GCC header fragment and gettext header, rather
# than replicas: unrelated system.h dependencies are outside this regression.
set -euo pipefail

# Retain the precise input identities alongside the negative diagnostics.
{
  "$CXX" --version
  sha256sum "$gccSource" "$gettext/include/libintl.h" "$CXX"
} > inputs.log

tar -xOf "$gccSource" gcc-13.4.0/libcpp/system.h > original.h
mkdir -p candidate/libcpp
cp original.h candidate/libcpp/system.h
if [[ -n "$gettextOrderPatch" ]]; then
  patch --fuzz=0 -d candidate -p1 < "$gettextOrderPatch"
fi

for variant in original candidate; do
  header=original.h
  [[ $variant == original ]] || header=candidate/libcpp/system.h
  # Keep the genuine conditional blocks, including both NLS and locale paths.
  awk '/^#ifdef HAVE_LOCALE_H$/ { emit=1 } /^#ifndef _$/ { emit=0 } emit' "$header" > "$variant-fragment.h"
  test -s "$variant-fragment.h"
  for have_locale in 0 1; do
    for nls in 0 1; do
      cat > probe.cc <<EOF_PROBE
#include <locale.h>
#include <cstring>
#define PACKAGE "gcc"
$(if [[ $have_locale == 1 ]]; then echo '#define HAVE_SETLOCALE 1'; fi)
$(if [[ $nls == 1 ]]; then echo '#define ENABLE_NLS 1'; fi)
#include "$variant-fragment.h"
#if $have_locale == 0
# ifndef setlocale
#  error missing setlocale fallback
# endif
#else
# ifdef setlocale
#  error unexpected setlocale fallback
# endif
#endif
int main() {
  const char *locale = "C";
#if $have_locale == 0
  int category_evaluated = 0;
  if (setlocale(++category_evaluated, locale) != locale || category_evaluated)
    return 1;
#else
  if (!setlocale(LC_ALL, locale)) return 2;
#endif
  return std::strcmp(dgettext(PACKAGE, "untranslated regression message"),
                     "untranslated regression message") != 0;
}
EOF_PROBE
      label="$variant-$have_locale-$nls"
      if [[ $variant == original && $have_locale == 0 && $nls == 1 ]]; then
        if "$CXX" -I"$gettext/include" probe.cc -L"$gettext/lib" -lintl -o probe > "$label.log" 2>&1; then
          echo 'Unfixed GCC header unexpectedly compiled' >&2
          exit 1
        fi
        # Require the failure to come from the real gettext declaration and
        # GCC fallback expansion, not a missing header, linker or SDK failure.
        grep -F 'libintl.h:' "$label.log"
        grep -F "expanded from macro 'setlocale'" "$label.log"
        grep -F 'expected' "$label.log"
      else
        "$CXX" -I"$gettext/include" probe.cc -L"$gettext/lib" -lintl -o probe
        ./probe
      fi
      echo "PASS $label"
    done
  done
done
mkdir "$out"
cp ./*.log "$out/"
