# ADwhale Mediation iOS SDK

다양한 광고 네트워크를 지원하는 광고 미디에이션 플랫폼 iOS SDK 입니다.
바이너리(XCFramework)로 배포됩니다.

## Requirements

- iOS 15.0+
- Swift 5.9+
- Xcode 16.0+

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/adwhale-sdk/adwhale-sdk-ios.git", from: "0.0.2")
]
```

제공 라이브러리:
- `AdWhaleSDK` - Core SDK (필수)
- `AdWhaleAdMobAdapter` - AdMob 어댑터
- `AdWhaleCaulyAdapter` - Cauly 어댑터
- `AdWhaleAdFitAdapter` - AdFit 어댑터
- `AdWhaleAdmizeAdapter` - Admize 어댑터

`AdWhaleLevelPlayAdapter` 는 이 패키지에 포함되지 않는다. LevelPlay 는 AdMob 과
동시 탑재가 불가능해 별도 배포 라인으로 제공된다. AdMob 라인과 LevelPlay 라인 중
하나만 선택해야 하며, 둘 다 링크하면 중복 심볼 링커 에러가 발생한다.

AdMob 미디에이션 파트너 어댑터(InMobi, AppLovin, Vungle, DT Exchange, Mintegral,
Pangle, Unity, Moloco)도 이 패키지에 포함되지 않는다. 앱이 직접 SPM 패키지로
추가한다 (Android SDK 와 동일한 방식). 버전은 README 의 표대로 고정해야 하며,
앱 타겟 Other Linker Flags 에 `-ObjC` 가 필요하다. 이 플래그가 없으면 링커가
ObjC 어댑터를 제거해 런타임에 파트너로 워터폴이 넘어가지 않는다.

## API Overview

| 클래스 | 역할 |
|--------|------|
| `AdWhaleMediationAds` | SDK 초기화 및 전역 설정 |
| `AdWhaleMediationAdView` | 일반 배너 광고 (로드 성공 시 자동 노출) |
| `AdWhaleMediationAdBannerView` | 프리로드 배너 광고 (load / show 분리) |
| `AdWhaleMediationInterstitialAd` | 전면 광고 |
| `AdWhaleMediationRewardAd` | 리워드 광고 |
| `AdWhaleMediationNativeAdView` | 네이티브 광고 |
| `AdWhaleMediationAppOpenAd` | 앱오프닝 광고 |
| `AdWhaleMediationPopupAd` | 팝업 광고 (종료/전환 공용, AdFit 전용) |

## 서버 환경 (UAT / REAL)

배포 바이너리는 운영 서버로 고정 동작한다. 환경 전환 API(`setEnvironment(useUAT:)`)는
`ADWHALE_INTERNAL` 컴파일 조건이 켜진 내부 검증 빌드에만 포함되며, 매체 배포본에는 심볼이 없다.
(내부 바이너리: `ADWHALE_INTERNAL_API=1 ./scripts/build_xcframework.sh`)

## Info.plist 필수 설정

```xml
<key>net.adwhale.sdk.mediation.PUBLISHER_UID</key>
<string>YOUR_PUBLISHER_UID</string>

<!-- AdMob 사용 시 -->
<key>GADApplicationIdentifier</key>
<string>YOUR_ADMOB_APP_ID</string>

<!-- iOS 14+ ATT 권한 요청 문구 -->
<key>NSUserTrackingUsageDescription</key>
<string>사용자 맞춤 광고 제공을 위해 광고 식별자에 접근합니다.</string>
```

- SDK 는 `ATTrackingManager` 상태를 확인만 하며 팝업은 앱이 직접 호출. IDFA 수집을 위해 `ATTrackingManager.requestTrackingAuthorization` → `AdWhaleMediationAds.initialize` 순서 권장.
- `SKAdNetworkItems` 는 네트워크별 공식 가이드 참조 (iOS 14.5+ 어트리뷰션).

## Usage

### 1. 초기화 (ATT 먼저)

```swift
import AppTrackingTransparency
import AdWhaleSDK
import AdWhaleAdMobAdapter

ATTrackingManager.requestTrackingAuthorization { _ in
    AdWhaleAdMobAdapter.register()
    AdWhaleMediationAds.initialize { statusCode, _ in
        if statusCode == 100 { print("SDK 초기화 성공") }
    }
}
```

### 1-alt. 초기화 (ATT 생략 시)

```swift
import AdWhaleSDK
import AdWhaleAdMobAdapter  // 사용 어댑터 import

AdWhaleAdMobAdapter.register()  // 어댑터 등록

AdWhaleMediationAds.initialize { statusCode, message in
    if statusCode == 100 {
        print("SDK 초기화 성공")
    }
}
```

### 1-b. Publisher UID 를 코드에서 전달

`Info.plist` 의 `net.adwhale.sdk.mediation.PUBLISHER_UID` 대신 파라미터로 넘길 수 있다.
**파라미터가 `Info.plist` 보다 우선**하고, 공백이면 `Info.plist` 로 폴백한다.

```swift
AdWhaleMediationAds.initialize(publisherUid: "YOUR_PUBLISHER_UID") { statusCode, _ in
    if statusCode == 100 { print("SDK 초기화 성공") }
}

// Delegate 패턴
AdWhaleMediationAds.initialize(publisherUid: "YOUR_PUBLISHER_UID", delegate: self)
```

| 초기화 API | Publisher UID 출처 |
|---|---|
| `initialize(completion:)` / `initialize(delegate:)` | `Info.plist` |
| `initialize(publisherUid:completion:)` / `initialize(publisherUid:delegate:)` | 파라미터 (공백이면 `Info.plist`) |

### 2. 배너 광고

> **호출 순서**: `addSubview` → `loadAd`. attach 전 `loadAd` 호출 시 parent VC 를 찾지 못해 실패.

```swift
let bannerView = AdWhaleMediationAdBannerView()
bannerView.placementUid = "YOUR_PLACEMENT_UID"
bannerView.bannerSize = .banner320x50
bannerView.delegate = self
view.addSubview(bannerView)
bannerView.loadAd()

// AdWhaleMediationAdBannerViewDelegate
func bannerDidReceiveAd(_ bannerView: AdWhaleMediationAdBannerView) {}
func banner(_ bannerView: AdWhaleMediationAdBannerView, didFailToLoadWithError statusCode: Int, message: String) {}
```

### 3. 전면 광고

```swift
let interstitialAd = AdWhaleMediationInterstitialAd(placementUid: "UID")
interstitialAd.delegate = self
interstitialAd.loadAd()

func interstitialDidLoad(_ ad: AdWhaleMediationInterstitialAd) {
    ad.show(from: self)
}
```

### 4. 리워드 광고

```swift
let rewardedAd = AdWhaleMediationRewardAd(placementUid: "UID")
rewardedAd.loadDelegate = self
rewardedAd.fullScreenDelegate = self
rewardedAd.loadAd()

func rewardedAdDidLoad(_ ad: AdWhaleMediationRewardAd) {
    ad.show(from: self, rewardDelegate: self)
}

func userDidEarnReward(_ rewardItem: AdWhaleMediationRewardItem) {
    print("보상: \(rewardItem.rewardType) x\(rewardItem.rewardAmount)")
}
```

### 5. 프라이버시 설정

```swift
AdWhaleMediationAds.setCoppa(false)
AdWhaleMediationAds.setMaxAdContentRating(.teen)
AdWhaleMediationAds.setGdpr(true)
AdWhaleMediationAds.setTestDeviceIdentifiers(["YOUR_DEVICE_ID"])
```

> COPPA, MaxAdContentRating, GDPR 수동 동의 값은 `UserDefaults` 에 영구 저장됩니다.
> `testDeviceIdentifiers`, `isAppMuted`, `appVolume` 은 메모리 전용(앱 재시작 시 초기화).

### 6. GDPR 동의 요청 (Google UMP)

```swift
AdWhaleMediationAds.requestGdprConsent(from: self) { isSuccess, message in
    // 완료 후 IAB TCF 파싱 결과가 gdprConsent 에 반영됨
}

// 상태 조회
let status = AdWhaleMediationAds.gdprConsentStatus  // .obtained / .required / .notRequired / .unknown

// 초기화 (UMP 리셋 + 저장된 수동 동의 제거)
AdWhaleMediationAds.resetGdprConsentStatus()
```

> UMP 는 `UserDefaults.standard` 에 IAB 표준 키(`IABTCF_PurposeConsents`, `IABTCF_VendorConsents` 등)를 기록합니다. 앱에서 이 키를 직접 수정하지 마세요.

### 7. 팝업 광고 동작 주의

팝업은 **`AdWhaleMediationPopupAd` 하나로 통합**되어 있다 (iOS 네트워크가 종료/전환을 구분하지 않음).
AdFit `SuperboardPopUp` 의 구조상 **로드와 표시가 `show(from:)` 시점에 함께** 수행되므로
재고를 미리 확인할 수 없다 (`SuperboardPopUp` 에 로드 API 가 없고 `present()` 만이 광고를 요청한다).
SDK 는 두 단계 모두 통지한다.

| 단계 | 콜백 | 의미 |
|---|---|---|
| `loadAd()` | `popupAdDidLoad(_:)` (**잠정 성공**) | 팝업 준비까지만 성공. 재고 미확인 |
| `show(from:)` 성공 | `popupAdDidShow(_:)` | 실제 노출 |
| `show(from:)` 재고 없음 | `popupAd(_:didFailToShowWithError:message:)` **statusCode = 300** | 노출 시점 확정된 광고 미충족 |

⚠️ **팝업만 노출 실패에 300 이 올 수 있다.** 다른 애드폼의 노출 실패는 모두 200(연동 오류)이다.

### 8. show(from:) ViewController 요구사항

모든 전면/리워드/앱오픈/팝업 광고의 `show(from:)` 은 `viewController.view.window != nil` 상태의 VC 여야 합니다. dismiss 된 VC 를 전달하면 `didFailToShowWithError` 콜백(`statusCode=200`, message="ViewController is not in window hierarchy.")이 반환됩니다.

### 7. AdMob Ad Inspector (개발용)

`AdWhaleAdMobAdapter.register()` 가 호출된 경우에만 동작합니다.

```swift
AdWhaleMediationAds.openAdInspector(from: self) { errorCode, errorMessage in
    // errorCode == 0 이면 성공
}
```

## 지원 광고 포맷

| 포맷 | 클래스 |
|------|--------|
| 배너 | `AdWhaleMediationAdBannerView` |
| 전면 | `AdWhaleMediationInterstitialAd` |
| 리워드 | `AdWhaleMediationRewardAd` |
| 네이티브 | `AdWhaleMediationNativeAdView` |
| 앱오프닝 | `AdWhaleMediationAppOpenAd` |
| 팝업 (종료 / 전환 공용) | `AdWhaleMediationPopupAd(placementUid:)` |

## 콜백과 에러 코드 정책

| 코드 | 의미 | 대표 상황 | 대응 |
|:---:|---|---|---|
| **200** | **연동 오류** | 초기화 누락, `placementUid` 미설정, 미로드 상태의 `show()`, window 미부착 VC | 코드 수정 필요. 재시도해도 동일 실패 |
| **300** | **광고 미충족** | 설정 응답 무효, 워터폴 전체 소진(실패/무응답) | 정상 상황. 자체광고 대체 등 후처리 |
| 100 | 성공 | `initialize()` 완료 | - |

### 광고 로드 워치독

광고 네트워크가 성공과 실패 어느 콜백도 주지 않으면 **네트워크당 10초** 후 다음 순위로 진행한다.
서버 설정의 `timeout_sec`(설정 API 통신 타임아웃)과는 무관한 SDK 내부 상수다.
만료는 별도 콜백으로 통지되지 않고, **워터폴이 모두 소진된 시점에 실패 콜백이 1회** 온다.

### 배너와 네이티브의 "노출 유지" 갱신 실패

자동 갱신 중 실패(300)해도 **이미 노출 중인 광고는 유지된다.** 두 상황은 메시지로 구분한다.

| 메시지 | 상태 | 대응 |
|---|---|---|
| `... Previous ad is still showing.` | 이번 갱신 시도만 실패. 광고는 노출 중 | **아무것도 하지 않기** |
| (해당 문구 없음) | 보여줄 광고 없음 | 자체광고 대체 |

로드 성공 콜백을 한 번이라도 받았는지 플래그로 판별해도 동일하다.

## Important

- `AdWhaleMediationAds.initialize` 를 호출하지 않고 광고를 로드하면 초기화 실패 상태가 됩니다.
- 사용하려는 광고 네트워크의 어댑터 라이브러리를 SPM 에서 선택하고 `register()` 를 호출해야 합니다.
- `delegate` 를 설정하지 않으면 실패 콜백이 어디에도 전달되지 않습니다. SDK 가 `통지할 리스너가 없습니다` 경고 로그를 남깁니다. "광고도 안 나오고 콜백도 없다" 면 먼저 이 로그를 확인하세요.
- 이 SDK 는 바이너리로만 배포됩니다. 소스 코드는 제공되지 않습니다.
