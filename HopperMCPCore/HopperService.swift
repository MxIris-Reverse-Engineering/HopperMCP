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
        private(set) var swiftTypeDescByName: [String: any HPSwiftTypeDesc] = [:]
        private(set) var swiftProtocolDescByName: [String: any HPSwiftProtocolDesc] = [:]

        init(document: any HPDocument) {
            self.document = document
        }

        func buildCache() async throws {
            guard let document else { throw Error.invalidDocument }
            guard let file = document.disassembledFile() else { throw Error.invalidFile }
            for (index, name) in file.allNames().enumerated() {
                addressByName[name] = file.addressOfName(at: .init(index))
            }
            for typeDesc in file.allSwiftTypeDescs() {
                swiftTypeDescByName[typeDesc.name] = typeDesc
            }
            for protocolDesc in file.allSwiftProtocolDescs() {
                swiftProtocolDescByName[protocolDesc.name] = protocolDesc
            }
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
            file.setComment(request.comment, atVirtualAddress: request.address.asAddress, reason: .CCReason_Automatic)
            return .result("Success")
        }

        handler.setMessageHandler { [weak self] (request: AddInlineCommentRequest) in
            guard let self else { throw Error.invalidService }
            guard let document = await nameOrCurrentOrLastDocument(for: request) else { throw Error.invalidDocument }
            guard let file = document.disassembledFile() else { throw Error.invalidFile }
            file.setInlineComment(request.comment, atVirtualAddress: request.address.asAddress, reason: .CCReason_Automatic)
            return .result("Success")
        }

        handler.setMessageHandler { [weak self] (request: AssemblyByAddressRequest) in
            guard let self else { throw Error.invalidService }
            guard let document = await nameOrCurrentOrLastDocument(for: request) else { throw Error.invalidDocument }
            let result = try await assembly(by: document, at: request.address.asAddress)
            return .result(result)
        }

        handler.setMessageHandler { [weak self] (request: PseudocodeByAddressRequest) in
            guard let self else { throw Error.invalidService }
            guard let document = await nameOrCurrentOrLastDocument(for: request) else { throw Error.invalidDocument }
            let result = try await pseudocode(by: document, at: request.address.asAddress)
            return .result(result)
        }

        handler.setMessageHandler { [weak self] (request: AssemblyByNameRequest) in
            guard let self else { throw Error.invalidService }
            guard let document = await nameOrCurrentOrLastDocument(for: request) else { throw Error.invalidDocument }
            guard let file = document.disassembledFile() else { throw Error.invalidFile }
            guard let addressIndex = file.allNames().firstIndex(where: { $0 == request.name }) else { throw Error.invalidFile }
            let result = try await assembly(by: document, at: file.addressOfName(at: .init(addressIndex)))
            return .result(result)
        }

        handler.setMessageHandler { [weak self] (request: PseudocodeByNameRequest) in
            guard let self else { throw Error.invalidService }
            guard let document = await nameOrCurrentOrLastDocument(for: request) else { throw Error.invalidDocument }
            guard let file = document.disassembledFile() else { throw Error.invalidFile }
            guard let addressIndex = file.allNames().firstIndex(where: { $0 == request.name }) else { throw Error.invalidFile }
            let result = try await pseudocode(by: document, at: file.addressOfName(at: .init(addressIndex)))
            return .result(result)
        }
    }

    private func nameOrCurrentOrLastDocument<Request: ToolRequestWithDocument>(for request: Request) async -> (any HPDocument)? {
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
    func document(for name: String) -> (any HPDocument)? {
        for document in documents {
            if document.displayName == name, let document = document as? HPDocument {
                return document
            }
        }
        return nil
    }

    var currentDocumentOrLastDocument: (any HPDocument)? {
        (currentDocument ?? documents.last) as? HPDocument
    }
}

extension Int {
    var asAddress: Address {
        Address(self)
    }
}
