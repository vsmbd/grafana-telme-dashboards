// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "GrafanaDashboardGenerator",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(url: "https://github.com/vsmbd/swift-json.git", branch: "main"),
    ],
    targets: [
        .executableTarget(
            name: "GrafanaDashboardGenerator",
            dependencies: [
                .product(name: "JSON", package: "swift-json"),
            ],
            path: "Sources"
        ),
    ]
)
