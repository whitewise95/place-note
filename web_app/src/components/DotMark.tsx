type DotMarkProps = {
  size?: 'small' | 'large';
};

export function DotMark({ size = 'small' }: DotMarkProps) {
  return (
    <span className={`dot-mark dot-mark--${size}`} aria-hidden="true">
      {Array.from({ length: 9 }, (_, index) => (
        <span
          className={(index + Math.floor(index / 3)) % 2 === 0 ? 'is-accent' : ''}
          key={index}
        />
      ))}
    </span>
  );
}
