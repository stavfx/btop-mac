#!/bin/bash
# Install the btop launcher app so Spotlight / Alfred / Finder can find it.
# Symlinks the bundle into ~/Applications and registers it with Launch
# Services. Using a symlink means edits in this repo take effect immediately.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$REPO_DIR/btop.app"
DEST_DIR="$HOME/Applications"
DEST="$DEST_DIR/btop.app"
LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"

chmod +x "$SRC/Contents/MacOS/btop"

mkdir -p "$DEST_DIR"
rm -f "$DEST"
ln -s "$SRC" "$DEST"
echo "Linked $DEST -> $SRC"

"$LSREGISTER" -f "$SRC"
echo "Registered with Launch Services."
echo "Done. Launch 'btop' from Spotlight, Alfred, or Finder."
