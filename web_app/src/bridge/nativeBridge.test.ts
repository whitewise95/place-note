import { describe, expect, it, vi } from 'vitest';

import { WebViewNativeBridge } from './nativeBridge';

describe('WebViewNativeBridge', () => {
  it('resolves reports.list when Flutter emits the response event', async () => {
    const postMessage = vi.fn();
    Object.assign(window, { PlaceNoteNative: { postMessage } });
    const bridge = new WebViewNativeBridge();

    const result = bridge.listReports();
    const payload = JSON.parse(postMessage.mock.calls[0][0] as string) as {
      id: string;
    };
    window.dispatchEvent(
      new CustomEvent('place-note:native-response', {
        detail: { id: payload.id, ok: true, result: [{ id: 'report-1' }] },
      }),
    );

    await expect(result).resolves.toEqual([{ id: 'report-1' }]);
  });

  it('posts capture.start when the capture action is requested', async () => {
    const postMessage = vi.fn();
    Object.assign(window, { PlaceNoteNative: { postMessage } });
    const bridge = new WebViewNativeBridge();

    const result = bridge.startCapture();
    const payload = JSON.parse(postMessage.mock.calls[0][0] as string) as {
      id: string;
      method: string;
    };
    window.dispatchEvent(
      new CustomEvent('place-note:native-response', {
        detail: { id: payload.id, ok: true },
      }),
    );

    expect(payload.method).toBe('capture.start');
    await expect(result).resolves.toBeUndefined();
  });
});
