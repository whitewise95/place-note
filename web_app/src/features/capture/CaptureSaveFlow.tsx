import { ArrowLeft, FolderOpen, MapPin, Save, Search } from 'lucide-react';
import { useMemo, useState } from 'react';

import type {
  AddressSearchCandidate,
  Folder,
  OcrCaptureResult,
  SaveReportParams,
} from '../../types/native';
import { KakaoMap } from '../maps/KakaoMap';
import type { AddressSearch } from '../maps/kakaoSearch';

type CaptureSaveFlowProps = {
  capture: OcrCaptureResult;
  folders: Folder[];
  onCancel: () => void;
  onSave: (params: SaveReportParams) => Promise<void>;
  searchAddress: AddressSearch;
};

type FlowStatus = 'idle' | 'searching' | 'saving';

export function CaptureSaveFlow({
  capture,
  folders,
  onCancel,
  onSave,
  searchAddress,
}: CaptureSaveFlowProps) {
  const initialText = capture.ocrLines[0] ?? capture.ocrWords[0] ?? '';
  const [selectedText, setSelectedText] = useState(initialText);
  const [folderId, setFolderId] = useState(folders[0]?.id ?? 'folder-inbox');
  const [candidates, setCandidates] = useState<AddressSearchCandidate[]>([]);
  const [selectedCandidate, setSelectedCandidate] =
    useState<AddressSearchCandidate | null>(null);
  const [status, setStatus] = useState<FlowStatus>('idle');
  const [error, setError] = useState<string | null>(null);

  const selectableTexts = useMemo(() => {
    const merged = [...capture.ocrLines, ...capture.ocrWords]
      .map((item) => item.trim())
      .filter((item) => item.length > 0);
    return [...new Set(merged)];
  }, [capture.ocrLines, capture.ocrWords]);

  const canSearch = selectedText.trim().length > 0 && status === 'idle';
  const canSave = selectedCandidate !== null && status === 'idle';
  const kakaoJavascriptKey =
    window.PlaceNoteConfig?.kakaoJavascriptKey ?? import.meta.env.VITE_KAKAO_JAVASCRIPT_KEY ?? '';

  async function handleSearch() {
    if (!canSearch) {
      return;
    }

    setStatus('searching');
    setError(null);
    setCandidates([]);
    setSelectedCandidate(null);
    try {
      const results = await searchAddress(selectedText.trim());
      setCandidates(results);
      if (results.length === 0) {
        setError('주소 후보를 찾지 못했습니다. 문장을 조금 다르게 선택하거나 직접 수정해보세요.');
      }
    } catch {
      setError('주소 검색을 불러오지 못했습니다. 카카오 JavaScript 키와 도메인 설정을 확인해주세요.');
    } finally {
      setStatus('idle');
    }
  }

  async function handleSave() {
    if (!selectedCandidate || status !== 'idle') {
      return;
    }

    setStatus('saving');
    setError(null);
    try {
      await onSave({
        folderId,
        selectedText: selectedText.trim(),
        normalizedAddress: selectedCandidate.normalizedAddress,
        detailAddress: selectedCandidate.detailAddress ?? selectedCandidate.title,
        latitude: selectedCandidate.latitude,
        longitude: selectedCandidate.longitude,
        province: selectedCandidate.province,
        district: selectedCandidate.district,
        locality: selectedCandidate.locality,
        imagePath: capture.imagePath,
        ocrText: capture.ocrText,
      });
    } catch {
      setError('저장하지 못했습니다. 잠시 뒤 다시 시도해주세요.');
      setStatus('idle');
    }
  }

  return (
    <main className="app-shell capture-save-shell">
      <header className="detail-header">
        <button aria-label="홈으로 돌아가기" className="icon-button" onClick={onCancel} type="button">
          <ArrowLeft size={25} />
        </button>
        <h1>저장할 텍스트 선택</h1>
      </header>

      {capture.imageDataUrl ? (
        <img alt="OCR 원본 이미지" className="capture-source-image" src={capture.imageDataUrl} />
      ) : null}

      <section className="capture-panel">
        <div className="section-heading">
          <h2>고른 문장</h2>
          <span className="count-pill">Local</span>
        </div>
        <textarea
          aria-label="선택한 텍스트"
          className="capture-textarea"
          onChange={(event) => {
            setSelectedText(event.target.value);
            setSelectedCandidate(null);
          }}
          rows={3}
          value={selectedText}
        />

        <label className="folder-select-field">
          <span>
            <FolderOpen size={18} />
            저장 폴더
          </span>
          <select
            aria-label="저장 폴더"
            onChange={(event) => setFolderId(event.target.value)}
            value={folderId}
          >
            {folders.map((folder) => (
              <option key={folder.id} value={folder.id}>
                {folder.name}
              </option>
            ))}
          </select>
        </label>
      </section>

      <section className="capture-panel">
        <div className="section-heading">
          <h2>OCR 글자</h2>
          <span className="count-pill">{selectableTexts.length}개</span>
        </div>
        <div className="ocr-token-list">
          {selectableTexts.map((text) => (
            <button
              className={text === selectedText ? 'ocr-token is-selected' : 'ocr-token'}
              key={text}
              onClick={() => {
                setSelectedText(text);
                setSelectedCandidate(null);
              }}
              type="button"
            >
              {text}
            </button>
          ))}
        </div>
      </section>

      <section className="capture-panel">
        <button
          className="primary-action"
          disabled={!canSearch}
          onClick={handleSearch}
          type="button"
        >
          <Search size={20} />
          {status === 'searching' ? '찾는 중' : '주소 후보 찾기'}
        </button>

        {error ? <p className="flow-error">{error}</p> : null}

        {candidates.length > 0 ? (
          <div className="candidate-list">
            {candidates.map((candidate) => (
              <button
                className={
                  selectedCandidate?.id === candidate.id
                    ? 'candidate-card is-selected'
                    : 'candidate-card'
                }
                key={candidate.id}
                onClick={() => setSelectedCandidate(candidate)}
                type="button"
              >
                <MapPin size={18} />
                <span>
                  <strong>{candidate.title}</strong>
                  <small>{candidate.normalizedAddress}</small>
                </span>
              </button>
            ))}
          </div>
        ) : null}

        {selectedCandidate ? (
          <section aria-label="선택 후보 지도" className="candidate-map-preview">
            <div className="section-heading">
              <h2>선택 위치</h2>
              <span className="count-pill">Kakao Map</span>
            </div>
            <KakaoMap
              apiKey={kakaoJavascriptKey}
              latitude={selectedCandidate.latitude}
              longitude={selectedCandidate.longitude}
            />
          </section>
        ) : null}

        <button className="save-action" disabled={!canSave} onClick={handleSave} type="button">
          <Save size={20} />
          {status === 'saving' ? '저장 중' : '선택 주소 저장'}
        </button>
      </section>
    </main>
  );
}
