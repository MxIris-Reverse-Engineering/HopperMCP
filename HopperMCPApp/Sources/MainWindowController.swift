//
//  MainWindowController.swift
//  HopperMCPApp
//
//  Created by JH on 2025/4/13.
//

import AppKit
import SwiftUI

final class MainWindowController: NSWindowController, NSWindowDelegate {
    
    static let shared = MainWindowController()
    
    lazy var mainViewController = MainViewController()

    override var windowNibName: NSNib.Name? { "" }

    init() {
        super.init(window: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadWindow() {
        window = NSWindow(contentViewController: mainViewController)
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        window?.title = "Hopper MCP"
        window?.center()
        window?.styleMask.remove(.resizable)
        window?.titlebarAppearsTransparent = true
        window?.setFrameAutosaveName("Main Window")
        window?.delegate = self
    }
    
    
    func windowWillClose(_ notification: Notification) {
        NSApplication.shared.setActivationPolicy(.accessory)
    }
}


