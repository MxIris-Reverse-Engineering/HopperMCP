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

// Create browser at top level
let browser = NWBrowser(
    for: .bonjour(type: serviceType, domain: nil),
    using: parameters
)
Logger.server.info("Created Bonjour browser for service type: \(serviceType)")

actor ConnectionState {
    private var hasResumed = false

    func checkAndSetResumed() -> Bool {
        if !hasResumed {
            hasResumed = true
            return true
        }
        return false
    }
}

// Create MCPService class to manage lifecycle
actor MCPService: Service {
    let browser: NWBrowser
    private var currentProxy: StdioProxy?

    init() {
        self.browser = NWBrowser(
            for: .bonjour(type: serviceType, domain: nil),
            using: parameters
        )
        Logger.server.info("Created Bonjour browser for service type: \(serviceType)")
    }

    func run() async throws {
        while true {
            do {
                Logger.server.info("Starting Bonjour service discovery...")

                // Find and connect to iMCP app
                let endpoint: NWEndpoint = try await withCheckedThrowingContinuation {
                    continuation in
                    let connectionState = ConnectionState()

                    // Convert async handlers to sync handlers
                    browser.stateUpdateHandler = { state in
                        if case let .failed(error) = state {
                            Task {
                                Logger.server.error("Browser failed: \(error)")
                                if await connectionState.checkAndSetResumed() {
                                    continuation.resume(throwing: error)
                                }
                            }
                        }
                        Task {
                            Logger.server.debug("Browser state changed: \(state)")
                        }
                    }

                    browser.browseResultsChangedHandler = { results, changes in
                        Task {
                            Logger.server.debug("Found \(results.count) Bonjour services")
                            if let endpoint = results.first?.endpoint {
                                if await connectionState.checkAndSetResumed() {
                                    Logger.server.info("Selected endpoint: \(endpoint)")
                                    continuation.resume(returning: endpoint)
                                }
                            }
                        }
                    }

                    Task {
                        Logger.server.debug("Starting Bonjour browser...")
                    }
                    browser.start(queue: .main)
                }

                Logger.server.info("Creating connection to endpoint...")

                // Create the proxy
                let proxy = StdioProxy(
                    endpoint: endpoint,
                    parameters: parameters,
                    stdinBufferSize: 8192,
                    networkBufferSize: 8192
                )
                currentProxy = proxy

                do {
                    try await proxy.start()
                } catch let error as StdioProxyError {
                    switch error {
                    case .stdinTimeout:
                        Logger.server.info("Stdin timed out, will reconnect...")
                        try await Task.sleep(for: .seconds(1))
                        continue
                    case .networkTimeout:
                        Logger.server.info("Network timed out, will reconnect...")
                        try await Task.sleep(for: .seconds(1))
                        continue
                    case .connectionClosed:
                        Logger.server.critical("Connection closed, terminating...")
                        return
                    }
                } catch let error as NWError where error.errorCode == 54 || error.errorCode == 57 {
                    // Handle connection reset by peer (54) or socket not connected (57)
                    Logger.server.critical("Network connection terminated: \(error), shutting down...")
                    return
                } catch {
                    // Rethrow other errors to be handled by the outer catch block
                    throw error
                }
            } catch {
                // Handle all other errors with retry
                Logger.server.error("Connection error: \(error)")
                Logger.server.info("Will retry connection in 5 seconds...")
                try await Task.sleep(for: .seconds(5))
            }
        }
    }

    func shutdown() async throws {
        browser.cancel()
        if let proxy = currentProxy {
            await proxy.stop()
        }
    }
}

// Update the ServiceLifecycle initialization
let lifecycle = ServiceGroup(
    configuration: .init(
        services: [MCPService()],
        logger: Logger.server
    )
)

try await lifecycle.run()
