import { fireEvent, render, screen, waitFor } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';

import { App } from './App';
import { MockNativeBridge } from './bridge/mockNativeBridge';
import type { AddressSearchCandidate, NativeBridge, Report } from './types/native';

describe('App', () => {
  it('renders local folders returned by the native bridge', async () => {
    render(<App bridge={new MockNativeBridge()} />);

    expect(await screen.findByText('기본 보관함')).toBeInTheDocument();
    expect(screen.getByText('서울 중구 퇴계로 409')).toBeInTheDocument();
  });

  it('opens saved entries in a folder and then a saved text detail', async () => {
    render(<App bridge={new MockNativeBridge()} />);

    fireEvent.click(await screen.findByRole('button', { name: /기본 보관함/ }));
    expect(await screen.findByRole('heading', { name: '기본 보관함' })).toBeInTheDocument();

    fireEvent.click(screen.getByRole('button', { name: /서울 중구 퇴계로 409/ }));

    expect(await screen.findByRole('heading', { name: '저장된 텍스트' })).toBeInTheDocument();
    expect(screen.getByText('서울 중구 퇴계로 409')).toBeInTheDocument();
  });

  it('starts the native OCR capture flow from the floating action', async () => {
    const bridge = new MockNativeBridge();
    const startOcrCapture = vi.spyOn(bridge, 'startOcrCapture');
    render(<App bridge={bridge} />);

    fireEvent.click(await screen.findByRole('button', { name: '사진 속 글자 읽기' }));

    await waitFor(() => expect(startOcrCapture).toHaveBeenCalledTimes(1));
    expect(await screen.findByRole('heading', { name: '저장할 텍스트 선택' })).toBeInTheDocument();
  });

  it('reloads reports when Flutter reports archive changes', async () => {
    const bridge = new MockNativeBridge();
    const listReports = vi
      .spyOn(bridge, 'listReports')
      .mockResolvedValueOnce([])
      .mockResolvedValueOnce([
        {
          id: 'report-new',
          folderId: 'folder-inbox',
          normalizedAddress: '서울 서대문구 연희동 산5-79',
          createdAt: '2026-05-30T07:10:00.000Z',
          latitude: 37.5742,
          longitude: 126.9301,
        },
      ]);

    render(<App bridge={bridge} />);

    expect(await screen.findByText('저장된 텍스트가 없습니다.')).toBeInTheDocument();
    window.dispatchEvent(
      new CustomEvent('place-note:archive-changed', {
        detail: { reportId: 'report-new' },
      }),
    );

    expect(await screen.findByText('서울 서대문구 연희동 산5-79')).toBeInTheDocument();
    expect(listReports).toHaveBeenCalledTimes(2);
  });

  it('saves selected OCR text through Kakao candidate selection and folder choice', async () => {
    const reports: Report[] = [];
    const bridge: NativeBridge = {
      listFolders: vi.fn(async () => [
        {
          id: 'folder-inbox',
          name: '기본 보관함',
          createdAt: '2026-06-03T00:00:00.000Z',
        },
      ]),
      listReports: vi.fn(async () => reports),
      startCapture: vi.fn(async () => undefined),
      startOcrCapture: vi.fn(async () => ({
        imagePath: '/tmp/capture.jpg',
        imageDataUrl: 'data:image/jpeg;base64,aW1hZ2U=',
        ocrText: '연희숲속쉼터\n서대문구 연희동 산5-79',
        ocrLines: ['연희숲속쉼터', '서대문구 연희동 산5-79'],
        ocrWords: ['연희숲속쉼터', '서대문구', '연희동', '산5-79'],
      })),
      saveReport: vi.fn(async (params) => {
        const report = {
          id: 'report-saved',
          folderId: params.folderId,
          normalizedAddress: params.normalizedAddress,
          rawAddress: params.selectedText,
          createdAt: '2026-06-03T10:00:00.000Z',
          latitude: params.latitude,
          longitude: params.longitude,
          imageDataUrl: 'data:image/jpeg;base64,aW1hZ2U=',
        };
        reports.unshift(report);
        return report;
      }),
    };
    const searchAddress = vi.fn(async (_query: string): Promise<AddressSearchCandidate[]> => [
      {
        id: 'kakao-1',
        title: '연희숲속쉼터',
        normalizedAddress: '서울 서대문구 연희동 산5-79',
        detailAddress: '연희숲속쉼터',
        latitude: 37.5742,
        longitude: 126.9301,
        province: '서울',
        district: '서대문구',
        locality: '연희동',
      },
    ]);

    render(<App bridge={bridge} searchAddress={searchAddress} />);

    fireEvent.click(await screen.findByRole('button', { name: '사진 속 글자 읽기' }));
    expect(await screen.findByRole('heading', { name: '저장할 텍스트 선택' })).toBeInTheDocument();

    fireEvent.click(screen.getByRole('button', { name: '연희숲속쉼터' }));
    fireEvent.click(screen.getByRole('button', { name: '주소 후보 찾기' }));
    expect(searchAddress).toHaveBeenCalledWith('연희숲속쉼터');

    fireEvent.click(await screen.findByRole('button', { name: /서울 서대문구 연희동 산5-79/ }));
    fireEvent.click(screen.getByRole('button', { name: '선택 주소 저장' }));

    await waitFor(() => expect(bridge.saveReport).toHaveBeenCalledTimes(1));
    expect(bridge.saveReport).toHaveBeenCalledWith(
      expect.objectContaining({
        folderId: 'folder-inbox',
        selectedText: '연희숲속쉼터',
        normalizedAddress: '서울 서대문구 연희동 산5-79',
        latitude: 37.5742,
        longitude: 126.9301,
      }),
    );
    expect(await screen.findByText('서울 서대문구 연희동 산5-79')).toBeInTheDocument();
  });
});
