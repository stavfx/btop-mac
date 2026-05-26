# btop-app

A minimal macOS `.app` bundle that launches [`btop`](https://github.com/aristocratos/btop)
as if it were a standalone application — type "btop" in Spotlight/Alfred (or click
the app) and it opens in iTerm.

Because `btop` is a terminal TUI it needs a real terminal/PTY to render, so this
launcher drives **iTerm** rather than trying to draw btop itself. If a btop window
is already open it gets focused instead of opening a duplicate (the same
focus-or-launch behavior as the scrcpy Alfred workflow).

## Layout

```
btop.app/
  Contents/
    Info.plist            # bundle metadata; LSUIElement hides the launcher's own Dock icon
    MacOS/btop            # the launcher script (focus existing btop, else open new iTerm window)
    Resources/            # optional btop.icns goes here
install.sh                # symlink into ~/Applications + register with Launch Services
```

## Install

```sh
./install.sh
```

This symlinks `btop.app` into `~/Applications` and registers it, so edits in this
repo take effect immediately. Prefer a copy instead of a symlink? Replace the
`ln -s` line in `install.sh` with `cp -R`.

## Requirements

- `btop` at `/opt/homebrew/bin/btop` (`brew install btop`)
- iTerm

## Custom icon (optional)

Drop a `btop.icns` into `btop.app/Contents/Resources/` (the `Info.plist` already
points `CFBundleIconFile` at `btop`), then re-run `./install.sh`.
