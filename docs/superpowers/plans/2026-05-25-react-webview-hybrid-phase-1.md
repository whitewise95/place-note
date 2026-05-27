# React WebView Hybrid Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Deliver the first runnable hybrid slice: a Vercel-ready React Dot Archive UI rendered in the Flutter WebView shell, reading existing local folders/reports/images through a typed native bridge and rendering saved Kakao coordinates on a React map.

**Architecture:** Flutter remains the owner of `ReportStorage`, managed image files, and existing local data; it adds a WebView shell and JSON read bridge while retaining the current Flutter UI as a configuration fallback during migration. A new `web_app` React/Vite application owns the folder-first home, list/detail reading views, and Kakao JavaScript map rendering. The currently uncommitted Flutter map work is reconciled by retaining coordinate/region persistence but removing native map UI and moving map configuration to React.

**Tech Stack:** Flutter/Dart, `webview_flutter`, React, TypeScript, Vite, Vitest, React Testing Library, Kakao Maps JavaScript SDK, Vercel

---

## Phase Boundary

This plan implements a complete read-and-map vertical slice. It does not yet
move native image selection, ML Kit OCR invocation, folder mutation, or report
save/delete actions into the React bridge; those are Phase 2 once the shell
and message contract run correctly on an emulator. Until then the React capture
button displays a migration notice and the existing Flutter flow remains
available when no web app URL is configured.

## File Responsibilities

| File or directory | Responsibility |
| --- | --- |
| `web_app/` | React app deployed by Vercel; owns UI, client bridge, and Kakao presentation. |
| `lib/bridge/native_bridge_dispatcher.dart` | Parses React requests and reads native records/images. |
| `lib/bridge/bridge_message.dart` | Stable JSON request/response DTOs shared by Flutter tests and React fixture shape. |
| `lib/shell/web_app_shell.dart` | Hosts the deployed React app in WebView and transports bridge responses. |
| `lib/main.dart` | Selects WebView shell when `PLACE_NOTE_WEB_APP_URL` is provided; otherwise retains existing UI. |
| Existing `lib/data/` files | Continue to own local records, image files, and Kakao metadata stored before/after migration. |

### Task 1: Reconcile Location Metadata With The New Architecture

**Files:**
- Modify: `lib/data/models/address_candidate.dart`
- Modify: `lib/data/models/research_report.dart`
- Modify: `lib/data/kakao/kakao_address_search_service.dart`
- Modify: `lib/data/mock/mock_report_factory.dart`
- Modify: `lib/features/history/history_screen.dart`
- Modify: `pubspec.yaml`
- Modify: `pubspec.lock`
- Modify: `android/app/src/main/AndroidManifest.xml`
- Remove from the in-flight implementation: `lib/features/report/kakao_map_preview.dart`
- Remove from the in-flight implementation: `lib/data/kakao/kakao_map_document.dart`
- Modify: `lib/features/report/report_screen.dart`
- Test: `test/kakao_address_search_service_test.dart`
- Test: `test/research_report_location_test.dart`
- Remove from the in-flight implementation: `test/kakao_map_document_test.dart`

- [x] **Step 1: Preserve the failing-to-passing metadata tests already written**

Keep these expectations in the tests because both React map display and regional
filters need locally persisted location metadata:

```dart
expect(resolved.latitude, 37.565);
expect(resolved.longitude, 127.009);
expect(resolved.province, '서울');
expect(restored.longitude, 127.009);
expect(restored.locality, '흥인동');
```

- [x] **Step 2: Remove native map rendering from the in-flight changes**

Delete the not-yet-committed Flutter map document/widget and remove this block
from `lib/features/report/report_screen.dart`, since React now owns maps:

```dart
if (report.latitude != null && report.longitude != null) ...[
  const SizedBox(height: 14),
  KakaoMapPreview(report: report),
],
```

Keep `webview_flutter` in `pubspec.yaml`; it is used by the shell in Task 5.
Keep the Android `INTERNET` permission; it is required to load Vercel.

- [x] **Step 3: Verify metadata behavior remains green**

Run:

```bash
flutter test test/kakao_address_search_service_test.dart test/research_report_location_test.dart
```

Expected: both metadata test files pass and no native map document test remains.

- [ ] **Step 4: Commit the location metadata reconciliation with the shell work, not separately**

Do not stage `ios/Runner.xcodeproj/project.pbxproj` or
`design_previews/kakao_application_screens/`; they are unrelated working-tree
content.

### Task 2: Scaffold The Vercel-Ready React Application

**Files:**
- Create: `web_app/package.json`
- Create: `web_app/index.html`
- Create: `web_app/tsconfig.json`
- Create: `web_app/vite.config.ts`
- Create: `web_app/src/main.tsx`
- Create: `web_app/src/App.tsx`
- Create: `web_app/src/theme/tokens.css`
- Create: `web_app/src/theme/global.css`
- Create: `web_app/src/components/DotMark.tsx`
- Create: `web_app/src/types/native.ts`
- Create: `web_app/src/test/setup.ts`
- Create: `web_app/src/App.test.tsx`
- Create: `vercel.json`

- [x] **Step 1: Add a failing React home-screen test**

Create `web_app/src/App.test.tsx`:

```tsx
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { App } from './App';
import { MockNativeBridge } from './bridge/mockNativeBridge';

describe('App', () => {
  it('renders local folders returned by the native bridge', async () => {
    render(<App bridge={new MockNativeBridge()} />);
    expect(await screen.findByText('기본 보관함')).toBeInTheDocument();
    expect(screen.getByText('서울 중구 퇴계로 409')).toBeInTheDocument();
  });
});
```

- [x] **Step 2: Add Vite scripts and run the test to see the missing app fail**

Create `web_app/package.json` with:

```json
{
  "name": "place-note-web",
  "private": true,
  "version": "0.1.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc -b && vite build",
    "test": "vitest run"
  },
  "dependencies": {
    "react": "^19.1.0",
    "react-dom": "^19.1.0"
  },
  "devDependencies": {
    "@testing-library/jest-dom": "^6.6.3",
    "@testing-library/react": "^16.3.0",
    "@types/react": "^19.1.0",
    "@types/react-dom": "^19.1.0",
    "@vitejs/plugin-react": "^4.4.1",
    "jsdom": "^26.1.0",
    "typescript": "~5.8.3",
    "vite": "^6.3.5",
    "vitest": "^3.1.3"
  }
}
```

Run:

```bash
cd web_app && npm install && npm test
```

Expected: FAIL because `App` and `MockNativeBridge` do not yet exist.

- [x] **Step 3: Implement the read-only Dot Archive home**

Define stable bridge display types in `web_app/src/types/native.ts`:

```ts
export type Folder = { id: string; name: string; createdAt: string };
export type Report = {
  id: string;
  folderId: string;
  normalizedAddress: string;
  createdAt: string;
  latitude?: number;
  longitude?: number;
  imageDataUrl?: string;
};

export interface NativeBridge {
  listFolders(): Promise<Folder[]>;
  listReports(): Promise<Report[]>;
}
```

Implement `App` to load `listFolders()` and `listReports()`, render a compact
header, a folder list, and a disabled-for-phase-1 floating dot capture button
with the accessible label `사진 속 글자 읽기 준비 중`. Use CSS tokens matching
the source-of-truth Flutter palette:

```css
:root {
  --paper: #f6f2ea;
  --surface: #fffcf5;
  --surface-alt: #f1e7d8;
  --ink: #211d19;
  --brown: #2f2923;
  --caramel: #e08a32;
  --sage: #6d8d70;
  --line: #dccbb7;
}
```

- [x] **Step 4: Configure Vite and Vercel**

Use a single-page rewrite in root `vercel.json`:

```json
{
  "buildCommand": "cd web_app && npm install && npm run build",
  "outputDirectory": "web_app/dist",
  "rewrites": [{ "source": "/(.*)", "destination": "/index.html" }]
}
```

- [x] **Step 5: Verify React foundation**

Run:

```bash
cd web_app && npm test && npm run build
```

Expected: test passes and Vite creates `web_app/dist`.

### Task 3: Add The Browser And Native Bridge Clients

**Files:**
- Create: `web_app/src/bridge/nativeBridge.ts`
- Create: `web_app/src/bridge/mockNativeBridge.ts`
- Create: `web_app/src/bridge/nativeBridge.test.ts`
- Modify: `web_app/src/App.tsx`
- Create: `web_app/src/features/reports/ReportDetail.tsx`

- [x] **Step 1: Write a failing bridge round-trip test**

Create `web_app/src/bridge/nativeBridge.test.ts`:

```ts
import { describe, expect, it, vi } from 'vitest';
import { WebViewNativeBridge } from './nativeBridge';

describe('WebViewNativeBridge', () => {
  it('resolves reports.list when Flutter emits the response event', async () => {
    const postMessage = vi.fn();
    Object.assign(window, { PlaceNoteNative: { postMessage } });
    const bridge = new WebViewNativeBridge();
    const result = bridge.listReports();
    const payload = JSON.parse(postMessage.mock.calls[0][0]);
    window.dispatchEvent(new CustomEvent('place-note:native-response', {
      detail: { id: payload.id, ok: true, result: [{ id: 'report-1' }] },
    }));
    await expect(result).resolves.toEqual([{ id: 'report-1' }]);
  });
});
```

- [x] **Step 2: Run the targeted test to confirm the bridge is missing**

Run:

```bash
cd web_app && npm test -- src/bridge/nativeBridge.test.ts
```

Expected: FAIL because `WebViewNativeBridge` has not been created.

- [x] **Step 3: Implement JSON transport and mock fallback**

Implement `WebViewNativeBridge.request` around the global JavaScript channel:

```ts
declare global {
  interface Window {
    PlaceNoteNative?: { postMessage: (payload: string) => void };
  }
}

type ResponseEnvelope<T> = { id: string; ok: boolean; result?: T; error?: string };

export class WebViewNativeBridge implements NativeBridge {
  private request<T>(method: string): Promise<T> {
    const id = crypto.randomUUID();
    return new Promise((resolve, reject) => {
      const receive = (event: Event) => {
        const response = (event as CustomEvent<ResponseEnvelope<T>>).detail;
        if (response.id !== id) return;
        window.removeEventListener('place-note:native-response', receive);
        response.ok ? resolve(response.result as T) : reject(new Error(response.error));
      };
      window.addEventListener('place-note:native-response', receive);
      window.PlaceNoteNative?.postMessage(JSON.stringify({ id, method, params: {} }));
    });
  }

  listFolders() { return this.request<Folder[]>('folders.list'); }
  listReports() { return this.request<Report[]>('reports.list'); }
}
```

Use `MockNativeBridge` when the app runs in an ordinary browser without
`window.PlaceNoteNative`, so React UI can be designed outside an emulator.

- [x] **Step 4: Add read-only detail navigation**

Clicking a report switches `App` into a detail view that shows saved text,
timestamp, image if `imageDataUrl` exists, and a map slot if coordinates exist.
Provide a back icon button rather than adding routing dependencies in Phase 1.

- [x] **Step 5: Verify the bridge client**

Run:

```bash
cd web_app && npm test
```

Expected: home and native bridge tests pass.

### Task 4: Render Kakao Maps In React

**Files:**
- Create: `web_app/.env.example`
- Create: `web_app/src/features/maps/kakaoLoader.ts`
- Create: `web_app/src/features/maps/KakaoMap.tsx`
- Create: `web_app/src/features/maps/KakaoMap.test.tsx`
- Modify: `web_app/src/features/reports/ReportDetail.tsx`
- Modify: `README.md`

- [x] **Step 1: Write a failing map fallback test**

Create `web_app/src/features/maps/KakaoMap.test.tsx`:

```tsx
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { KakaoMap } from './KakaoMap';

describe('KakaoMap', () => {
  it('shows configuration guidance when no JavaScript key is supplied', () => {
    render(<KakaoMap latitude={37.565} longitude={127.009} apiKey="" />);
    expect(screen.getByText('카카오 지도 키를 설정해주세요')).toBeInTheDocument();
  });
});
```

- [x] **Step 2: Run the test to confirm the component is absent**

Run:

```bash
cd web_app && npm test -- src/features/maps/KakaoMap.test.tsx
```

Expected: FAIL because `KakaoMap` does not exist.

- [x] **Step 3: Implement the Kakao loader and coordinate marker**

Use `VITE_KAKAO_JAVASCRIPT_KEY` in React and load:

```ts
const url =
  `https://dapi.kakao.com/v2/maps/sdk.js?appkey=${encodeURIComponent(apiKey)}` +
  '&autoload=false&libraries=services';
```

`KakaoMap` displays the fallback state without a key; otherwise it calls
`kakao.maps.load`, creates a map centered at `new kakao.maps.LatLng(latitude,
longitude)`, and places a marker. Keep the card height at `216px` and use the
Dot Archive map header/status styling.

Create `web_app/.env.example`:

```dotenv
VITE_KAKAO_JAVASCRIPT_KEY={kakao_javascript_key}
```

Register the deployed Vercel origin in Kakao Developers JavaScript SDK domains.
Do not place a REST API key in React environment files.

- [x] **Step 4: Document the new configuration source**

Update `README.md` to state:

```text
Flutter local config contains the optional REST migration key only.
Vercel/Vite VITE_KAKAO_JAVASCRIPT_KEY powers React Kakao address/map UI.
```

- [x] **Step 5: Verify React map behavior**

Run:

```bash
cd web_app && npm test && npm run build
```

Expected: map fallback test and existing React tests pass; production build
completes.

### Task 5: Build The Flutter JSON Read Bridge

**Files:**
- Create: `lib/bridge/bridge_message.dart`
- Create: `lib/bridge/native_bridge_dispatcher.dart`
- Create: `test/native_bridge_dispatcher_test.dart`
- Modify: `lib/core/storage/image_attachment_storage.dart`

- [x] **Step 1: Write failing dispatcher tests with injectable native reads**

Create `test/native_bridge_dispatcher_test.dart`:

```dart
test('dispatches folders.list as a successful response envelope', () async {
  final dispatcher = NativeBridgeDispatcher(
    loadFolders: () async => [TextFolder.inbox()],
    loadReports: () async => const [],
    loadImageDataUrl: (_) async => null,
  );

  final response = await dispatcher.handle(
    '{"id":"1","method":"folders.list","params":{}}',
  );

  expect(response['id'], '1');
  expect(response['ok'], true);
  expect((response['result'] as List).first['name'], '기본 보관함');
});
```

Add tests for `reports.list`, unknown method, and malformed JSON. A report with
an existing managed image should contain an `imageDataUrl` value returned by
the injected loader.

- [x] **Step 2: Run targeted Flutter tests to see missing dispatcher failure**

Run:

```bash
flutter test test/native_bridge_dispatcher_test.dart
```

Expected: FAIL because `NativeBridgeDispatcher` does not exist.

- [x] **Step 3: Implement request parsing and read endpoints**

Create envelopes with:

```dart
class BridgeResponse {
  const BridgeResponse.success(this.id, this.result)
      : ok = true,
        error = null;
  const BridgeResponse.error(this.id, this.error)
      : ok = false,
        result = null;

  final String id;
  final bool ok;
  final Object? result;
  final String? error;
  Map<String, dynamic> toJson() => {
    'id': id,
    'ok': ok,
    if (result != null) 'result': result,
    if (error != null) 'error': error,
  };
}
```

The dispatcher handles only `folders.list` and `reports.list` in Phase 1.
Map `ResearchReport` to a web DTO containing `id`, `folderId`,
`normalizedAddress`, `createdAt`, `latitude`, `longitude`, and optional
`imageDataUrl`. Any other method responds with
`unsupported_method` without mutating local state.

- [x] **Step 4: Provide WebView-safe image reads**

Add `Future<String?> readAsDataUrl(String? imagePath)` to
`ImageAttachmentStorage`. It applies the same managed-directory guard as
`delete`, reads an existing managed image, and returns:

```dart
'data:image/jpeg;base64,${base64Encode(bytes)}'
```

Return `null` for a missing image, a mock source, or a non-managed file.

- [x] **Step 5: Verify native bridge tests**

Run:

```bash
flutter test test/native_bridge_dispatcher_test.dart
```

Expected: bridge parsing, DTO, error, and image response tests pass.

### Task 6: Host React In The Flutter Shell

**Files:**
- Create: `lib/shell/web_app_shell.dart`
- Create: `test/web_app_shell_test.dart`
- Modify: `lib/main.dart`
- Modify: `config/app_config.example.yml`
- Modify: `scripts/flutter_env.sh`
- Modify: `README.md`

- [x] **Step 1: Write a failing shell-selection test**

Make shell selection an ordinary function so it can be tested without
instantiating platform WebView views:

```dart
testWidgets('uses legacy Flutter app when web app URL is not configured',
    (tester) async {
  await tester.pumpWidget(buildRootApp(webAppUrl: ''));
  expect(find.text('폴더'), findsOneWidget);
});
```

Add a lightweight test that a valid `https://app.example.com` URL selects a
`WebAppShell` widget without pumping its platform surface.

- [x] **Step 2: Run the shell test to confirm `buildRootApp` is missing**

Run:

```bash
flutter test test/web_app_shell_test.dart
```

Expected: FAIL because the shell selector has not yet been added.

- [x] **Step 3: Implement URL-gated WebView startup**

In `lib/main.dart`:

```dart
const configuredWebAppUrl = String.fromEnvironment('PLACE_NOTE_WEB_APP_URL');

Widget buildRootApp({String webAppUrl = configuredWebAppUrl}) {
  final uri = Uri.tryParse(webAppUrl);
  if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
    return const AddressResearchApp();
  }
  return WebAppShell(webAppUri: uri);
}
```

`WebAppShell` sets JavaScript unrestricted, adds the `PlaceNoteNative` channel,
loads the configured URI, parses messages through `NativeBridgeDispatcher`,
and emits results into React:

```dart
await controller.runJavaScript(
  'window.dispatchEvent(new CustomEvent("place-note:native-response", '
  '{ detail: ${jsonEncode(response)} }));',
);
```

Reject main-frame navigation to origins other than `webAppUri.origin`. Render
a warm paper loading surface and a retry panel on main-frame load error.

- [x] **Step 4: Pass web application URL as a local/native configuration**

Add this to `config/app_config.example.yml`:

```yaml
place_note_web_app_url: "{place_note_web_app_url}"
```

Update `scripts/flutter_env.sh` to convert it into:

```bash
--dart-define=PLACE_NOTE_WEB_APP_URL=<configured HTTPS URL>
```

During emulator development, allow the URL to be supplied directly:

```bash
PLACE_NOTE_WEB_APP_URL="https://your-vercel-preview.vercel.app" scripts/run_android.sh
```

- [x] **Step 5: Verify Flutter shell and full regression suite**

Run:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

Expected: no analysis issues, all Flutter tests pass, and an Android debug APK
builds with the WebView shell included.

### Task 7: Integrated Android Emulator Verification

**Files:**
- Modify: `README.md`

- [x] **Step 1: Run React locally or deploy a Vercel preview**

For local browser UI development:

```bash
cd web_app && npm run dev -- --host 0.0.0.0
```

For actual Kakao SDK testing, use a Vercel preview origin registered in Kakao
Developers and configure `VITE_KAKAO_JAVASCRIPT_KEY` in Vercel.

- [ ] **Step 2: Launch Flutter against the React URL**

Run:

```bash
PLACE_NOTE_WEB_APP_URL="https://your-preview.vercel.app" scripts/run_android.sh
```

Expected: the installed Flutter app opens the React folder screen rather than
the legacy Flutter home screen.

- [ ] **Step 3: Verify the Phase 1 acceptance path**

On the Android emulator:

```text
Open app -> React folder list loads from native storage
Open saved record -> local image is visible when present
Open saved record with coordinates -> Kakao map marker is visible
Return to home -> UI remains Dot Archive styled
```

- [x] **Step 4: Capture known Phase 2 handoff**

Update README with the intentionally inactive behavior:

```text
In Hybrid Phase 1, capture/OCR/save mutation still uses the legacy Flutter
fallback. Phase 2 connects these actions through PlaceNoteNative.
```

- [ ] **Step 5: Commit the verified vertical slice**

Stage only intended implementation and documentation paths:

```bash
git add README.md android/app/src/main/AndroidManifest.xml config/app_config.example.yml \
  docs/development/location_filtering.md lib pubspec.lock pubspec.yaml scripts test \
  vercel.json web_app
git commit -m "Add React WebView hybrid foundation"
```

Do not include `ios/Runner.xcodeproj/project.pbxproj` or the untracked
application-screen preview directory unless separately reviewed and requested.

## Next Plan: Native Mutation Bridge

After Phase 1 runs successfully on Android, write the next implementation plan
for `capture.pickImage`, `capture.recognizeText`, folder create/rename/delete,
`reports.save`, and `reports.delete`. That plan will migrate the remainder of
the interactive flow to React before removing duplicate Flutter screens.
