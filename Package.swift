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
            name: "utils-ios",
            targets: ["utils-ios"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.0.0"),
        .package(url: "https://github.com/RxSwiftCommunity/RxDataSources.git", from: "5.0.0"),
        .package(url: "https://github.com/RxSwiftCommunity/RxSwiftExt.git", from: "6.0.0"),
        .package(url: "https://github.com/RxSwiftCommunity/RxGesture.git", .branch("main")),
        .package(url: "https://github.com/RxSwiftCommunity/RxKeyboard.git", from: "2.0.0"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.2.0"),
        .package(url: "https://github.com/Alamofire/AlamofireImage.git", from: "4.1.0"),
        .package(url: "https://github.com/Kitura/HeliumLogger.git", from: "1.9.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "utils-ios",
            dependencies: ["Alamofire", "RxSwift", .product(name: "RxCocoa", package: "RxSwift"), "RxDataSources", "RxSwiftExt", "RxGesture", "RxKeyboard", "AlamofireImage", "HeliumLogger"],
            path: "Sources"),
        .testTarget(
            name: "utils-iosTests",
            dependencies: ["utils-ios"]),
    ]
)
