# MVP 실행 가이드

이 앱은 실제 OCR/서버 없이 Mock 데이터로 동작하는 Flutter Local MVP입니다.

## 1. 준비

현재 Codex 작업 환경에는 Flutter SDK가 설치되어 있지 않았습니다.

먼저 Flutter를 설치합니다.

- Flutter 설치: https://docs.flutter.dev/get-started/install
- 설치 확인:

```bash
flutter --version
flutter doctor
```

`flutter doctor`에서 iOS 또는 Android 개발 환경 경고가 나오면 안내에 따라 Xcode, Android Studio, CocoaPods 등을 설치합니다.

## 2. 프로젝트 폴더로 이동

```bash
cd "/Users/baeghyeonmyeong/Documents/New project 2"
```

## 3. 플랫폼 파일 생성

Codex가 Flutter SDK 없이 앱 소스와 설정 파일을 먼저 만들었기 때문에, 최초 1회 플랫폼 파일을 생성해야 합니다.

```bash
flutter create . --project-name address_research_mobile --platforms ios,android
```

주의: `lib/`, `pubspec.yaml`, `README.md`는 이미 구현된 핵심 파일입니다. Flutter가 덮어쓰기 여부를 묻거나 변경을 만들면, 앱 구현 파일은 이 폴더의 현재 내용을 유지하세요.

## 4. 패키지 설치

```bash
flutter pub get
```

## 5. 실행

iOS 시뮬레이터:

```bash
open -a Simulator
flutter run
```

Android 에뮬레이터 또는 실제 기기:

```bash
flutter devices
flutter run
```

## 6. MVP 데모 순서

1. 홈 화면에서 `새 분석 시작`
2. `샘플 데이터로 시작`
3. Mock OCR 진행 화면 확인
4. 주소 후보 선택
5. `이 주소로 분석하기`
6. 분석 결과 카드 확인
7. `저장된 이력 보기`
8. 이력 검색, 상세 재진입, 삭제 확인

사진첩/카메라도 진입 UI가 구현되어 있습니다. 실제 OCR은 아직 Mock으로 처리하므로 어떤 이미지를 골라도 샘플 OCR 텍스트가 반환됩니다.

## 7. 테스트

```bash
flutter test
```

현재 테스트는 Mock OCR 텍스트에서 한국 도로명주소 후보를 추출하는 핵심 로직을 확인합니다.

## 8. 서버 붙이는 위치

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
