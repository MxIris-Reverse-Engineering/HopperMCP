//
//  ServerNetworkManager.swift
//  HopperMCPServer
//
//  Created by JH on 2025/4/2.
//

import MCP
import Foundation
import Network
import Logging
import OSLog

private let serviceType = "_mcp._tcp"
private let serviceDomain = "local."

private let log = Logger.server

public actor ServerNetworkManager {
    private var isRunning: Bool = false
    private var isEnabled: Bool = true
    private var listener: NWListener
    private var browser: NWBrowser
    private var connections: [UUID: NWConnection] = [:]
    private var connectionTasks: [UUID: Task<Void, Never>] = [:]
    private var pendingConnections: [UUID: String] = [:]
    private var mcpServers: [UUID: MCP.Server] = [:]

    public typealias ConnectionApprovalHandler = @Sendable (UUID, MCP.Client.Info) async -> Bool

    private var connectionApprovalHandler: ConnectionApprovalHandler?

    private var services: [any Service]

    public init(services: [any Service]) {
        self.services = services
        // Set up Bonjour service
        let parameters = NWParameters.tcp
        parameters.acceptLocalOnly = true
        parameters.includePeerToPeer = false

        if let tcpOptions = parameters.defaultProtocolStack.internetProtocol
            as? NWProtocolIP.Options {
            tcpOptions.version = .v4
        }

        // Create the listener with service discovery
        self.listener = try! NWListener(using: parameters)
        listener.service = NWListener.Service(type: serviceType, domain: serviceDomain)

        // Set up browser for debugging/monitoring
        self.browser = NWBrowser(
            for: .bonjour(type: serviceType, domain: serviceDomain),
            using: parameters
        )

        log.info(
            "Network manager initialized with Bonjour service type: \(serviceType)")
    }

    public func setConnectionApprovalHandler(_ handler: @escaping ConnectionApprovalHandler) {
        log.debug("Setting connection approval handler")
        connectionApprovalHandler = handler
    }

    public func start() async {
        log.info("Starting network manager")
        isRunning = true
        listener.stateUpdateHandler = { state in
            switch state {
            case .ready:
                log.info("Server ready and advertising via Bonjour")
            case let .failed(error):
                log.error("Server failed: \(error)")
            default:
                return
            }
        }

        listener.newConnectionHandler = { [weak self] connection in
            Task {
                await self?.handleNewConnection(connection)
            }
        }

        listener.start(queue: .main)
        browser.start(queue: .main)
    }

    public func stop() async {
        log.info("Stopping network manager")
        isRunning = false

        // Stop all MCP servers
        for (_, server) in mcpServers {
            Task {
                await server.stop()
            }
        }

        // Cancel all connections
        for (id, connection) in connections {
            log.debug("Cancelling connection: \(id)")
            connectionTasks[id]?.cancel()
            connection.cancel()
        }

        listener.cancel()
        browser.cancel()
    }

    nonisolated func removeConnection(_ id: UUID) {
        Task {
            await _removeConnection(id)
        }
    }

    private func _removeConnection(_ id: UUID) {
        log.debug("Removing connection: \(id)")
        // Stop the MCP server if it exists
        if let server = mcpServers[id] {
            Task {
                await server.stop()
            }
            mcpServers.removeValue(forKey: id)
        }

        if let task = connectionTasks[id] {
            task.cancel()
            connectionTasks.removeValue(forKey: id)
        }

        if let connection = connections[id] {
            connection.cancel()
            connections.removeValue(forKey: id)
        }

        pendingConnections.removeValue(forKey: id)
    }

    // Handle new incoming connections
    private func handleNewConnection(_ connection: NWConnection) async {
        let connectionID = UUID()
        log.info("Handling new connection: \(connectionID)")
        connections[connectionID] = connection

        // Set up connection state handler
        connection.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                log.debug("Connection ready")
                Task {
                    if let self = self {
                        await self.setupConnection(
                            connectionID: connectionID,
                            connection: connection
                        )
                    }
                }
            case let .failed(error):
                log.error("Connection failed: \(error)")
                Task {
                    await self?._removeConnection(connectionID)
                }
            case .cancelled:
                log.info("Connection cancelled")
                Task {
                    await self?._removeConnection(connectionID)
                }
            default:
                return
            }
        }

        connection.start(queue: .main)
    }

    private func setupConnection(connectionID: UUID, connection: NWConnection) async {
        let logger = Logger(label: "com.loopwork.mcp-server.\(connectionID)")
        let transport = NetworkTransport(connection: connection, logger: logger)

        // Create the MCP server
        let server = MCP.Server(
            name: Bundle.main.name,
            version: Bundle.main.shortVersionString ?? "unknown",
            capabilities: MCP.Server.Capabilities(
                tools: .init(listChanged: true)
            )
        )

        // Store the server immediately
        mcpServers[connectionID] = server

        // Start the server
        Task {
            do {
                log.notice("Starting MCP server for connection: \(connectionID)")
                try await server.start(transport: transport) { clientInfo, capabilities in
                    log.info("Received initialize request from client: \(clientInfo.name)")

                    // Request user approval
                    var approved = false
                    if let approvalHandler = await self.connectionApprovalHandler {
                        approved = await approvalHandler(connectionID, clientInfo)
                        log.info(
                            "Approval result for connection \(connectionID): \(approved ? "Approved" : "Denied")"
                        )
                    }

                    if !approved {
                        await self._removeConnection(connectionID)
                        throw MCP.Error.connectionClosed
                    }
                }
                log.notice("MCP Server started successfully for connection: \(connectionID)")

                // Register handlers after successful approval
                await self.registerHandlers(for: server)
            } catch {
                log.error("Failed to start MCP server: \(error.localizedDescription)")
                _removeConnection(connectionID)
            }
        }
    }

    private func registerHandlers(for server: MCP.Server) async {
        // Register prompts/list handler
        await server.withMethodHandler(ListPrompts.self) { _ in
            log.debug("Handling ListPrompts request")
            return ListPrompts.Result(prompts: [])
        }

        // Register the resources/list handler
        await server.withMethodHandler(ListResources.self) { _ in
            log.debug("Handling ListResources request")
            return ListResources.Result(resources: [])
        }

        // Update tools/list handler with proper actor isolation
        await server.withMethodHandler(ListTools.self) { [self] _ in
            log.debug("Handling ListTools request")

            var tools: [MCP.Tool] = []
            if await self.isEnabled {
                for service in await self.services {
                    let serviceId = String(describing: type(of: service))

                    for tool in service.tools {
                        log.debug("Adding tool: \(tool.name)")
                        tools.append(
                            .init(
                                name: tool.name,
                                description: tool.description,
                                inputSchema: tool.inputSchema
                            )
                        )
                    }
                }
            }

            log.info("Returning \(tools.count) available tools")
            return ListTools.Result(tools: tools)
        }

        // Update tools/call handler with proper actor isolation
        await server.withMethodHandler(CallTool.self) { [self] params in
            log.notice("Tool call received: \(params.name)")

            guard await self.isEnabled else {
                log.notice("Tool call rejected: \(Bundle.main.name) is disabled")
                return CallTool.Result(
                    content: [.text("\(Bundle.main.name) is currently disabled. Please enable it to use tools.")],
                    isError: true
                )
            }

            for service in await self.services {
                let serviceId = String(describing: type(of: service))

                do {
                    if let value = try await service.call(
                        tool: params.name,
                        with: params.arguments ?? [:]
                    ) {
                        log.notice("Tool \(params.name) executed successfully")
                        let encoder = JSONEncoder()
                        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
                        let data = try encoder.encode(value)
                        let text = String(data: data, encoding: .utf8)!
                        return CallTool.Result(content: [.text(text)], isError: false)
                    }
                } catch {
                    log.error("Error executing tool \(params.name): \(error.localizedDescription)")
                    return CallTool.Result(content: [.text("Error: \(error)")], isError: true)
                }
            }

            log.error("Tool not found or service not enabled: \(params.name)")
            return CallTool.Result(
                content: [.text("Tool not found or service not enabled: \(params.name)")],
                isError: true
            )
        }
    }

    // Update the enabled state and notify clients
    public func setEnabled(_ enabled: Bool) async {
        // Only do something if the state actually changes
        guard isEnabled != enabled else { return }

        isEnabled = enabled
        log.info("\(Bundle.main.name) enabled state changed to: \(enabled)")

        // Notify all connected clients that the tool list has changed
        for (connectionID, server) in mcpServers {
            // Check if the connection is still active before sending notification
            if let connection = connections[connectionID], connection.state == .ready {
                Task {
                    do {
                        log.info(
                            "Notified client that tool list changed. Tools are now \(enabled ? "enabled" : "disabled")"
                        )
                        try await server.notify(ToolListChangedNotification.message())
                    } catch {
                        log.error("Failed to notify client of tool list change: \(error)")

                        // If the error is related to connection issues, clean up the connection
                        if let nwError = error as? NWError,
                           nwError.errorCode == 57 // Socket is not connected
                           || nwError.errorCode == 54 { // Connection reset by peer
                            log.debug("Connection appears to be closed, removing it")
                            _removeConnection(connectionID)
                        }
                    }
                }
            } else {
                log.debug("Connection \(connectionID) is no longer active, removing it")
                _removeConnection(connectionID)
            }
        }
    }
}
