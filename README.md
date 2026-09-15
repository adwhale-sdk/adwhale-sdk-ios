# ADwhale Mediation iOS SDK

다양한 광고 네트워크를 지원하는 광고 미디에이션 플랫폼 iOS SDK 입니다.
바이너리(XCFramework)로 배포되며, Swift 및 Objective-C 프로젝트 모두에서 사용할 수 있습니다.

> **Requirements:** iOS 15.0+, Swift 5.9+, Xcode 16.0+
>
> **Privacy manifest:** 이 SDK 는 `PrivacyInfo.xcprivacy` 를 포함합니다.
> Xcode 가 앱을 아카이브할 때 앱의 개인정보 보고서에 자동으로 합쳐집니다. 별도 설정은 필요 없습니다.

---

## Installation

### Swift Package Manager

Xcode → File → Add Package Dependencies 에서 아래 URL 을 추가합니다.

```
https://github.com/adwhale-sdk/adwhale-sdk-ios
```

또는 `Package.swift` 에 직접 추가합니다.

```swift
dependencies: [
    .package(url: "https://github.com/adwhale-sdk/adwhale-sdk-ios.git", from: "0.0.5")
]
```

필요한 라이브러리를 선택합니다.
- `AdWhaleSDK` - Core SDK (필수)
- `AdWhaleAdMobAdapter` - AdMob 어댑터 (선택)
- `AdWhaleCaulyAdapter` - Cauly 어댑터 (선택)
- `AdWhaleAdFitAdapter` - AdFit 어댑터 (선택)
- `AdWhaleAdmizeAdapter` - Admize 어댑터 (선택)

> **LevelPlay 는 이 패키지에 포함되지 않습니다.**
> LevelPlay 는 AdMob 과 동시 탑재가 불가능해 별도 배포 라인으로 제공됩니다.
> AdMob 라인과 LevelPlay 라인 중 **하나만** 선택하세요. 둘 다 링크하면 중복 심볼 링커 에러가 발생합니다.

### AdMob 미디에이션 파트너 (선택)

미디에이션 파트너 어댑터는 SDK 에 포함되지 않습니다. **앱이 직접 추가**합니다 (Android SDK 와 동일한 방식).

Xcode → File → Add Package Dependencies 에서 필요한 네트워크만 추가하세요.

| 네트워크 | SPM 저장소 | 버전 (exact) | product |
|---|---|---|---|
| InMobi | `googleads/googleads-mobile-ios-mediation-inmobi` | `11.1.101` | `InMobiAdapterTarget` |
| AppLovin | `googleads/googleads-mobile-ios-mediation-applovin` | `13.5.100` | `AppLovinAdapterTarget` |
| Vungle (Liftoff) | `googleads/googleads-mobile-ios-mediation-liftoffmonetize` | `7.7.0` | `LiftoffMonetizeAdapterTarget` |
| DT Exchange | `googleads/googleads-mobile-ios-mediation-dtexchange` | `8.4.401` | `DTExchangeAdapterTarget` |
| Mintegral | `googleads/googleads-mobile-ios-mediation-mintegral` | `8.0.700` | `MintegralAdapterTarget` |
| Pangle | `googleads/googleads-mobile-ios-mediation-pangle` | `7.9.600` | `PangleAdapterTarget` |
| Unity Ads | `googleads/googleads-mobile-ios-mediation-unity` | `4.16.601` | `UnityAdapterTarget` |
| Moloco | `googleads/googleads-mobile-ios-mediation-moloco` | `4.3.2` | `MolocoAdapterTarget` |

`Package.swift` 로 추가하는 경우:

```swift
dependencies: [
    .package(url: "https://github.com/adwhale-sdk/adwhale-sdk-ios.git", from: "0.0.5"),
    .package(url: "https://github.com/googleads/googleads-mobile-ios-mediation-inmobi.git", exact: "11.1.101"),
    // 필요한 네트워크만 추가
]
```

> ⚠️ **버전을 반드시 위 표대로 고정하세요.**
> ADwhale AdMob 어댑터는 `Google-Mobile-Ads-SDK 13.0.0` 기준으로 빌드되어 있습니다.
> 파트너 어댑터가 다른 메이저 버전의 GMA 를 끌어오면 런타임에 광고가 로드되지 않습니다.

> ⚠️ **앱 타겟에 `-ObjC` 링커 플래그가 필요합니다.**
> 파트너 어댑터는 Objective-C 클래스/카테고리로 구현되어 있어, 이 플래그가 없으면
> 링커가 코드를 제거해 런타임에 어댑터를 찾지 못합니다.
>
> Xcode → 앱 타겟 → Build Settings → **Other Linker Flags** 에 `-ObjC` 추가

### CocoaPods

> 현재 **SPM 만 공식 지원**합니다.
> CocoaPods 매니페스트(`AdWhaleSDK.podspec`)가 저장소에 포함되어 있으나 미검증 초안이며,
> spec repo 에 등록되어 있지 않습니다. 필요하시면 문의해 주세요.
>
> CocoaPods trunk 는 2026-12-02 부터 read-only 로 전환되어 파트너 SDK 의 신규 버전을
> 받을 수 없게 됩니다. 신규 프로젝트는 SPM 을 사용하세요.

---

## Quick Start

### 1. Info.plist 설정 (필수)

`Info.plist` 에 Publisher UID 를 추가합니다.

```xml
<key>net.adwhale.sdk.mediation.PUBLISHER_UID</key>
<string>YOUR_PUBLISHER_UID</string>
```

> **Publisher UID 를 코드에서 전달할 수도 있습니다.**
> `Info.plist` 대신 초기화 시 파라미터로 넘기면 됩니다 (아래 3번 참고).
> 두 방법을 모두 쓴 경우 **파라미터가 우선**하며, 파라미터가 공백이면 `Info.plist` 값으로 폴백합니다.
> 빌드 구성별로 다른 UID 를 쓰거나 xcconfig / 원격 설정에서 주입할 때 유용합니다.

AdMob 을 사용하는 경우 `GADApplicationIdentifier` 도 추가합니다.

```xml
<key>GADApplicationIdentifier</key>
<string>YOUR_ADMOB_APP_ID</string>
```

iOS 14+ 에서 IDFA 를 수집해 광고 수익을 정상화하려면 ATT 권한 요청용 설명 문구를 추가합니다.

```xml
<key>NSUserTrackingUsageDescription</key>
<string>사용자 맞춤 광고 제공을 위해 광고 식별자에 접근합니다.</string>
```

iOS 14.5+ SKAdNetwork 어트리뷰션을 위해 네트워크별 `SKAdNetworkItems` 도 `Info.plist` 에 추가하세요. (AdMob / Cauly / AdFit / Admize 각 네트워크의 공식 가이드 참조)

### 2. ATT(App Tracking Transparency) 권한 요청

SDK 는 `ATTrackingManager` 상태를 확인만 하며 권한 팝업은 **앱이 직접 띄워야 합니다**. 팝업 응답을 받은 뒤 SDK 를 초기화하는 것이 권장 플로우입니다.

```swift
import AppTrackingTransparency

ATTrackingManager.requestTrackingAuthorization { _ in
    AdWhaleAdMobAdapter.register()
    AdWhaleMediationAds.initialize { _, _ in }
}
```

권한 요청을 생략하면 IDFA 가 `00000000-...` 로 수집되어 광고 매칭률이 떨어집니다.

### 3. SDK 초기화

```swift
import AdWhaleSDK
import AdWhaleAdMobAdapter  // AdMob 사용 시

// AppDelegate 또는 앱 시작 시
AdWhaleAdMobAdapter.register()  // 어댑터 등록

AdWhaleMediationAds.initialize { statusCode, message in
    if statusCode == 100 {
        print("SDK 초기화 성공")
    }
}
```

Publisher UID 를 코드에서 전달하는 경우 (`Info.plist` 선언 불필요):

```swift
AdWhaleMediationAds.initialize(publisherUid: "YOUR_PUBLISHER_UID") { statusCode, message in
    if statusCode == 100 {
        print("SDK 초기화 성공")
    }
}
```

Objective-C 또는 Delegate 패턴:

```swift
AdWhaleMediationAds.initialize(delegate: self)                                       // Info.plist 사용
AdWhaleMediationAds.initialize(publisherUid: "YOUR_PUBLISHER_UID", delegate: self)   // 파라미터 전달
```

| 초기화 API | Publisher UID 출처 |
|---|---|
| `initialize(completion:)` / `initialize(delegate:)` | `Info.plist` |
| `initialize(publisherUid:completion:)` / `initialize(publisherUid:delegate:)` | **파라미터** (공백이면 `Info.plist` 폴백) |

### 4. 배너 광고

> **호출 순서 중요**: `loadAd()` 는 반드시 `addSubview(...)` 로 배너 뷰를 **화면 계층에 추가한 후** 호출하세요. Cauly 등 일부 네트워크는 parent `UIViewController` 를 responder chain 으로 찾기 때문에 attach 전 호출 시 로드가 실패합니다.

```swift
let bannerView = AdWhaleMediationAdBannerView()
bannerView.placementUid = "YOUR_PLACEMENT_UID"
bannerView.bannerSize = .banner320x50
bannerView.delegate = self
view.addSubview(bannerView)  // 먼저 attach
bannerView.loadAd()            // 그 다음 로드

// AdWhaleMediationAdBannerViewDelegate
func bannerDidReceiveAd(_ bannerView: AdWhaleMediationAdBannerView) {
    print("배너 광고 로드 성공")
}

func banner(_ bannerView: AdWhaleMediationAdBannerView, didFailToLoadWithError statusCode: Int, message: String) {
    print("배너 광고 로드 실패: \(message)")
}
```

### 5. 전면 광고

```swift
let interstitialAd = AdWhaleMediationInterstitialAd(placementUid: "YOUR_PLACEMENT_UID")
interstitialAd.delegate = self
interstitialAd.loadAd()

// 로드 성공 후 표시 (viewController 는 window 에 attach 된 상태여야 함)
func interstitialDidLoad(_ ad: AdWhaleMediationInterstitialAd) {
    ad.show(from: self)
}
```

### 6. 리워드 광고

```swift
let rewardedAd = AdWhaleMediationRewardAd(placementUid: "YOUR_PLACEMENT_UID")
rewardedAd.loadDelegate = self
rewardedAd.fullScreenDelegate = self
rewardedAd.loadAd()

// 로드 성공 후 표시
func rewardedAdDidLoad(_ ad: AdWhaleMediationRewardAd) {
    ad.show(from: self, rewardDelegate: self)
}

// 보상 지급
func userDidEarnReward(_ rewardItem: AdWhaleMediationRewardItem) {
    print("보상: \(rewardItem.rewardType) x\(rewardItem.rewardAmount)")
}
```

### 7. 팝업 광고 (종료 / 전환 공용)

iOS 광고 네트워크(AdFit)는 종료/전환 구분 없이 단일 팝업 형식만 제공하므로,
**`AdWhaleMediationPopupAd` 하나로 통합**되어 있습니다. (Android 는 종료/전환이 분리되어 있습니다)

AdFit 팝업은 내부적으로 **로드와 표시가 한 번에 이뤄지는** 구조라, 재고를 미리 확인할 수 없습니다.
(`AdFitSDK` 의 `SuperboardPopUp` 에는 로드 API 가 없고 `present()` 만이 광고를 요청합니다)
따라서 SDK 는 **두 단계 모두 통지**합니다.

| 단계 | 콜백 | 의미 |
|---|---|---|
| `loadAd()` | `popupAdDidLoad(_:)` (**잠정 성공**) | 팝업 준비까지만 성공. 재고는 미확인 |
| `show(from:)` → 노출 성공 | `popupAdDidShow(_:)` | 실제 광고가 노출됨 |
| `show(from:)` → 재고 없음 | `popupAd(_:didFailToShowWithError:message:)` **statusCode = 300** | 노출 시점에 확정된 광고 미충족 |

> ⚠️ **팝업만 노출 실패에 300 이 올 수 있습니다.** 다른 애드폼의 노출 실패는 모두 200(연동 오류)입니다.
> 팝업의 300 은 "연동은 정상인데 광고 재고가 없었다" 는 뜻이므로 코드 수정 대상이 아닙니다.

```swift
let popupAd = AdWhaleMediationPopupAd(placementUid: "YOUR_PLACEMENT_UID")
popupAd.delegate = self
popupAd.loadAd()

func popupAdDidLoad(_ ad: AdWhaleMediationPopupAd) {
    ad.show(from: self)  // 실제 광고 요청은 이 시점
}

func popupAd(_ ad: AdWhaleMediationPopupAd, didFailToShowWithError statusCode: Int, message: String) {
    // statusCode == 300 이면 재고 부재 (연동 오류 아님)
}
```

### 8. 프라이버시 설정

COPPA, 광고 콘텐츠 등급, GDPR 수동 동의 설정은 `UserDefaults` 에 영구 저장됩니다.

```swift
AdWhaleMediationAds.setCoppa(false)
AdWhaleMediationAds.setMaxAdContentRating(.teen)
AdWhaleMediationAds.setGdpr(true)
AdWhaleMediationAds.setTestDeviceIdentifiers(["YOUR_DEVICE_ID"])
```

### 9. GDPR 동의 요청 (Google UMP)

EEA 사용자를 위한 Google UMP 동의 플로우를 실행합니다. 폼이 종료되면 IAB TCF 문자열을 파싱해 개인 맞춤 광고 동의 여부를 자동 저장합니다.

```swift
AdWhaleMediationAds.requestGdprConsent(from: self) { isSuccess, message in
    if isSuccess {
        print("GDPR 동의 처리 완료")
    }
}
```

상태 조회와 초기화:

```swift
let status = AdWhaleMediationAds.gdprConsentStatus  // .obtained / .required / .notRequired / .unknown
AdWhaleMediationAds.resetGdprConsentStatus()        // UMP 리셋 + 저장된 동의 제거
```

> UMP 는 동의 결과를 IAB 표준 키(`IABTCF_PurposeConsents`, `IABTCF_VendorConsents` 등)로 `UserDefaults.standard` 에 기록합니다. 앱에서 동일 키를 직접 수정하지 마세요.

### 10. AdMob Ad Inspector (개발용)

AdMob 광고 호출을 실시간 진단하는 검사기를 실행합니다. `AdWhaleAdMobAdapter.register()` 가 호출된 경우에만 동작합니다.

```swift
AdWhaleMediationAds.openAdInspector(from: self) { errorCode, errorMessage in
    print("Ad Inspector 종료: \(errorMessage)")
}
```

---

### 11. 서버 환경

배포 SDK 는 **운영 서버(`https://api.adwhale.net`)로 고정**되어 동작합니다.
환경 전환 API 는 애드웨일 내부 검증 빌드에만 포함되며, 배포 바이너리에는 들어가지 않습니다.

UAT 환경에서의 검증이 필요하면 애드웨일 담당자에게 내부 검증용 빌드를 요청하세요.

- Placement UID / Publisher UID 같은 키값은 xcconfig 로 분리하는 것을 권장합니다.

---

## 콜백과 에러 코드 정책

모든 실패 콜백의 `statusCode` 는 두 가지 의미로만 내려옵니다.

| 코드 | 의미 | 대표 상황 | 매체사 대응 |
|:---:|---|---|---|
| **200** | **연동 오류** | 초기화 누락, `placementUid` 미설정, 미로드 상태의 `show()`, window 에 붙지 않은 `UIViewController` 전달 | **코드 수정이 필요합니다.** 재시도해도 동일하게 실패합니다 |
| **300** | **광고 미충족** | 설정 응답 무효, 워터폴 전체 소진(모든 네트워크 실패/무응답) | 정상 상황입니다. 자체광고 대체 등 후처리 |
| 100 | 성공 | `initialize()` 완료 | - |

### 광고 로드 제한 시간 (워치독)

광고 네트워크가 **성공과 실패 어느 콜백도 돌려주지 않는** 경우, SDK 가 네트워크당 **10초**를 기다린 뒤
다음 순위 네트워크로 진행합니다. 한 네트워크의 무응답이 워터폴 전체를 멈추거나
콜백이 아예 오지 않는 상태(침묵)를 만들지 않습니다.

- 이 제한 시간은 SDK 내부 상수이며, 서버 설정의 `timeout_sec`(설정 API 통신 타임아웃)과는 **무관**합니다.
- 만료는 별도 콜백으로 통지되지 않습니다. 워터폴이 계속 진행되고, **모두 소진된 시점에 실패 콜백이 1회** 옵니다.

### "노출 중인 광고가 유지되는" 갱신 실패 (배너와 네이티브)

배너와 네이티브는 자동 갱신 중에도 로드 실패(300)를 받을 수 있습니다.
이때 **이미 노출 중인 광고는 그대로 유지**되므로, 실패 콜백을 그대로 믿고 자체광고로 덮으면
멀쩡히 노출 중인 광고를 가리게 됩니다. 두 상황은 **메시지로 구분**합니다.

| 메시지 | 상태 | 권장 대응 |
|---|---|---|
| `... Previous ad is still showing.` | 이번 **갱신 시도만** 실패. 광고는 계속 노출 중 | **아무것도 하지 않기** |
| (해당 문구 없음) | 보여줄 광고가 없음 | 자체광고 대체 등 후처리 |

> 메시지 문자열 비교가 부담스러우면 로드 성공 콜백을
> **한 번이라도 받았는지**를 플래그로 두고 판별해도 동일한 효과를 얻습니다.

### 리스너(Delegate) 미설정 주의

`delegate` 를 설정하지 않으면 실패가 어디에도 전달되지 않아 "광고도 안 나오고 콜백도 없는" 상태가 됩니다.
SDK 는 이 경우 `통지할 리스너가 없습니다` 경고 로그를 남깁니다.
광고가 안 나오는데 콜백도 없다면 **먼저 이 로그를 확인**하세요.

---
## Objective-C

모든 공개 클래스가 `@objc` 로 노출되어 있습니다. 모듈로 가져옵니다.

```objc
@import AdWhaleSDK;
// 또는
#import <AdWhaleSDK/AdWhaleSDK-Swift.h>
```

### 초기화

```objc
[AdWhaleMediationAds initializeWithCompletion:^(NSInteger statusCode, NSString * _Nonnull message) {
    if (statusCode == 0) {
        NSLog(@"SDK 초기화 성공");
    } else {
        NSLog(@"SDK 초기화 실패: %ld %@", (long)statusCode, message);
    }
}];

// Publisher UID 를 파라미터로 전달하는 경우
[AdWhaleMediationAds initializeWithPublisherUid:@"YOUR_PUBLISHER_UID"
                                     completion:^(NSInteger statusCode, NSString * _Nonnull message) { }];

// Delegate 패턴 (AdWhaleMediationOnInitCompleteDelegate 채택)
[AdWhaleMediationAds initializeWithDelegate:self];

- (void)onInitCompleteWithStatusCode:(NSInteger)statusCode message:(NSString *)message {
    // 초기화 완료
}
```

### 배너 광고

```objc
AdWhaleMediationAdView *adView = [[AdWhaleMediationAdView alloc] initWithFrame:CGRectZero];
adView.placementUid = @"YOUR_PLACEMENT_UID";
adView.bannerSize = AdWhaleBannerSizeBanner320x50;
[adView setAdWhaleMediationAdViewDelegate:self];
[self.view addSubview:adView];
[adView loadAd];

// 화면 전환 시
[adView pause];
[adView resume];
[adView destroy];
```

`AdWhaleBannerSize` 값은 `Banner320x50`, `Banner320x100`, `Banner300x250`, `Banner250x250`, `AdaptiveAnchor` 입니다.

```objc
- (void)adViewDidReceiveAd:(AdWhaleMediationAdView *)adView {
    // 로드 성공. 자동으로 노출됩니다
}
```

### 전면 광고

```objc
AdWhaleMediationInterstitialAd *ad =
    [[AdWhaleMediationInterstitialAd alloc] initWithPlacementUid:@"YOUR_PLACEMENT_UID"];
[ad setAdWhaleMediationInterstitialDelegate:self];
[ad loadAd];

// 로드 완료 후
[ad showFrom:self];

- (void)interstitialDidLoad:(AdWhaleMediationInterstitialAd *)ad {
    [ad showFrom:self];
}

- (void)interstitial:(AdWhaleMediationInterstitialAd *)ad
didFailToLoadWithError:(NSInteger)statusCode
             message:(NSString *)message {
    // statusCode 200 = 연동 오류, 300 = 광고 미충족
}
```

### 리워드 광고

```objc
AdWhaleMediationRewardAd *rewardAd =
    [[AdWhaleMediationRewardAd alloc] initWithPlacementUid:@"YOUR_PLACEMENT_UID"];
[rewardAd setUserId:@"USER_ID"];
[rewardAd loadAdWithLoadDelegate:self];

// 로드 완료 후. 보상 지급은 rewardDelegate 로 받습니다
[rewardAd showFrom:self rewardDelegate:self];
[rewardAd destroy];
```

> 리워드는 로드와 노출의 delegate 가 분리되어 있습니다.
> 로드는 `AdWhaleMediationRewardAdLoadDelegate`, 전체화면 생명주기는 `AdWhaleRewardedFullScreenDelegate`,
> 보상 지급은 `AdWhaleUserEarnedRewardDelegate` 입니다.

## 지원 광고 포맷

| 포맷 | 클래스 |
|------|--------|
| 배너 | `AdWhaleMediationAdBannerView` |
| 전면 | `AdWhaleMediationInterstitialAd` |
| 리워드 | `AdWhaleMediationRewardAd` |
| 네이티브 | `AdWhaleMediationNativeAdView` |
| 앱오프닝 | `AdWhaleMediationAppOpenAd` |
| 팝업 (종료 / 전환 공용) | `AdWhaleMediationPopupAd(placementUid:)` |

---

## Important

- `AdWhaleMediationAds.initialize` 를 호출하지 않고 광고를 로드하면 초기화 실패 상태가 됩니다.
- 배너 광고는 `addSubview(...)` 로 화면 계층에 추가한 뒤 `loadAd()` 를 호출해야 합니다.
- 전면/리워드/앱오픈/팝업 광고의 `show(from:)` 은 `viewController.view.window != nil` 상태인 VC 로만 호출해야 합니다. dismiss 된 VC 를 전달하면 `didFailToShowWithError` 로 실패가 전달됩니다.
- AdFit 팝업은 내부 구조상 `show(from:)` 시점에 실제 광고가 요청됩니다. `loadAd` 성공 콜백은 **잠정 성공**이며, 재고 부재는 show 단계에서 `statusCode=300` 으로 통지됩니다.
- 실패 콜백의 `statusCode` 는 **200 = 연동 오류(코드 수정 필요)**, **300 = 광고 미충족(정상 상황)** 으로만 구분됩니다. 자세한 내용은 [콜백과 에러 코드 정책](#콜백과-에러-코드-정책) 참고.
- 배너와 네이티브의 갱신 실패 메시지에 `Previous ad is still showing.` 이 포함되면 **광고는 계속 노출 중**입니다. 자체광고로 덮지 마세요.
- `delegate` 를 설정하지 않으면 실패 콜백이 어디에도 전달되지 않습니다. SDK 가 `통지할 리스너가 없습니다` 경고 로그를 남깁니다.
- UMP 는 `UserDefaults.standard` 에 IAB 표준 키(`IABTCF_*`)를 기록합니다. 앱에서 이 키를 직접 수정하지 마세요.
- 이 SDK 는 바이너리로만 배포됩니다. 소스 코드는 제공되지 않습니다.

## AI Agent Support

AI 코딩 도구(Claude Code, Codex, Gemini CLI, Cursor 등)를 사용하여 SDK 를 연동하는 경우 [AGENTS.md](AGENTS.md) 를 참고하세요.

## License

Proprietary. 자세한 내용은 [LICENSE](LICENSE) 파일을 참고하세요.

Copyright © ADwhale. All rights reserved.
