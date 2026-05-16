# Place Note MVP

캡쳐 이미지와 복사한 화면 속 텍스트를 OCR로 읽고, 필요한 문장을 폴더별로 저장하는 Flutter 로컬 MVP입니다.

## 포함된 기능

- 폴더 생성, 이름 변경, 삭제
- 캡쳐/사진첩 이미지 선택
- iOS/Android Google ML Kit 실제 OCR
- macOS/Web 및 샘플 흐름용 Mock OCR fallback
- OCR 원문 사진/텍스트 탭 보기
- OCR 줄/단어 선택으로 저장할 문장 조합
- 직접 입력 저장
- 선택한 텍스트를 카카오 주소 검색으로 확인 후 저장
- `shared_preferences` 기반 로컬 폴더/텍스트 저장

## 실행

```bash
cd "/Users/baeghyeonmyeong/Documents/New project 2"
source scripts/flutter_env.sh
scripts/run_android.sh
```

카카오 주소 검색을 테스트하려면 로컬 설정 파일을 만들고 REST API 키를 넣습니다.
이 파일은 git에 올라가지 않습니다.

```bash
cp config/app_config.example.yml config/app_config.local.yml
scripts/run_android.sh
```

`config/app_config.local.yml` 안의 `{kakao_rest_api_key}` placeholder에는
Kakao Developers에서 발급받은 **REST API 키**를 넣어야 합니다.
JavaScript 키나 Native App 키가 아니라 REST API 키를 사용합니다.
또한 Kakao Developers 앱 설정에서 **Kakao Map / Local API 사용 설정**을 켜야
주소 검색 요청이 허용됩니다.

실제 iPhone은 Xcode Signing Team과 데이터 케이블 연결이 필요합니다.

```bash
source scripts/flutter_env.sh
scripts/run_ios.sh
```

## MVP 흐름

1. 홈에서 폴더 생성
2. 오른쪽 아래 플로팅 버튼으로 사진 속 글자 읽기 시작
3. 사진 선택 후 OCR 실행
4. 저장 폴더 선택 또는 새 폴더 생성
5. OCR 줄/단어 선택 또는 직접 입력
6. `폴더에 저장하기`를 누르면 카카오 주소 검색 결과가 있으면 정제 주소로 저장
7. 홈의 폴더에서 저장 항목 확인

## 테스트

```bash
flutter test
```
