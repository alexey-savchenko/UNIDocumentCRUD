// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UNIDocumentCRUD",
    platforms: [
        .iOS(.v12),
        .macOS(SupportedPlatform.MacOSVersion.v10_15),
    ],
    products: [
        .library(
            name: "UNIDocumentCRUD",
            targets: ["UNIDocumentCRUD"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/onmyway133/DeepDiff.git", .upToNextMajor(from: "2.3.0")),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .exact("5.0.0")),
        .package(url: "https://github.com/alexey-savchenko/UNIScanLib.git", Package.Dependency.Requirement.branch("main")),
        .package(url: "https://github.com/alexey-savchenko/UNILib.git", Package.Dependency.Requirement.branch("main")),
    ],
    targets: [
        .target(
            name: "UNIDocumentCRUD",
            dependencies: [
                "UNIScanLib",
                "RxSwift",
                "DeepDiff",
                .product(name: "UNILibCore", package: "UNILib"),
                .product(name: "RxUNILib", package: "UNILib"),
            ]
        ),
    ]
)
