import { ImagePlus } from 'lucide-react';

type EmptyStateProps = {
  onAddPress: () => void;
};

export function EmptyState({ onAddPress }: EmptyStateProps) {
  return (
    <section className="place-empty-state">
      <span className="empty-state-icon">
        <ImagePlus size={28} />
      </span>
      <h2>아직 저장한 주소가 없어요</h2>
      <p>사진 속 주소를 캡쳐해서 첫 장소를 저장해보세요.</p>
      <button onClick={onAddPress} type="button">
        주소 캡쳐하기
      </button>
    </section>
  );
}
