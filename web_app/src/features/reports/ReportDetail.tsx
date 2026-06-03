import { ArrowLeft, CalendarDays, MapPin } from 'lucide-react';

import { KakaoMap } from '../maps/KakaoMap';
import type { Report } from '../../types/native';

declare global {
  interface Window {
    /**
     * Flutter WebView가 페이지 로드 후 주입할 수 있는 런타임 설정입니다.
     * Vercel 빌드 환경변수만으로도 동작하지만, 네이티브 앱에서 키를 갈아끼워 테스트할 수 있게
     * window.PlaceNoteConfig를 우선으로 읽습니다.
     */
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
  /**
   * 카카오 JavaScript 키 우선순위:
   * 1. Flutter WebView가 주입한 런타임 키(window.PlaceNoteConfig)
   * 2. Vercel/Vite 빌드 시점 환경변수(VITE_KAKAO_JAVASCRIPT_KEY)
   *
   * 앱에서는 1번, 브라우저 배포 미리보기에서는 2번이 주로 사용됩니다.
   */
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
        /**
         * 지도는 좌표가 저장된 항목에서만 보여줍니다.
         * 좌표는 Flutter 저장 플로우에서 Kakao Local API로 주소/장소명을 해석할 때 report에 저장됩니다.
         */
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
