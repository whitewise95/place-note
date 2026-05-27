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
    if (!apiKey.trim() || !containerRef.current) {
      return;
    }

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
