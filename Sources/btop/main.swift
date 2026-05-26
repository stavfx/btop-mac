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

        terminal.startProcess(executable: btopPath, args: [], environment: env)

        NSApp.activate(ignoringOtherApps: true)
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
