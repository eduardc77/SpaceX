// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SpaceXData",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v9),
        .tvOS(.v16)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SpaceXData",
            targets: ["SpaceXData"])
    ],
    dependencies: [
        .package(path: "../SpaceXDomain"), // Dependency on Domain models for mapping
        .package(path: "../SpaceXNetwork"), // Dependency on Network services for repositories
        .package(path: "../SpaceXProtocols"),
        .package(path: "../SpaceXMocks") // Test-only dependency
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SpaceXData",
            dependencies: [
                "SpaceXDomain",
                "SpaceXNetwork",
                "SpaceXProtocols"
            ]),
        .testTarget(
            name: "SpaceXDataTests",
            dependencies: [
                "SpaceXData",
                "SpaceXDomain",
                "SpaceXNetwork",
                "SpaceXProtocols",
                "SpaceXMocks"
            ]
        )
    ]
)
