import AppKit

@main
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        _ = MainStatusItemController.shared
        showMainWindow()
    }

    @objc func showMainWindow() {
        MainWindowController.shared.showWindow(nil)
        NSApplication.shared.setActivationPolicy(.regular)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }
}
