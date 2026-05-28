import AppKit
import SwiftTerm

// Path to the btop binary installed via Homebrew.
let btopPath = "/opt/homebrew/bin/btop"

final class AppDelegate: NSObject, NSApplicationDelegate, LocalProcessTerminalViewDelegate {
    var window: NSWindow!
    var terminal: LocalProcessTerminalView!

    func applicationDidFinishLaunching(_ notification: Notification) {
        installMainMenu()

        let frame = NSRect(x: 0, y: 0, width: 1000, height: 640)

        terminal = LocalProcessTerminalView(frame: frame)
        terminal.processDelegate = self
        terminal.font = NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)

        window = NSWindow(
            contentRect: frame,
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "btop"
        window.contentView = terminal
        window.center()
        window.makeKeyAndOrderFront(nil)
        window.makeFirstResponder(terminal)

        // Pass through the current environment plus a sane TERM.
        var env = Terminal.getEnvironmentVariables(termName: "xterm-256color")
        if let path = ProcessInfo.processInfo.environment["PATH"] {
            env.append("PATH=\(path)")
        }

        if FileManager.default.isExecutableFile(atPath: btopPath) {
            terminal.startProcess(executable: btopPath, args: [], environment: env)
        } else {
            startInstallHelper(environment: env)
        }

        NSApp.activate(ignoringOtherApps: true)
    }

    // btop is missing. Spawn an interactive zsh with the prompt pre-filled with
    // `brew install btop` (via zsh's `print -z`) and a friendly message above it.
    // After installing, the user closes the window and relaunches the app.
    private func startInstallHelper(environment baseEnv: [String]) {
        // Apps launched from Finder don't inherit the user's shell PATH, so make
        // sure /opt/homebrew/bin is on PATH for `brew` to resolve.
        var env = baseEnv
        if let i = env.firstIndex(where: { $0.hasPrefix("PATH=") }) {
            let existing = String(env[i].dropFirst("PATH=".count))
            env[i] = "PATH=/opt/homebrew/bin:\(existing)"
        } else {
            env.append("PATH=/opt/homebrew/bin:/usr/bin:/bin")
        }
        if env.first(where: { $0.hasPrefix("HOME=") }) == nil {
            env.append("HOME=\(NSHomeDirectory())")
        }

        // Stage a private ZDOTDIR so we can run a one-off .zshrc without touching
        // the user's real one. `print -z` queues text into zsh's line editor so it
        // appears on the next prompt with the cursor at the end, ready to edit/Enter.
        let dir = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("btop-installer-\(UUID().uuidString)")
        // If Homebrew itself is missing, guide the user to install it first.
        // After that they relaunch the app, which then triggers the btop-install
        // branch below (a clean two-step flow rather than a fragile chained one).
        let brewMissing = !FileManager.default.isExecutableFile(atPath: "/opt/homebrew/bin/brew")
        let rc: String
        if brewMissing {
            rc = """
            print -P '%F{yellow}Homebrew is not installed.%f'
            print 'btop is installed via Homebrew, but Homebrew is not present.'
            print
            print 'Press Enter to install Homebrew (or Ctrl-C to cancel).'
            print 'This may take a few minutes; you may be prompted for your password.'
            print
            print -z '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && brew install btop && btop'
            """
        } else {
            rc = """
            print -P '%F{yellow}btop is not installed.%f'
            print 'This app launches /opt/homebrew/bin/btop, but it is not there.'
            print
            print 'Press Enter to install it via Homebrew (or Ctrl-C to cancel).'
            print 'The install takes about a minute; btop will launch when it finishes.'
            print
            print -z 'brew install btop && btop'
            """
        }
        do {
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            try rc.write(to: dir.appendingPathComponent(".zshrc"), atomically: true, encoding: .utf8)
        } catch {
            // If staging fails, just spawn a bare shell so the user isn't stuck.
            terminal.startProcess(executable: "/bin/zsh", args: ["-i"], environment: env)
            return
        }
        env.append("ZDOTDIR=\(dir.path)")

        terminal.startProcess(executable: "/bin/zsh", args: ["-i"], environment: env)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    // A minimal menu so standard shortcuts (⌘Q quit, ⌘W close) work. Without it
    // ⌘Q has no target and the keystroke leaks into the terminal / btop.
    private func installMainMenu() {
        let mainMenu = NSMenu()

        let appItem = NSMenuItem()
        mainMenu.addItem(appItem)
        let appMenu = NSMenu()
        appItem.submenu = appMenu
        appMenu.addItem(withTitle: "Quit btop",
                        action: #selector(NSApplication.terminate(_:)),
                        keyEquivalent: "q")

        let windowItem = NSMenuItem()
        mainMenu.addItem(windowItem)
        let windowMenu = NSMenu(title: "Window")
        windowItem.submenu = windowMenu
        windowMenu.addItem(withTitle: "Close",
                           action: #selector(NSWindow.performClose(_:)),
                           keyEquivalent: "w")

        NSApp.mainMenu = mainMenu
    }

    // MARK: - LocalProcessTerminalViewDelegate

    func processTerminated(source: TerminalView, exitCode: Int32?) {
        NSApp.terminate(nil)
    }

    func sizeChanged(source: LocalProcessTerminalView, newCols: Int, newRows: Int) {}

    func setTerminalTitle(source: LocalProcessTerminalView, title: String) {
        // btop sets its own title; keep the menu-bar / window identity as "btop".
        window.title = "btop"
    }

    func hostCurrentDirectoryUpdate(source: TerminalView, directory: String?) {}
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.regular)
app.run()
