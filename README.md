# AdWhale Mediation iOS SDK

AdWhale Mediation SDK for iOS - 다양한 광고 네트워크를 지원하는 광고 미디에이션 플랫폼

## 요구 사항

- iOS 15.0+
- Swift 5.9+
- Xcode 15+

## 설치

### Swift Package Manager

Xcode에서 **File > Add Package Dependencies...** 선택 후 아래 URL 입력:

```
https://github.com/adwhale-sdk/adwhale-sdk-ios.git
```

버전 설정:

```swift
.package(url: "https://github.com/adwhale-sdk/adwhale-sdk-ios.git", from: "0.0.1")
```

필요한 라이브러리 선택:
- `AdWhaleSDK` — Core SDK (필수)
- `AdWhaleAdMobAdapter` — AdMob 어댑터 (선택)

## 설정

### Info.plist

`Info.plist`에 Publisher UID를 추가합니다:

```xml
<key>net.adwhale.sdk.mediation.PUBLISHER_UID</key>
<string>YOUR_PUBLISHER_UID</string>
```

AdMob을 사용하는 경우 `GADApplicationIdentifier`도 추가합니다:

```xml
<key>GADApplicationIdentifier</key>
<string>YOUR_ADMOB_APP_ID</string>
```

## 사용법

### SDK 초기화

```swift
import AdWhaleSDK
import AdWhaleAdMobAdapter  // AdMob 사용 시

// AppDelegate 또는 앱 시작 시
AdWhaleAdMobAdapter.register()  // AdMob 어댑터 등록

AdWhaleMediationAds.initialize { statusCode, message in
    if statusCode == 100 {
        print("SDK 초기화 성공")
    }
}
```

### 배너 광고

```swift
let bannerView = AdWhaleBannerView()
bannerView.placementUid = "YOUR_PLACEMENT_UID"
bannerView.bannerSize = .banner320x50
bannerView.delegate = self
view.addSubview(bannerView)
bannerView.loadAd()

// AdWhaleBannerDelegate
func bannerDidReceiveAd(_ bannerView: AdWhaleBannerView) {
    print("배너 광고 로드 성공")
}

func banner(_ bannerView: AdWhaleBannerView, didFailToLoadWithError statusCode: Int, message: String) {
    print("배너 광고 로드 실패: \(message)")
}
```

### 전면 광고

```swift
let interstitialAd = AdWhaleInterstitialAd(placementUid: "YOUR_PLACEMENT_UID")
interstitialAd.delegate = self
interstitialAd.loadAd()

// 로드 성공 후 표시
func interstitialDidLoad(_ ad: AdWhaleInterstitialAd) {
    ad.show(from: self)
}
```

### 리워드 광고

```swift
let rewardedAd = AdWhaleRewardedAd(placementUid: "YOUR_PLACEMENT_UID")
rewardedAd.loadDelegate = self
rewardedAd.fullScreenDelegate = self
rewardedAd.loadAd()

// 로드 성공 후 표시
func rewardedAdDidLoad(_ ad: AdWhaleRewardedAd) {
    ad.show(from: self, rewardDelegate: self)
}

// 보상 지급
func userDidEarnReward(_ rewardItem: AdWhaleRewardItem) {
    print("보상: \(rewardItem.rewardType) x\(rewardItem.rewardAmount)")
}
```

### 프라이버시 설정

```swift
// COPPA
AdWhaleMediationAds.setCoppa(false)

// 콘텐츠 등급
AdWhaleMediationAds.setMaxAdContentRating(.teen)

// GDPR 동의
AdWhaleMediationAds.setGdpr(true)

// 테스트 디바이스
AdWhaleMediationAds.setTestDeviceIdentifiers(["YOUR_DEVICE_ID"])
```

## 지원 광고 포맷

| 포맷 | 클래스 |
|------|--------|
| 배너 | `AdWhaleBannerView` |
| 전면 | `AdWhaleInterstitialAd` |
| 리워드 | `AdWhaleRewardedAd` |
| 네이티브 | `AdWhaleNativeAdView` |
| 앱오프닝 | `AdWhaleAppOpenAd` |
| 종료 팝업 | `AdWhalePopupAd.exitPopup(placementUid:)` |
| 전환 팝업 | `AdWhalePopupAd.transitionPopup(placementUid:)` |

## 라이선스

Copyright © AdWhale. All rights reserved.
