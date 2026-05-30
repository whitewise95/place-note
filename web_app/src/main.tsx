import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';

import { App } from './App';
import { MockNativeBridge } from './bridge/mockNativeBridge';
import { WebViewNativeBridge } from './bridge/nativeBridge';

const bridge = window.PlaceNoteNative ? new WebViewNativeBridge() : new MockNativeBridge();

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App bridge={bridge} />
  </StrictMode>,
);
