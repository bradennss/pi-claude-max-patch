#!/usr/bin/env bash
set -euo pipefail

AUTO_YES=false
while getopts "y" opt; do
    case $opt in
        y) AUTO_YES=true ;;
    esac
done

EXPECTED_VERSION="0.84.1"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PATCHES_DIR="$SCRIPT_DIR/patches"

PI_ROOT="$(npm root -g | tr '\\' '/')/@earendil-works/pi-coding-agent"

if [ ! -d "$PI_ROOT" ]; then
    echo "Pi not found at $PI_ROOT." >&2
    echo "Install it first: npm install -g @earendil-works/pi-coding-agent" >&2
    exit 1
fi

PI_VERSION=$(node -e "console.log(require('$PI_ROOT/package.json').version)")
echo "Pi install: $PI_ROOT (v$PI_VERSION)"

if [ "$PI_VERSION" != "$EXPECTED_VERSION" ]; then
    echo "Patches were built for v$EXPECTED_VERSION, current is v$PI_VERSION." >&2
    echo "Patches may fail or produce incorrect results." >&2
    if [ "$AUTO_YES" = false ]; then
        read -rp "Continue? [y/N] " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
fi

FAILED=0

for patch_file in "$PATCHES_DIR"/*.patch; do
    name="$(basename "$patch_file")"

    if patch -d "$PI_ROOT" --dry-run --forward -p1 < "$patch_file" > /dev/null 2>&1; then
        patch -d "$PI_ROOT" --forward -p1 < "$patch_file"
        echo "  Ok: $name"
    elif patch -d "$PI_ROOT" --dry-run -R -p1 < "$patch_file" > /dev/null 2>&1; then
        echo "Skip: $name (already applied)"
    else
        echo "Failed: $name" >&2
        FAILED=1
    fi
done

if [ "$FAILED" -ne 0 ]; then
    echo "Some patches failed to apply." >&2
    exit 1
fi

echo "Done."
