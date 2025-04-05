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
import MainService

let server = try HelperServer(serverType: .machService(name: "com.JH.hoppermcpd"), services: [MainService(), InjectionService()])
server.activate()
RunLoop.current.run()
