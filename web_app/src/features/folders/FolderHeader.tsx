import { ArrowLeft, SlidersHorizontal } from 'lucide-react';

type FolderHeaderProps = {
  title: string;
  count: number;
  onBack: () => void;
};

export function FolderHeader({ title, count, onBack }: FolderHeaderProps) {
  return (
    <header className="folder-screen-header">
      <button
        aria-label="폴더 목록으로 돌아가기"
        className="icon-button"
        onClick={onBack}
        type="button"
      >
        <ArrowLeft size={27} />
      </button>
      <div className="folder-screen-title">
        <h1>{title}</h1>
        <p>저장한 주소 {count}개</p>
      </div>
      <button
        aria-label="정렬 옵션"
        className="icon-button"
        onClick={() => console.log('sort options')}
        type="button"
      >
        <SlidersHorizontal size={22} />
      </button>
    </header>
  );
}
