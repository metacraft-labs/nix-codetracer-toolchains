"""Check that nimble records a package's own git revision under a leaked GIT_DIR.

A git hook or `git bisect run` exports GIT_DIR (with GIT_PREFIX and
GIT_EXEC_PATH) into the command it runs. git reads GIT_DIR before it looks at
the working directory, so nimble's `git rev-parse HEAD` in a package directory
answers for the exported repository instead. The test installs a package from
its own repository with GIT_DIR pointing at an unrelated repository, and
requires the install to record the package's HEAD. The control install, with
the variables removed, shows the fixture itself records the right revision.

No mocks: the package, the unrelated repository and the nimble install all run
for real, against a temporary directory and a private NIMBLE_DIR.

Usage: python3 tests/check_nimble_git_env.py <nimble binary>
Exits 0 when both installs record the package's HEAD, 1 otherwise.
"""

import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path

GIT_REPO_VARS = ["GIT_DIR", "GIT_WORK_TREE", "GIT_INDEX_FILE", "GIT_PREFIX", "GIT_EXEC_PATH"]
GIT_IDENTITY = ["-c", "user.name=test", "-c", "user.email=test@example.invalid"]
PACKAGE_NAME = "fixlib"
NIMBLE_FILE = 'version = "0.1.0"\nauthor = "test"\ndescription = "test"\nlicense = "MIT"\n'


def clean_env(extra=None):
    """The ambient environment without git's repository variables, plus `extra`."""
    env = {name: value for name, value in os.environ.items() if name not in GIT_REPO_VARS}
    env.update(extra or {})
    return env


def git(repo, *args):
    result = subprocess.run(
        ["git", "-C", str(repo), *GIT_IDENTITY, *args],
        env=clean_env(),
        capture_output=True,
        text=True,
        check=True,
    )
    return result.stdout.strip()


def make_repo(path, with_package):
    """Create a git repository with one commit and return its HEAD sha."""
    path.mkdir()
    git(path, "init", "-q")
    if with_package:
        (path / f"{PACKAGE_NAME}.nimble").write_text(NIMBLE_FILE)
    else:
        (path / "unrelated.txt").write_text("not a nimble package\n")
    git(path, "add", ".")
    git(path, "commit", "-q", "-m", "fixture")
    return git(path, "rev-parse", "HEAD")


def install(nimble, package_dir, nimble_dir, extra_env):
    """Run `nimble install -y` in the package directory and return the result."""
    env = clean_env(extra_env)
    env["NIMBLE_DIR"] = str(nimble_dir)
    result = subprocess.run(
        [nimble, "install", "-y"],
        cwd=package_dir,
        env=env,
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        raise SystemExit(
            f"nimble install failed with exit code {result.returncode}\n"
            f"stdout:\n{result.stdout}\nstderr:\n{result.stderr}"
        )


def recorded_revisions(nimble_dir):
    """The vcsRevision of every installed copy of the fixture package."""
    metas = sorted((nimble_dir / "pkgs2").glob(f"{PACKAGE_NAME}-0.1.0-*/nimblemeta.json"))
    return [json.loads(meta.read_text())["metaData"]["vcsRevision"] for meta in metas]


def main(argv):
    if len(argv) != 2:
        print("usage: python3 tests/check_nimble_git_env.py <nimble binary>", file=sys.stderr)
        return 2
    nimble = argv[1]
    with tempfile.TemporaryDirectory(prefix="nimble-git-env-") as tmp:
        root = Path(tmp)
        package = root / "package"
        unrelated = root / "unrelated"
        package_head = make_repo(package, with_package=True)
        unrelated_head = make_repo(unrelated, with_package=False)
        if unrelated_head == package_head:
            raise SystemExit("fixture error: the two repositories share a HEAD")

        control_dir = root / "nimble-control"
        install(nimble, package, control_dir, {})
        control = recorded_revisions(control_dir)
        if control != [package_head]:
            print(
                f"FAIL control: recorded {control}, expected [{package_head}]",
                file=sys.stderr,
            )
            return 1

        leaked_dir = root / "nimble-exported"
        install(nimble, package, leaked_dir, {"GIT_DIR": str(unrelated / ".git")})
        leaked = recorded_revisions(leaked_dir)
        if leaked != [package_head]:
            print(
                f"FAIL exported GIT_DIR: recorded {leaked}, expected [{package_head}] "
                f"(the unrelated repository's HEAD is {unrelated_head})",
                file=sys.stderr,
            )
            return 1

    print(f"OK: {nimble} records the package's own HEAD {package_head} with and without GIT_DIR")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
