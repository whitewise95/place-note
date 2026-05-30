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
});
