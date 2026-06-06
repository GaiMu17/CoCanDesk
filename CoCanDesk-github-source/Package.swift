// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "CoCanDesk",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "CoCanDesk", targets: ["CoCanDesk"])
    ],
    targets: [
        .executableTarget(
            name: "CoCanDesk",
            path: "Sources/CoCanDesk",
            exclude: ["Resources"]
        )
    ]
)
