import type { Folder, NativeBridge, Report } from '../types/native';

const folders: Folder[] = [
  {
    id: 'folder-inbox',
    name: '기본 보관함',
    createdAt: '2026-05-25T00:00:00.000Z',
  },
];

const reports: Report[] = [
  {
    id: 'report-preview',
    folderId: 'folder-inbox',
    normalizedAddress: '서울 중구 퇴계로 409',
    createdAt: '2026-05-25T12:49:00.000Z',
    latitude: 37.565,
    longitude: 127.009,
  },
  {
    id: 'report-second',
    folderId: 'folder-inbox',
    normalizedAddress: '서울 서대문구 연희동 산5-79',
    createdAt: '2026-05-24T11:10:00.000Z',
  },
];

export class MockNativeBridge implements NativeBridge {
  async listFolders(): Promise<Folder[]> {
    return folders;
  }

  async listReports(): Promise<Report[]> {
    return reports;
  }
}
