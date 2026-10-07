// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "WakTrainerDesignSystem",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "WakTrainerDesignSystem",
            targets: ["WakTrainerDesignSystem"]
        )
    ],
    targets: [
        .target(
            name: "WakTrainerDesignSystem"
        ),
        .testTarget(
            name: "WakTrainerDesignSystemTests",
            dependencies: ["WakTrainerDesignSystem"]
        )
    ]
)
