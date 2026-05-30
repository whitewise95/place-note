import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';

import { KakaoMap } from './KakaoMap';
import { ReportDetail } from '../reports/ReportDetail';

describe('KakaoMap', () => {
  it('shows configuration guidance when no JavaScript key is supplied', () => {
    render(<KakaoMap apiKey="" latitude={37.565} longitude={127.009} />);

    expect(screen.getByText('카카오 지도 키를 설정해주세요')).toBeInTheDocument();
  });

  it('uses the Kakao JavaScript key injected by the native WebView', () => {
    Object.assign(window, {
      PlaceNoteConfig: { kakaoJavascriptKey: 'runtime-javascript-key' },
    });

    render(
      <ReportDetail
        onBack={() => undefined}
        report={{
          id: 'report-1',
          folderId: 'folder-inbox',
          normalizedAddress: '서울 서대문구 연희동 산5-79',
          createdAt: '2026-05-31T00:00:00.000Z',
          latitude: 37.5742,
          longitude: 126.9301,
        }}
      />,
    );

    expect(screen.queryByText('카카오 지도 키를 설정해주세요')).not.toBeInTheDocument();
    expect(screen.getByText('지도를 불러오는 중입니다')).toBeInTheDocument();
  });
});
