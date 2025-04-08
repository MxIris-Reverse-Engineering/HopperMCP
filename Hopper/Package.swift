// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Hopper",
    platforms: [.macOS(.v10_13)],
    products: [
        .library(
            name: "Hopper",
            targets: ["Hopper"]
        ),
        .library(
            name: "HopperPlus",
            targets: ["HopperPlus"]
        ),
    ],
    targets: [
        .target(
            name: "Hopper"
        ),
        .target(
            name: "HopperPlus",
            dependencies: ["Hopper"]
        ),
    ]
)
