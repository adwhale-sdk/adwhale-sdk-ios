# ─────────────────────────────────────────────────────────────
# ADwhale Mediation iOS SDK - CocoaPods 배포 매니페스트
#
# ⚠️ 아직 검증되지 않은 초안이며 spec repo 에 등록되지 않았다.
#    SPM 이 1차 배포 경로이고, 이 podspec 은 React Native 래퍼가
#    SPM 을 지원하기 전까지의 과도기용 대비다.
#
# ★ SPM 과 완전히 같은 XCFramework 를 가리킨다 ★
#   재빌드가 필요 없다. dist-resources/Package.swift 의 binaryTarget 과
#   이 파일의 vendored_frameworks 가 같은 파일을 가리킨다.
#
# 등록 방법 (필요해질 때):
#   pod repo push adwhale-specs AdWhaleSDK.podspec \
#     --sources='https://github.com/dev-adwhale/AdWhaleSDK_iOS.git,https://cdn.cocoapods.org'
#
#   ※ CocoaPods trunk 는 2026-12-02 부터 read-only 이지만
#     private spec repo 는 영향받지 않는다.
#
# 제외된 어댑터:
#   AdFit  - CocoaPods 지원 중단 (SPM 전용). pod 고객은 팝업 포맷 미지원.
#   Admize - CocoaPods 미지원 (추후 지원 예정). 지원 시 subspec 추가만 하면 된다.
#   LevelPlay - AdMob 과 동시 탑재 불가. 별도 배포 라인.
# ─────────────────────────────────────────────────────────────

Pod::Spec.new do |s|
  s.name     = 'AdWhaleSDK'
  s.version  = '0.0.3'
  s.summary  = 'ADwhale Mediation iOS SDK'
  s.description = <<-DESC
    다양한 광고 네트워크를 지원하는 광고 미디에이션 플랫폼 iOS SDK.
    바이너리(XCFramework)로 배포되며 Swift / Objective-C 모두에서 사용할 수 있다.
  DESC
  s.homepage = 'https://github.com/adwhale-sdk/adwhale-sdk-ios'
  s.license  = { :type => 'Commercial', :file => 'LICENSE' }
  s.author   = { 'FSN' => 'develop@fsn.co.kr' }

  s.platform              = :ios, '15.0'
  s.swift_version         = '5.9'
  s.source                = {
    :git => 'https://github.com/adwhale-sdk/adwhale-sdk-ios.git',
    :tag => s.version.to_s
  }

  # vendored 프레임워크가 static 이므로 embed 하지 않는다.
  # (기존 AdWhaleSDK 1.0.8 pod 과 동일한 링크 방식 → 고객 앱 패키징 변화 없음)
  s.static_framework = true

  s.default_subspecs = 'Core'

  # ── Core (필수) ──
  s.subspec 'Core' do |ss|
    ss.vendored_frameworks = 'AdWhaleSDK.xcframework'
    ss.dependency 'GoogleUserMessagingPlatform', '>= 3.0'

    # UMP 는 pod 이름(GoogleUserMessagingPlatform)과
    # 실제 프레임워크/모듈 이름(UserMessagingPlatform)이 달라 링크 경로를 잡아줘야 한다.
    # 이 처리를 SDK 가 흡수해 두면 Flutter / RN 래퍼 podspec 이 깨끗해진다.
    ss.pod_target_xcconfig = {
      'DEFINES_MODULE' => 'YES',
      'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
      'FRAMEWORK_SEARCH_PATHS' => '$(inherited) ' \
        '"${PODS_CONFIGURATION_BUILD_DIR}/GoogleUserMessagingPlatform" ' \
        '"${PODS_ROOT}/GoogleUserMessagingPlatform/Frameworks/Release/UserMessagingPlatform.xcframework/ios-arm64" ' \
        '"${PODS_ROOT}/GoogleUserMessagingPlatform/Frameworks/Release/UserMessagingPlatform.xcframework/ios-arm64_x86_64-simulator"',
      'OTHER_LDFLAGS' => '$(inherited) -framework "UserMessagingPlatform"',
    }
    ss.user_target_xcconfig = {
      'OTHER_LDFLAGS' => '$(inherited) -ObjC',
    }
  end

  # ── AdMob / AdManager 어댑터 ──
  #
  # 미디에이션 파트너 어댑터는 포함하지 않는다. 앱 Podfile 에서 직접 추가한다.
  # (안드로이드와 동일한 방식. README 의 버전표 참조)
  s.subspec 'AdMob' do |ss|
    ss.dependency 'AdWhaleSDK/Core'
    ss.vendored_frameworks = 'AdWhaleAdMobAdapter.xcframework'
    ss.dependency 'Google-Mobile-Ads-SDK', '13.0.0'
  end

  # ── Cauly 어댑터 ──
  # 앱 Podfile 에 source 추가 필요:
  #   source 'https://github.com/cauly/CaulySDK_iOS.git'
  s.subspec 'Cauly' do |ss|
    ss.dependency 'AdWhaleSDK/Core'
    ss.vendored_frameworks = 'AdWhaleCaulyAdapter.xcframework'
    ss.dependency 'CaulySDK', '3.1.22'
  end

  # ── AdFit 어댑터 - CocoaPods 미지원 ──
  # AdFit 이 CocoaPods 배포를 중단해 파트너 SDK 를 pod 으로 받을 수 없다.
  # 하이브리드(앱이 Xcode 에서 AdFit SPM 패키지를 직접 추가)는 링크 시점에
  # 심볼이 해결되므로 동작하지만, CocoaPods 가 의존성으로 표현할 수 없다.
  # 필요해지면 아래를 열고 가이드로 안내한다.
  #
  # s.subspec 'AdFit' do |ss|
  #   ss.dependency 'AdWhaleSDK/Core'
  #   ss.vendored_frameworks = 'AdWhaleAdFitAdapter.xcframework'
  #   # AdFitSDK 는 앱이 Xcode SPM 으로 직접 추가해야 한다:
  #   #   https://github.com/adfit/adfit-spm.git  exact 3.21.24
  # end

  # ── Admize 어댑터 - CocoaPods 지원 예정 ──
  # Admize pod 이 나오면 아래 3줄만 열면 된다 (XCFramework 재빌드 불필요).
  #
  # s.subspec 'Admize' do |ss|
  #   ss.dependency 'AdWhaleSDK/Core'
  #   ss.vendored_frameworks = 'AdWhaleAdmizeAdapter.xcframework'
  #   ss.dependency 'AdmizeSdk', '0.0.1'
  # end
end
