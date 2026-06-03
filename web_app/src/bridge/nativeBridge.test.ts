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

  it('posts capture.ocr when the React OCR flow starts', async () => {
    const postMessage = vi.fn();
    Object.assign(window, { PlaceNoteNative: { postMessage } });
    const bridge = new WebViewNativeBridge();

    const result = bridge.startOcrCapture();
    const payload = JSON.parse(postMessage.mock.calls[0][0] as string) as {
      id: string;
      method: string;
      params: { source: string };
    };
    window.dispatchEvent(
      new CustomEvent('place-note:native-response', {
        detail: {
          id: payload.id,
          ok: true,
          result: {
            imagePath: '/tmp/capture.jpg',
            imageDataUrl: 'data:image/jpeg;base64,aW1hZ2U=',
            ocrText: '연희숲속쉼터',
            ocrLines: ['연희숲속쉼터'],
            ocrWords: ['연희숲속쉼터'],
          },
        },
      }),
    );

    expect(payload.method).toBe('capture.ocr');
    expect(payload.params).toEqual({ source: 'gallery' });
    await expect(result).resolves.toEqual(
      expect.objectContaining({ ocrText: '연희숲속쉼터' }),
    );
  });

  it('posts reports.save with selected Kakao candidate payload', async () => {
    const postMessage = vi.fn();
    Object.assign(window, { PlaceNoteNative: { postMessage } });
    const bridge = new WebViewNativeBridge();

    const result = bridge.saveReport({
      folderId: 'folder-inbox',
      selectedText: '연희숲속쉼터',
      normalizedAddress: '서울 서대문구 연희동 산5-79',
      detailAddress: '연희숲속쉼터',
      latitude: 37.5742,
      longitude: 126.9301,
      imagePath: '/tmp/capture.jpg',
      ocrText: '연희숲속쉼터',
    });
    const payload = JSON.parse(postMessage.mock.calls[0][0] as string) as {
      id: string;
      method: string;
      params: { selectedText: string; normalizedAddress: string };
    };
    window.dispatchEvent(
      new CustomEvent('place-note:native-response', {
        detail: {
          id: payload.id,
          ok: true,
          result: {
            id: 'report-1',
            folderId: 'folder-inbox',
            normalizedAddress: '서울 서대문구 연희동 산5-79',
            createdAt: '2026-06-03T10:00:00.000Z',
          },
        },
      }),
    );

    expect(payload.method).toBe('reports.save');
    expect(payload.params.selectedText).toBe('연희숲속쉼터');
    expect(payload.params.normalizedAddress).toBe('서울 서대문구 연희동 산5-79');
    await expect(result).resolves.toEqual(
      expect.objectContaining({ id: 'report-1' }),
    );
  });
});
