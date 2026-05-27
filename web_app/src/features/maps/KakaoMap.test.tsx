import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';

import { KakaoMap } from './KakaoMap';

describe('KakaoMap', () => {
  it('shows configuration guidance when no JavaScript key is supplied', () => {
    render(<KakaoMap apiKey="" latitude={37.565} longitude={127.009} />);

    expect(screen.getByText('카카오 지도 키를 설정해주세요')).toBeInTheDocument();
  });
});
