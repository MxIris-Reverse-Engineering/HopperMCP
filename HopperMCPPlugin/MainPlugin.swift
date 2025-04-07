@preconcurrency import Hopper
@preconcurrency import HopperMCPCore
import Foundation

@objc(HopperMCPMainPlugin)
class MainPlugin: NSObject, HopperTool, @unchecked Sendable {
    let services: HPHopperServices

    var server: HelperServer?

    static func sdkVersion() -> Int32 {
        return HOPPER_CURRENT_SDK_VERSION
    }

    func pluginType() -> HopperPluginType {
        return .Plugin_Tool
    }

    func pluginUUID() -> HPHopperUUID {
        return services.uuid(with: "b2bbe202-3add-4f70-99c2-3682778bb078")
    }

    func pluginName() -> String {
        return "Hopper MCP Plugin"
    }

    func pluginDescription() -> String {
        return "Hopper Plugin for MCP"
    }

    func pluginAuthor() -> String {
        return "Mx-Iris"
    }

    func pluginCopyright() -> String {
        return "© Cryptic JH"
    }

    func commandLineIdentifiers() -> [String] {
        return ["HopperMCPMainPlugin"]
    }

    func pluginVersion() -> String {
        return "0.1.0"
    }

    required init(hopperServices services: HPHopperServices) {
        self.services = services
        super.init()
    }

    func toolMenuDescription() -> [[String: Any]] {
        return [
            [
                HPM_TITLE: "Start MCP Plugin",
                HPM_SELECTOR: NSStringFromSelector(#selector(startPluginServer(_:))),
            ],

            [
                HPM_TITLE: "Stop MCP Plugin",
                HPM_SELECTOR: NSStringFromSelector(#selector(stopPluginServer(_:))),
            ],
            [
                HPM_TITLE: "Reload Tool Plugins",
                HPM_SELECTOR: NSStringFromSelector(#selector(reloadToolPlugins(_:))),
            ]
        ]
    }

    @objc func startPluginServer(_ sender: Any?) {
        Task { @MainActor in
            do {
                let server = try await HelperServer(serverType: .plain(name: "Hopper", identifier: "com.JH.HopperMCP.Server"), services: [HopperService(services: services)])
                await server.activate()
                try await server.connectToTool(machServiceName: "com.JH.hoppermcpd", isPrivilegedHelperTool: true)
                services.logMessage("Connected to helper tool")
                self.server = server
            } catch {
                services.logMessage("\(error)")
            }
        }
    }

    @objc func stopPluginServer(_ sender: Any?) {}

    @objc func reloadToolPlugins(_ sender: Any?) {
        Dynamic.ToolFactory.loadPluginsIncludingUserPlugins(true)
    }
    
    deinit {
        services.logMessage("Deinit \(self)")
    }
}
