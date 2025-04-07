//
//  ViewController.swift
//  HopperMCPApp
//
//  Created by JH on 2025/4/3.
//

import AppKit
import SwiftUI

class ViewController: NSHostingController<ContentView> {
    let viewModel = ViewModel()

    init() {
        super.init(rootView: .init(viewModel: viewModel))
        sizingOptions = .preferredContentSize
    }

    @available(*, unavailable)
    @MainActor @preconcurrency dynamic required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct ContentView: View {
    var viewModel: ViewModel

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
    ContentView(viewModel: .init())
}
