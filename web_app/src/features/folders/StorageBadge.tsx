import type { StorageType } from './placeTypes';

type StorageBadgeProps = {
  type: StorageType;
};

export function StorageBadge({ type }: StorageBadgeProps) {
  return <span className={type === 'Local' ? 'storage-badge local' : 'storage-badge cloud'}>{type}</span>;
}
