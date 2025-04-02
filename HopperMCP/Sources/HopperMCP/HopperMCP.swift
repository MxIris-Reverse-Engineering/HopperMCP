import os.log
import Network
import Semaphore
import Foundation
import Asynchrone

//public protocol CommandRequest: Codable {
//    associatedtype Response: CommandResponse
//
//    static var identifier: String { get }
//}
//
//public protocol CommandResponse: Codable {}
//
//public struct VoidResponse: CommandResponse, Codable {
//    public init() {}
//
//    public static let empty: VoidResponse = .init()
//}
//
//private struct CommandNull: Codable {
//    static let null = CommandNull()
//}
//
//public struct CommandError: Error, Codable {
//    public let message: String
//}
//
//public struct CommandData: Codable {
//    public let identifier: String
//
//    public let data: Data
//
//    public init(identifier: String, data: Data) {
//        self.identifier = identifier
//        self.data = data
//    }
//
//    public init<Value: Codable>(identifier: String, value: Value) throws {
//        self.identifier = identifier
//        self.data = try JSONEncoder().encode(value)
//    }
//
//    public init<Request: CommandRequest>(request: Request) throws {
//        self.identifier = Request.identifier
//        self.data = try JSONEncoder().encode(request)
//    }
//}
//
//public enum ConnectionError: Error {
//    case notConnected
//    case invalidPort
//    case receiveFailed
//}
//
//package final class CommandHandler {
//    typealias RawHandler = (Data) async throws -> Data
//    let closure: RawHandler
//    let requestType: Codable.Type
//    let responseType: Codable.Type
//
//    init<Request: Codable, Response: Codable>(closure: @escaping (Request) async throws -> Response) {
//        self.requestType = Request.self
//        self.responseType = Response.self
//
//        self.closure = { request in
//            let request = try JSONDecoder().decode(Request.self, from: request)
//            let response = try await closure(request)
//            return try JSONEncoder().encode(response)
//        }
//    }
//}
//
//public final class CommandConnection {
//    private typealias ReceiveType = (Data?, NWConnection.ContentContext?, Bool, NWError?) -> Void
//
//    public let id = UUID()
//
//    public var didStop: ((CommandConnection) -> Void)?
//
//    public var didReady: ((CommandConnection) -> Void)?
//
//    private let connection: NWConnection
//
//    private static let logger = Logger(subsystem: "com.JH.HopperMCP", category: "Connection")
//
//    private static let endMarkerData = "\nOK".data(using: .utf8)!
//
//    private var logger: Logger { CommandConnection.logger }
//
//    private let queue = DispatchQueue(label: "com.JH.HopperMCP.Connection.queue")
//
//    private var connectionStateStream: AsyncStream<NWConnection.State>?
//
//    private var connectionStateContinuation: AsyncStream<NWConnection.State>.Continuation?
//
//    private var receivedDataStream: SharedAsyncSequence<AsyncThrowingStream<Data, Error>>?
//
//    private var receivedDataContinuation: AsyncThrowingStream<Data, Error>.Continuation?
//
//    private var isStarted = false
//
//    private var receivingData = Data()
//
//    private let semaphore = AsyncSemaphore(value: 1)
//
//    package var commandHandlers: [String: CommandHandler] = [:]
//
//    /// outgoing connection
//    public init(endpoint: NWEndpoint) throws {
//        CommandConnection.logger.info("Connection outgoing endpoint: \(endpoint.debugDescription)")
//        let tcpOptions = NWProtocolTCP.Options()
//        tcpOptions.enableKeepalive = true
//        tcpOptions.keepaliveIdle = 2
//
//        let parameters = NWParameters(tls: nil, tcp: tcpOptions)
//        parameters.includePeerToPeer = true
//        self.connection = NWConnection(to: endpoint, using: parameters)
//        try start()
//    }
//
//    /// incoming connection
//    public init(connection: NWConnection) throws {
//        CommandConnection.logger.info("Connection incoming connection: \(connection.debugDescription)")
//        self.connection = connection
//        try start()
//    }
//
//    public func start() throws {
//        guard !isStarted else { return }
//        isStarted = true
//        CommandConnection.logger.info("Connection will start")
//        setupStreams()
//        setupStateUpdateHandler()
//        setupReceiver()
//        observeIncomingMessages()
//        connection.start(queue: queue)
//        CommandConnection.logger.info("Connection did start")
//    }
//
//    public func stop() {
//        guard isStarted else { return }
//        isStarted = false
//        CommandConnection.logger.info("Connection will stop")
//        connection.stateUpdateHandler = nil
//        connection.cancel()
//        connectionStateContinuation?.finish()
//        receivedDataContinuation?.finish()
//        didStop?(self)
//        didStop = nil
//        CommandConnection.logger.info("Connection did stop")
//    }
//
//    public func setCommandHandler<Request: Codable, Response: Codable>(name: String, handler: @escaping ((Request) async throws -> Response)) {
//        commandHandlers[name] = .init(closure: handler)
//    }
//
//    public func setCommandHandler<Request: CommandRequest>(_ handler: @escaping ((Request) async throws -> Request.Response)) {
//        commandHandlers[Request.identifier] = .init(closure: handler)
//    }
//
//    public func send(requestData: CommandData) async throws {
//        await semaphore.wait()
//        defer { semaphore.signal() }
//        logger.info("Connection send identifier: \(requestData.identifier)")
//        try await send(content: requestData)
//    }
//
//    public func send<Response: Codable>(requestData: CommandData) async throws -> Response {
//        await semaphore.wait()
//        defer { semaphore.signal() }
//        logger.info("Connection send identifier: \(requestData.identifier)")
//        try await send(content: requestData)
//        let receiveData = try await receiveData()
//        let responseData = try JSONDecoder().decode(CommandData.self, from: receiveData)
//        logger.info("Connection received identifier: \(responseData.identifier)")
//        logger.info("Connection received data: \(receiveData)")
//        return try JSONDecoder().decode(Response.self, from: responseData.data)
//    }
//
//    public func send<Request: CommandRequest>(request: Request) async throws {
//        let requestData = try CommandData(request: request)
//        try await send(requestData: requestData)
//    }
//
//    public func send<Request: CommandRequest>(request: Request) async throws -> Request.Response {
//        let requestData = try CommandData(request: request)
//        return try await send(requestData: requestData)
//    }
//
//    private func observeIncomingMessages() {
//        Task {
//            do {
//                guard let receivedDataStream else { return }
//                for try await data in receivedDataStream {
//                    do {
//                        let requestData = try JSONDecoder().decode(CommandData.self, from: data)
//                        guard let messageHandler = commandHandlers[requestData.identifier] else { continue }
//                        logger.info("Connection received identifier: \(requestData.identifier)")
//                        logger.info("Connection received data: \(data)")
//                        let responseData = try await messageHandler.closure(requestData.data)
//                        if messageHandler.responseType != CommandNull.self {
//                            try await send(requestData: CommandData(identifier: requestData.identifier, data: responseData))
//                        }
//                    } catch {
//                        logger.error("\(error)")
//                        let requestError = CommandError(message: "\(error)")
//                        do {
//                            let commandErrorData = try JSONEncoder().encode(requestError)
//                            try await send(data: commandErrorData)
//                        } catch {
//                            logger.error("\(error)")
//                        }
//                    }
//                }
//
//            } catch {
//                logger.error("\(error)")
//            }
//        }
//    }
//
//    private func stateDidChange(_ state: NWConnection.State) {
//        switch state {
//        case .setup:
//            logger.info("Connection is setup")
//        case let .waiting(error):
//            logger.info("Connection is waiting, error: \(error)")
//            stop()
//        case .preparing:
//            logger.info("Connection is preparing")
//        case .ready:
//            logger.info("Connection is ready")
//
//            didReady?(self)
//            didReady = nil
//        case let .failed(error):
//            logger.info("Connection is failed, error: \(error)")
//            stop()
//        case .cancelled:
//            logger.info("Connection is cancelled")
//        default:
//            break
//        }
//    }
//
//    private func setupStreams() {
//        let (connectionStateStream, connectionStateContinuation) = AsyncStream<NWConnection.State>.makeStream()
//        self.connectionStateStream = connectionStateStream
//        self.connectionStateContinuation = connectionStateContinuation
//
//        let (receivedDataStream, receivedDataContinuation) = AsyncThrowingStream<Data, Error>.makeStream()
//        self.receivedDataStream = receivedDataStream.shared()
//        self.receivedDataContinuation = receivedDataContinuation
//    }
//
//    private func setupStateUpdateHandler() {
//        connection.stateUpdateHandler = { [weak self] in
//            guard let self else { return }
//            connectionStateContinuation?.yield($0)
//            stateDidChange($0)
//        }
//    }
//
//    private func setupReceiver() {
//        connection.receive(minimumIncompleteLength: 1, maximumLength: Int.max) { [weak self] data, contentContext, isComplete, error in
//            guard let self else { return }
//            if let error {
//                receivedDataContinuation?.finish(throwing: error)
//                stop()
//            } else if isComplete {
//                receivedDataContinuation?.finish()
//                stop()
//            } else if let data = data {
//                receivingData.append(data)
//                processReceivedData(context: contentContext)
//                setupReceiver()
//            }
//        }
//    }
//
//    private func processReceivedData(context: NWConnection.ContentContext? = nil) {
//        guard let endMarker = "\nOK".data(using: .utf8) else { return }
//
//        while true {
//            guard let endRange = receivingData.range(of: endMarker) else {
//                break
//            }
//
//            let messageData = receivingData.subdata(in: 0 ..< endRange.lowerBound)
//            receivedDataContinuation?.yield(messageData)
//
//            if endRange.upperBound < receivingData.count {
//                receivingData = receivingData.subdata(in: endRange.upperBound ..< receivingData.count)
//            } else {
//                receivingData = Data()
//                break
//            }
//        }
//    }
//
//    private func send<Content: Codable>(content: Content) async throws {
//        let data = try JSONEncoder().encode(content)
//        try await send(data: data)
//    }
//
//    private func send(data: Data) async throws {
//        try await withCheckedThrowingContinuation { [weak self] (continuation: CheckedContinuation<Void, Error>) in
//            guard let self else {
//                continuation.resume(throwing: ConnectionError.notConnected)
//                return
//            }
//
//            connection.send(content: data + CommandConnection.endMarkerData, completion: .contentProcessed { error in
//                if let error = error {
//                    continuation.resume(throwing: error)
//                    return
//                }
//                CommandConnection.logger.info("Connection send data: \(data)")
//                continuation.resume()
//            })
//        }
//    }
//
//    private func receiveData() async throws -> Data {
//        guard let receivedDataStream else {
//            throw ConnectionError.notConnected
//        }
//
//        for try await data in receivedDataStream {
//            if let error = try? JSONDecoder().decode(CommandError.self, from: data) {
//                throw error
//            } else {
//                return data
//            }
//        }
//
//        throw ConnectionError.receiveFailed
//    }
//}
//
//public actor CommandListener {
//    private let listener: NWListener
//
//    private var connections: [UUID: CommandConnection] = [:]
//
//    private var commandHandlers: [String: CommandHandler] = [:]
//
//    public func setCommandHandler<Request: Codable, Response: Codable>(name: String, handler: @escaping ((Request) async throws -> Response)) {
//        commandHandlers[name] = .init(closure: handler)
//    }
//
//    public func setCommandHandler<Request: CommandRequest>(_ handler: @escaping ((Request) async throws -> Request.Response)) {
//        commandHandlers[Request.identifier] = .init(closure: handler)
//    }
//
//    public init() {
//        self.listener = try! NWListener(using: .tcp, on: 5001)
//    }
//
//    public func start() {
//        listener.newConnectionHandler = { [weak self] connection in
//            guard let self else { return }
//            Task {
//                await self.handleNewConnection(connection)
//            }
//        }
//        listener.start(queue: .global())
//    }
//
//    public func stop() {
//        listener.newConnectionHandler = nil
//        listener.cancel()
//    }
//
//    private func handleNewConnection(_ nwConnection: NWConnection) {
//        do {
//            let connection = try CommandConnection(connection: nwConnection)
//            connection.commandHandlers = commandHandlers
//            connections[UUID()] = connection
//        } catch {}
//    }
//}
