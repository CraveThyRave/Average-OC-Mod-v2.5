import argparse
import json
import os
from pathlib import Path
import re
import subprocess

from generate_manifest import build_number, generate


def git(root, *arguments, input=None):
    result = subprocess.run(["git", "-C", str(root), *arguments], input=input, text=True, encoding="utf-8", capture_output=True)
    if result.returncode:
        raise RuntimeError(f"Git {arguments[0]} failed: {result.stderr.strip()}")
    return result.stdout.strip()


def remote_ref(root, name):
    result = git(root, "ls-remote", "origin", name)
    return result.split()[0] if result else None


def publish(root, run_number):
    root = Path(root).resolve(strict=True)
    if not re.fullmatch(r"[1-9][0-9]*", str(run_number)):
        raise ValueError("A positive GitHub run number is required")
    git(root, "diff", "--quiet", "HEAD")
    source = git(root, "rev-parse", "HEAD")
    if remote_ref(root, "refs/heads/main") != source:
        print("A newer main commit exists; its workflow will publish it.")
        return None
    previous = remote_ref(root, "refs/heads/updates")
    old_number = 0
    if previous:
        git(root, "fetch", "--no-tags", "origin", "refs/heads/updates")
        previous = git(root, "rev-parse", "FETCH_HEAD")
        descriptor = json.loads(git(root, "show", f"{previous}:assets/updateVersion.json"))
        old_number = build_number(descriptor["version"])
        if descriptor.get("sourceCommit") == source:
            print(f"This commit is already published as {descriptor['version']}.")
            return descriptor["version"]
    number = max(int(run_number), old_number + 1)
    version = f"2.5.{number}"
    release_ref = f"aom-build-{number}"
    manifest = generate(root, version, release_ref=release_ref, source_commit=source)
    git(root, "add", "--", ".gitattributes", "assets/updateManifest.json", "assets/updateVersion.json")
    tracked = set(git(root, "ls-files", "-z").split("\0"))
    for entry in manifest["files"]:
        if entry["path"] not in tracked:
            raise ValueError(f"Uncommitted build file: {entry['path']}")
    tree = git(root, "write-tree")
    parents = ["-p", previous] if previous else []
    parents += ["-p", source]
    commit = git(root, "-c", "user.name=github-actions[bot]", "-c", "user.email=41898282+github-actions[bot]@users.noreply.github.com", "commit-tree", tree, *parents, input=f"Publish Average OC Mod {version}\n")
    if remote_ref(root, "refs/heads/main") != source:
        print("Main changed while preparing the update; the newer workflow will publish it.")
        return None
    if remote_ref(root, "refs/heads/updates") != previous:
        raise RuntimeError("Another publisher changed updates; rerun this workflow")
    git(root, "push", "--atomic", "origin", f"{commit}:refs/heads/updates", f"{commit}:refs/tags/{release_ref}")
    message = f"Published {version}: {len(manifest['files'])} files from {source}."
    print(message)
    if os.environ.get("GITHUB_STEP_SUMMARY"):
        with open(os.environ["GITHUB_STEP_SUMMARY"], "a", encoding="utf-8") as output:
            output.write(message + "\n")
    return version


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--build-dir", default=".")
    parser.add_argument("--run-number", default=os.environ.get("GITHUB_RUN_NUMBER"), required=not os.environ.get("GITHUB_RUN_NUMBER"))
    arguments = parser.parse_args()
    publish(arguments.build_dir, arguments.run_number)
