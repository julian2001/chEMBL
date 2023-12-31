
// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "Osiris",
    products: [
        .library(
            name: "Osiris",
            targets: ["Osiris"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.8.1")),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", .upToNextMajor(from: "5.0.0")),
    ],
    targets: [
        .target(
            name: "Osiris",
            dependencies: ["Alamofire", "SwiftyJSON"]),
        .testTarget(
            name: "OsirisTests",
            dependencies: ["Osiris"]),
    ]
)
