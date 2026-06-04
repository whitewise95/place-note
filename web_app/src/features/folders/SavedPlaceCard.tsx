import { ChevronRight, Clock3, Image as ImageIcon, MapPinned } from 'lucide-react';

import type { SavedPlace } from './placeTypes';
import { StorageBadge } from './StorageBadge';
import { TagChip } from './TagChip';

type SavedPlaceCardProps = {
  place: SavedPlace;
  onPress: (place: SavedPlace) => void;
  onMapPress: (place: SavedPlace) => void;
};

export function SavedPlaceCard({ place, onPress, onMapPress }: SavedPlaceCardProps) {
  return (
    <article className="saved-place-card">
      <button className="saved-place-main" onClick={() => onPress(place)} type="button">
        {place.sourceImageUrl ? (
          <img alt="" className="place-thumbnail" src={place.sourceImageUrl} />
        ) : (
          <span aria-hidden className="place-thumbnail placeholder">
            <ImageIcon size={22} />
          </span>
        )}
        <span className="place-card-body">
          <span className="place-card-topline">
            <strong>{place.title}</strong>
            <StorageBadge type={place.storageType} />
          </span>
          <span className="place-address">{place.address}</span>
          {place.memo ? <span className="place-memo">{place.memo}</span> : null}
          <span className="place-tags">
            {place.tags.slice(0, 3).map((tag) => (
              <TagChip key={tag} label={tag} />
            ))}
          </span>
          <span className="place-date">
            <Clock3 size={14} />
            {place.savedAt}
          </span>
        </span>
      </button>
      <button className="place-map-action" onClick={() => onMapPress(place)} type="button">
        <MapPinned size={16} />
        지도 보기
        <ChevronRight size={16} />
      </button>
    </article>
  );
}
