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
- Android AVD: `PlaceNote_API35`

## Android 에뮬레이터 실행

```bash
source scripts/flutter_env.sh
emulator -avd PlaceNote_API35
```

다른 터미널에서:

```bash
source scripts/flutter_env.sh
scripts/run_android.sh
```

## 앱 사용 흐름

1. 홈에서 `새 폴더`를 눌러 폴더를 만듭니다.
2. `캡쳐 텍스트 저장`을 눌러 사진첩 또는 카메라 이미지를 선택합니다.
3. OCR이 끝나면 저장할 폴더를 선택합니다.
4. `원문 보기`에서 사진과 OCR 글을 확인합니다.
5. `OCR 글자 선택`에서 줄 또는 단어를 골라 저장 문장을 만듭니다.
6. 필요하면 직접 입력칸에서 문장을 수정합니다.
7. `폴더에 저장하기`를 누릅니다.
8. 홈의 폴더를 눌러 저장 항목을 다시 확인합니다.

## iPhone 참고

실제 iPhone 테스트는 데이터 전송 가능한 케이블과 Xcode Signing 설정이 필요합니다. iOS 시뮬레이터는 Google ML Kit 일부 Pod의 Apple Silicon simulator arm64 지원 문제로 막힐 수 있습니다.

## 테스트

```bash
flutter test
```
