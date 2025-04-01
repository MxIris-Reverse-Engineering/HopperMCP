// swift-tools-version: 6.1
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
    ],
    targets: [
        .target(
            name: "Hopper"
        ),
    ]
)
