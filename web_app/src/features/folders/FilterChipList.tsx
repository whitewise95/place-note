import { PLACE_FILTERS, type PlaceFilter } from './placeTypes';

type FilterChipListProps = {
  selectedFilter: PlaceFilter;
  onChange: (filter: PlaceFilter) => void;
};

export function FilterChipList({ selectedFilter, onChange }: FilterChipListProps) {
  return (
    <div aria-label="주소 필터" className="place-filter-list">
      {PLACE_FILTERS.map((filter) => (
        <button
          className={filter === selectedFilter ? 'place-filter-chip is-active' : 'place-filter-chip'}
          key={filter}
          onClick={() => onChange(filter)}
          type="button"
        >
          {filter}
        </button>
      ))}
    </div>
  );
}
