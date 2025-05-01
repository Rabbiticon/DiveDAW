// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DiveDaw",
    platforms: [.macOS(.v13)],
    products: [
        .executable(
            name: "DiveDaw",
            targets: ["DiveDaw"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/AudioKit/AudioKit.git", from: "5.6.0"),
        .package(url: "https://github.com/AudioKit/AudioKitUI.git", from: "0.3.5"),
        .package(url: "https://github.com/AudioKit/DunneAudioKit.git", from: "5.6.0"),
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-numerics", from: "1.0.0"),
        .package(url: "https://github.com/AudioKit/SoundpipeAudioKit.git", from: "5.6.0"),
        .package(url: "https://github.com/AudioKit/Tonic.git", from: "1.0.0")
    ],
    targets: [
        .executableTarget(
            name: "DiveDaw",
            dependencies: [
                "AudioKit",
                "AudioKitUI",
                "DunneAudioKit",
                "SoundpipeAudioKit",
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "Numerics", package: "swift-numerics"),
                "Tonic"
            ],
            path: "Sources/DiveDaw"
        ),
        .testTarget(
            name: "DiveDawTests",
            dependencies: ["DiveDaw"],
            path: "Tests/DiveDaw"
        ),
    ]
)