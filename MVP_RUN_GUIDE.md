# MVP 실행 가이드

이 앱은 iOS/Android에서 Google ML Kit OCR로 실제 이미지 텍스트를 인식하고, 서버 없이 로컬에 분석 결과를 저장하는 Flutter Local MVP입니다.

## 1. 준비

이 Mac에는 Codex 작업용 Flutter/Android 환경을 준비해두었습니다.

```bash
cd "/Users/baeghyeonmyeong/Documents/New project 2"
source scripts/flutter_env.sh
flutter --version
flutter doctor -v
```

설치된 주요 경로:

- Flutter SDK: `/Users/baeghyeonmyeong/.codex-flutter/flutter`
- Android SDK: `/Users/baeghyeonmyeong/Library/Android/sdk`
- Android AVD: `PlaceNote_API35`

Xcode/CocoaPods도 iOS 빌드가 가능한 상태까지 확인했습니다. 실제 iPhone 실행에는 Apple 개발자 계정 Signing Team 선택이 필요합니다.

## 2. 프로젝트 폴더로 이동

```bash
cd "/Users/baeghyeonmyeong/Documents/New project 2"
source scripts/flutter_env.sh
```

## 3. 패키지 설치

```bash
flutter pub get
```

## 4. Android 기기/에뮬레이터 실행

에뮬레이터 목록 확인:

```bash
flutter emulators
```

준비된 Android 에뮬레이터 실행:

```bash
emulator -avd PlaceNote_API35
```

다른 터미널에서 앱 실행:

```bash
scripts/run_android.sh
```

또는 특정 기기 ID로 실행:

```bash
flutter devices
flutter run -d emulator-5554
```

실제 Android 기기는 개발자 옵션과 USB 디버깅을 켠 뒤 USB로 연결하고 `flutter devices`에 표시되면 같은 명령으로 실행합니다.

## 5. 실제 iPhone 실행

먼저 iPhone을 USB로 연결하고 iPhone 화면에서 `이 컴퓨터를 신뢰`를 허용합니다. 그 다음 Xcode에서 Signing Team을 지정합니다.

```bash
open ios/Runner.xcworkspace
```

Xcode에서:

- 좌측 `Runner` 프로젝트 선택
- `Runner` target 선택
- `Signing & Capabilities`
- `Team`에 본인 Apple 계정 선택
- Bundle Identifier는 `com.whitewise95.placenote` 유지

기기 인식 확인:

```bash
flutter devices
```

실행:

```bash
scripts/run_ios.sh
```

특정 iPhone ID로 실행하려면:

```bash
flutter run -d <iphone-device-id>
```

참고: `flutter build ios --no-codesign`은 성공했습니다. 실제 기기 실행만 Apple Signing Team과 연결된 iPhone이 필요합니다.

## 6. iOS 시뮬레이터 주의

현재 OCR 패키지의 Google ML Kit iOS Pod 일부가 Apple Silicon iOS 26+ 시뮬레이터에서 필요한 arm64 simulator architecture를 지원하지 않습니다.

따라서 iOS 시뮬레이터에서는 아래 의존성 문제로 실행이 막힐 수 있습니다.

- `GoogleMLKit`
- `MLImage`
- `MLKitCommon`
- `MLKitVision`

실제 OCR MVP 검증은 실제 iPhone 또는 Android 기기/에뮬레이터에서 진행하는 쪽이 안정적입니다.

## 7. MVP 데모 순서

1. 홈 화면에서 `새 분석 시작`
2. `사진첩에서 선택` 또는 `카메라로 촬영`
3. 주소가 선명한 캡쳐 이미지 선택
4. OCR 원문과 주소 후보 확인
5. `이 주소로 분석하기`
6. 분석 결과 카드 확인
7. `저장된 이력 보기`
8. 이력 검색, 상세 재진입, 삭제 확인

샘플 흐름을 보고 싶으면 `샘플 데이터로 시작`을 누르면 됩니다.

## 8. 실제 OCR 테스트 방법

1. 실제 iPhone 또는 Android 기기/에뮬레이터를 준비합니다.

```bash
flutter devices
```

2. 앱에서 `새 분석 시작`을 누릅니다.
3. `사진첩에서 선택` 또는 `카메라로 촬영`을 누릅니다.
4. 주소가 선명하게 보이는 부동산 캡쳐 이미지를 선택합니다.
5. `주소 후보 찾기`를 누릅니다.
6. OCR 원문과 주소 후보가 표시되는지 확인합니다.

## 9. 테스트

```bash
flutter test
```

현재 테스트는 Mock OCR 텍스트에서 한국 도로명주소 후보를 추출하는 핵심 로직을 확인합니다.

## 10. 서버 붙이는 위치

아래 파일에서 `TODO(server):`를 검색하면 Spring Boot API로 교체할 지점을 볼 수 있습니다.

```bash
rg "TODO\\(server\\)"
```

주요 교체 파일:

- `lib/app.dart`
- `lib/data/repositories/local_address_analysis_repository.dart`
- `lib/data/mock/mock_ocr_service.dart`

권장 방식:

1. `RemoteAddressAnalysisRepository` 추가
2. Spring Boot API DTO와 Flutter 모델 매핑
3. `lib/app.dart`에서 Repository 주입만 교체
4. UI 코드는 최대한 유지
