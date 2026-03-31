// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "AdWhaleSDK",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "AdWhaleSDK", targets: ["AdWhaleSDK"]),
        .library(name: "AdWhaleAdMobAdapter", targets: ["AdWhaleAdMobAdapter"]),
        .library(name: "AdWhaleCaulyAdapter", targets: ["AdWhaleCaulyAdapter"]),
        .library(name: "AdWhaleAdFitAdapter", targets: ["AdWhaleAdFitAdapter"]),
        .library(name: "AdWhaleAdmizeAdapter", targets: ["AdWhaleAdmizeAdapter"]),
    ],
    dependencies: [
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", from: "12.0.0"),
        .package(url: "https://github.com/cauly/CaulySPM.git", from: "3.1.22"),
        .package(url: "https://github.com/adfit/adfit-spm.git", from: "3.21.0"),
        .package(url: "https://github.com/admize-sdk/admize-sdk-ios.git", from: "0.0.1"),
    ],
    targets: [
        .binaryTarget(
            name: "AdWhaleSDK",
            path: "AdWhaleSDK.xcframework"
        ),
        .binaryTarget(
            name: "AdWhaleAdMobAdapter",
            path: "AdWhaleAdMobAdapter.xcframework"
        ),
        .binaryTarget(
            name: "AdWhaleCaulyAdapter",
            path: "AdWhaleCaulyAdapter.xcframework"
        ),
        .binaryTarget(
            name: "AdWhaleAdFitAdapter",
            path: "AdWhaleAdFitAdapter.xcframework"
        ),
        .binaryTarget(
            name: "AdWhaleAdmizeAdapter",
            path: "AdWhaleAdmizeAdapter.xcframework"
        ),
    ]
)
