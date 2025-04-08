import Hopper

extension HPProcedure {
    public func completeAssemblyCode(showAddress: Bool = true, showHex: Bool = false) -> String? {
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
