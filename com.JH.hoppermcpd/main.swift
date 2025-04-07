//
//  main.swift
//  hopperinjectd
//
//  Created by JH on 2025/4/3.
//

import Foundation
import HelperService
import InjectionService
import HelperServer

let server = try await HelperServer(serverType: .machService(name: "com.JH.hoppermcpd"), services: [InjectionService()])
await server.activate()
try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in }
