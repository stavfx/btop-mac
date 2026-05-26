#!/usr/bin/env bash
# Install the native btop app into ~/Applications and register it with LaunchServices.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$SCRIPT_DIR/dist/btop.app"
DEST="$HOME/Applications/btop.app"

if [[ ! -d "$SRC" ]]; then
    echo "ERROR: $SRC not found. Run ./build.sh first." >&2
    exit 1
fi

mkdir -p "$HOME/Applications"
rm -rf "$DEST"
cp -R "$SRC" "$DEST"

LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"
"$LSREGISTER" -f "$DEST"

echo "==> Installed: $DEST"
