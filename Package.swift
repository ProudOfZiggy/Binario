// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Binario",
    platforms: [.macOS(.v11)],
    products: [
        .executable(name: "binario", targets: ["Binario"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", .branch("release/1.0.3")),
        .package(name: "SwiftPM", url: "https://github.com/apple/swift-package-manager.git", .branch("release/5.7")),
        .package(url: "https://github.com/apple/swift-tools-support-core.git", .branch("release/5.7"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "Binario",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SwiftPM-auto", package: "SwiftPM"),
                .product(name: "SwiftToolsSupport-auto", package: "swift-tools-support-core"),
            ]),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
