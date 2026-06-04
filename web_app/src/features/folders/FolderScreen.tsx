import { useMemo, useState } from 'react';

import type { Folder, Report } from '../../types/native';
import { EmptyState } from './EmptyState';
import { FilterChipList } from './FilterChipList';
import { FloatingAddButton } from './FloatingAddButton';
import { FolderHeader } from './FolderHeader';
import type { PlaceFilter, SavedPlace } from './placeTypes';
import { reportToSavedPlace } from './placeTypes';
import { SavedPlaceCard } from './SavedPlaceCard';
import { SearchBar } from './SearchBar';

type FolderScreenProps = {
  folder: Folder;
  reports: Report[];
  onBack: () => void;
  onOpenReport: (report: Report) => void;
};

export function FolderScreen({ folder, reports, onBack, onOpenReport }: FolderScreenProps) {
  const [searchKeyword, setSearchKeyword] = useState('');
  const [selectedFilter, setSelectedFilter] = useState<PlaceFilter>('전체');
  const savedPlaces = useMemo(() => reports.map(reportToSavedPlace), [reports]);

  const filteredPlaces = useMemo(
    () => filterPlaces(savedPlaces, searchKeyword, selectedFilter),
    [savedPlaces, searchKeyword, selectedFilter],
  );

  function handlePlacePress(place: SavedPlace) {
    console.log('open place detail', place);
    onOpenReport(place.report);
  }

  function handleMapPress(place: SavedPlace) {
    console.log('open place map', place);
  }

  function handleAddPress() {
    console.log('add address from folder', folder);
  }

  return (
    <main className="app-shell folder-screen">
      <FolderHeader count={savedPlaces.length} onBack={onBack} title={folder.name} />
      <SearchBar onChange={setSearchKeyword} value={searchKeyword} />
      <FilterChipList onChange={setSelectedFilter} selectedFilter={selectedFilter} />

      <section aria-label="저장 주소 목록" className="saved-place-list">
        <div className="place-group-heading">
          <h2>최근 저장</h2>
          <span>{filteredPlaces.length}개</span>
        </div>
        {filteredPlaces.length === 0 ? (
          <EmptyState onAddPress={handleAddPress} />
        ) : (
          filteredPlaces.map((place) => (
            <SavedPlaceCard
              key={place.id}
              onMapPress={handleMapPress}
              onPress={handlePlacePress}
              place={place}
            />
          ))
        )}
      </section>

      <FloatingAddButton onAddPress={handleAddPress} />
    </main>
  );
}

function filterPlaces(
  places: SavedPlace[],
  keyword: string,
  selectedFilter: PlaceFilter,
): SavedPlace[] {
  const normalizedKeyword = keyword.trim().toLowerCase();
  const searched = normalizedKeyword
    ? places.filter((place) =>
        [place.title, place.address, place.memo, ...place.tags].some((value) =>
          value.toLowerCase().includes(normalizedKeyword),
        ),
      )
    : places;

  const filtered = searched.filter((place) => {
    if (selectedFilter === '전체' || selectedFilter === '최근 저장') {
      return true;
    }
    if (selectedFilter === '태그 있음') {
      return place.tags.length > 0;
    }
    return place.storageType === selectedFilter;
  });

  if (selectedFilter === '최근 저장') {
    return [...filtered].sort(
      (a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime(),
    );
  }

  return filtered;
}
