// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "utils-ios",
    platforms: [
        .iOS("10.0"),
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "utils-ios", type: .static,
            targets: ["utils-ios"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "5.0.0"),
        .package(url: "https://github.com/RxSwiftCommunity/RxDataSources.git", from: "4.0.0"),
        .package(url: "https://github.com/RxSwiftCommunity/RxSwiftExt.git", from: "5.0.0"),
        .package(url: "https://github.com/RxSwiftCommunity/RxGesture.git", from: "3.0.0"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.2.0"),
        .package(url: "https://github.com/Alamofire/AlamofireImage.git", from: "4.1.0"),
        .package(url: "https://github.com/Kitura/HeliumLogger.git", from: "1.9.0"),
        .package(url: "ssh://git@repos.ni.bg/nidata/git/CosmicMind/Material.git", .branch("development")),
        .package(url: "ssh://git@repos.ni.bg/nidata/git/CosmicMind/Motion.git", .branch("development")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "utils-ios",
            dependencies: ["Alamofire", "RxSwift", .product(name: "RxCocoa", package: "RxSwift"), "RxDataSources", "RxSwiftExt", "RxGesture",
                           "AlamofireImage", "HeliumLogger", "Material", "Motion"]),
        .testTarget(
            name: "utils-iosTests",
            dependencies: ["utils-ios"]),
    ]
)
