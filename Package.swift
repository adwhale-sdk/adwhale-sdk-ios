// swift-tools-version: 5.9

import PackageDescription

// ─────────────────────────────────────────────────────────────
// ADwhale Mediation iOS SDK - 바이너리(XCFramework) 배포 매니페스트
//
// ★ shim 타겟 구조 ★
//   .binaryTarget 은 dependencies 를 선언할 수 없다.
//   따라서 binaryTarget 을 얇은 일반 타겟(*Target)으로 감싸고,
//   파트너 SDK 의존성은 그 shim 타겟에 선언한다.
//   이 구조가 없으면 SPM 이 파트너 패키지를 clone 만 하고 링크하지 않아
//   앱이 dyld 에러로 즉시 크래시한다.
//   (Google 의 swift-package-manager-google-mobile-ads 와 동일한 패턴)
//
//   product 이름은 그대로이므로 고객이 쓰는 방법은 바뀌지 않는다.
//
// ※ 파트너 버전은 release.conf / 소스 Package.swift 와 일치해야 하며
//   scripts/preflight.sh 가 불일치를 검사한다.
//
// ※ AdMob 미디에이션 파트너 어댑터는 이 패키지에 포함하지 않는다.
//   앱이 직접 추가한다 (안드로이드와 동일한 방식). README 의 버전표 참조.
// ─────────────────────────────────────────────────────────────

let package = Package(
    name: "AdWhaleSDK",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "AdWhaleSDK",           targets: ["AdWhaleSDKTarget"]),
        .library(name: "AdWhaleAdMobAdapter",  targets: ["AdWhaleAdMobAdapterTarget"]),
        .library(name: "AdWhaleCaulyAdapter",  targets: ["AdWhaleCaulyAdapterTarget"]),
        .library(name: "AdWhaleAdFitAdapter",  targets: ["AdWhaleAdFitAdapterTarget"]),
        .library(name: "AdWhaleAdmizeAdapter", targets: ["AdWhaleAdmizeAdapterTarget"]),
        .library(name: "AdWhaleLevelPlayAdapter", targets: ["AdWhaleLevelPlayAdapterTarget"]),
    ],
    dependencies: [
        // Google UMP (Core SDK 의 GDPR 동의 플로우용)
        .package(url: "https://github.com/googleads/swift-package-manager-google-user-messaging-platform.git", from: "3.0.0"),
        // AdMob adapter dependency
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", exact: "13.0.0"),
        // Cauly adapter dependency
        .package(url: "https://github.com/cauly/CaulySPM.git", exact: "3.1.24"),
        // AdFit adapter dependency
        .package(url: "https://github.com/adfit/adfit-spm.git", exact: "3.21.24"),
        // Admize adapter dependency
        .package(url: "https://github.com/admize-sdk/admize-sdk-ios.git", exact: "0.0.1"),
        // LevelPlay(ironSource) adapter dependency
        .package(url: "https://github.com/ironsource-mobile/LevelPlay-Swift-Package", exact: "9.5.0"),
    ],
    targets: [
        // ── Core ──
        .binaryTarget(
            name: "AdWhaleSDK",
            path: "AdWhaleSDK.xcframework"
        ),
        .target(
            name: "AdWhaleSDKTarget",
            dependencies: [
                "AdWhaleSDK",
                .product(name: "GoogleUserMessagingPlatform", package: "swift-package-manager-google-user-messaging-platform"),
            ],
            path: "Shims/AdWhaleSDKTarget"
        ),

        // ── AdMob / AdManager 어댑터 ──
        .binaryTarget(
            name: "AdWhaleAdMobAdapter",
            path: "AdWhaleAdMobAdapter.xcframework"
        ),
        .target(
            name: "AdWhaleAdMobAdapterTarget",
            dependencies: [
                "AdWhaleAdMobAdapter",
                "AdWhaleSDKTarget",
                .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads"),
            ],
            path: "Shims/AdWhaleAdMobAdapterTarget"
        ),

        // ── Cauly 어댑터 ──
        .binaryTarget(
            name: "AdWhaleCaulyAdapter",
            path: "AdWhaleCaulyAdapter.xcframework"
        ),
        .target(
            name: "AdWhaleCaulyAdapterTarget",
            dependencies: [
                "AdWhaleCaulyAdapter",
                "AdWhaleSDKTarget",
                .product(name: "CaulySDK", package: "CaulySPM"),
            ],
            path: "Shims/AdWhaleCaulyAdapterTarget"
        ),

        // ── AdFit 어댑터 ──
        .binaryTarget(
            name: "AdWhaleAdFitAdapter",
            path: "AdWhaleAdFitAdapter.xcframework"
        ),
        .target(
            name: "AdWhaleAdFitAdapterTarget",
            dependencies: [
                "AdWhaleAdFitAdapter",
                "AdWhaleSDKTarget",
                .product(name: "AdFitSDK", package: "adfit-spm"),
            ],
            path: "Shims/AdWhaleAdFitAdapterTarget"
        ),

        // ── Admize 어댑터 ──
        .binaryTarget(
            name: "AdWhaleAdmizeAdapter",
            path: "AdWhaleAdmizeAdapter.xcframework"
        ),
        .target(
            name: "AdWhaleAdmizeAdapterTarget",
            dependencies: [
                "AdWhaleAdmizeAdapter",
                "AdWhaleSDKTarget",
                .product(name: "AdmizeSdk", package: "admize-sdk-ios"),
            ],
            path: "Shims/AdWhaleAdmizeAdapterTarget"
        ),

        // ── LevelPlay 어댑터 ──
        // AdMob 과 함께 탑재할 수 있다. 충돌하는 경우는 앱이 AdMob 미디에이션 파트너로
        // IronSource 어댑터를 추가했을 때뿐이다 (IronSource SDK 중복).
        .binaryTarget(
            name: "AdWhaleLevelPlayAdapter",
            path: "AdWhaleLevelPlayAdapter.xcframework"
        ),
        .target(
            name: "AdWhaleLevelPlayAdapterTarget",
            dependencies: [
                "AdWhaleLevelPlayAdapter",
                "AdWhaleSDKTarget",
                .product(name: "UnityMediationSDK", package: "LevelPlay-Swift-Package"),
            ],
            path: "Shims/AdWhaleLevelPlayAdapterTarget"
        ),
    ]
)
