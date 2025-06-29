// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SpaceXSharedUI",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v9),
        .tvOS(.v16)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SpaceXSharedUI",
            targets: ["SpaceXSharedUI"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.0.0"),
        .package(path: "../SpaceXDomain"),
        .package(path: "../SpaceXMocks"),
        .package(path: "../SpaceXUtilities")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SpaceXSharedUI",
            dependencies: [
                .product(name: "Kingfisher", package: "Kingfisher"),
                "SpaceXDomain",
                "SpaceXMocks",
                "SpaceXUtilities"
            ])
    ]
)
