# Address Research Mobile MVP

캡쳐 이미지에서 주소 후보를 추출하고, Mock 자료 카드를 만들어 로컬에 저장하는 Flutter MVP입니다.

## 포함된 기능

- 홈 화면의 새 분석 시작 및 최근 분석 이력
- 사진첩/카메라 진입 UI
- Mock OCR 텍스트 인식 흐름
- 주소 후보 자동 추출 및 직접 입력
- Mock 분석 결과 카드 생성
- `shared_preferences` 기반 로컬 저장, 조회, 삭제
- Spring Boot API 교체 지점 `TODO(server):` 주석

## 실행 가이드

현재 이 컴퓨터에는 `flutter`/`dart` 명령이 설치되어 있지 않아 Codex가 직접 실행 검증하지는 못했습니다.

더 자세한 단계별 가이드는 `MVP_RUN_GUIDE.md`를 확인하세요.

1. Flutter SDK 설치 후 PATH를 설정합니다.
   - https://docs.flutter.dev/get-started/install

2. 이 폴더에서 플랫폼 파일을 생성합니다.

```bash
cd "/Users/baeghyeonmyeong/Documents/New project 2"
flutter create . --project-name address_research_mobile --platforms ios,android
```

3. 의존성을 설치합니다.

```bash
flutter pub get
```

4. 시뮬레이터나 실제 기기에서 실행합니다.

```bash
flutter run
```

5. 테스트를 실행합니다.

```bash
flutter test
```

## MVP 데모 흐름

1. 홈에서 `새 분석 시작`
2. `샘플 데이터로 시작` 또는 사진첩/카메라 선택
3. Mock OCR 진행 화면
4. 주소 후보 선택 또는 직접 입력
5. 분석 결과 저장
6. 이력 화면에서 검색/삭제/상세 재진입

## 서버 연동 가이드

서버는 아직 만들지 않습니다. 이후 Spring Boot + Java API를 붙일 때는 `lib/data/repositories/local_address_analysis_repository.dart`를 기준으로 `RemoteAddressAnalysisRepository`를 추가하고, `lib/app.dart`에서 주입 Repository만 교체하면 됩니다.

예정 API:

- `POST /v1/address-analyses`
- `GET /v1/address-analyses/{id}`
- `GET /v1/address-analyses`
- `POST /v1/address/resolve`
- `GET /v1/address/reports`
