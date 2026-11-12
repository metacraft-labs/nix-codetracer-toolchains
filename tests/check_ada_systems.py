"""Check that every declared system evaluates its Ada exports and default dev shell.

The check runs the real flake through `nix eval`, one attribute at a time, with
no mocked evaluator. Each attribute is forced under builtins.tryEval, so a
failing attribute is reported by name instead of aborting the whole run.

Regression for the aarch64-linux evaluation error: packages.aarch64-linux.gnat
and gprbuild threw "Unsupported system: aarch64-linux", because
languages/ada/default.nix fell back to nixpkgs' GNAT 13 bootstrap, which has no
aarch64-linux entry. devShells.aarch64-linux.default failed for the same reason.
Against the unfixed tree this check reports gnat, gprbuild and the aarch64-linux
dev shell as failing.

Scope: the Ada exports and the default dev shell. devShells.x86_64-darwin.default
is not checked: it contains fpc, which the pinned nixpkgs marks broken on that
system, so it fails for a reason this check does not cover.
"""

import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

# Systems that have a GNAT producer. Keep in step with nixpkgsGnatSystems and
# the aarch64-darwin branch of languages/ada/default.nix.
GNAT_SYSTEMS = {"x86_64-linux", "x86_64-darwin", "aarch64-darwin"}

# Systems whose default dev shell is expected to evaluate. x86_64-darwin is
# excluded for the fpc reason in the module docstring.
DEV_SHELL_SYSTEMS = {"x86_64-linux", "aarch64-linux", "aarch64-darwin"}

# Each Ada export is forced under tryEval: true when it evaluates, false when it
# throws, and "absent" when the system does not export it.
ADA_EXPR = (
    "ps: builtins.listToAttrs (map (n: { name = n; value = "
    'if builtins.hasAttr n ps then (builtins.tryEval (builtins.seq ps.${n}.drvPath true)).success '
    'else "absent"; }) [ "gnat" "gprbuild" ])'
)

SHELL_EXPR = "ds: (builtins.tryEval (builtins.seq ds.default.drvPath true)).success"


def declared_systems():
    """Return the systems listed in flake.nix's `systems = [ ... ];`."""
    text = (ROOT / "flake.nix").read_text()
    block = re.search(r"\bsystems = \[(.*?)\];", text, re.S)
    if block is None:
        raise ValueError("flake.nix has no `systems = [ ... ];` list")
    return re.findall(r'"([\w-]+)"', block.group(1))


def nix_eval(attribute, expression):
    """Evaluate one flake attribute with `expression` applied, returning JSON."""
    result = subprocess.run(
        [
            "nix",
            "eval",
            "--no-write-lock-file",
            "--json",
            f"{ROOT}#{attribute}",
            "--apply",
            expression,
        ],
        capture_output=True,
        text=True,
    )
    if result.returncode:
        raise RuntimeError(f"nix eval {attribute} failed:\n{result.stderr}")
    return json.loads(result.stdout)


def main():
    failures = []
    for system in declared_systems():
        ada = nix_eval(f"packages.{system}", ADA_EXPR)
        expected = True if system in GNAT_SYSTEMS else "absent"
        for name in ["gnat", "gprbuild"]:
            if ada[name] != expected:
                failures.append(
                    f"packages.{system}.{name} is {ada[name]!r}, expected {expected!r}"
                )
        if system in DEV_SHELL_SYSTEMS:
            if nix_eval(f"devShells.{system}", SHELL_EXPR) is not True:
                failures.append(f"devShells.{system}.default does not evaluate")
    if failures:
        raise SystemExit("\n".join(failures))
    print("every declared system evaluates its Ada exports and default dev shell")


if __name__ == "__main__":
    main()
