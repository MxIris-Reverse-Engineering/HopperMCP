import Logging
import MCP
import Network
import ServiceLifecycle
import SystemPackage
import struct Foundation.Data
import class Foundation.RunLoop

extension Logger {
    static var server: Logger = {
        var log = Logger(label: "com.loopwork.iMCP.server") { StreamLogHandler.standardError(label: $0) }
        log.logLevel = .debug
        return log
    }()
}

// Network setup
let serviceType = "_mcp._tcp"
let parameters = NWParameters.tcp
parameters.acceptLocalOnly = true
parameters.includePeerToPeer = false

if let tcpOptions = parameters.defaultProtocolStack.internetProtocol as? NWProtocolIP.Options {
    tcpOptions.version = .v4
}

/// Create browser at top level
let browser = NWBrowser(
    for: .bonjour(type: serviceType, domain: nil),
    using: parameters
)
Logger.server.info("Created Bonjour browser for service type: \(serviceType)")

/// Update the ServiceLifecycle initialization
let lifecycle = ServiceGroup(
    configuration: .init(
        services: [MCPService()],
        logger: Logger.server
    )
)

try await lifecycle.run()
