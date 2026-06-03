type KakaoPosition = object;

export type KakaoAddressDocument = {
  address_name: string;
  x: string;
  y: string;
  address?: {
    address_name?: string;
    region_1depth_name?: string;
    region_2depth_name?: string;
    region_3depth_name?: string;
  };
  road_address?: {
    address_name?: string;
    region_1depth_name?: string;
    region_2depth_name?: string;
    region_3depth_name?: string;
  };
};

export type KakaoPlaceDocument = {
  id: string;
  place_name: string;
  address_name: string;
  road_address_name?: string;
  x: string;
  y: string;
};

export type KakaoMapsApi = {
  load: (callback: () => void) => void;
  LatLng: new (latitude: number, longitude: number) => KakaoPosition;
  Map: new (
    container: HTMLElement,
    options: { center: KakaoPosition; level: number },
  ) => object;
  Marker: new (options: { position: KakaoPosition }) => {
    setMap: (map: object) => void;
  };
  services: {
    Status: {
      OK: string;
      ZERO_RESULT: string;
      ERROR: string;
    };
    Geocoder: new () => {
      addressSearch: (
        query: string,
        callback: (documents: KakaoAddressDocument[], status: string) => void,
      ) => void;
    };
    Places: new () => {
      keywordSearch: (
        query: string,
        callback: (documents: KakaoPlaceDocument[], status: string) => void,
      ) => void;
    };
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

/**
 * Kakao Maps JavaScript SDK를 한 번만 로드하는 싱글톤 로더입니다.
 *
 * React 상세 화면을 왔다 갔다 할 때마다 script 태그를 새로 만들면 같은 SDK가 중복 로드됩니다.
 * 그래서 module scope의 loading Promise를 재사용합니다.
 */
export function loadKakaoMap(apiKey: string): Promise<KakaoMapsApi> {
  /**
   * 이미 SDK가 로드된 경우에는 script를 다시 붙이지 않고 kakao.maps.load만 기다립니다.
   * Kakao SDK는 autoload=false 옵션일 때 maps.load(callback)을 호출해야 실제 초기화가 끝납니다.
   */
  if (window.kakao?.maps) {
    return ready(window.kakao.maps);
  }

  if (loading) {
    return loading;
  }

  loading = new Promise((resolve, reject) => {
    const script = document.createElement('script');
    /**
     * appkey에는 Kakao Developers의 JavaScript 키가 들어갑니다.
     *
     * 주의:
     * - REST API 키를 넣으면 지도 SDK가 동작하지 않습니다.
     * - Kakao Developers > 플랫폼 > Web 사이트 도메인에 Vercel 도메인을 등록해야 합니다.
     */
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
  /**
   * SDK script의 onload는 파일 다운로드 완료만 의미합니다.
   * 실제 지도 생성자는 maps.load 콜백 이후 안전하게 사용할 수 있습니다.
   */
  return new Promise((resolve) => {
    maps.load(() => resolve(maps));
  });
}
