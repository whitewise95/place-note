type TagChipProps = {
  label: string;
};

export function TagChip({ label }: TagChipProps) {
  return <span className="place-tag-chip">{label}</span>;
}
