// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HopperMCP",
    platforms: [.macOS(.v13)],
    products: [
        .library(
            name: "HopperMCP",
            targets: ["HopperMCP"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/reddavis/Asynchrone",
            from: "0.1.0"
        ),
        .package(
            url: "https://github.com/groue/Semaphore",
            from: "0.1.0"
        ),
        .package(
            url: "https://github.com/ajevans99/swift-json-schema",
            from: "0.3.2"
        ),
        .package(
            url: "https://github.com/modelcontextprotocol/swift-sdk",
            from: "0.6.0"
        ),
    ],
    targets: [
        .target(
            name: "HopperMCP",
            dependencies: [
                .product(name: "Asynchrone", package: "Asynchrone"),
                .product(name: "Semaphore", package: "Semaphore"),
                .product(name: "MCP", package: "swift-sdk"),
            ]
        ),
    ]
)
