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

@Schemable
public struct AddCommentRequest: Codable, ToolRequest {
    public static var name: String { "Add comment" }
    public let comment: String
    public let address: Int

    public init(comment: String, address: Int) {
        self.comment = comment
        self.address = address
    }
}

@Schemable
public struct AddInlineCommentRequest: Codable, ToolRequest {
    public static var name: String { "Add inline comment" }
    public let comment: String
    public let address: Int

    public init(comment: String, address: Int) {
        self.comment = comment
        self.address = address
    }
}


@Schemable
public struct RenameFunctionByAddressRequest: Codable, ToolRequest {
    public static var name: String { "Rename function by address" }
    public let name: String
    public let address: Int

    public init(name: String, address: Int) {
        self.name = name
        self.address = address
    }
}

@Schemable
public struct AssemblyByAddressRequest: Codable, ToolRequest {
    public static var name: String { "Get assembly by address" }
    public let address: Int

    public init(address: Int) {
        self.address = address
    }
}

@Schemable
public struct PseudocodeByAddressRequest: Codable, ToolRequest {
    public static var name: String { "Get pseudocode by address" }
    public let address: Int

    public init(address: Int) {
        self.address = address
    }
}

@Schemable
public struct AssemblyByNameRequest: Codable, ToolRequest {
    public static var name: String { "Get assembly by name" }
    public let name: String

    public init(name: String) {
        self.name = name
    }
}

@Schemable
public struct PseudocodeByNameRequest: Codable, ToolRequest {
    public static var name: String { "Get pseudocode by name" }
    public let name: String

    public init(name: String) {
        self.name = name
    }
}

@Schemable
public struct SwiftTypeDescriptionRequest: Codable, ToolRequest {
    public static var name: String { "Get Swift type description" }
    public let typeName: String

    public init(typeName: String) {
        self.typeName = typeName
    }
}

@Schemable
public struct SwiftProtocolDescriptionRequest: Codable, ToolRequest {
    public static var name: String { "Get Swift protocol description" }
    public let protocolName: String

    public init(protocolName: String) {
        self.protocolName = protocolName
    }
}

