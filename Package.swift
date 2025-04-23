// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "OpenAIImagesKit",
    platforms: [
        .macOS(.v12),
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "OpenAIImagesKit",
            targets: ["OpenAIImagesKit"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "OpenAIImagesKit",
            dependencies: []),
        .testTarget(
            name: "OpenAIImagesKitTests",
            dependencies: ["OpenAIImagesKit"]),
    ]
)