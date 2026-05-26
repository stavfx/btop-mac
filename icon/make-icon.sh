#!/usr/bin/env bash
# Regenerate btop.icns from make-icon.swift. Run when you change the icon design.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"

echo "==> rendering icon_1024.png"
xcrun swift make-icon.swift

ICONSET="btop.iconset"
rm -rf "$ICONSET"
mkdir "$ICONSET"
sips -z 16 16     icon_1024.png --out "$ICONSET/icon_16x16.png"      >/dev/null
sips -z 32 32     icon_1024.png --out "$ICONSET/icon_16x16@2x.png"   >/dev/null
sips -z 32 32     icon_1024.png --out "$ICONSET/icon_32x32.png"      >/dev/null
sips -z 64 64     icon_1024.png --out "$ICONSET/icon_32x32@2x.png"   >/dev/null
sips -z 128 128   icon_1024.png --out "$ICONSET/icon_128x128.png"    >/dev/null
sips -z 256 256   icon_1024.png --out "$ICONSET/icon_128x128@2x.png" >/dev/null
sips -z 256 256   icon_1024.png --out "$ICONSET/icon_256x256.png"    >/dev/null
sips -z 512 512   icon_1024.png --out "$ICONSET/icon_256x256@2x.png" >/dev/null
sips -z 512 512   icon_1024.png --out "$ICONSET/icon_512x512.png"    >/dev/null
cp icon_1024.png "$ICONSET/icon_512x512@2x.png"

echo "==> building btop.icns"
iconutil -c icns "$ICONSET" -o btop.icns
rm -rf "$ICONSET"
echo "==> wrote $(pwd)/btop.icns"
