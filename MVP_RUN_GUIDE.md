# MVP 실행 가이드

Place Note는 캡쳐 이미지나 저장한 화면에서 텍스트를 읽고, 필요한 문장을 폴더별로 모아두는 Flutter Local MVP입니다.

## 준비

```bash
cd "/Users/baeghyeonmyeong/Documents/New project 2"
source scripts/flutter_env.sh
flutter doctor -v
```

주요 로컬 환경:

- Flutter SDK: `/Users/baeghyeonmyeong/.codex-flutter/flutter`
- Android SDK: `/Users/baeghyeonmyeong/Library/Android/sdk`
- Android AVD: `PlaceNote_Lite_API35`

## 카카오 REST API 키 설정

카카오 주소 검색 기능은 로컬 YAML 파일의 REST API 키를 `--dart-define`으로 전달합니다.
실제 키 파일은 git에 올라가지 않고, 저장소에는 placeholder 예시만 남습니다.
Kakao Developers 앱 설정에서 **Kakao Map / Local API 사용 설정**도 켜야 합니다.

```bash
cp config/app_config.example.yml config/app_config.local.yml
```

`config/app_config.local.yml` 파일에서 아래 값을 실제 REST API 키로 바꿉니다.

```yml
kakao_rest_api_key: "{kakao_rest_api_key}"
```

환경변수로 직접 넘기고 싶으면 YAML보다 `KAKAO_REST_API_KEY`가 우선 적용됩니다.

```bash
KAKAO_REST_API_KEY=실제_REST_API_키 scripts/run_android.sh
```

## Android 에뮬레이터 실행

```bash
source scripts/flutter_env.sh
emulator -avd PlaceNote_Lite_API35
```

다른 터미널에서:

```bash
source scripts/flutter_env.sh
scripts/run_android.sh
```

## 앱 사용 흐름

1. 홈에서 `새 폴더`를 눌러 폴더를 만듭니다.
2. 오른쪽 아래 플로팅 버튼을 눌러 사진첩 또는 카메라 이미지를 선택합니다.
3. OCR이 끝나면 저장할 폴더를 선택합니다.
4. `원문 보기`에서 사진과 OCR 글을 확인합니다.
5. `OCR 글자 선택`에서 줄 또는 단어를 골라 저장 문장을 만듭니다.
6. 필요하면 직접 입력칸에서 문장을 수정합니다.
7. `폴더에 저장하기`를 누릅니다. 카카오 REST API 키가 설정되어 있으면 선택한 텍스트를 주소 검색으로 확인한 뒤 저장합니다.
8. 홈의 폴더를 눌러 저장 항목을 다시 확인합니다.

## iPhone 참고

실제 iPhone 테스트는 데이터 전송 가능한 케이블과 Xcode Signing 설정이 필요합니다. iOS 시뮬레이터는 Google ML Kit 일부 Pod의 Apple Silicon simulator arm64 지원 문제로 막힐 수 있습니다.

## 테스트

```bash
flutter test
```
