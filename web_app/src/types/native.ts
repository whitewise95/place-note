export type Folder = {
  id: string;
  name: string;
  createdAt: string;
};

export type Report = {
  id: string;
  folderId: string;
  normalizedAddress: string;
  rawAddress?: string;
  createdAt: string;
  latitude?: number;
  longitude?: number;
  imageDataUrl?: string;
};

export interface NativeBridge {
  listFolders(): Promise<Folder[]>;
  listReports(): Promise<Report[]>;
  startCapture(): Promise<void>;
}
