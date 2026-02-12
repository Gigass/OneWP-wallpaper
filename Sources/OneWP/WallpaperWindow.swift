import AppKit
import WebKit

class WallpaperWindow: NSWindow {
    private var webView: WKWebView!

    init(screen: NSScreen) {
        super.init(
            contentRect: screen.frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )

        level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopWindow)) + 1)
        collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        isOpaque = false
        backgroundColor = .black
        ignoresMouseEvents = true
        hasShadow = false

        let config = WKWebViewConfiguration()
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")

        webView = WKWebView(frame: screen.frame, configuration: config)
        webView.autoresizingMask = [.width, .height]
        webView.setValue(false, forKey: "drawsBackground")

        contentView = webView
        loadHTML()
    }

    func updateToScreen(_ screen: NSScreen) {
        setFrame(screen.frame, display: true)
    }

    private func loadHTML() {
        guard let url = Bundle.module.url(forResource: "wallpaper", withExtension: "html") else {
            print("Error: wallpaper.html not found in bundle")
            return
        }
        webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
    }
}
