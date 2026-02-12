import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    private var windows: [WallpaperWindow] = []
    private var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        setupStatusItem()
        createWindows()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenDidChange),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "sparkles", accessibilityDescription: "Wallpaper")
        }

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Cosmic Flow Wallpaper", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        statusItem.menu = menu
    }

    private func createWindows() {
        windows.forEach { $0.close() }
        windows.removeAll()

        for screen in NSScreen.screens {
            let window = WallpaperWindow(screen: screen)
            window.orderFront(nil)
            windows.append(window)
        }
    }

    @objc private func screenDidChange() {
        createWindows()
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
