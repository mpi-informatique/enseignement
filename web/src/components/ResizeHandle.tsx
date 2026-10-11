import { useRef, type PointerEvent } from 'react';

interface Props {
  label: string;
  value: number;
  min: number;
  max: number;
  onChange: (value: number) => void;
}

export function ResizeHandle({ label, value, min, max, onChange }: Props) {
  const drag = useRef<{ x: number; value: number } | undefined>(undefined);
  const update = (value: number) => onChange(Math.round(Math.max(min, Math.min(max, value))));
  function start(event: PointerEvent<HTMLDivElement>) {
    drag.current = { x: event.clientX, value };
    event.currentTarget.setPointerCapture(event.pointerId);
  }
  return <div className="resize-handle" role="separator" tabIndex={0} aria-label={label} aria-orientation="vertical" aria-valuenow={value} aria-valuemin={min} aria-valuemax={max}
    onPointerDown={start}
    onPointerMove={event => { if (drag.current) update(drag.current.value + event.clientX - drag.current.x); }}
    onPointerUp={() => { drag.current = undefined; }}
    onPointerCancel={() => { drag.current = undefined; }}
    onKeyDown={event => {
      if (['ArrowLeft', 'ArrowRight', 'Home', 'End'].includes(event.key)) {
        event.preventDefault();
        update(event.key === 'Home' ? min : event.key === 'End' ? max : value + (event.key === 'ArrowLeft' ? -20 : 20));
      }
    }}><span /></div>;
}
