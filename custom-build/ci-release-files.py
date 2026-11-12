#!/usr/bin/env python3
"""Verify firmware targets and collect configured prerelease files."""

import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess


TARGETS = {
    "cmcc-rax3000m": ("mediatek", "filogic", ["cmcc_rax3000m"]),
    "nokia-xg-040g-md": ("airoha", "an7581", ["nokia_xg-040g-md-ubi"]),
    "x86-64-efi-qemu": ("x86", "64", ["generic"]),
    "rockchip": ("rockchip", "armv8", ["smart_am40", "norco_emb-3531"]),
}


def write_json(path, data):
    path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n")


def sha256(path):
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def git_output(directory, *args):
    return subprocess.check_output(["git", "-C", str(directory), *args], text=True).strip()


def verify(root, target):
    text = (root / ".config").read_text()
    selected = dict(re.findall(r"^CONFIG_([^=]+)=([ym])$", text, re.M))
    board, subtarget, profiles = TARGETS[target]
    for symbol in (f"TARGET_{board}", f"TARGET_{board}_{subtarget}"):
        if selected.get(symbol) != "y":
            raise ValueError(f"Expected CONFIG_{symbol}=y after defconfig")
    # Snapshot configurations can drift; never publish a build for the wrong devices.
    if selected.get("TARGET_MULTI_PROFILE") == "y":
        for profile in profiles:
            symbol = f"TARGET_DEVICE_{board}_{subtarget}_DEVICE_{profile}"
            if selected.get(symbol) != "y":
                raise ValueError(f"Expected CONFIG_{symbol}=y after defconfig")
    elif len(profiles) != 1 or selected.get(f"TARGET_{board}_{subtarget}_DEVICE_{profiles[0]}") != "y":
        raise ValueError("Unexpected device profile selection")


def collect(root, target, info):
    board, subtarget, expected = TARGETS[target]
    output = root / "bin/targets" / board / subtarget
    profiles = json.loads((output / "profiles.json").read_text())["profiles"]
    release = root / "ci-output/release"
    release.mkdir(parents=True, exist_ok=True)
    image_hashes = {}
    for profile in expected:
        if profile not in profiles or not profiles[profile].get("images"):
            raise ValueError(f"No firmware images found for {profile}")
        image_hashes.update({image["name"]: image["sha256"] for image in profiles[profile]["images"]})
    manifest = json.loads((root / "custom-build/release-files.json").read_text())
    names = [Path(pattern).name for patterns in manifest.values() for pattern in patterns]
    if len(names) != len(set(names)):
        raise ValueError("Release manifest contains duplicate asset names")
    receipts = []
    for pattern in manifest[target]:
        if Path(pattern).is_absolute() or ".." in Path(pattern).parts:
            raise ValueError(f"Invalid release path: {pattern}")
        matches = sorted(root.glob(pattern))
        if len(matches) != 1 or not matches[0].is_file():
            raise ValueError(f"Release file must match exactly one file: {pattern} ({len(matches)} matches)")
        source = matches[0]
        if not source.resolve().is_relative_to(root):
            raise ValueError(f"Release file is outside the checkout: {pattern}")
        if source.stat().st_size >= 2 * 1024**3:
            raise ValueError(f"Release asset exceeds the 2 GiB limit: {source.name}")
        digest = sha256(source)
        if source.name in image_hashes and digest != image_hashes[source.name]:
            raise ValueError(f"Image checksum mismatch: {source.name}")
        shutil.copyfile(source, release / source.name)
        receipts.append({"source": str(source.relative_to(root)), "name": source.name, "sha256": digest})
    if not receipts:
        raise ValueError(f"No release files configured for {target}")
    write_json(info / "release-files.json", receipts)
    for name in ("profiles.json", "config.buildinfo", "feeds.buildinfo", "version.buildinfo", "sha256sums"):
        shutil.copyfile(output / name, info / name)
    for package_manifest in output.glob("*.manifest"):
        shutil.copyfile(package_manifest, info / package_manifest.name)
    feeds = {feed.name: git_output(feed, "rev-parse", "HEAD")
             for feed in sorted((root / "feeds").iterdir()) if (feed / ".git").exists()}
    write_json(info / "feeds.lock.json", feeds)
    write_json(info / "build.json", {"target": target, "source_commit": git_output(root, "rev-parse", "HEAD")})


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=("verify", "collect"))
    parser.add_argument("target", choices=TARGETS)
    args = parser.parse_args()
    root = Path.cwd().resolve()
    info = root / "ci-output/build-info"
    info.mkdir(parents=True, exist_ok=True)
    if args.command == "verify":
        verify(root, args.target)
    else:
        collect(root, args.target, info)


if __name__ == "__main__":
    try:
        main()
    except (ValueError, OSError, subprocess.CalledProcessError) as error:
        raise SystemExit(str(error)) from error
