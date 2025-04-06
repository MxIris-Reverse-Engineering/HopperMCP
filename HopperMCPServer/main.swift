import Logging
import Foundation
import MCPServer
import HelperService
import HelperClient
import HopperServiceInterface
import JSONSchemaBuilder

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
        func makeTool<Request: ToolRequest>(for requestType: Request.Type) -> Tool<Request> {
            Tool(name: Request.name) { (input: Request) in
                try await helperClient.sendToServer(request: input, for: serverInfo).results.map { .text(.init(text: $0)) }
            }
        }
        let server = try await MCPServer(
            info: Implementation(name: "HopperMCP", version: "0.1.0"), capabilities: .init(tools: [
                makeTool(for: ListDocumentsRequest.self),
                makeTool(for: CurrentAssemblyRequest.self),
                makeTool(for: CurrentPseudocodeRequest.self),
                makeTool(for: CurrentAssemblyByDocumentRequest.self),
                makeTool(for: CurrentPseudocodeByDocumentRequest.self),
            ]),
            transport: .stdio()
        )
        try await server.waitForDisconnection()
    }
}
