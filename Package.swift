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
        .executable(
            name: "OpenAIImagesCLI",
            targets: ["OpenAIImagesCLI"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "OpenAIImagesKit",
            dependencies: []),
        .executableTarget(
            name: "OpenAIImagesCLI",
            dependencies: ["OpenAIImagesKit"]),
        .testTarget(
            name: "OpenAIImagesKitTests",
            dependencies: ["OpenAIImagesKit"]),
    ]
)