// swift-tools-version: 5.8.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GameControllerKit",
    platforms: [
        .macOS(.v12),
        .iOS(.v16),
        .tvOS(.v16)
    ],
    products: [
        .library(
            name: "GameControllerKit",
            targets: ["GameControllerKit"]
        ),
        .executable(
            name: "GameControllerKitDemo",
            targets: ["GameControllerKitDemo"]
        )
    ],
    targets: [
        .target(
            name: "GameControllerKit"
        ),
        .executableTarget(
            name: "GameControllerKitDemo",
            dependencies: ["GameControllerKit"]
        ),
        .testTarget(
            name: "GameControllerKitTests",
            dependencies: ["GameControllerKit"]
        )
    ]
)
