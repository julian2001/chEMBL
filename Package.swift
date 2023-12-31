// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

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
        // Example dependencies that you might use for networking and JSON parsing
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.0.0"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.0")
    ],
    targets: [
        .target(
            name: "Osiris",
            dependencies: ["alamofire", "SwiftyJSON"]),
        .testTarget(
            name: "OsirisTests",
            dependencies: ["Osiris"]),
    ]
)
