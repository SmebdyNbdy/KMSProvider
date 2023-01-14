// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "KMSProvider",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(name: "AWSProvider", targets: ["AWSProvider"]),
        .library(name: "KMSProvider", targets: ["KMSProvider"]),
        .library(name: "PPProvider", targets: ["PPProvider"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/jwt.git", from: "4.0.0"),
        .package(url: "https://github.com/soto-project/soto-core.git", from: "6.1.2"),
        .package(url: "https://github.com/soto-project/soto.git", from: "6.0.0"),
        .package(url: "https://github.com/GraphQLSwift/Graphiti.git", from: "1.2.0"),
        .package(url: "https://github.com/d-exclaimation/pioneer", from: "0.10.0"),
    ],
    targets: [
        .target(
            name: "PPProvider",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "SotoCore", package: "soto-core"),
                .product(name: "SotoPinpoint", package: "soto"),
                .product(name: "Graphiti", package: "Graphiti"),
                .target(name: "AWSProvider"),
            ],
            path: "Sources/PPProvider"),
        .target(
            name: "KMSProvider",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "JWT", package: "jwt"),
                .product(name: "SotoCore", package: "soto-core"),
                .product(name: "SotoKMS", package: "soto"),
                .product(name: "Graphiti", package: "Graphiti"),
                .product(name: "Pioneer", package: "pioneer"),
                .target(name: "AWSProvider"),
            ],
            path: "Sources/KMSProvider"),
        .target(name: "AWSProvider",
                dependencies: [
                    .product(name: "Vapor", package: "vapor"),
                    .product(name: "SotoCore", package: "soto-core"),
                ],
                path: "Sources/AWSProvider"),
    ],
    swiftLanguageVersions: [.version("5.5")]
)
