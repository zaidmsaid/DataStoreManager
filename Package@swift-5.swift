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
    products: {
        var products: [Product] = []
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
#if os(iOS)
        products.append(contentsOf: [
            .library(
                name: "DataStoreManager",
                targets: [
                    "DataStoreManager-iOS"
                ]
            ),
        ])
#elseif os(macOS)
        products.append(contentsOf: [
            .library(
                name: "DataStoreManager",
                targets: [
                    "DataStoreManager-macOS"
                ]
            ),
        ])
#elseif os(watchOS)
        products.append(contentsOf: [
            .library(
                name: "DataStoreManager",
                targets: [
                    "DataStoreManager-watchOS"
                ]
            ),
        ])
#elseif os(tvOS)
        products.append(contentsOf: [
            .library(
                name: "DataStoreManager",
                targets: [
                    "DataStoreManager-tvOS"
                ]
            ),
        ])
#endif
        return products
    }(),
    dependencies: [
        // add your dependencies here, for example:
        // .package(url: "https://github.com/User/Project.git", .upToNextMajor(from: "1.0.0")),
    ],
    targets: {
        var targets: [Target] = []
#if os(iOS)
        targets.append(contentsOf: [
            .target(
                name: "DataStoreManager-iOS",
                dependencies: [
                    // add your dependencies scheme names here, for example:
                    // "Project",
                ],
                path: "Sources/DataStoreManager"
            ),
            .testTarget(
                name: "DataStoreManagerTests-iOS",
                dependencies: [
                    "DataStoreManager-iOS"
                ],
                path: "Tests/DataStoreManagerTests"
            ),
        ])
#elseif os(macOS)
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
#elseif os(watchOS)
        targets.append(contentsOf: [
            .target(
                name: "DataStoreManager-watchOS",
                dependencies: [
                    // add your dependencies scheme names here, for example:
                    // "Project",
                ],
                path: "Sources/DataStoreManager"
            ),
        ])
#elseif os(tvOS)
        targets.append(contentsOf: [
            .target(
                name: "DataStoreManager-tvOS",
                dependencies: [
                    // add your dependencies scheme names here, for example:
                    // "Project",
                ],
                path: "Sources/DataStoreManager"
            ),
            .testTarget(
                name: "DataStoreManagerTests-tvOS",
                dependencies: [
                    "DataStoreManager-tvOS"
                ],
                path: "Tests/DataStoreManagerTests"
            ),
        ])
#endif
        return targets
    }(),
    swiftLanguageVersions: [.v5]
)
