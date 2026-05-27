type KakaoPosition = object;

type KakaoMapsApi = {
  load: (callback: () => void) => void;
  LatLng: new (latitude: number, longitude: number) => KakaoPosition;
  Map: new (
    container: HTMLElement,
    options: { center: KakaoPosition; level: number },
  ) => object;
  Marker: new (options: { position: KakaoPosition }) => {
    setMap: (map: object) => void;
  };
};

declare global {
  interface Window {
    kakao?: {
      maps: KakaoMapsApi;
    };
  }
}

let loading: Promise<KakaoMapsApi> | null = null;

export function loadKakaoMap(apiKey: string): Promise<KakaoMapsApi> {
  if (window.kakao?.maps) {
    return ready(window.kakao.maps);
  }

  if (loading) {
    return loading;
  }

  loading = new Promise((resolve, reject) => {
    const script = document.createElement('script');
    script.src =
      `https://dapi.kakao.com/v2/maps/sdk.js?appkey=${encodeURIComponent(apiKey)}` +
      '&autoload=false&libraries=services';
    script.onload = () => {
      if (!window.kakao?.maps) {
        reject(new Error('kakao_map_unavailable'));
        return;
      }
      ready(window.kakao.maps).then(resolve, reject);
    };
    script.onerror = () => reject(new Error('kakao_map_load_failed'));
    document.head.appendChild(script);
  });

  return loading;
}

function ready(maps: KakaoMapsApi): Promise<KakaoMapsApi> {
  return new Promise((resolve) => {
    maps.load(() => resolve(maps));
  });
}
