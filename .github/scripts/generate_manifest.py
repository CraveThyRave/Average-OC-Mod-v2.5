BASELINE_VERSION = "2.5.0"

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import stat
import sys
import tempfile
import time

TEXT_EXTENSIONS = {".json", ".lua", ".txt", ".xml", ".frag", ".vert", ".glsl", ".cfg", ".ini", ".csv", ".hx", ".hscript", ".hxs", ".md", ".yml", ".yaml"}
TEXT_HASH_LIMIT = 8 * 1024 * 1024

GENERATED = {"assets/updatemanifest.json", "assets/updateversion.json", "assets/updateinventory.json", ".aom-update-receipt.json"}
PRIVATE_DIRS = {"update_temp", ".git", ".github", ".codex", ".agents", "saves", "save", "savedata", "screenshots", "logs", "crash", "crashes", "replays", "userdata", "user-data", "__pycache__"}
PRIVATE_NAMES = {"settings.json", "settings.ini", "preferences.json", "preferences.ini", "controls.json", "keybinds.json", "modlist.txt", "modslist.txt", "updates.log"}
PRIVATE_EXTENSIONS = {".sol", ".sav", ".save", ".log", ".tmp", ".bak"}


def build_number(version):
    if not isinstance(version, str) or not re.fullmatch(r"2\.5\.(0|[1-9][0-9]*)", version):
        raise ValueError(f"Invalid version: {version!r}; expected 2.5.BUILD_NUMBER")
    number = int(version[4:])
    if number > 2147483647:
        raise ValueError("Build number exceeds 2147483647")
    return number


def validate_path(value):
    if not isinstance(value, str) or not value or len(value) > 220:
        raise ValueError(f"Invalid manifest path: {value!r}")
    parts = value.split("/")
    for part in parts:
        if not part or part in {".", ".."} or part[-1] in " ." or re.search(r'[\x00-\x1f\\:*?"<>|]', part):
            raise ValueError(f"Unsafe manifest path: {value!r}")
        if re.fullmatch(r"(?i)(con|prn|aux|nul|com[1-9]|lpt[1-9])(?:\..*)?", part):
            raise ValueError(f"Reserved Windows path: {value!r}")
    return value


def is_private(value):
    lower = value.lower()
    parts = lower.split("/")
    return lower in GENERATED or any(p in PRIVATE_DIRS for p in parts) or parts[-1] in PRIVATE_NAMES or Path(lower).suffix in PRIVATE_EXTENSIONS


def sha256(path):
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()



def text_hash(path):
    if path.suffix.lower() not in TEXT_EXTENSIONS or path.stat().st_size > TEXT_HASH_LIMIT:
        return None
    data = path.read_bytes()
    if b"\0" in data:
        return None
    try:
        data.decode("utf-8", errors="strict")
    except UnicodeDecodeError:
        return None
    return hashlib.sha256(data.replace(b"\r\n", b"\n")).hexdigest()


def same_content(before, after):
    if before["sha256"] == after["sha256"] and before["size"] == after["size"]:
        return True
    return (Path(after["path"]).suffix.lower() in TEXT_EXTENSIONS
            and before.get("textSha256", before["sha256"]) == after.get("textSha256", after["sha256"]))


def is_link(path):
    return path.is_symlink() or bool(getattr(path.lstat(), "st_file_attributes", 0) & getattr(stat, "FILE_ATTRIBUTE_REPARSE_POINT", 0x400))


def atomic_write(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    handle, temporary = tempfile.mkstemp(prefix=".aom-manifest-", dir=path.parent)
    try:
        with os.fdopen(handle, "wb") as output:
            output.write(data)
            output.flush()
            os.fsync(output.fileno())
        for attempt in range(5):
            try:
                os.replace(temporary, path)
                break
            except PermissionError as error:
                if os.name != "nt" or error.winerror not in (5, 32, 33) or attempt == 4:
                    raise
                time.sleep(0.05 * (2 ** attempt))
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


def hide_updater_files(root):
    if os.name != "nt":
        return
    import ctypes
    kernel = ctypes.WinDLL("kernel32", use_last_error=True)
    kernel.SetFileAttributesW.argtypes = [ctypes.c_wchar_p, ctypes.c_uint32]
    kernel.SetFileAttributesW.restype = ctypes.c_int
    for name in (".github", ".gitattributes", "update_temp", ".aom-update-receipt.json"):
        path = root / name
        if path.exists() and not is_link(path):
            attributes = path.stat().st_file_attributes | stat.FILE_ATTRIBUTE_HIDDEN
            if not kernel.SetFileAttributesW(str(path), attributes):
                raise ctypes.WinError(ctypes.get_last_error())


def generate(root, version=BASELINE_VERSION, deletions=None, release_ref=None, source_commit=None, write_metadata=True):
    build_number(version)
    root = Path(root).resolve(strict=True)
    if not root.is_dir() or not (root / "assets").is_dir() or not any(root.glob("*.exe")):
        raise ValueError(f"Not a finished Windows bin directory: {root}")
    attributes = root / ".gitattributes"
    if attributes.exists() and is_link(attributes):
        raise ValueError("Build .gitattributes cannot be a link")
    attributes_text = attributes.read_text(encoding="utf-8") if attributes.exists() else ""
    if not attributes_text.rstrip().endswith("* -text"):
        atomic_write(attributes, (attributes_text.rstrip() + "\n* -text\n").lstrip("\n").encode("utf-8"))
    files = []
    seen = set()
    for directory, directories, names in os.walk(root, followlinks=False):
        base = Path(directory)
        directories[:] = sorted(d for d in directories if not is_private((base / d).relative_to(root).as_posix()))
        for name in directories:
            if is_link(base / name):
                raise ValueError(f"Reparse point/symlink in build: {base / name}")
        for name in sorted(names):
            path = base / name
            relative = path.relative_to(root).as_posix()
            if is_private(relative):
                continue
            validate_path(relative)
            if is_link(path) or not path.is_file():
                raise ValueError(f"Non-regular file in build: {path}")
            if relative.lower() in seen:
                raise ValueError(f"Windows case collision: {relative}")
            seen.add(relative.lower())
            before = path.stat()
            digest = sha256(path)
            normalized = text_hash(path)
            after = path.stat()
            if (before.st_size, before.st_mtime_ns) != (after.st_size, after.st_mtime_ns):
                raise ValueError(f"Build changed while hashing: {relative}")
            entry = {"path": relative, "size": after.st_size, "sha256": digest}
            if normalized is not None:
                entry["textSha256"] = normalized
            files.append(entry)
    removed = []
    for path in [] if deletions is None else deletions:
        validate_path(path)
        if is_private(path) or path.lower() in seen:
            raise ValueError(f"Protected, duplicate, or still-present delete path: {path}")
        seen.add(path.lower())
        removed.append(path)
    for path in seen:
        parent = path.rpartition("/")[0]
        while parent:
            if parent in seen:
                raise ValueError(f"File/directory collision: {path}")
            parent = parent.rpartition("/")[0]
    manifest = {"version": version, "files": sorted(files, key=lambda f: f["path"].lower()), "delete": sorted(removed)}
    payload = (json.dumps(manifest, indent=2, ensure_ascii=False) + "\n").encode("utf-8")
    descriptor = {"version": version, "manifestSize": len(payload), "manifestSha256": hashlib.sha256(payload).hexdigest()}
    if release_ref is not None:
        if release_ref != f"aom-build-{build_number(version)}" or not re.fullmatch(r"[a-f0-9]{40}", source_commit or ""):
            raise ValueError("Invalid published release identity")
        descriptor.update(releaseRef=release_ref, sourceCommit=source_commit)
    if write_metadata:
        atomic_write(root / "assets/updateManifest.json", payload)
        atomic_write(root / "assets/updateVersion.json", (json.dumps(descriptor, indent=2) + "\n").encode("utf-8"))
        hide_updater_files(root)
    return manifest



def json_bytes(value):
    return (json.dumps(value, indent=2, ensure_ascii=False) + "\n").encode("utf-8")


def read_inventory(root):
    root = Path(root)
    descriptor_path = root / "assets/updateVersion.json"
    if not descriptor_path.exists():
        return None
    descriptor = json.loads(descriptor_path.read_bytes())
    build_number(descriptor["version"])
    delta = descriptor.get("format") == 2
    name = "updateInventory.json" if delta else "updateManifest.json"
    prefix = "inventory" if delta else "manifest"
    payload = (root / "assets" / name).read_bytes()
    if len(payload) != descriptor[prefix + "Size"] or hashlib.sha256(payload).hexdigest() != descriptor[prefix + "Sha256"]:
        raise ValueError("Previous inventory does not match its version descriptor")
    inventory = json.loads(payload)
    if inventory["version"] != descriptor["version"]:
        raise ValueError("Previous inventory version mismatch")
    return inventory


def write_delta(root, current, previous=None, source_commit=None):
    root = Path(root)
    number = build_number(current["version"])
    old = {entry["path"].lower(): entry for entry in previous["files"]} if previous else {}
    files = {entry["path"].lower(): entry for entry in current["files"]}
    changes = []
    for key, entry in files.items():
        before = old.get(key)
        if before is None or before["path"] != entry["path"] or not same_content(before, entry):
            changes.append(dict(entry, change="added" if before is None else "changed"))
    removed = sorted((entry["path"] for key, entry in old.items() if key not in files), key=str.lower)
    manifest = {"format": 2, "version": current["version"], "baseVersion": previous["version"] if previous else None,
                "files": changes, "delete": removed}
    inventory = {"version": current["version"], "files": current["files"], "delete": []}
    payload = json_bytes(manifest)
    inventory_payload = json_bytes(inventory)
    descriptor = {"format": 2, "version": current["version"],
                  "manifestSize": len(payload), "manifestSha256": hashlib.sha256(payload).hexdigest(),
                  "inventorySize": len(inventory_payload), "inventorySha256": hashlib.sha256(inventory_payload).hexdigest()}
    if source_commit is not None:
        if not re.fullmatch(r"[a-f0-9]{40}", source_commit):
            raise ValueError("Invalid published source identity")
        descriptor.update(releaseRef=f"aom-delta-build-{number}", sourceCommit=source_commit)
    atomic_write(root / "assets/updateInventory.json", inventory_payload)
    atomic_write(root / "assets/updateManifest.json", payload)
    atomic_write(root / "assets/updateVersion.json", json_bytes(descriptor))
    hide_updater_files(root)
    return manifest


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--build-dir", required=True)
    args = parser.parse_args()
    root = Path(args.build_dir)
    previous = read_inventory(root)
    install_publisher(root)
    current = generate(root, write_metadata=False)
    manifest = write_delta(root, current, previous)
    print(f"Updater manifest: {manifest['version']} (local baseline; GitHub assigns releases); {len(manifest['files'])} added/changed; {len(manifest['delete'])} deleted; {len(current['files'])} indexed files; {root.resolve()}")


def install_publisher(root):
    tools = Path(__file__).resolve().parent
    templates = {
        ".github/scripts/generate_manifest.py": tools / "generate_manifest.py",
        ".github/scripts/publish_update.py": tools / "publish_update.py",
        ".github/workflows/publish-update.yml": tools / "publish-update.yml",
    }
    for relative, source in templates.items():
        target = root / relative
        if any(p.exists() and is_link(p) for p in [target, *target.parents]):
            raise ValueError(f"Publisher target cannot be a link: {target}")
        atomic_write(target, source.read_bytes())


if __name__ == "__main__":
    try:
        main()
    except Exception as error:
        print(f"MANIFEST GENERATION FAILED: {error}", file=sys.stderr)
        sys.exit(1)
