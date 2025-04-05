//
//  WindowController.swift
//  HopperMCPApp
//
//  Created by JH on 2025/4/5.
//

import AppKit

enum AppDefaults {
    static let defaultWindowRect = NSRect(x: 0, y: 0, width: 800, height: 600)
}

final class WindowController: NSWindowController {
    override var windowNibName: NSNib.Name? { "" }

    lazy var viewController = ViewController()

    init() {
        super.init(window: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadWindow() {
        window = NSWindow(contentRect: AppDefaults.defaultWindowRect, styleMask: [.titled, .closable], backing: .buffered, defer: false)
        window?.center()
        window?.title = "HopperMCP"
        window?.titlebarAppearsTransparent = true
    }

    override func windowDidLoad() {
        super.windowDidLoad()

        contentViewController = viewController
    }
}
