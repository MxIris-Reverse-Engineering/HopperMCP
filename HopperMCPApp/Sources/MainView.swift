//
//  ViewController.swift
//  HopperMCPApp
//
//  Created by JH on 2025/4/3.
//

import AppKit
import SwiftUI

struct MainView: View {
    var viewModel: MainViewModel = .init()

    var body: some View {
        Image(nsImage: NSApplication.shared.applicationIconImage)
            .resizable()
            .frame(width: 100, height: 100)

        Form {
            Section {
                HStack {
                    Text("Install Helper")

                    Spacer()

                    Button {
                        Task {
                            do {
                                try await viewModel.installHelper()
                            } catch {
                                print(error)
                            }
                        }
                    } label: {
                        Text("Install")
                    }
                }

                HStack {
                    Text("Install Hopper Plugin")

                    Spacer()

                    Button {
                        Task {
                            try await viewModel.installPlugin()
                        }
                    } label: {
                        Text("Install")
                    }
                }

                HStack {
                    Text("Inject Hopper App")

                    Spacer()

                    Button {
                        Task {
                            try await viewModel.injectHopper()
                        }
                    } label: {
                        Text("Inject")
                    }
                }

                HStack {
                    Text("Copy MCP Server Path")

                    Spacer()

                    Button {
                        if let mcpServerPath = viewModel.mcpServerURL?.path {
                            let pasteboard = NSPasteboard.general
                            pasteboard.clearContents()
                            pasteboard.setString(mcpServerPath, forType: .string)
                        }
                    } label: {
                        Text("Copy")
                    }
                }
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 400)
    }
}

@available(macOS 14.0, *)
#Preview {
    MainView()
}
