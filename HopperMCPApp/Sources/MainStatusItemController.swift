import AppKit
import SwiftUI
import StatusItemController

final class MainStatusItemController: StatusItemController {
    static let shared = MainStatusItemController()

    init() {
        let image = NSImage(named: "StatusItem")!
        image.size = .init(width: 22, height: 22)
        super.init(image: image)
    }

    override func buildMenu() -> NSMenu {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Show Main Window", action: #selector(AppDelegate.showMainWindow), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: ""))
        return menu
    }

    override func leftClickAction() {
        openMenu()
    }
}
