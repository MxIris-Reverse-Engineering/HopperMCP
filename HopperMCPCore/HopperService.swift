import OSLog
import AppKit
import HelperService
import HopperServiceInterface
@preconcurrency import Hopper
@preconcurrency import HopperPlus

public actor HopperService: HelperService {
    public let services: HPHopperServices

    private var documentCacheByName: [String: DocumentCache] = [:]

    private actor DocumentCache {
        private(set) weak var document: (any HPDocument)?
        private(set) var addressByName: [String: Address] = [:]
//        private(set) var swiftTypeDescByName: [String: any HPSwiftTypeDesc] = [:]
//        private(set) var swiftProtocolDescByName: [String: any HPSwiftProtocolDesc] = [:]

        init(document: any HPDocument) {
            self.document = document
        }

        func buildCache() async throws {
            guard let document else { throw Error.invalidDocument }
            guard let file = document.disassembledFile() else { throw Error.invalidFile }
            for (index, name) in file.allNames().enumerated() {
                addressByName[name] = file.addressOfName(at: .init(index))
            }
//            for typeDesc in file.allSwiftTypeDescs() {
//                swiftTypeDescByName[typeDesc.name] = typeDesc
//            }
//            for protocolDesc in file.allSwiftProtocolDescs() {
//                swiftProtocolDescByName[protocolDesc.name] = protocolDesc
//            }
        }
    }

    public init(services: HPHopperServices) {
        self.services = services
    }

    public enum Error: LocalizedError {
        case invalidService
        case invalidDocument
        case invalidFile
        case invalidProcedure
        case invalidName
        case invalidSwiftType
        case invalidSwiftProtocol
        case invalidAddress

        public var errorDescription: String? {
            switch self {
            case .invalidService:
                return "Invalid service"
            case .invalidDocument:
                return "Invalid document"
            case .invalidFile:
                return "Invalid file"
            case .invalidProcedure:
                return "Invalid procedure"
            case .invalidName:
                return "Invalid name"
            case .invalidSwiftType:
                return "Invalid Swift type"
            case .invalidSwiftProtocol:
                return "Invalid Swift protocol"
            case .invalidAddress:
                return "Invalid address"
            }
        }
    }

    public func run() async throws {}

    public func setupHandler(_ handler: any HelperHandler) async {
        handler.setMessageHandler { (request: ListDocumentsRequest) in
            var results: [String] = []
            for document in await NSDocumentController.shared.documents {
                await results.append(document.displayName)
            }
            return .result(results.joined(separator: "\n"))
        }

        handler.setMessageHandler { [weak self] (request: CurrentAssemblyByDocumentRequest) in
            guard let self else { throw Error.invalidService }
            guard let document = await NSDocumentController.shared.document(for: request.documentName) else {
                await services.logMessage("Invalid document")
                throw Error.invalidDocument
            }
            let result = try await self.assembly(by: document, at: nil)
            return .result(result)
        }

        handler.setMessageHandler { [weak self] (request: CurrentPseudocodeByDocumentRequest) in
            guard let self else { throw Error.invalidService }
            guard let document = await NSDocumentController.shared.document(for: request.documentName) else {
                await services.logMessage("Invalid document")
                throw Error.invalidDocument
            }
            let result = try await self.pseudocode(by: document, at: nil)
            return .result(result)
        }

        handler.setMessageHandler { [weak self] (request: CurrentAssemblyRequest) in
            guard let self else { throw Error.invalidService }
            guard let document = await NSDocumentController.shared.currentDocumentOrLastDocument else {
                await services.logMessage("Invalid document")
                throw Error.invalidDocument
            }
            let result = try await self.assembly(by: document, at: nil)
            return .result(result)
        }

        handler.setMessageHandler { [weak self] (request: CurrentPseudocodeRequest) in
            guard let self else { throw Error.invalidService }
            guard let document = await NSDocumentController.shared.currentDocumentOrLastDocument else {
                await services.logMessage("Invalid document")
                throw Error.invalidDocument
            }
            let result = try await self.pseudocode(by: document, at: nil)
            return .result(result)
        }

        handler.setMessageHandler { [weak self] (request: AddCommentRequest) in
            guard let self else { throw Error.invalidService }
            guard let document = await nameOrCurrentOrLastDocument(for: request) else { throw Error.invalidDocument }
            guard let file = document.disassembledFile() else { throw Error.invalidFile }
            guard let address = request.address.asAddress else { throw Error.invalidAddress }
            file.setComment(request.comment, atVirtualAddress: address, reason: .CCReason_Automatic)
            document.updateUI()
            return .result("Success")
        }

        handler.setMessageHandler { [weak self] (request: AddInlineCommentRequest) in
            guard let self else { throw Error.invalidService }
            guard let document = await nameOrCurrentOrLastDocument(for: request) else { throw Error.invalidDocument }
            guard let file = document.disassembledFile() else { throw Error.invalidFile }
            guard let address = request.address.asAddress else { throw Error.invalidAddress }
            file.setInlineComment(request.comment, atVirtualAddress: address, reason: .CCReason_Automatic)
            document.updateUI()
            return .result("Success")
        }

        handler.setMessageHandler { [weak self] (request: AssemblyByAddressRequest) in
            guard let self else { throw Error.invalidService }
            guard let document = await nameOrCurrentOrLastDocument(for: request) else { throw Error.invalidDocument }
            guard let address = request.address.asAddress else { throw Error.invalidAddress }
            let result = try await assembly(by: document, at: address)
            return .result(result)
        }

        handler.setMessageHandler { [weak self] (request: PseudocodeByAddressRequest) in
            guard let self else { throw Error.invalidService }
            guard let document = await nameOrCurrentOrLastDocument(for: request) else { throw Error.invalidDocument }
            guard let address = request.address.asAddress else { throw Error.invalidAddress }
            let result = try await pseudocode(by: document, at: address)
            return .result(result)
        }

        handler.setMessageHandler { [weak self] (request: AssemblyByNameRequest) in
            guard let self else { throw Error.invalidService }
            guard let document = await nameOrCurrentOrLastDocument(for: request) else { throw Error.invalidDocument }
            let documentCache = await documentCache(for: document)
            guard let address = await documentCache.addressByName[request.name] else { throw Error.invalidName }
            let result = try await assembly(by: document, at: address)
            return .result(result)
        }

        handler.setMessageHandler { [weak self] (request: PseudocodeByNameRequest) in
            guard let self else { throw Error.invalidService }
            guard let document = await nameOrCurrentOrLastDocument(for: request) else { throw Error.invalidDocument }
            let documentCache = await documentCache(for: document)
            guard let address = await documentCache.addressByName[request.name] else { throw Error.invalidName }
            let result = try await pseudocode(by: document, at: address)
            return .result(result)
        }
        
//        handler.setMessageHandler { [weak self] (request: SwiftTypeDescriptionRequest) in
//            guard let self else { throw Error.invalidService }
//            guard let document = await nameOrCurrentOrLastDocument(for: request) else { throw Error.invalidDocument }
//            let documentCache = await documentCache(for: document)
//            guard let type = await documentCache.swiftTypeDescByName[request.typeName] else { throw Error.invalidSwiftType }
//            return .result(type.description)
//        }
//
//        handler.setMessageHandler { [weak self] (request: SwiftProtocolDescriptionRequest) in
//            guard let self else { throw Error.invalidService }
//            guard let document = await nameOrCurrentOrLastDocument(for: request) else { throw Error.invalidDocument }
//            let documentCache = await documentCache(for: document)
//            guard let type = await documentCache.swiftProtocolDescByName[request.protocolName] else { throw Error.invalidSwiftProtocol }
//            return .result(type.description)
//        }
        
    }

    public func notifyDocumentDidLoad() async throws {
        guard let document = await NSDocumentController.shared.currentDocumentOrLastDocument else { return }
        let documentCache = await documentCache(for: document)
        await MainActor.run {
            document.begin(toWait: "Building MCP Document Cache")
        }
        try await documentCache.buildCache()
        await MainActor.run {
            document.endWaiting()
        }
    }
    
    private func documentCache(for document: any HPDocument & NSDocument) async -> DocumentCache {
        if let cache = await documentCacheByName[document.displayName] {
            return cache
        } else {
            let cache = DocumentCache(document: document)
            await documentCacheByName[document.displayName] = cache
            return cache
        }
    }
    
    private func nameOrCurrentOrLastDocument<Request: ToolRequestWithDocument>(for request: Request) async -> (any HPDocument & NSDocument)? {
        if let documentName = request.documentName, let document = await NSDocumentController.shared.document(for: documentName) {
            return document
        } else if let document = await NSDocumentController.shared.currentDocumentOrLastDocument {
            return document
        } else {
            return nil
        }
    }

    private func assembly(by document: HPDocument, at address: Address?) async throws -> String {
        guard let file = document.disassembledFile() else {
            services.logMessage("Invalid file")
            throw Error.invalidFile
        }
        services.logMessage("\(file)")
        guard let procedure = file.procedure(at: address ?? document.currentAddress()) else {
            services.logMessage("Invalid procedure")
            throw Error.invalidProcedure
        }
        services.logMessage("\(procedure)")
        guard let result = procedure.completeAssemblyCode() else {
            services.logMessage("Invalid assembly code")
            throw Error.invalidProcedure
        }
        services.logMessage(result)
        return result
    }

    private func pseudocode(by document: HPDocument, at address: Address?) async throws -> String {
        guard let file = document.disassembledFile() else {
            services.logMessage("Invalid file")
            throw Error.invalidFile
        }
        services.logMessage("\(file)")
        guard let procedure = file.procedure(at: address ?? document.currentAddress()) else {
            services.logMessage("Invalid procedure")
            throw Error.invalidProcedure
        }
        services.logMessage("\(procedure)")
        guard let result = procedure.completePseudoCode()?.string() else {
            services.logMessage("Invalid pseudocode")
            throw Error.invalidProcedure
        }
        services.logMessage(result)
        return result
    }

    private func setupCaches() async throws {}
}

extension NSDocumentController {
    func document(for name: String) -> (any HPDocument & NSDocument)? {
        for document in documents {
            if document.displayName == name, let document = document as? (any HPDocument & NSDocument) {
                return document
            }
        }
        return nil
    }

    var currentDocumentOrLastDocument: (any HPDocument & NSDocument)? {
        (currentDocument ?? documents.last) as? (any HPDocument & NSDocument)
    }
}

extension Int {
    var asAddress: Address {
        Address(self)
    }
}

extension String {
    var asAddress: Address? {
        Int(self, radix: 16)?.asAddress
    }
}
