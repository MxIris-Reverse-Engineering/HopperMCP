import OSLog
import AppKit
import HelperService
import HopperServiceInterface
@preconcurrency import Hopper
@preconcurrency import HopperPlus

public final class HopperService: HelperService {
    public let services: HPHopperServices

    private var addressByName: [String: Address] = [:]
    
    
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

    public func currentAssembly(by document: HPDocument) async throws -> String {
        guard let file = document.disassembledFile() else {
            services.logMessage("Invalid file")
            throw Error.invalidFile
        }
        services.logMessage("\(file)")
        guard let procedure = file.procedure(at: document.currentAddress()) else {
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

    public func currentPseudocode(by document: HPDocument) async throws -> String {
        guard let file = document.disassembledFile() else {
            services.logMessage("Invalid file")
            throw Error.invalidFile
        }
        services.logMessage("\(file)")
        guard let procedure = file.procedure(at: document.currentAddress()) else {
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

    public func setupHandler(_ handler: any HelperHandler) {
        handler.setMessageHandler { (request: ListDocumentsRequest) in
            var results: [String] = []
            for document in await NSDocumentController.shared.documents {
                await results.append(document.displayName)
            }
            return .result(results.joined(separator: "\n"))
        }

        handler.setMessageHandler { [weak self] (request: CurrentAssemblyByDocumentRequest) in
            guard let self else { throw Error.invalidService }
            guard let document = await NSDocumentController.shared.document(for: request.documentName) as? HPDocument else {
                services.logMessage("Invalid document")
                throw Error.invalidDocument
            }
            let result = try await self.currentAssembly(by: document)
            return .result(result)
        }

        handler.setMessageHandler { [weak self] (request: CurrentPseudocodeByDocumentRequest) in
            guard let self else { throw Error.invalidService }
            guard let document = await NSDocumentController.shared.document(for: request.documentName) as? HPDocument else {
                services.logMessage("Invalid document")
                throw Error.invalidDocument
            }
            let result = try await self.currentPseudocode(by: document)
            return .result(result)
        }

        handler.setMessageHandler { [weak self] (request: CurrentAssemblyRequest) in
            guard let self else { throw Error.invalidService }
            guard let document = await NSDocumentController.shared.currentDocument as? HPDocument else {
                services.logMessage("Invalid document")
                throw Error.invalidDocument
            }
            let result = try await self.currentAssembly(by: document)
            return .result(result)
        }

        handler.setMessageHandler { [weak self] (request: CurrentPseudocodeRequest) in
            guard let self else { throw Error.invalidService }
            guard let document = await NSDocumentController.shared.currentDocument as? HPDocument else {
                services.logMessage("Invalid document")
                throw Error.invalidDocument
            }
            let result = try await self.currentPseudocode(by: document)
            return .result(result)
        }
    }

    public func run() async throws {}
}

extension NSDocumentController {
    func document(for name: String) -> NSDocument? {
        for document in documents {
            if document.displayName == name {
                return document
            }
        }
        return nil
    }
}
