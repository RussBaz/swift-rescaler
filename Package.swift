// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-rescaler",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "swift-rescaler",
            targets: ["swift-rescaler"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .systemLibrary(
            name: "cVips",
            pkgConfig: "vips",
            providers: [
                .brew(["vips"]),
                .apt(["libvips-dev"]),
            ]
        ),
        .target(name: "cVipsWrapper", dependencies: [
            "cVips",
        ]),
        .target(
            name: "swift-rescaler", dependencies: [
                "cVipsWrapper",
            ]
        ),
        .testTarget(
            name: "swift-rescalerTests",
            dependencies: ["swift-rescaler"]
        ),
    ]
)
