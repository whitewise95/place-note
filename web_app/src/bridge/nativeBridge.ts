import type { Folder, NativeBridge, Report } from '../types/native';

declare global {
  interface Window {
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
  private request<T>(method: string): Promise<T> {
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
      nativeChannel.postMessage(JSON.stringify({ id, method, params: {} }));
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
}
