import OSLog
import Foundation
import MCPServer
import HelperService
import HelperClient
import HopperServiceInterface
import JSONSchemaBuilder

extension Logger {
    static var server: Logger = .init(subsystem: "com.JH.HopperMCPServer", category: "HopperMCPServer")
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
            info: Implementation(name: "HopperMCP", version: "0.1.0"),
            capabilities: .init(
                tools: [
                    makeTool(for: ListDocumentsRequest.self),
                    makeTool(for: CurrentAssemblyRequest.self),
                    makeTool(for: CurrentPseudocodeRequest.self),
                    makeTool(for: CurrentAssemblyByDocumentRequest.self),
                    makeTool(for: CurrentPseudocodeByDocumentRequest.self),
                    makeTool(for: AddCommentRequest.self),
                    makeTool(for: AddInlineCommentRequest.self),
//                    makeTool(for: RenameFunctionByAddressRequest.self),
                    makeTool(for: AssemblyByNameRequest.self),
                    makeTool(for: AssemblyByAddressRequest.self),
                    makeTool(for: PseudocodeByNameRequest.self),
                    makeTool(for: PseudocodeByAddressRequest.self),
                    makeTool(for: SwiftTypeDescriptionRequest.self),
                    makeTool(for: SwiftProtocolDescriptionRequest.self),
                ]),
            transport: .stdio()
        )
        try await server.waitForDisconnection()
    }
}
