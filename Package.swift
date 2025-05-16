// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "RKOperations",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v14),
        .macOS(.v10_14),
        .tvOS(.v14),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "RKOperations",
            targets: ["RKOperations"]),
    ],
    targets: [
        .target(
            name: "RKOperations",
            dependencies: []),
        .testTarget(
            name: "RKOperationsTests",
            dependencies: ["RKOperations"]),
    ]
)
