import Foundation
import HelperService
import HelperCommunication
import JSONSchemaBuilder
import MCPInterface
import MemberwiseInit

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


public protocol ToolRequestWithDocument: ToolRequest {
    var documentName: String? { get }
}

extension ToolRequest {
    public static var identifier: String { "com.JH.HopperService.\(String(describing: Self.self))" }
}

@Schemable
@MemberwiseInit(.public)
public struct CurrentAssemblyRequest: Codable, ToolRequest {
    public static var name: String { "Get current assembly" }
}

@Schemable
@MemberwiseInit(.public)
public struct CurrentPseudocodeRequest: Codable, ToolRequest {
    public static var name: String { "Get current pseudocode" }
}

@Schemable
@MemberwiseInit(.public)
public struct CurrentAssemblyByDocumentRequest: Codable, ToolRequest {
    public static var name: String { "Get current assembly by document" }
    public let documentName: String
}

@Schemable
@MemberwiseInit(.public)
public struct CurrentPseudocodeByDocumentRequest: Codable, ToolRequest {
    public static var name: String { "Get current pseudocode by document" }
    public let documentName: String
}

@Schemable
@MemberwiseInit(.public)
public struct ListDocumentsRequest: Codable, ToolRequest {
    public static var name: String { "List documents" }
}

@Schemable
@MemberwiseInit(.public)
public struct AddCommentRequest: Codable, ToolRequestWithDocument {
    public static var name: String { "Add comment" }
    public let documentName: String?
    public let comment: String
    public let address: String
}

@Schemable
@MemberwiseInit(.public)
public struct AddInlineCommentRequest: Codable, ToolRequestWithDocument {
    public static var name: String { "Add inline comment" }
    public let documentName: String?
    public let comment: String
    public let address: String
}

@Schemable
@MemberwiseInit(.public)
public struct RenameFunctionByAddressRequest: Codable, ToolRequestWithDocument {
    public static var name: String { "Rename function by address" }
    public let documentName: String?
    public let name: String
    public let address: String
}

@Schemable
@MemberwiseInit(.public)
public struct AssemblyByAddressRequest: Codable, ToolRequestWithDocument {
    public static var name: String { "Get assembly by address" }
    public let documentName: String?
    public let address: String
}

@Schemable
@MemberwiseInit(.public)
public struct PseudocodeByAddressRequest: Codable, ToolRequestWithDocument {
    public static var name: String { "Get pseudocode by address" }
    public let documentName: String?
    public let address: String
}

@Schemable
@MemberwiseInit(.public)
public struct AssemblyByNameRequest: Codable, ToolRequestWithDocument {
    public static var name: String { "Get assembly by name" }
    public let documentName: String?
    public let name: String
}

@Schemable
@MemberwiseInit(.public)
public struct PseudocodeByNameRequest: Codable, ToolRequestWithDocument {
    public static var name: String { "Get pseudocode by name" }
    public let documentName: String?
    public let name: String
}

@Schemable
@MemberwiseInit(.public)
public struct SwiftTypeDescriptionRequest: Codable, ToolRequestWithDocument {
    public static var name: String { "Get Swift type description" }
    public let documentName: String?
    public let typeName: String
}

@Schemable
@MemberwiseInit(.public)
public struct SwiftProtocolDescriptionRequest: Codable, ToolRequestWithDocument {
    public static var name: String { "Get Swift protocol description" }
    public let documentName: String?
    public let protocolName: String
}
