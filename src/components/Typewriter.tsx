"use client";

import { useEffect, useRef, useState } from "react";

const FULL = "Hi! I am Pratima Jain! This is my world.";
const NAME_START = FULL.indexOf("Pratima");
const NAME_END = NAME_START + "Pratima Jain!".length;

// pauses that make the typing feel human rather than metronomic
function delayAfter(char: string): number {
  if (char === "!" || char === ".") return 330;
  if (char === " ") return 85;
  return 44 + Math.random() * 58;
}

export default function Typewriter({ onDone }: { onDone?: () => void }) {
  const [count, setCount] = useState(0);
  const [done, setDone] = useState(false);
  const onDoneRef = useRef(onDone);
  onDoneRef.current = onDone;

  useEffect(() => {
    if (
      typeof window !== "undefined" &&
      window.matchMedia("(prefers-reduced-motion: reduce)").matches
    ) {
      setCount(FULL.length);
      setDone(true);
      onDoneRef.current?.();
      return;
    }

    let i = 0;
    let timer: ReturnType<typeof setTimeout>;

    const tick = () => {
      i += 1;
      setCount(i);
      if (i >= FULL.length) {
        setDone(true);
        onDoneRef.current?.();
        return;
      }
      timer = setTimeout(tick, delayAfter(FULL[i - 1]));
    };

    timer = setTimeout(tick, 650);
    return () => clearTimeout(timer);
  }, []);

  return (
    <h1 aria-label={FULL}>
      <span aria-hidden="true">
        {FULL.slice(0, Math.min(count, NAME_START))}
        <span className="name">
          {count > NAME_START
            ? FULL.slice(NAME_START, Math.min(count, NAME_END))
            : ""}
        </span>
        {count > NAME_END ? FULL.slice(NAME_END, count) : ""}
        <span
          className={`caret${done ? " caret--blink" : ""}`}
          aria-hidden="true"
        />
      </span>
    </h1>
  );
}
