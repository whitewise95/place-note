# React-Owned Capture Save Flow Design

## Goal

Move the user-facing capture/save flow into React while keeping native-only work in Flutter. A user should choose a screenshot, receive OCR text from Flutter, select or type the text they want to save, search Kakao address/place candidates in React, choose the correct candidate, choose a folder, and save the result locally through Flutter.

## Current State

React currently owns folder list, saved item list, saved item detail, and Kakao map display. The floating button calls Flutter's legacy capture route, and Flutter owns image selection, OCR, text selection, address resolution, folder selection, and save.

Flutter already has:

- ML Kit OCR through `LocalAddressAnalysisRepository.extractCandidates`.
- Local image persistence through `ImageAttachmentStorage`.
- Local report/folder persistence through `ReportStorage`.
- A WebView bridge with `folders.list`, `reports.list`, and `capture.start`.

React already has:

- Folder and report list UI.
- Kakao Maps JavaScript SDK loader.
- A bridge abstraction with native and mock implementations.

## Target User Flow

1. User taps the floating capture button in React.
2. React calls Flutter bridge method `capture.ocr`.
3. Flutter opens the native image picker and runs ML Kit OCR.
4. Flutter returns `imagePath`, `imageDataUrl`, `ocrText`, `ocrLines`, and `ocrWords`.
5. React opens a capture save screen.
6. User selects OCR lines/words or types text manually.
7. User chooses a folder from local folders.
8. User searches Kakao address/place candidates from the selected text.
9. User chooses one Kakao candidate.
10. React calls Flutter bridge method `reports.save`.
11. Flutter persists the image and report locally.
12. React reloads folders/reports and returns to the folder-first home.

## Bridge Contract

### `capture.ocr`

Request params:

```json
{
  "source": "gallery"
}
```

Response:

```json
{
  "imagePath": "/opaque/local/path.jpg",
  "imageDataUrl": "data:image/jpeg;base64,...",
  "ocrText": "full OCR text",
  "ocrLines": ["line 1", "line 2"],
  "ocrWords": ["line", "1"]
}
```

If the user cancels the picker, Flutter returns an error code `capture_cancelled`. React keeps the user on the home screen and can show no destructive state change.

### `reports.save`

Request params:

```json
{
  "folderId": "folder-inbox",
  "selectedText": "연희숲속쉼터",
  "normalizedAddress": "서울 서대문구 연희동 산5-79",
  "detailAddress": "연희숲속쉼터",
  "latitude": 37.5742,
  "longitude": 126.9301,
  "province": "서울",
  "district": "서대문구",
  "locality": "연희동",
  "imagePath": "/opaque/local/path.jpg",
  "ocrText": "full OCR text"
}
```

Response is the saved `Report` DTO used by React lists.

## React Components

- `CaptureSaveFlow`: owns the multi-step save screen.
- `kakaoSearch`: wraps Kakao Maps JavaScript SDK address and keyword search.
- Existing `App`: replaces `startCapture()` route launch with `startOcrCapture()` and opens `CaptureSaveFlow`.
- Existing `NativeBridge`: expands to `startOcrCapture()` and `saveReport(params)`.

## Error Handling

- OCR cancelled: stay on home.
- OCR failed: show a compact error message and allow retry through the floating button.
- Empty selected text: keep search/save disabled.
- Kakao no results: show "검색 결과가 없습니다" and allow direct text edit/search retry.
- Kakao SDK/domain/key failure: show "카카오 주소 검색을 불러오지 못했습니다".
- Save failure: keep the flow open and show a retryable save error.

## Design Notes

Use the Dot Archive visual system. The save flow should feel like a focused utility screen, not a marketing page. Long OCR text should live in scrollable token/line sections. The source image should be a compact preview with object-fit containment so it does not crop important screenshot content.

## Testing

- React tests cover opening capture flow, selecting OCR text, searching candidates, selecting a candidate, selecting folder, and saving.
- React bridge tests cover request params and save method.
- Flutter bridge tests cover `reports.save` params to persisted report DTO.
- Flutter shell tests cover `capture.ocr` cancellation/success as feasible with injected functions.
