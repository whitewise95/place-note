import { MapPinned } from 'lucide-react';
import { useEffect, useRef, useState } from 'react';

import { loadKakaoMap } from './kakaoLoader';

type KakaoMapProps = {
  apiKey: string;
  latitude: number;
  longitude: number;
};

type MapStatus = 'loading' | 'ready' | 'error';

export function KakaoMap({ apiKey, latitude, longitude }: KakaoMapProps) {
  const containerRef = useRef<HTMLDivElement>(null);
  const [status, setStatus] = useState<MapStatus>('loading');

  useEffect(() => {
    /**
     * apiKey가 없으면 SDK를 아예 요청하지 않습니다.
     * Kakao Developers 도메인 등록 문제나 키 오타는 loadKakaoMap에서 실패하고 error 상태로 표시됩니다.
     */
    if (!apiKey.trim() || !containerRef.current) {
      return;
    }

    /**
     * active 플래그는 화면을 떠난 뒤 비동기 SDK 로딩이 끝나더라도 setState를 하지 않게 막습니다.
     * 모바일 WebView에서는 화면 이동이 잦아서 이런 방어가 없으면 경고가 나기 쉽습니다.
     */
    let active = true;
    loadKakaoMap(apiKey)
      .then((maps) => {
        if (!active || !containerRef.current) {
          return;
        }
        const position = new maps.LatLng(latitude, longitude);
        const map = new maps.Map(containerRef.current, {
          center: position,
          level: 3,
        });
        /**
         * 현재는 MVP라 단일 저장 항목의 위치만 표시합니다.
         * 여러 장소 후보를 지도에 올리는 기능이 생기면 Marker 배열과 bounds 조정이 여기서 확장됩니다.
         */
        new maps.Marker({ position }).setMap(map);
        setStatus('ready');
      })
      .catch(() => {
        if (active) {
          setStatus('error');
        }
      });

    return () => {
      active = false;
    };
  }, [apiKey, latitude, longitude]);

  if (!apiKey.trim()) {
    return <MapNotice text="카카오 지도 키를 설정해주세요" />;
  }

  return (
    <div className="kakao-map-frame">
      <div className="kakao-map" ref={containerRef} />
      {status === 'loading' ? <MapNotice text="지도를 불러오는 중입니다" /> : null}
      {status === 'error' ? <MapNotice text="지도를 불러오지 못했습니다" /> : null}
    </div>
  );
}

function MapNotice({ text }: { text: string }) {
  return (
    <div className="map-notice">
      <MapPinned size={22} />
      <span>{text}</span>
    </div>
  );
}
