import { FolderOpen } from 'lucide-react';
import { useEffect, useMemo, useState } from 'react';

import { DotMark } from './components/DotMark';
import { FolderEntries } from './features/folders/FolderEntries';
import { ReportDetail } from './features/reports/ReportDetail';
import type { Folder, NativeBridge, Report } from './types/native';
import './theme/tokens.css';
import './theme/global.css';

type AppProps = {
  bridge: NativeBridge;
};

export function App({ bridge }: AppProps) {
  const [folders, setFolders] = useState<Folder[]>([]);
  const [reports, setReports] = useState<Report[]>([]);
  const [selectedFolder, setSelectedFolder] = useState<Folder | null>(null);
  const [selectedReport, setSelectedReport] = useState<Report | null>(null);

  useEffect(() => {
    Promise.all([bridge.listFolders(), bridge.listReports()]).then(
      ([loadedFolders, loadedReports]) => {
        setFolders(loadedFolders);
        setReports(loadedReports);
      },
    );
  }, [bridge]);

  const latestByFolder = useMemo(() => {
    return new Map(
      folders.map((folder) => [
        folder.id,
        reports.find((report) => report.folderId === folder.id),
      ]),
    );
  }, [folders, reports]);

  if (selectedReport) {
    return <ReportDetail onBack={() => setSelectedReport(null)} report={selectedReport} />;
  }

  if (selectedFolder) {
    return (
      <FolderEntries
        folder={selectedFolder}
        onBack={() => setSelectedFolder(null)}
        onOpenReport={setSelectedReport}
        reports={reports.filter((report) => report.folderId === selectedFolder.id)}
      />
    );
  }

  return (
    <main className="app-shell">
      <header className="app-header">
        <DotMark />
        <h1>Place Note</h1>
      </header>

      <section aria-label="폴더 목록">
        <div className="section-heading">
          <h2>폴더</h2>
          <span className="count-pill">{folders.length}개</span>
        </div>
        {folders.length === 0 ? (
          <p className="empty-message">저장된 폴더가 없습니다.</p>
        ) : (
          folders.map((folder) => {
            const items = reports.filter((report) => report.folderId === folder.id);
            const latest = latestByFolder.get(folder.id);
            return (
              <button
                className="folder-card"
                key={folder.id}
                onClick={() => setSelectedFolder(folder)}
                type="button"
              >
                <span className="folder-icon">
                  <FolderOpen size={24} />
                </span>
                <span className="folder-copy">
                  <strong>{folder.name}</strong>
                  <p>{latest?.normalizedAddress ?? '저장된 텍스트가 없습니다.'}</p>
                </span>
                <span className="folder-count">{items.length}</span>
              </button>
            );
          })
        )}
      </section>

      <button
        aria-label="사진 속 글자 읽기 준비 중"
        className="capture-fab"
        disabled
        title="사진 속 글자 읽기 준비 중"
        type="button"
      >
        <DotMark size="large" />
      </button>
    </main>
  );
}
