# Place Note MVP

캡쳐 이미지와 복사한 화면의 텍스트를 읽어 따뜻한 폴더에 보관하는 로컬 우선 앱입니다. 현재 하이브리드 전환 1단계에서는 Flutter가 기기 데이터와 네이티브 기능을 맡고, React 화면이 폴더/저장 상세/카카오 지도 보기를 담당합니다.

## 현재 기능

- Flutter 로컬 저장소의 폴더와 저장 텍스트를 React WebView에서 읽기
- Dot Archive 디자인의 폴더 목록, 저장 항목 목록, 텍스트 상세 화면
- 저장 주소의 위도/경도가 있을 때 React에서 카카오 지도 마커 표시
- 기존 Flutter 흐름의 이미지 선택, ML Kit OCR, 텍스트 선택 및 로컬 저장
- 카카오 Local API 결과의 위치/지역 저장과 지역 필터 fallback

> React에서 사진 선택, OCR 실행, 새 저장을 호출하는 쓰기 브리지는 다음 단계입니다. 지금은 `place_note_web_app_url`을 설정하면 새 읽기/지도 UI가 열리고, 설정하지 않으면 기존 Flutter 캡쳐/저장 흐름을 실행할 수 있습니다.

## React 화면 실행

```bash
cd "/Users/baeghyeonmyeong/Documents/New project 2/web_app"
npm install
cp .env.example .env.local
npm run dev
```

`web_app/.env.local`에 Kakao Developers에서 발급받은 **JavaScript 키**를 입력합니다.

```dotenv
VITE_KAKAO_JAVASCRIPT_KEY="발급받은 JavaScript 키"
```

카카오 지도는 React가 배포된 웹 도메인에서 실행됩니다. Kakao Developers의 웹 플랫폼 도메인에 Vercel 도메인(예: `https://place-note.vercel.app`)을 등록해야 지도가 표시됩니다.

## Vercel 배포

루트 디렉터리를 그대로 Vercel 프로젝트로 가져오면 됩니다. 루트의 `vercel.json`이 `web_app`을 빌드하고 결과물을 배포하도록 설정되어 있습니다.

Vercel 프로젝트의 환경변수에는 아래 값을 등록합니다.

```dotenv
VITE_KAKAO_JAVASCRIPT_KEY="발급받은 JavaScript 키"
```

배포 후 발급된 `https://...vercel.app` URL을 Flutter 설정에 넣으면 앱이 이 React 화면을 WebView로 엽니다.

## Android 앱 실행

```bash
cd "/Users/baeghyeonmyeong/Documents/New project 2"
cp config/app_config.example.yml config/app_config.local.yml
scripts/run_android.sh
```

`config/app_config.local.yml`은 git에 올라가지 않습니다.

```yaml
kakao_rest_api_key: "발급받은 REST API 키"
kakao_javascript_key: "발급받은 JavaScript 키"
place_note_web_app_url: "https://배포된-react-앱.vercel.app"
```

- `kakao_rest_api_key`: 기존 Flutter 저장 흐름에서 주소를 확인하고 위치/지역을 저장할 때 사용하는 Local API 키입니다.
- `kakao_javascript_key`: React WebView에서 카카오 지도를 표시할 때 사용하는 JavaScript 키입니다. 앱 실행 시 WebView에 주입됩니다.
- `place_note_web_app_url`: 앱 안에서 띄울 배포된 React UI의 HTTPS 주소입니다.

환경변수로 전달할 수도 있습니다.

```bash
export KAKAO_REST_API_KEY="발급받은 REST API 키"
export KAKAO_JAVASCRIPT_KEY="발급받은 JavaScript 키"
export PLACE_NOTE_WEB_APP_URL="https://배포된-react-앱.vercel.app"
scripts/run_android.sh
```

React UI 없이 기존 캡쳐/저장 기능을 먼저 실행하려면 `place_note_web_app_url` 값을 비우거나 해당 항목을 제거합니다.

실제 iPhone은 Xcode Signing Team과 기기 설치 준비가 필요합니다.

```bash
source scripts/flutter_env.sh
scripts/run_ios.sh
```

## 테스트

```bash
cd web_app
npm test
npm run build

cd ..
flutter test
flutter analyze
```
