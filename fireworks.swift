import AppKit
import WebKit

let app = NSApplication.shared
app.setActivationPolicy(.accessory)

let home = FileManager.default.homeDirectoryForCurrentUser.path
let screen = NSScreen.main ?? NSScreen.screens[0]
let W = screen.frame.width
let H = screen.frame.height

let window = NSWindow(
    contentRect: CGRect(x: 0, y: 0, width: W, height: H),
    styleMask: [.borderless], backing: .buffered, defer: false
)
window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.screenSaverWindow)))
window.backgroundColor = .clear
window.isOpaque = false
window.hasShadow = false
window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
window.alphaValue = 0

let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: W, height: H))
webView.setValue(false, forKey: "drawsBackground")

let htmlURL = URL(fileURLWithPath: "\(home)/.claude/avocado-hook/avocado.html")
webView.loadFileURL(htmlURL, allowingReadAccessTo: htmlURL)

window.contentView = webView
window.makeKeyAndOrderFront(nil)

DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
    NSAnimationContext.runAnimationGroup { ctx in ctx.duration = 0.3; window.animator().alphaValue = 1 }
}

DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
    NSAnimationContext.runAnimationGroup({ ctx in
        ctx.duration = 0.4
        window.animator().alphaValue = 0
    }, completionHandler: { app.terminate(nil) })
}

app.run()
