// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DesignSystemKit",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "DesignSystemKit", targets: ["DesignSystemKit"])
    ],
    targets: [
        .target(name: "DesignSystemKit")
    ]
)
