#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."
target=${BUILD_TARGET:?BUILD_TARGET is required}
case "$target" in
    cmcc-rax3000m|nokia-xg-040g-md|x86-64-efi-qemu|rockchip) ;;
    *) echo "Unknown build target: $target" >&2; exit 1 ;;
esac

mkdir -p ci-output/logs ci-output/build-info
exec > >(tee ci-output/logs/build.log) 2>&1

# Each target requires its own build directory.
if [[ -e .config || -d build_dir || -d bin ]]; then
    echo 'Run this script in a fresh checkout, without .config, build_dir or bin.' >&2
    exit 1
fi

./scripts/feeds update -a
./scripts/feeds install -a

(
    cd custom-build
    sh "$target-cfg.sh"
)
mv "custom-build/$target-cfg" .config
cp .config ci-output/build-info/config.seed
make defconfig
cp .config ci-output/build-info/config.full
python3 custom-build/ci-release-files.py verify "$target"

jobs=$(nproc)
make download V=s "-j$jobs"
make V=s "-j$jobs" BUILD_LOG=1
python3 custom-build/ci-release-files.py collect "$target"
