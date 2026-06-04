import { Search } from 'lucide-react';

type SearchBarProps = {
  value: string;
  onChange: (value: string) => void;
};

export function SearchBar({ value, onChange }: SearchBarProps) {
  return (
    <label className="place-search-field">
      <Search size={21} />
      <input
        onChange={(event) => onChange(event.target.value)}
        placeholder="주소, 제목, 메모 검색"
        type="search"
        value={value}
      />
    </label>
  );
}
