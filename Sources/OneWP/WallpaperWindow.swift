import AppKit
import WebKit

class WallpaperWindow: NSWindow, WKNavigationDelegate {
    private var webView: WKWebView!
    private var keepAliveTimer: Timer?

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
        isReleasedWhenClosed = false

        let config = WKWebViewConfiguration()
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        config.suppressesIncrementalRendering = false

        webView = WKWebView(frame: screen.frame, configuration: config)
        webView.autoresizingMask = [.width, .height]
        webView.setValue(false, forKey: "drawsBackground")
        webView.navigationDelegate = self

        contentView = webView
        loadHTML()
        startKeepAlive()
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

    private func startKeepAlive() {
        keepAliveTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.webView.evaluateJavaScript("1") { _, _ in }
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.loadHTML()
        }
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.loadHTML()
        }
    }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        loadHTML()
    }

    deinit {
        keepAliveTimer?.invalidate()
    }
}
