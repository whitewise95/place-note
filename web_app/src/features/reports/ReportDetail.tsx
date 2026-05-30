import { ArrowLeft, CalendarDays, MapPin } from 'lucide-react';

import { KakaoMap } from '../maps/KakaoMap';
import type { Report } from '../../types/native';

declare global {
  interface Window {
    PlaceNoteConfig?: {
      kakaoJavascriptKey?: string;
    };
  }
}

type ReportDetailProps = {
  report: Report;
  onBack: () => void;
};

export function ReportDetail({ report, onBack }: ReportDetailProps) {
  const kakaoJavascriptKey =
    window.PlaceNoteConfig?.kakaoJavascriptKey ?? import.meta.env.VITE_KAKAO_JAVASCRIPT_KEY ?? '';

  return (
    <main className="app-shell detail-shell">
      <header className="detail-header">
        <button aria-label="폴더로 돌아가기" className="icon-button" onClick={onBack} type="button">
          <ArrowLeft size={25} />
        </button>
        <h1>저장된 텍스트</h1>
      </header>

      <section className="detail-card">
        <div className="detail-badge">
          <MapPin size={16} />
          선택 텍스트
        </div>
        <h2>{report.normalizedAddress}</h2>
        <p className="detail-date">
          <CalendarDays size={16} />
          {formatDate(report.createdAt)}
        </p>
      </section>

      {report.imageDataUrl ? (
        <img alt="저장된 원본 이미지" className="saved-image" src={report.imageDataUrl} />
      ) : null}

      {report.latitude !== undefined && report.longitude !== undefined ? (
        <section aria-label="지도 위치" className="map-slot">
          <div className="section-heading">
            <h2>지도 위치</h2>
            <span className="count-pill">Kakao Map</span>
          </div>
          <KakaoMap
            apiKey={kakaoJavascriptKey}
            latitude={report.latitude}
            longitude={report.longitude}
          />
        </section>
      ) : null}
    </main>
  );
}

function formatDate(value: string): string {
  const date = new Date(value);
  return new Intl.DateTimeFormat('ko-KR', {
    dateStyle: 'medium',
    timeStyle: 'short',
  }).format(date);
}
