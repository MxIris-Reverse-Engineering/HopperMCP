import Foundation
import OSLog
@preconcurrency import Hopper

public actor HopperService: @preconcurrency Service {
    public let services: HPHopperServices

    public init(services: HPHopperServices) {
        self.services = services
    }

    public enum Error: Swift.Error {
        case invalidService
        case invalidDocument
        case invalidFile
        case invalidProcedure
    }

    public lazy var tools = [
        Tool(name: "GetCurrentAssemblyCode", description: "Get Current Assembly Code", inputSchema: [:], implementation: { [weak self] arguments in
            guard let self else { throw Error.invalidService }
            guard let doc = await services.currentDocument() else { throw Error.invalidDocument }
            guard let file = doc.disassembledFile() else { throw Error.invalidFile }
            guard let procedure = file.procedure(at: doc.currentAddress()) else { throw Error.invalidProcedure }
            guard let assemblyCode = procedure.completeAssemblyCode() else { throw Error.invalidProcedure }
            return assemblyCode
        }),
    ]
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
                        if !showAddress, !showHex,
                           !line.hasAttribute("ASMLineNameDeclaration") {
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
