// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HopperMCP",
    platforms: [.macOS(.v14)],
    products: [
        .library(
            name: "HopperServiceInterface",
            targets: ["HopperServiceInterface"]
        ),
        .library(
            name: "HopperMCPShared",
            targets: ["HopperMCPShared"]
        ),
    ],
    dependencies: [
        .package(path: "../../../Library/macOS/swift-helper-service"),
        .package(url: "https://github.com/ajevans99/swift-json-schema", from: "0.3.2"),
        .package(url: "https://github.com/MxIris-Library-Forks/mcp-swift-sdk", branch: "main"),
        .package(url: "https://github.com/gohanlon/swift-memberwise-init-macro", from: "0.5.2"),
    ],
    targets: [
        .target(
            name: "HopperMCPShared"
        ),
        .target(
            name: "HopperServiceInterface",
            dependencies: [
                .product(name: "HelperService", package: "swift-helper-service"),
                .product(name: "JSONSchemaBuilder", package: "swift-json-schema"),
                .product(name: "MCPInterface", package: "mcp-swift-sdk"),
                .product(name: "MemberwiseInit", package: "swift-memberwise-init-macro"),
            ]
        ),
    ]
)
