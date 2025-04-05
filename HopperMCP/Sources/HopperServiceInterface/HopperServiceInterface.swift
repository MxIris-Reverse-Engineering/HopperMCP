import Foundation
import HelperService
import HelperCommunication
import JSONSchemaBuilder

@Schemable
public struct GetCurrentAssemblyRequest: Codable, Request {
    public struct Response: HelperCommunication.Response {
        public let result: String
        public init(result: String) {
            self.result = result
        }
    }

    public init() {}
}


@Schemable
public struct GetCurrentPseudoCodeRequest: Codable, Request {
    public struct Response: HelperCommunication.Response {
        public let result: String
        public init(result: String) {
            self.result = result
        }
    }

    public init() {}
}

extension Request {
    public static var identifier: String { "com.JH.HopperService.\(String(describing: Self.self))" }
}
