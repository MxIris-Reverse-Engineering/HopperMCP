//
//  ViewModel.swift
//  HopperMCPApp
//
//  Created by JH on 2025/4/5.
//

import AppKit
import Observation
import HelperClient
import HopperMCPShared
import HelperCommunication
import InjectionService
import OSLog
import RunningApplicationKit

@Observable
final class MainViewModel {
    private static let pluginSearchPath = "~/Library/Application Support/Hopper/PlugIns/v4/Tools"

    private static let pluginURL = URL(filePath: pluginSearchPath).appending(path: "HopperMCPPlugin.hopperTool")
    
    public private(set) var isHelperInstalled: Bool = false

    public private(set) var isHelperConnected: Bool = false
    
    public var isPluginInstalled: Bool {
        (try? FileManager.default.contentsOfDirectory(atPath: Self.pluginSearchPath))?.contains(where: { $0 == Self.pluginURL.path }) ?? false
    }

    public private(set) var isHopperRunning: Bool = false

    public var mcpServerURL: URL? {
        Bundle.main.url(forResource: "HopperMCPServer", withExtension: nil)
    }

    private let helperClient = HelperClient()

    private static var logger = Logger(subsystem: "com.JH.HopperMCPApp", category: "ViewModel")

    private var logger: Logger { Self.logger }

    private let runningApplicationObserver = RunningApplicationObserver(observeApplicationBundleID: HopperApplicationBundleIdentifier)

    public init() {
        
        Task {
            do {
                try await connectToHelper()
            } catch {
                print(error)
            }
        }
        
        Task {
            isHopperRunning = NSWorkspace.shared.runningApplications.contains(bundleID: HopperApplicationBundleIdentifier)
            await runningApplicationObserver.onLaunch { [weak self] in
                guard let self, isHelperConnected else { return }
                Task {
                    try await Task.sleep(nanoseconds: 3 * 1_000_000_000)
                    try await self.injectHopper()
                }
            }
            
            await runningApplicationObserver.onTerminate {
                
            }
            
            await runningApplicationObserver.start()
        }
    }

    public func installHelper() async throws {
        try await helperClient.installTool(name: HopperMCPDaemonBundleIdentifier)
        try await connectToHelper()
    }
    
    public nonisolated func installPlugin() async throws {
        guard let url = Bundle.main.url(forResource: "HopperMCPPlugin", withExtension: "hopperTool") else { return }
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: Self.pluginURL.path) {
            try fileManager.removeItem(at: Self.pluginURL)
        }
        try fileManager.copyItem(at: url, to: Self.pluginURL)
    }

    public func connectToHelper() async throws {
        try await helperClient.connectToTool(machServiceName: HopperMCPDaemonBundleIdentifier, isPrivilegedHelperTool: true)
        isHelperConnected = await helperClient.isConnectedToTool
    }

    public func injectHopper() async throws {
        guard let pid = NSWorkspace.shared.runningApplications.first(bundleID: HopperApplicationBundleIdentifier)?.processIdentifier else {
            logger.error("Failed to get process identifier")
            return
        }
        guard let dylib = Bundle.main.url(forResource: "HopperInjection", withExtension: "framework") else {
            logger.error("Failed to get dylib URL")
            return
        }
        guard let dylibURL = Bundle(url: dylib)?.executableURL else {
            logger.error("Failed to get dylib executable URL")
            return
        }

        try await helperClient.sendToTool(request: InjectApplicationRequest(pid: pid, dylibURL: dylibURL))
    }
}
