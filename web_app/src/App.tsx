import { FolderOpen } from 'lucide-react';
import { useCallback, useEffect, useMemo, useState } from 'react';

import { DotMark } from './components/DotMark';
import { CaptureSaveFlow } from './features/capture/CaptureSaveFlow';
import { FolderEntries } from './features/folders/FolderEntries';
import { searchKakaoAddress, type AddressSearch } from './features/maps/kakaoSearch';
import { ReportDetail } from './features/reports/ReportDetail';
import type { Folder, NativeBridge, OcrCaptureResult, Report, SaveReportParams } from './types/native';
import './theme/tokens.css';
import './theme/global.css';

type AppProps = {
  bridge: NativeBridge;
  searchAddress?: AddressSearch;
};

export function App({ bridge, searchAddress = searchKakaoAddress }: AppProps) {
  /**
   * 현재 React 앱은 별도 라우터를 쓰지 않고, 간단한 화면 상태만으로 이동합니다.
   *
   * - selectedFolder === null && selectedReport === null: 홈/폴더 목록
   * - selectedFolder !== null: 선택한 폴더의 저장 텍스트 목록
   * - selectedReport !== null: 저장 텍스트 상세/지도 화면
   *
   * 모바일 WebView 안에서 화면 구조를 작게 유지하려고 react-router 대신 이 방식을 씁니다.
   */
  const [folders, setFolders] = useState<Folder[]>([]);
  const [reports, setReports] = useState<Report[]>([]);
  const [selectedFolder, setSelectedFolder] = useState<Folder | null>(null);
  const [selectedReport, setSelectedReport] = useState<Report | null>(null);
  const [captureResult, setCaptureResult] = useState<OcrCaptureResult | null>(null);
  const [captureError, setCaptureError] = useState<string | null>(null);

  /**
   * 로컬 저장소의 최신 상태를 Flutter 브릿지에서 다시 가져옵니다.
   * 폴더와 저장 텍스트는 서로 연결되어 있으므로 항상 같이 읽어 화면 상태를 맞춥니다.
   */
  const loadArchive = useCallback(() => {
    return Promise.all([bridge.listFolders(), bridge.listReports()]).then(
      ([loadedFolders, loadedReports]) => {
        setFolders(loadedFolders);
        setReports(loadedReports);
      },
    );
  }, [bridge]);

  useEffect(() => {
    void loadArchive();
  }, [loadArchive]);

  /**
   * Flutter에서 캡처/OCR/저장이 끝나면 WebView에 이 커스텀 이벤트를 쏩니다.
   * React는 이벤트를 받는 즉시 로컬 저장소를 다시 읽어 방금 저장한 항목을 화면에 반영합니다.
   */
  useEffect(() => {
    window.addEventListener('place-note:archive-changed', loadArchive);
    return () => window.removeEventListener('place-note:archive-changed', loadArchive);
  }, [loadArchive]);

  /**
   * 홈의 폴더 카드에는 각 폴더의 최신 저장 텍스트 한 줄만 보여줍니다.
   * reports는 저장소에서 최신순으로 내려온다는 전제라, 같은 folderId의 첫 항목을 사용합니다.
   */
  const latestByFolder = useMemo(() => {
    return new Map(
      folders.map((folder) => [
        folder.id,
        reports.find((report) => report.folderId === folder.id),
      ]),
    );
  }, [folders, reports]);

  const startCaptureFlow = useCallback(async () => {
    setCaptureError(null);
    try {
      const result = await bridge.startOcrCapture();
      setCaptureResult(result);
    } catch (error) {
      const message = error instanceof Error ? error.message : '';
      if (message !== 'capture_cancelled') {
        setCaptureError('사진 속 글자를 읽지 못했습니다. 다시 시도해주세요.');
      }
    }
  }, [bridge]);

  const saveCapturedReport = useCallback(
    async (params: SaveReportParams) => {
      await bridge.saveReport(params);
      await loadArchive();
      setCaptureResult(null);
    },
    [bridge, loadArchive],
  );

  if (selectedReport) {
    return <ReportDetail onBack={() => setSelectedReport(null)} report={selectedReport} />;
  }

  if (captureResult) {
    return (
      <CaptureSaveFlow
        capture={captureResult}
        folders={folders}
        onCancel={() => setCaptureResult(null)}
        onSave={saveCapturedReport}
        searchAddress={searchAddress}
      />
    );
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

      {captureError ? <p className="flow-error floating-error">{captureError}</p> : null}

      <button
        aria-label="사진 속 글자 읽기"
        className="capture-fab"
        onClick={() => void startCaptureFlow()}
        title="사진 속 글자 읽기"
        type="button"
      >
        <DotMark size="large" />
      </button>
    </main>
  );
}
