@preconcurrency
public protocol Service {
    @ToolBuilder var tools: [Tool] { get }

    var isActivated: Bool { get async }
    func activate() async throws
}

extension Service {
    public var isActivated: Bool {
        get async {
            return true
        }
    }

    public func activate() async throws {}

    public func call(tool name: String, with arguments: [String: Value]) async throws -> Value? {
        for tool in tools where tool.name == name {
            return try await tool.callAsFunction(arguments)
        }

        return nil
    }
}

@resultBuilder
public struct ToolBuilder {
    public static func buildBlock(_ tools: Tool...) -> [Tool] {
        tools
    }
}
