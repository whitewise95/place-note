type DotMarkProps = {
  size?: 'small' | 'large';
};

export function DotMark({ size = 'small' }: DotMarkProps) {
  return (
    <span className={`dot-mark dot-mark--${size}`} aria-hidden="true">
      {/* Place Note의 대표 아이콘입니다. 3x3 점 배열에서 짝수 위치만 caramel 색을 주어 도트 아카이브 느낌을 만듭니다. */}
      {Array.from({ length: 9 }, (_, index) => (
        <span
          className={(index + Math.floor(index / 3)) % 2 === 0 ? 'is-accent' : ''}
          key={index}
        />
      ))}
    </span>
  );
}
