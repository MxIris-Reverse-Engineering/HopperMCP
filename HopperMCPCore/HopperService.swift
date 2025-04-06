import OSLog
import AppKit
import HelperService
import HopperServiceInterface
@preconcurrency import Hopper

public final class HopperService: HelperService {
    public let services: HPHopperServices

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

extension HPProcedure {
    func completeAssemblyCode(showAddress: Bool = true, showHex: Bool = false) -> String? {
        var output = String()

        guard let basicBlocks = basicBlocks else { return nil }
        guard let file = segment().file else { return nil }
        let sortedBlocks = basicBlocks.sorted { block1, block2 in
            let addr1 = block1.from()
            let addr2 = block2.from()
            return addr1 < addr2
        }

        let indent = "        "

        for block in sortedBlocks {
            let basicBlock = block
            var currentAddress = basicBlock.from()
            let endAddress = basicBlock.to()

            guard let segment = file.segment(forVirtualAddress: currentAddress) else { continue }

            if currentAddress <= endAddress {
                while currentAddress <= endAddress {
                    guard let strings = segment.strings(
                        forVirtualAddress: currentAddress,
                        includingDecorations: true,
                        inlineComments: true,
                        addressField: showAddress,
                        hexColumn: showHex,
                        compactMode: false
                    ) else {
                        continue
                    }

                    for line in strings {
                        if !showAddress, !showHex, !line.hasAttribute("ASMLineNameDeclaration") {
                            output.append(indent)
                        }

                        output.append(line.string())

                        output.append("\n")
                    }

                    let byteLength = segment.getByteLength(atVirtualAddress: currentAddress)
                    let increment = byteLength <= 1 ? 1 : byteLength
                    currentAddress += .init(increment)
                }
            }
        }

        return output
    }
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
