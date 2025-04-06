import Foundation
import HelperService
import HelperCommunication
import JSONSchemaBuilder
import MCPInterface

public struct ToolResponse: Codable {
    public let results: [String]
    
    public static func result(_ result: String) -> ToolResponse {
        ToolResponse(results: [result])
    }
    
    public static func results(_ results: [String]) -> ToolResponse {
        ToolResponse(results: results)
    }
}

public protocol ToolRequest: HelperCommunication.Request, Schemable where Self.Schema.Output == Self, Self.Response == ToolResponse {
    static var name: String { get }
}

extension ToolRequest {
    public static var identifier: String { "com.JH.HopperService.\(String(describing: Self.self))" }
}

@Schemable
public struct CurrentAssemblyRequest: Codable, ToolRequest {
    public static var name: String { "Get current assembly" }
    public init() {}
}

@Schemable
public struct CurrentPseudocodeRequest: Codable, ToolRequest {
    public static var name: String { "Get current pseudocode" }
    public init() {}
}

@Schemable
public struct CurrentAssemblyByDocumentRequest: Codable, ToolRequest {
    public static var name: String { "Get current assembly by document" }
    public let documentName: String

    public init(documentName: String) {
        self.documentName = documentName
    }
}

@Schemable
public struct CurrentPseudocodeByDocumentRequest: Codable, ToolRequest {
    public static var name: String { "Get current pseudocode by document" }
    public let documentName: String

    public init(documentName: String) {
        self.documentName = documentName
    }
}

@Schemable
public struct ListDocumentsRequest: Codable, ToolRequest {
    public static var name: String { "List documents" }
    public init() {}
}
