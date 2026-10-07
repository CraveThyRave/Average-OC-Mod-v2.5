import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess

from generate_manifest import build_number, generate, write_delta


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
    previous = {}
    descriptors = {}
    inventories = {}
    for branch in ("updates", "updates-v2"):
        previous[branch] = remote_ref(root, f"refs/heads/{branch}")
        if previous[branch]:
            git(root, "fetch", "--no-tags", "origin", f"refs/heads/{branch}")
            previous[branch] = git(root, "rev-parse", "FETCH_HEAD")
            descriptor = json.loads(git(root, "show", f"{previous[branch]}:assets/updateVersion.json"))
            build_number(descriptor["version"])
            name = "updateInventory.json" if branch == "updates-v2" else "updateManifest.json"
            prefix = "inventory" if branch == "updates-v2" else "manifest"
            payload = subprocess.run(["git", "-C", str(root), "show", f"{previous[branch]}:assets/{name}"], check=True, capture_output=True).stdout
            if len(payload) != descriptor[prefix + "Size"] or hashlib.sha256(payload).hexdigest() != descriptor[prefix + "Sha256"]:
                raise ValueError("Published inventory does not match its descriptor")
            inventory = json.loads(payload)
            if inventory["version"] != descriptor["version"]:
                raise ValueError("Published inventory version mismatch")
            descriptors[branch] = descriptor
            inventories[branch] = inventory
    if len(descriptors) == 2 and all(d.get("sourceCommit") == source for d in descriptors.values()):
        versions = {d["version"] for d in descriptors.values()}
        if len(versions) != 1:
            raise ValueError("Published feeds disagree about the version")
        version = versions.pop()
        print(f"This commit is already published as {version}.")
        return version
    latest = max(descriptors, key=lambda b: build_number(descriptors[b]["version"])) if descriptors else None
    old_number = build_number(descriptors[latest]["version"]) if latest else 0
    number = max(int(run_number), old_number + 1)
    version = f"2.5.{number}"
    manifest = generate(root, version, release_ref=f"aom-build-{number}", source_commit=source)
    git(root, "add", "--", ".gitattributes", "assets/updateManifest.json", "assets/updateVersion.json")
    git(root, "rm", "--cached", "--ignore-unmatch", "--", "assets/updateInventory.json")
    tracked = set(git(root, "ls-files", "-z").split("\0"))
    for entry in manifest["files"]:
        if entry["path"] not in tracked:
            raise ValueError(f"Uncommitted build file: {entry['path']}")
    commits = {}
    changes = None
    for branch in ("updates", "updates-v2"):
        if branch == "updates-v2":
            changes = write_delta(root, manifest, inventories.get(latest), source)
            git(root, "add", "--", "assets/updateManifest.json", "assets/updateVersion.json", "assets/updateInventory.json")
        tree = git(root, "write-tree")
        parents = ["-p", previous[branch]] if previous[branch] else []
        parents += ["-p", source]
        commits[branch] = git(root, "-c", "user.name=github-actions[bot]", "-c", "user.email=41898282+github-actions[bot]@users.noreply.github.com",
                             "commit-tree", tree, *parents, input=f"Publish Average OC Mod {version} ({branch})\n")
    if remote_ref(root, "refs/heads/main") != source:
        print("Main changed while preparing the update; the newer workflow will publish it.")
        return None
    for branch, commit in previous.items():
        if remote_ref(root, f"refs/heads/{branch}") != commit:
            raise RuntimeError(f"Another publisher changed {branch}; rerun this workflow")
    git(root, "push", "--atomic", "origin",
        f"{commits['updates']}:refs/heads/updates", f"{commits['updates']}:refs/tags/aom-build-{number}",
        f"{commits['updates-v2']}:refs/heads/updates-v2", f"{commits['updates-v2']}:refs/tags/aom-delta-build-{number}")
    message = f"Published {version}: {len(changes['files'])} added/changed, {len(changes['delete'])} deleted; {len(manifest['files'])} indexed files from {source}."
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
