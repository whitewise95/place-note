import {
  ArrowLeft,
  Bookmark,
  Check,
  Crop,
  FileText,
  Image as ImageIcon,
  MapPin,
  RefreshCcw,
  Search,
  X,
} from 'lucide-react';
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

type SaveForm = {
  title: string;
  address: string;
  memo: string;
  folderId: string;
  tags: string[];
};

const MOCK_ADDRESS_CANDIDATES: AddressSearchCandidate[] = [
  {
    id: 'mock-yeonhui',
    title: '연희숲속쉼터',
    normalizedAddress: '서울 서대문구 연희동 산5-79',
    latitude: 37.5742,
    longitude: 126.9301,
    province: '서울',
    district: '서대문구',
    locality: '연희동',
  },
  {
    id: 'mock-seodaemun',
    title: '서울 서대문구',
    normalizedAddress: '서울 서대문구',
    latitude: 37.5791,
    longitude: 126.9368,
    province: '서울',
    district: '서대문구',
  },
  {
    id: 'mock-bukhansan',
    title: '북한산둘레길 7구간옛성길',
    normalizedAddress: '서울 서대문구 홍은동',
    latitude: 37.5947,
    longitude: 126.9476,
    province: '서울',
    district: '서대문구',
    locality: '홍은동',
  },
];

export function CaptureSaveFlow({
  capture,
  folders,
  onCancel,
  onSave,
}: CaptureSaveFlowProps) {
  const ocrTexts = useMemo(() => {
    const merged = [...capture.ocrLines, ...capture.ocrWords]
      .map((item) => item.trim())
      .filter((item) => item.length > 0);
    return [...new Set(merged)];
  }, [capture.ocrLines, capture.ocrWords]);

  const defaultSelectedOcrText =
    ocrTexts.find((text) => text.includes('산5-79')) ?? ocrTexts[0] ?? '';
  const [selectedOcrText, setSelectedOcrText] = useState(defaultSelectedOcrText);
  const [isAddressEdited, setIsAddressEdited] = useState(false);
  const [showCandidates, setShowCandidates] = useState(false);
  const [selectedCandidate, setSelectedCandidate] = useState<AddressSearchCandidate | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [isSaving, setIsSaving] = useState(false);
  const [form, setForm] = useState<SaveForm>({
    title: '연희숲속쉼터',
    address: defaultSelectedOcrText || '서울 서대문구 연희동 산5-79',
    memo: '주말 산책 후보로 저장',
    folderId: folders[0]?.id ?? 'folder-inbox',
    tags: ['산책', '공원', '가볼 곳'],
  });
  const kakaoJavascriptKey =
    window.PlaceNoteConfig?.kakaoJavascriptKey ?? import.meta.env.VITE_KAKAO_JAVASCRIPT_KEY ?? '';

  function updateForm<K extends keyof SaveForm>(key: K, value: SaveForm[K]) {
    setForm((current) => ({ ...current, [key]: value }));
  }

  function handleOcrSelect(text: string) {
    setSelectedOcrText(text);
    /**
     * 실제 제품에서는 사용자가 주소를 직접 수정한 뒤 OCR chip을 누를 때
     * "현재 주소를 덮어쓸까요?" 확인 모달을 붙일 수 있습니다.
     * 지금 mock 단계에서는 직접 수정 전이면 자동 반영하고, 수정 후에는 사용자의 입력을 보존합니다.
     */
    if (!isAddressEdited) {
      updateForm('address', text);
    }
  }

  function handleCandidateSelect(candidate: AddressSearchCandidate) {
    setSelectedCandidate(candidate);
    setForm((current) => ({
      ...current,
      title: candidate.title,
      address: candidate.normalizedAddress,
    }));
    setIsAddressEdited(false);
  }

  async function handleSave() {
    const address = form.address.trim();
    if (!address) {
      setError('주소를 입력하거나 OCR 텍스트를 선택해주세요.');
      return;
    }

    setIsSaving(true);
    setError(null);
    const savePayload = {
      title: form.title.trim() || address,
      address,
      memo: form.memo.trim(),
      folder: folders.find((folder) => folder.id === form.folderId)?.name ?? '기본 보관함',
      tags: form.tags,
      sourceImageUrl: capture.imagePath ?? capture.imageDataUrl ?? null,
      ocrTexts,
      selectedOcrText,
      addressCandidate: selectedCandidate
        ? {
            title: selectedCandidate.title,
            address: selectedCandidate.normalizedAddress,
          }
        : null,
    };
    console.log('save address place', savePayload);

    try {
      await onSave({
        folderId: form.folderId,
        selectedText: selectedOcrText,
        normalizedAddress: address,
        detailAddress: selectedCandidate?.title ?? savePayload.title,
        latitude: selectedCandidate?.latitude,
        longitude: selectedCandidate?.longitude,
        province: selectedCandidate?.province,
        district: selectedCandidate?.district,
        locality: selectedCandidate?.locality,
        imagePath: capture.imagePath,
        ocrText: capture.ocrText,
      });
    } catch {
      setError('저장하지 못했습니다. 잠시 뒤 다시 시도해주세요.');
      setIsSaving(false);
    }
  }

  return (
    <main className="app-shell address-save-screen">
      <Header onBack={onCancel} />
      <OriginalImageCard
        imageDataUrl={capture.imageDataUrl}
        onCrop={() => console.log('TODO crop image')}
        onReselect={() => console.log('TODO reselect image')}
      />
      <PlaceInfoCard
        folders={folders}
        form={form}
        onAddressChange={(value) => {
          setIsAddressEdited(true);
          updateForm('address', value);
        }}
        onMemoChange={(value) => updateForm('memo', value)}
        onRemoveTag={(tag) => updateForm('tags', form.tags.filter((item) => item !== tag))}
        onTitleChange={(value) => updateForm('title', value)}
        onFolderChange={(folderId) => updateForm('folderId', folderId)}
        onAddTag={() => console.log('TODO add tag')}
      />
      <OcrTextChipList
        ocrTexts={ocrTexts}
        onSelect={handleOcrSelect}
        selectedOcrText={selectedOcrText}
      />
      <section className="capture-panel">
        <div className="card-title-row">
          <span>
            <Search size={18} />
            주소 후보
          </span>
        </div>
        <button
          className="primary-action"
          onClick={() => {
            setShowCandidates(true);
            setError(null);
          }}
          type="button"
        >
          <Search size={20} />
          주소 후보 찾기
        </button>
        {showCandidates ? (
          <div className="candidate-list">
            {MOCK_ADDRESS_CANDIDATES.map((candidate) => (
              <AddressCandidateCard
                candidate={candidate}
                isSelected={selectedCandidate?.id === candidate.id}
                key={candidate.id}
                onSelect={handleCandidateSelect}
              />
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
      </section>
      {error ? <p className="flow-error">{error}</p> : null}
      <BottomSaveButton isSaving={isSaving} onSave={handleSave} />
    </main>
  );
}

function Header({ onBack }: { onBack: () => void }) {
  return (
    <header className="address-save-header">
      <button aria-label="홈으로 돌아가기" className="icon-button" onClick={onBack} type="button">
        <ArrowLeft size={25} />
      </button>
      <div>
        <h1>주소 저장하기</h1>
        <p>사진 속 주소를 확인하고 장소 정보로 저장해요.</p>
      </div>
    </header>
  );
}

function OriginalImageCard({
  imageDataUrl,
  onCrop,
  onReselect,
}: {
  imageDataUrl?: string;
  onCrop: () => void;
  onReselect: () => void;
}) {
  return (
    <section className="capture-panel">
      <div className="card-title-row">
        <span>
          <ImageIcon size={18} />
          원본 이미지
        </span>
      </div>
      <div className="original-image-layout">
        {imageDataUrl ? (
          <img alt="OCR 원본 이미지" className="original-image-preview" src={imageDataUrl} />
        ) : (
          <div className="original-image-placeholder">
            <ImageIcon size={28} />
            <span>이미지 미리보기</span>
          </div>
        )}
        <div className="image-tool-list">
          <button onClick={onReselect} type="button">
            <RefreshCcw size={16} />
            다시 선택
          </button>
          <button onClick={onCrop} type="button">
            <Crop size={16} />
            자르기
          </button>
        </div>
      </div>
    </section>
  );
}

function PlaceInfoCard({
  folders,
  form,
  onAddTag,
  onAddressChange,
  onFolderChange,
  onMemoChange,
  onRemoveTag,
  onTitleChange,
}: {
  folders: Folder[];
  form: SaveForm;
  onAddTag: () => void;
  onAddressChange: (value: string) => void;
  onFolderChange: (folderId: string) => void;
  onMemoChange: (value: string) => void;
  onRemoveTag: (tag: string) => void;
  onTitleChange: (value: string) => void;
}) {
  return (
    <section className="capture-panel">
      <div className="card-title-row">
        <span>
          <MapPin size={18} />
          장소 정보
        </span>
        <span className="storage-badge local">Local</span>
      </div>
      <div className="form-grid">
        <label>
          제목
          <input onChange={(event) => onTitleChange(event.target.value)} value={form.title} />
        </label>
        <label>
          주소
          <input onChange={(event) => onAddressChange(event.target.value)} value={form.address} />
        </label>
        <label>
          메모
          <input onChange={(event) => onMemoChange(event.target.value)} value={form.memo} />
        </label>
        <label>
          저장 폴더
          <select onChange={(event) => onFolderChange(event.target.value)} value={form.folderId}>
            {folders.map((folder) => (
              <option key={folder.id} value={folder.id}>
                {folder.name}
              </option>
            ))}
          </select>
        </label>
      </div>
      <div className="editable-tag-list">
        {form.tags.map((tag) => (
          <TagChip key={tag} label={tag} onRemove={() => onRemoveTag(tag)} />
        ))}
        <button className="add-tag-button" onClick={onAddTag} type="button">
          + 태그 추가
        </button>
      </div>
    </section>
  );
}

function OcrTextChipList({
  ocrTexts,
  onSelect,
  selectedOcrText,
}: {
  ocrTexts: string[];
  onSelect: (text: string) => void;
  selectedOcrText: string;
}) {
  return (
    <section className="capture-panel">
      <div className="card-title-row">
        <span>
          <FileText size={18} />
          OCR 텍스트
        </span>
      </div>
      <div className="ocr-token-list horizontal">
        {ocrTexts.map((text) => (
          <button
            className={text === selectedOcrText ? 'ocr-token is-selected' : 'ocr-token'}
            key={text}
            onClick={() => onSelect(text)}
            type="button"
          >
            {text === selectedOcrText ? <Check size={14} /> : null}
            {text}
          </button>
        ))}
      </div>
    </section>
  );
}

function AddressCandidateCard({
  candidate,
  isSelected,
  onSelect,
}: {
  candidate: AddressSearchCandidate;
  isSelected: boolean;
  onSelect: (candidate: AddressSearchCandidate) => void;
}) {
  return (
    <button
      className={isSelected ? 'candidate-card is-selected' : 'candidate-card'}
      onClick={() => onSelect(candidate)}
      type="button"
    >
      <MapPin size={18} />
      <span>
        <strong>{candidate.title}</strong>
        <small>{candidate.normalizedAddress}</small>
      </span>
    </button>
  );
}

function TagChip({ label, onRemove }: { label: string; onRemove: () => void }) {
  return (
    <span className="editable-tag-chip">
      {label}
      <button aria-label={`${label} 태그 삭제`} onClick={onRemove} type="button">
        <X size={13} />
      </button>
    </span>
  );
}

function BottomSaveButton({
  isSaving,
  onSave,
}: {
  isSaving: boolean;
  onSave: () => void;
}) {
  return (
    <button className="bottom-save-button" disabled={isSaving} onClick={onSave} type="button">
      <Bookmark size={20} />
      {isSaving ? '저장 중' : '장소 저장하기'}
    </button>
  );
}
