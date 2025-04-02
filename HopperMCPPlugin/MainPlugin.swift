//
//  MainPlugin.swift
//  HopperMCPPlugin
//
//  Created by JH on 2025/4/1.
//

import Hopper
import HopperMCP
import Foundation

@objc(HopperMCPMainPlugin)
class MainPlugin: NSObject, HopperTool, @unchecked Sendable {
    let listener = CommandListener()

    let services: HPHopperServices

    static func sdkVersion() -> Int32 {
        return HOPPER_CURRENT_SDK_VERSION
    }

    func pluginType() -> HopperPluginType {
        return .Plugin_Tool
    }

    func pluginUUID() -> HPHopperUUID {
        return services.uuid(with: "b2bbe202-3add-4f70-99c2-3682778bb078")
    }

    func pluginName() -> String {
        return "Hopper MCP Plugin"
    }

    func pluginDescription() -> String {
        return "Hopper Plugin for MCP"
    }

    func pluginAuthor() -> String {
        return "Mx-Iris"
    }

    func pluginCopyright() -> String {
        return "© Cryptic JH"
    }

    func commandLineIdentifiers() -> [String] {
        return ["HopperMCPMainPlugin"]
    }

    func pluginVersion() -> String {
        return "0.1.0"
    }

    enum Error: Swift.Error {
        case invalidService
        case invalidDocument
        case invalidFile
        case invalidProcedure
    }

    required init(hopperServices services: HPHopperServices) {
        self.services = services
        super.init()
        setupListener()
    }

    func setupListener() {
        Task {
            await listener.setCommandHandler { [weak self] (_: GetCurrentAssemblyCodeRequest) -> GetCurrentAssemblyCodeResponse in
                guard let self else { throw Error.invalidService }
                guard let doc = services.currentDocument() else { throw Error.invalidDocument }
                guard let file = doc.disassembledFile() else { throw Error.invalidFile }
                guard let procedure = file.procedure(at: doc.currentAddress()) else { throw Error.invalidProcedure }
                guard let assemblyCode = procedure.completeAssemblyCode() else { throw Error.invalidProcedure }
                return .init(code: assemblyCode)
            }
        }
    }

    func toolMenuDescription() -> [[String: Any]] {
        return [
            [
                HPM_TITLE: "Start MCP Plugin",
                HPM_SELECTOR: "startPluginServer:",
            ],

            [
                HPM_TITLE: "Stop MCP Plugin",
                HPM_SELECTOR: "stopPluginServer:",
            ],
        ]
    }

    @objc func startPluginServer(_ sender: Any?) {
        Task {
            await listener.start()
        }
    }

    @objc func stopPluginServer(_ sender: Any?) {
        Task {
            await listener.stop()
        }
    }

    @objc func fct3(_ sender: Any?) {
        if let doc = services.currentDocument(), let file = doc.disassembledFile(), let procedure = file.procedure(at: doc.currentAddress()) {
            if let pseudoCode = procedure.completePseudoCode() {
                services.logMessage(pseudoCode.string())
            }
            if let assemblyCode = procedure.completeAssemblyCode() {
                services.logMessage(assemblyCode)
            }
        }
    }
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
