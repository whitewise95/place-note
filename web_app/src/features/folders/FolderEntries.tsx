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
