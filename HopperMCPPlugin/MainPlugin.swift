//
//  MainPlugin.swift
//  HopperMCPPlugin
//
//  Created by JH on 2025/4/1.
//

import Foundation
import Hopper

@objc(HopperMCPMainPlugin)
class MainPlugin: NSObject, HopperTool {
    var services: HPHopperServices

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

    required init(hopperServices services: HPHopperServices) {
        self.services = services
        super.init()
    }

    func toolMenuDescription() -> [[String: Any]] {
        return [
            [HPM_TITLE: "Sample Tool Fct1",
             HPM_SELECTOR: "fct1:"],

            [HPM_TITLE: "Sample Tool Menu",
             HPM_SUBMENU: [
                 [HPM_TITLE: "Fct 2",
                  HPM_SELECTOR: "fct2:"],
                 [HPM_TITLE: "Fct 3",
                  HPM_SELECTOR: "fct3:"],
             ]],
        ]
    }

    @objc func fct1(_ sender: Any?) {
        if let doc = services.currentDocument() {
            doc.begin(toWait: "I'm waiting…")
            let msg = "Function1: address is \(String(format: "0x%llx", doc.currentAddress()))"
            doc.displayAlert(
                withMessageText: "Info",
                defaultButton: "OK",
                alternateButton: nil,
                otherButton: nil,
                informativeText: msg
            )
            doc.endWaiting()
        }
    }

    @objc func fct2(_ sender: Any?) {
        if let doc = services.currentDocument() {
            doc.displayAlert(
                withMessageText: "Info",
                defaultButton: "OK",
                alternateButton: nil,
                otherButton: nil,
                informativeText: "Function 2 triggered"
            )
        }
    }

    @objc func fct3(_ sender: Any?) {
        if let doc = services.currentDocument(), let file = doc.disassembledFile(), let procedure = file.procedure(at: doc.currentAddress()) {
            if let pseudoCode = procedure.completePseudoCode() {
                services.logMessage(pseudoCode.string())
            }
            if let assemblyCode = produceStrings(file: file, ofProcedure: procedure) {
                services.logMessage(assemblyCode)
            }
        }
    }

    func produceStrings(file: HPDisassembledFile, ofProcedure procedure: HPProcedure) -> String? {
        var output = String()

        guard let basicBlocks = procedure.basicBlocks else { return nil }

        let sortedBlocks = basicBlocks.sorted { block1, block2 in
            let addr1 = block1.from()
            let addr2 = block2.from()
            return addr1 < addr2
        }

        let showAddressWhenExporting = true
        let showHexWhenExporting = true

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
                        addressField: showAddressWhenExporting,
                        hexColumn: showHexWhenExporting,
                        compactMode: false
                    ) else {
                        continue
                    }

                    for line in strings {
                        if !showAddressWhenExporting && !showHexWhenExporting &&
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

