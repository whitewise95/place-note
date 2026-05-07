# Place Note MVP

캡쳐 이미지에서 주소 후보를 추출하고, Mock 자료 카드를 만들어 로컬에 저장하는 Flutter MVP입니다.

## 포함된 기능

- 홈 화면의 새 분석 시작 및 최근 분석 이력
- 사진첩/카메라 진입 UI
- iOS/Android Google ML Kit 실제 OCR
- macOS/Web 및 샘플 흐름용 Mock OCR fallback
- 주소 후보 자동 추출 및 직접 입력
- Mock 분석 결과 카드 생성
- `shared_preferences` 기반 로컬 저장, 조회, 삭제
- Spring Boot API 교체 지점 `TODO(server):` 주석
- 실제 iPhone/Android 실행을 위한 앱 ID `com.whitewise95.placenote`

## 실행 가이드

더 자세한 단계별 가이드는 `MVP_RUN_GUIDE.md`를 확인하세요.

1. 프로젝트 폴더로 이동합니다.

```bash
cd "/Users/baeghyeonmyeong/Documents/New project 2"
```

2. 준비된 로컬 Flutter/Android 환경을 로드합니다.

```bash
source scripts/flutter_env.sh
```

3. Android 에뮬레이터 또는 실제 Android 기기에서 실행합니다.

```bash
scripts/run_android.sh
```

4. 실제 iPhone에서 실행합니다.

```bash
scripts/run_ios.sh
```

실제 iPhone은 Xcode에서 Signing Team을 지정하고, iPhone에서 `이 컴퓨터를 신뢰`를 허용해야 `flutter devices`에 표시됩니다.

5. 테스트를 실행합니다.

```bash
flutter test
```

## MVP 데모 흐름

1. 홈에서 `새 분석 시작`
2. iOS/Android에서 사진첩/카메라 선택
3. ML Kit OCR 진행 화면
4. 주소 후보 선택 또는 직접 입력
5. 분석 결과 저장
6. 이력 화면에서 검색/삭제/상세 재진입

macOS/Web에서는 ML Kit OCR이 지원되지 않아 샘플 OCR 텍스트로 fallback됩니다. 실제 OCR 테스트는 실제 iPhone 또는 Android 기기/에뮬레이터에서 진행하세요.

참고: 현재 Google ML Kit iOS Pod 일부가 Apple Silicon iOS 26+ 시뮬레이터 arm64를 지원하지 않아 iOS 시뮬레이터 실행은 막힐 수 있습니다. 실제 iPhone 빌드는 `flutter build ios --no-codesign`으로 확인했습니다.

## 서버 연동 가이드

서버는 아직 만들지 않습니다. 이후 Spring Boot + Java API를 붙일 때는 `lib/data/repositories/local_address_analysis_repository.dart`를 기준으로 `RemoteAddressAnalysisRepository`를 추가하고, `lib/app.dart`에서 주입 Repository만 교체하면 됩니다.

예정 API:

- `POST /v1/address-analyses`
- `GET /v1/address-analyses/{id}`
- `GET /v1/address-analyses`
- `POST /v1/address/resolve`
- `GET /v1/address/reports`
