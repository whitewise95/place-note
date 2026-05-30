import { fireEvent, render, screen, waitFor } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';

import { App } from './App';
import { MockNativeBridge } from './bridge/mockNativeBridge';

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

  it('starts the native capture flow from the floating action', async () => {
    const bridge = new MockNativeBridge();
    const startCapture = vi.spyOn(bridge, 'startCapture');
    render(<App bridge={bridge} />);

    fireEvent.click(await screen.findByRole('button', { name: '사진 속 글자 읽기' }));

    await waitFor(() => expect(startCapture).toHaveBeenCalledTimes(1));
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
    fireEvent.click(screen.getByRole('button', { name: '사진 속 글자 읽기' }));
    window.dispatchEvent(
      new CustomEvent('place-note:archive-changed', {
        detail: { reportId: 'report-new' },
      }),
    );

    expect(await screen.findByText('서울 서대문구 연희동 산5-79')).toBeInTheDocument();
    expect(listReports).toHaveBeenCalledTimes(2);
  });
});
