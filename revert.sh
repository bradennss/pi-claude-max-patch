#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PATCHES_DIR="$SCRIPT_DIR/patches"

PI_ROOT="$(npm root -g)/@earendil-works/pi-coding-agent"

if [ ! -d "$PI_ROOT" ]; then
    echo "error: Pi not found at $PI_ROOT" >&2
    exit 1
fi

FAILED=0

for patch_file in "$PATCHES_DIR"/*.patch; do
    name="$(basename "$patch_file")"

    if patch -d "$PI_ROOT" --dry-run -R -p1 < "$patch_file" > /dev/null 2>&1; then
        patch -d "$PI_ROOT" -R -p1 < "$patch_file"
        echo "  ok: $name (reverted)"
    elif patch -d "$PI_ROOT" --dry-run --forward -p1 < "$patch_file" > /dev/null 2>&1; then
        echo "skip: $name (not applied)"
    else
        echo "FAIL: $name" >&2
        FAILED=1
    fi
done

if [ "$FAILED" -ne 0 ]; then
    echo "some patches failed to revert" >&2
    exit 1
fi

echo "done"
