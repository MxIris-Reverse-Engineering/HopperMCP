//
//  File.swift
//  Hopper
//
//  Created by JH on 2025/4/8.
//

import Foundation
import Hopper

extension HPDisassembledFile {
    func allSwiftTypeDescs() -> [any HPSwiftTypeDesc] {
        guard let file, let sections = file.sectionsNamed("__swift5_types") else { return [] }
        var results = [any HPSwiftTypeDesc]()
        for section in sections {
            for type in file.buildSwiftTypeList(section) {
                results.append(type)
            }
        }
        return results
    }
    
    func allSwiftProtocolDescs() -> [any HPSwiftProtocolDesc] {
        guard let file, let sections = file.sectionsNamed("__swift5_protos") else { return [] }
        var results = [any HPSwiftProtocolDesc]()
        for section in sections {
            for desc in file.buildSwiftProtocolList(section) {
                results.append(desc)
            }
        }
        return results
    }
}
