#!/usr/bin/env bash
# Build the native "btop" macOS app and assemble it into dist/btop.app.
set -euo pipefail

# Resolve paths relative to this script so it works from any CWD.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Use Xcode's Swift toolchain (the bare swiftc on PATH may be ancient).
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"

echo "==> Using Swift toolchain:"
xcrun swift --version

echo "==> swift build -c release"
xcrun swift build -c release

BIN="$(xcrun swift build -c release --show-bin-path)/btop"
if [[ ! -x "$BIN" ]]; then
    echo "ERROR: compiled binary not found at $BIN" >&2
    exit 1
fi

APP="$SCRIPT_DIR/dist/btop.app"
echo "==> Assembling $APP"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN" "$APP/Contents/MacOS/btop"
cp "$SCRIPT_DIR/Info.plist" "$APP/Contents/Info.plist"
cp "$SCRIPT_DIR/icon/btop.icns" "$APP/Contents/Resources/btop.icns"

echo "==> Ad-hoc codesign"
codesign --force --deep --sign - "$APP"

echo "==> Done: $APP"
