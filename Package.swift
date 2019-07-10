// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DataStoreManager",
    platforms: [
        .iOS(.v8),
        .macOS(.v10_10),
        .watchOS(.v2),
        .tvOS(.v9)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "DataStoreManager",
            targets: ["DataStoreManager"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
    ],
    targets: {
        var targets: [Target] =
            [
            // Targets are the basic building blocks of a package. A target can define a module or a test suite.
            // Targets can depend on other targets in this package, and on products in packages which this package depends on.
            .testTarget(
                name: "DataStoreManagerTests",
                dependencies: ["DataStoreManager"]),
            ]
        #if os(iOS)
        targets.append(contentsOf: [
            .target(
                name: "DataStoreManager-iOS",
                dependencies: []),
            ])
        #elseif os(macOS)
        targets.append(contentsOf: [
            .target(
                name: "DataStoreManager-macOS",
                dependencies: []),
            ])
        #elseif os(watchOS)
        targets.append(contentsOf: [
            .target(
                name: "DataStoreManager-watchOS",
                dependencies: []),
            ])
        #elseif os(tvOS)
        targets.append(contentsOf: [
            .target(
                name: "DataStoreManager-tvOS",
                dependencies: []),
            ])
        #endif
        return targets
    }(),
    swiftLanguageVersions: [.v5]
)
