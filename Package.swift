// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Ricemill",
    platforms: [
        .macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)
    ],
    products: [
        .library(
            name: "Ricemill",
            targets: ["Ricemill"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Ricemill",
            dependencies: []),
        .testTarget(
            name: "RicemillTests",
            dependencies: ["Ricemill"]),
    ]
)
