import type { Report } from '../../types/native';

export type StorageType = 'Local' | 'Cloud';

export type SavedPlace = {
  id: string;
  report: Report;
  title: string;
  address: string;
  memo: string;
  tags: string[];
  sourceImageUrl: string | null;
  savedAt: string;
  createdAt: string;
  storageType: StorageType;
};

export type PlaceFilter = '전체' | 'Local' | 'Cloud' | '최근 저장' | '태그 있음';

export const PLACE_FILTERS: PlaceFilter[] = ['전체', 'Local', 'Cloud', '최근 저장', '태그 있음'];

export function reportToSavedPlace(report: Report): SavedPlace {
  return {
    id: report.id,
    report,
    title: report.title ?? report.rawAddress ?? report.normalizedAddress,
    address: report.normalizedAddress,
    memo: report.memo ?? defaultMemoFor(report.normalizedAddress),
    tags: report.tags ?? defaultTagsFor(report.normalizedAddress),
    sourceImageUrl: report.sourceImageUrl ?? report.imageDataUrl ?? null,
    savedAt: formatSavedAt(report.createdAt),
    createdAt: report.createdAt,
    storageType: report.storageType ?? 'Local',
  };
}

function defaultMemoFor(address: string): string {
  if (address.includes('연희동') || address.includes('숲')) {
    return '주말 산책 후보로 저장';
  }
  return '회의 장소 후보';
}

function defaultTagsFor(address: string): string[] {
  if (address.includes('연희동') || address.includes('숲')) {
    return ['산책', '공원', '가볼 곳'];
  }
  return ['회사', '미팅'];
}

function formatSavedAt(value: string): string {
  return new Intl.DateTimeFormat('ko-KR', {
    dateStyle: 'medium',
    timeStyle: 'short',
  }).format(new Date(value));
}
