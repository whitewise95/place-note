import type {
  Folder,
  NativeBridge,
  OcrCaptureResult,
  Report,
  SaveReportParams,
} from '../types/native';

declare global {
  interface Window {
    /**
     * Flutter WebView가 만들어주는 JavaScript channel입니다.
     * React에서 postMessage로 요청을 보내면 Flutter가 로컬 저장소나 캡처 플로우를 실행한 뒤
     * place-note:native-response 이벤트로 응답합니다.
     */
    PlaceNoteNative?: {
      postMessage: (payload: string) => void;
    };
  }
}

type ResponseEnvelope<T> = {
  id: string;
  ok: boolean;
  result?: T;
  error?: string;
};

export class WebViewNativeBridge implements NativeBridge {
  /**
   * Flutter와 통신하는 공통 요청 함수입니다.
   *
   * 요청:
   *   window.PlaceNoteNative.postMessage({ id, method, params })
   *
   * 응답:
   *   Flutter가 window.dispatchEvent(new CustomEvent('place-note:native-response', ...))
   *   형태로 같은 id를 돌려줍니다.
   *
   * id를 매칭하는 이유는 여러 요청이 동시에 날아가도 각 Promise가 자기 응답만 처리하게 하기 위해서입니다.
   */
  private request<T>(method: string, params: Record<string, unknown> = {}): Promise<T> {
    const nativeChannel = window.PlaceNoteNative;
    if (!nativeChannel) {
      return Promise.reject(new Error('native_channel_unavailable'));
    }

    const id = crypto.randomUUID();
    return new Promise((resolve, reject) => {
      const receive = (event: Event) => {
        const response = (event as CustomEvent<ResponseEnvelope<T>>).detail;
        if (response.id !== id) {
          return;
        }

        window.removeEventListener('place-note:native-response', receive);
        if (response.ok) {
          resolve(response.result as T);
        } else {
          reject(new Error(response.error ?? 'native_request_failed'));
        }
      };

      window.addEventListener('place-note:native-response', receive);
      nativeChannel.postMessage(JSON.stringify({ id, method, params }));
    });
  }

  listFolders(): Promise<Folder[]> {
    return this.request<Folder[]>('folders.list');
  }

  listReports(): Promise<Report[]> {
    return this.request<Report[]>('reports.list');
  }

  startCapture(): Promise<void> {
    return this.request<void>('capture.start');
  }

  startOcrCapture(): Promise<OcrCaptureResult> {
    return this.request<OcrCaptureResult>('capture.ocr', { source: 'gallery' });
  }

  saveReport(params: SaveReportParams): Promise<Report> {
    return this.request<Report>('reports.save', params);
  }
}
