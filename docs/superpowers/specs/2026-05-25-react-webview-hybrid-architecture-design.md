# React WebView Hybrid Architecture Design

## Goal

Refactor Place Note into an online-first hybrid application: a React web app
deployed to Vercel provides the primary product UI, while a thin Flutter mobile
shell keeps device-sensitive capabilities stable and exposes them to React
through a WebView bridge.

The reason for this split is product iteration speed. Folder views, capture
flows, filters, Kakao map presentation, copy, and visual design should be
changeable through a web deployment. Camera/photo permissions, on-device OCR,
managed image files, and local saved records remain native because they depend
on mobile APIs and should remain reliable.

## Confirmed Product Constraints

- The app requires an internet connection for the primary experience.
- Existing Dot Archive styling remains the design direction.
- Stored images, OCR results, folder records, and saved text remain on the
  device rather than moving to a hosted database.
- React owns changeable product UI and Kakao map presentation.
- Flutter owns native permissions, device image operations, OCR, and local
  persistence.
- Initial migration should preserve current local records.

## Repository Shape

Keep one repository and add a separately deployable React application:

```text
place-note/
  android/
  ios/
  lib/                         # Flutter native shell and bridge
    bridge/
    data/
    shell/
  web_app/                     # React + TypeScript + Vite application
    src/
      bridge/
      features/
      theme/
  config/                      # native-only ignored local configuration
  vercel.json                  # deploy web_app to Vercel
```

Flutter continues to build the installed iOS/Android binary. Vercel builds and
serves `web_app`. Flutter loads a configurable deployed URL in its WebView.
Development can use a local React dev server address in the Android emulator or
an accessible network address on a physical device.

## Runtime Architecture

### Flutter Native Shell

Flutter becomes a compact host application with:

- A startup WebView that opens the configured React app URL.
- A loading/offline/error screen using the existing Dot Archive colors.
- A typed JavaScript message channel named `PlaceNoteNative`.
- Existing OCR, local storage, image persistence, and deletion services behind
  bridge handlers.
- An allowlist that permits navigation only to the configured web app origin
  and Kakao resources needed inside the React page.

Flutter will not continue rendering duplicated folder, history, extraction, or
report UI once equivalent React screens pass validation. During migration those
old screens stay available for comparison and safe rollback.

### React Web Application

React becomes the screen layer for:

- Folder home and folder management.
- Capture entry point and OCR-selection flow.
- Saved-text list, search, and regional filtering.
- Saved-text detail with stored image preview.
- Kakao address confirmation and Kakao Maps JavaScript display.
- Dot Archive components and tokens used throughout the product.

The React app renders from records returned by Flutter. It must not assume that
browser `localStorage` or IndexedDB is the durable source of app content.

### Bridge Contract

Messages use JSON request/response envelopes so native methods can evolve
without coupling React to Flutter widgets:

```json
{
  "id": "request-uuid",
  "method": "reports.list",
  "params": {}
}
```

```json
{
  "id": "request-uuid",
  "ok": true,
  "result": []
}
```

Initial bridge operations:

| Method | Owner | Purpose |
| --- | --- | --- |
| `app.ready` | React -> Flutter | Indicates React UI mounted successfully. |
| `folders.list` | Flutter | Return all folders and counts. |
| `folders.create` | Flutter | Create a named local folder. |
| `folders.rename` | Flutter | Rename a local folder. |
| `folders.delete` | Flutter | Delete a folder and move entries to inbox. |
| `capture.pickImage` | Flutter | Open camera/gallery picker and return an image token. |
| `capture.recognizeText` | Flutter | Run ML Kit OCR for a picked image token. |
| `reports.save` | Flutter | Persist selected text, OCR source, image, and Kakao metadata. |
| `reports.list` | Flutter | Return locally stored saved entries. |
| `reports.delete` | Flutter | Delete an entry and its unused managed image file. |
| `images.read` | Flutter | Return a displayable data URL or temporary WebView-safe URL for a stored image. |

Native responses use stable serializable DTOs rather than Flutter model object
serialization directly. Errors return a code and Korean-facing message so
React can show a consistent state.

## Data And Kakao Flow

The saved record remains local and includes:

- Folder identifier
- OCR original text
- User-selected saved text
- Managed local image reference
- Created timestamp
- Normalized address, road/lot detail where available
- Kakao latitude, longitude, province, district, and locality where available

Address confirmation and map drawing move to React:

1. Flutter returns recognized text and an image token.
2. React lets the user select or type saved text.
3. React uses the Kakao Maps JavaScript SDK `services` library to resolve an
   address or place search term into address metadata and coordinates.
4. React previews the normalized address and map marker.
5. React calls `reports.save` with the chosen text and Kakao metadata.
6. Flutter copies/compresses the source image if needed and persists the local
   record.

For MVP deployment, React loads the Kakao Maps JavaScript SDK with the
`services` library and uses `Geocoder.addressSearch` or
`Places.keywordSearch`. The JavaScript SDK key is client configuration
restricted by the registered Vercel domain and supplied through Vercel
environment variables. The existing native REST lookup remains available only
during migration and is removed from the primary flow once the React search
flow is validated. A future backend proxy is required only if later features
need server-side Kakao REST calls or protected usage control.

## UI And Navigation

The React app retains the approved Dot Archive language:

- Warm paper page surface, ivory cards, caramel borders and highlights.
- Folder-first home screen with compact saved item previews.
- Floating circular capture action using the dot mark icon.
- Source image and raw OCR available behind `원문 보기`.
- Scrollable text selection surfaces.
- Saved detail page containing an image preview and Kakao map panel only when
  location metadata is present.

The React route structure begins with:

```text
/                       Folder home
/capture                Image/OCR request and selection
/folders/:folderId      Saved entries and filters
/reports/:reportId      Saved entry, image, and map detail
```

## Failure Handling

- If the React URL cannot load, Flutter shows a native retry screen explaining
  that internet connection is required.
- If a native operation is cancelled, React receives a cancelled result rather
  than treating it as an application failure.
- If OCR fails, React keeps the selected image and permits retry or manual text
  entry.
- If Kakao lookup fails, saving text without location metadata remains
  available; map content is hidden for that record.
- If bridge request parsing fails, Flutter responds with a structured error and
  does not mutate local data.
- If a React deployment breaks the primary flow, a Flutter-configured web app
  URL can point to a previous Vercel deployment while a corrected build is
  prepared.

## Migration Strategy

### Phase 1: Hybrid Foundation

- Preserve current Flutter services and local data models.
- Replace the Flutter-injected Kakao map UI direction with React-owned mapping.
- Add `web_app`, shared design tokens, Vercel configuration, and a Flutter
  WebView host with bridge plumbing.
- Expose read-only folder/report data first to validate the shell and UI.

### Phase 2: Native Action Bridge

- Connect image selection and ML Kit OCR through the bridge.
- Connect folder changes, report save/delete, and stored-image viewing.
- Pass structured Kakao metadata from React into local report storage.
- Verify the React flow matches all current user-visible capabilities.

### Phase 3: Remove Duplicate Flutter UI

- Make React the only primary navigation surface.
- Remove old Flutter feature screens and any Flutter-only Kakao map rendering
  once data compatibility and device testing pass.
- Retain native error/loading views, storage, OCR, and bridge code.

## Testing And Acceptance

Automated checks:

- Flutter unit tests for bridge validation, storage compatibility, OCR action
  result envelopes, and image deletion behavior.
- React unit/component tests for folders, OCR selection, filters, report
  detail, Kakao fallback, and bridge client behavior.
- Contract fixture tests using the same request/response JSON examples in both
  projects.

Device checks:

- Android emulator: load deployed or dev React URL, select an image, receive
  OCR results, save an entry, view image/map, filter it, and delete it.
- iPhone physical device after signing is available: perform the same workflow
  and confirm photo permissions and WebView messaging.
- Verify a prior locally saved Flutter entry still appears through the React
  report list.

Acceptance criteria:

- A UI-only change to React is visible after a web deployment without releasing
  a new mobile binary.
- Native OCR and local managed images remain functional through the React flow.
- Kakao map display occurs within React under the registered Vercel origin.
- Local records survive app restarts and React deployments.
- With no network, the Flutter shell clearly reports that connectivity is
  required and offers retry.

## Scope Boundaries

Included in this refactor:

- React web app creation and Vercel-ready deployment setup.
- Flutter WebView shell and typed native bridge.
- Migration of current primary UI and Kakao presentation to React.
- Preservation of local storage and native OCR/image capabilities.

Excluded from this refactor:

- User accounts or cross-device sync.
- Hosted database or backend service.
- Background uploads or cloud image storage.
- Offline React asset caching.
