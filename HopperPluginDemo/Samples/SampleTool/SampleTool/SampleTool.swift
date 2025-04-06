//
//  SampleTool.swift
//  SampleTool
//
//  Created by Vincent Bénony on 26/04/2019.
//  Copyright © 2019 Cryptic Apps. All rights reserved.
//

import Foundation
import Hopper

@objc
class SwiftSampleTool: NSObject, HopperTool {
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
        return "SampleTool (Swift)"
    }

    func pluginDescription() -> String {
        return "Sample Tool written in Swift"
    }

    func pluginAuthor() -> String {
        return "Vincent Bénony"
    }

    func pluginCopyright() -> String {
        return "© Cryptic Apps SARL"
    }

    func commandLineIdentifiers() -> [String] {
        return ["DummyTool"]
    }

    func pluginVersion() -> String {
        return "0.0.2"
    }

    required init(hopperServices services: HPHopperServices) {
        self.services = services
        super.init()
    }

    func toolMenuDescription() -> [[String: Any]] {
        return [
            [
                HPM_TITLE: "Sample Tool Fct1",
                HPM_SELECTOR: "fct1:",
            ],

            [
                HPM_TITLE: "Sample Tool Menu",
                HPM_SUBMENU: [
                    [
                        HPM_TITLE: "Fct 2",
                        HPM_SELECTOR: "fct2:",
                    ],
                    [
                        HPM_TITLE: "Fct 3",
                        HPM_SELECTOR: "fct3:",
                    ],
                ],
            ],
            
//            [
//                HPM_TITLE: "Reload Plugins",
//                HPM_SELECTOR: NSStringFromSelector(#selector(reloadPlugins(_:))),
//            ],
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

    @objc func reloadPlugins(_ sender: Any?) {
//        NSClassFromString("ToolFactory")?.perform(NSSelectorFromString("loadPluginsIncludingUserPlugins:"), with: true, afterDelay: 0.0)
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
