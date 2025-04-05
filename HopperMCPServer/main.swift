import Logging
import Foundation
import MCPServer
import HelperService
import HelperClient
import HopperServiceInterface

extension Logger {
    static var server: Logger = {
        var log = Logger(label: "com.JH.hoppermcpd") { StreamLogHandler.standardError(label: $0) }
        log.logLevel = .debug
        return log
    }()
}

let helperClient = HelperClient()

try await helperClient.connectToTool(machServiceName: "com.JH.hoppermcpd", isPrivilegedHelperTool: true)

let serverInfos = try await helperClient.availableServerInfos()

for serverInfo in serverInfos {
    if serverInfo.identifier == "com.JH.HopperMCP.Server" {
        try await helperClient.connectToServer(info: serverInfo)
        let server = try await MCPServer(
            info: Implementation(name: "HopperMCP", version: "0.1.0"), capabilities: .init(tools: [
                Tool(name: "Get current assembly code") { (input: GetCurrentAssemblyRequest) in
                    let response = try await helperClient.sendToServer(request: GetCurrentAssemblyRequest(), for: serverInfo)
                    let encoder = JSONEncoder()
                    let data = try encoder.encode(response)
                    let text = String(data: data, encoding: .utf8)!
                    return [.text(.init(text: text))]
                },

            ]),
            transport: .stdio()
        )
        try await server.waitForDisconnection()
    }
}
