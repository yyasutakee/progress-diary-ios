// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DiaryFeature",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "DiaryFeature", targets: ["DiaryFeature"])
    ],
    targets: [
        .target(name: "DiaryFeature")
    ]
)
