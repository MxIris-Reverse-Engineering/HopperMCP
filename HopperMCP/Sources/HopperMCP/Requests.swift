//
//  File.swift
//  HopperMCP
//
//  Created by JH on 2025/4/2.
//

import Foundation

public struct GetCurrentAssemblyCodeRequest: CommandRequest {
    public static var identifier: String = "GetCurrentAssemblyCode"
    public typealias Response = GetCurrentAssemblyCodeResponse
    public init() {}
}

public struct GetCurrentAssemblyCodeResponse: CommandResponse {
    public let code: String
    public init(code: String) {
        self.code = code
    }
}

public struct GetCurrentPseudoCodeRequest: CommandRequest {
    public static var identifier: String = "GetCurrentPseudoCode"

    public typealias Response = GetCurrentPseudoCodeResponse
}

public struct GetCurrentPseudoCodeResponse: CommandResponse {
    public let code: String
}
