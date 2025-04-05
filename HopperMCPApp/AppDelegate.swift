//
//  AppDelegate.swift
//  HopperMCPApp
//
//  Created by JH on 2025/4/3.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    lazy var windowController = WindowController()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        windowController.showWindow(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {}

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
