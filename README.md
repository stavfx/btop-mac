# btop (native macOS app)

A self-contained native macOS app that embeds a terminal view (via
[SwiftTerm](https://github.com/migueldeicaza/SwiftTerm)) and runs
`/opt/homebrew/bin/btop` inside it.

Because it is its own AppKit application with `CFBundleName = "btop"`, the macOS
menu bar shows **btop** when it is frontmost (not "iTerm2" / "Ghostty").

## Layout

```
Package.swift            SwiftPM package (depends on SwiftTerm)
Sources/btop/main.swift  AppKit app + LocalProcessTerminalView
Info.plist               App bundle metadata
build.sh                 Build + assemble dist/btop.app + ad-hoc codesign
install.sh               Copy to ~/Applications/btop.app + lsregister
icon/                    Icon generator (make-icon.swift/.sh) + btop.icns
```

## Icon

`icon/btop.icns` is committed and bundled by `build.sh`. To change the design,
edit `icon/make-icon.swift` and regenerate:

```sh
./icon/make-icon.sh
```

## Build

```sh
./build.sh
```

Produces `dist/btop.app`. Uses Xcode's Swift toolchain explicitly
(`DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`, `xcrun swift ...`),
since a bare `swiftc` on `PATH` may be too old for SwiftTerm.

## Run

```sh
open dist/btop.app
```

A ~1000x640 window titled "btop" opens running btop. Press **q** inside btop to
quit; the app then terminates. Closing the window also terminates the app.

## Install

```sh
./install.sh
```

Copies the app to `~/Applications/btop.app` and registers it with
LaunchServices, so it is launchable from Spotlight / Alfred / Finder.

## Caveats / rough edges

- **Gatekeeper:** the app is ad-hoc signed (`codesign --sign -`). On first launch
  macOS may warn it is from an unidentified developer. Right-click > Open, or
  `xattr -dr com.apple.quarantine dist/btop.app`, to clear it. (When built
  locally there is usually no quarantine attribute, so this rarely applies.)
- **Font:** uses the system monospaced font at 13pt. btop themes its own colors;
  this app only sets the font and window size.
- **Resize:** the window is resizable; SwiftTerm reflows the PTY and btop adapts.
- **btop path** is hard-coded to `/opt/homebrew/bin/btop` (Apple Silicon Homebrew).
