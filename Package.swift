// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "ClipGrid",
    defaultLocalization: "de",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "ClipGrid",
            targets: ["ClipGrid"]
        )
    ],
    targets: [
        .executableTarget(
            name: "ClipGrid",
            path: "Sources/ClipGrid",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
