import type { Folder, NativeBridge, Report } from '../types/native';

/**
 * Vercel 또는 로컬 브라우저에서 React만 단독으로 볼 때 사용하는 샘플 데이터입니다.
 * Flutter WebView 밖에서는 기기 로컬 저장소에 접근할 수 없으므로, 이 mock이 UI 미리보기 역할을 합니다.
 */
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
  /**
   * 실제 앱에서는 Flutter가 로컬 저장소에서 폴더를 읽습니다.
   * mock에서는 고정 샘플을 돌려 디자인과 기본 화면 전환만 확인합니다.
   */
  async listFolders(): Promise<Folder[]> {
    return folders;
  }

  /**
   * 첫 번째 샘플에는 좌표가 있어서 카카오맵 패널까지 확인할 수 있습니다.
   * 두 번째 샘플은 좌표가 없는 저장 텍스트가 상세 화면에서 어떻게 보이는지 확인하기 위한 데이터입니다.
   */
  async listReports(): Promise<Report[]> {
    return reports;
  }

  /**
   * 브라우저 mock 모드에서는 OCR/사진 선택을 실행할 Flutter가 없습니다.
   * 그래서 버튼 클릭 테스트가 깨지지 않도록 no-op Promise만 반환합니다.
   */
  async startCapture(): Promise<void> {
    return undefined;
  }
}
