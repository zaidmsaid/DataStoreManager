// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DataStoreManager",
    platforms: [
        .macOS(.v10_10)
    ],
    products: {
        var products: [Product] = []
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        products.append(contentsOf: [
            .library(
                name: "DataStoreManager",
                targets: [
                    "DataStoreManager-macOS"
                ]
            ),
        ])
        return products
    }(),
    dependencies: [
        // add your dependencies here, for example:
        // .package(url: "https://github.com/User/Project.git", .upToNextMajor(from: "1.0.0")),
    ],
    targets: {
        var targets: [Target] = []
        targets.append(contentsOf: [
            .target(
                name: "DataStoreManager-macOS",
                dependencies: [
                    // add your dependencies scheme names here, for example:
                    // "Project",
                ],
                path: "Sources/DataStoreManager"
            ),
            .testTarget(
                name: "DataStoreManagerTests-macOS",
                dependencies: [
                    "DataStoreManager-macOS"
                ],
                path: "Tests/DataStoreManagerTests"
            ),
        ])
        return targets
    }(),
    swiftLanguageVersions: [.v5]
)
