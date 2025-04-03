// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HopperMCP",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "HopperMCP",
            targets: ["HopperMCP"]
        ),
        .library(
            name: "HopperInjectionService",
            targets: ["HopperInjectionService"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/MxIris-macOS-Library-Forks/SwiftyXPC", branch: "main"),
        .package(url: "https://github.com/MxIris-Reverse-Engineering/MachInjector", branch: "main"),
    ],
    targets: [
        .target(
            name: "HopperMCP"
        ),
        .target(
            name: "HopperInjectionService",
            dependencies: [
                .product(name: "MachInjector", package: "MachInjector"),
                .product(name: "SwiftyXPC", package: "SwiftyXPC"),
            ]
        ),
    ]
)
