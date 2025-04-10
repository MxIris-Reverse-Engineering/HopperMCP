import AppKit
import SwiftUI
import MenuBarExtraAccess

@main
struct HopperMCPApp: App {
    @State var isMenuPresented: Bool = false
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(.init(width: 400, height: 300))
        .defaultPosition(.center)
        
        MenuBarExtra("HopperMCPApp", systemImage: "message.fill") {
            MenuView(isMenuPresented: $isMenuPresented)
        }
        .menuBarExtraStyle(.window) // required for menu builder
        .menuBarExtraAccess(isPresented: $isMenuPresented) // required for menu builder
    }
}
