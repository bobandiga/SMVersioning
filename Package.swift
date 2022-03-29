// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SMVersioning",
    platforms: [.macOS(.v11)],
    targets: [
        .executableTarget(
            name: "SMVersioning",
            dependencies: [])
    ],
    swiftLanguageVersions: [.v5]
)
