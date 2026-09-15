// AdWhaleAdMobAdapterTarget
//
// 링크 전용 shim. 실제 구현은 대응하는 XCFramework 안에 있다.
// .binaryTarget 이 dependencies 를 선언할 수 없기 때문에,
// 파트너 SDK 의존성을 걸어 줄 목적으로만 존재하는 빈 타겟이다.
// (SPM 이 소스 파일 0개인 타겟을 허용하지 않아 이 파일이 필요하다)
//
// 이 파일을 지우거나 내용을 추가하지 말 것.

enum AdWhaleAdMobAdapterTargetShim {}
