import { Plus } from 'lucide-react';

type FloatingAddButtonProps = {
  onAddPress: () => void;
};

export function FloatingAddButton({ onAddPress }: FloatingAddButtonProps) {
  return (
    <button className="place-add-fab" onClick={onAddPress} type="button">
      <Plus size={20} />
      주소 추가
    </button>
  );
}
