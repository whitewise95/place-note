/**
 * Flutter 로컬 저장소에서 넘어오는 폴더 DTO입니다.
 * React는 이 타입만 알고, 실제 저장 방식(shared_preferences/file)은 Flutter 쪽에 숨겨져 있습니다.
 */
export type Folder = {
  id: string;
  name: string;
  createdAt: string;
};

/**
 * Flutter가 저장된 텍스트를 React 화면용으로 변환한 DTO입니다.
 *
 * normalizedAddress라는 이름은 초기 주소 분석 MVP에서 온 필드명입니다.
 * 현재 제품 방향에서는 "사용자가 선택해 저장한 대표 텍스트"로 보면 됩니다.
 */
export type Report = {
  id: string;
  folderId: string;
  normalizedAddress: string;
  rawAddress?: string;
  createdAt: string;
  /**
   * latitude/longitude가 있으면 상세 화면에서 카카오맵을 보여줍니다.
   * 값이 없으면 지도 섹션을 숨기고 텍스트/이미지만 보여줍니다.
   */
  latitude?: number;
  longitude?: number;
  /**
   * Flutter가 로컬 이미지 파일을 읽어 data:image/...;base64 형태로 전달합니다.
   * 브라우저는 기기 파일 경로에 접근할 수 없으므로 data URL이 필요합니다.
   */
  imageDataUrl?: string;
};

/**
 * React가 Flutter와 대화하기 위해 기대하는 최소 기능입니다.
 * MockNativeBridge와 WebViewNativeBridge가 같은 인터페이스를 구현하므로,
 * App 컴포넌트는 실행 환경을 몰라도 같은 방식으로 동작합니다.
 */
export interface NativeBridge {
  listFolders(): Promise<Folder[]>;
  listReports(): Promise<Report[]>;
  startCapture(): Promise<void>;
}
