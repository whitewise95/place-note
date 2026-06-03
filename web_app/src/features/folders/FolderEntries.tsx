import { ArrowLeft, Clock3, Search } from 'lucide-react';
import { useMemo, useState } from 'react';

import type { Folder, Report } from '../../types/native';

type FolderEntriesProps = {
  folder: Folder;
  reports: Report[];
  onBack: () => void;
  onOpenReport: (report: Report) => void;
};

function formatDate(value: string) {
  return new Intl.DateTimeFormat('ko-KR', {
    dateStyle: 'medium',
    timeStyle: 'short',
  }).format(new Date(value));
}

export function FolderEntries({
  folder,
  reports,
  onBack,
  onOpenReport,
}: FolderEntriesProps) {
  const [query, setQuery] = useState('');
  const normalizedQuery = query.trim().toLowerCase();
  /**
   * MVP 검색은 서버 없이 현재 폴더에 이미 로드된 텍스트만 대상으로 합니다.
   * 나중에 OCR 원문, 태그, 지역 필터까지 붙이면 이 필터 조건을 확장하면 됩니다.
   */
  const filteredReports = useMemo(
    () =>
      reports.filter((report) =>
        report.normalizedAddress.toLowerCase().includes(normalizedQuery),
      ),
    [normalizedQuery, reports],
  );

  return (
    <main className="app-shell">
      <header className="detail-header">
        <button
          aria-label="폴더 목록으로 돌아가기"
          className="icon-button"
          onClick={onBack}
          type="button"
        >
          <ArrowLeft size={27} />
        </button>
        <h1>{folder.name}</h1>
      </header>

      <label className="search-field">
        <Search size={21} />
        <input
          onChange={(event) => setQuery(event.target.value)}
          placeholder="저장한 텍스트 검색"
          type="search"
          value={query}
        />
      </label>

      <section aria-label="저장된 텍스트" className="report-list">
        {filteredReports.length === 0 ? (
          <p className="empty-message">일치하는 저장 텍스트가 없습니다.</p>
        ) : (
          filteredReports.map((report) => (
            <button
              className="report-row"
              key={report.id}
              onClick={() => onOpenReport(report)}
              type="button"
            >
              {report.imageDataUrl ? (
                /**
                 * imageDataUrl은 Flutter가 로컬 이미지 파일을 base64 data URL로 변환해 전달합니다.
                 * React는 실제 파일 경로를 알 필요 없이 img src로 바로 렌더링할 수 있습니다.
                 */
                <img alt="" className="report-thumbnail" src={report.imageDataUrl} />
              ) : (
                <span aria-hidden className="report-placeholder" />
              )}
              <span className="report-copy">
                <strong>{report.normalizedAddress}</strong>
                <small>
                  <Clock3 size={14} />
                  {formatDate(report.createdAt)}
                </small>
              </span>
              <span className="local-pill">Local</span>
            </button>
          ))
        )}
      </section>
    </main>
  );
}
