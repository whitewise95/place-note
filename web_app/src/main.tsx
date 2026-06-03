import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';

import { App } from './App';
import { MockNativeBridge } from './bridge/mockNativeBridge';
import { WebViewNativeBridge } from './bridge/nativeBridge';

/**
 * React 앱은 두 환경에서 실행됩니다.
 *
 * 1. Flutter WebView 안:
 *    Flutter가 window.PlaceNoteNative 채널을 주입합니다. 이때는 실제 기기 로컬 저장소,
 *    OCR 캡처 플로우, 저장된 이미지 데이터를 NativeBridge로 읽습니다.
 *
 * 2. 일반 브라우저 또는 Vercel 미리보기:
 *    window.PlaceNoteNative가 없으므로 MockNativeBridge를 사용합니다. 이 모드는 디자인,
 *    배포 화면, 카카오맵 UI를 빠르게 확인하기 위한 샘플 데이터 모드입니다.
 */
const bridge = window.PlaceNoteNative ? new WebViewNativeBridge() : new MockNativeBridge();

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App bridge={bridge} />
  </StrictMode>,
);
