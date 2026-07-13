"use client";

import { useState } from "react";
import Typewriter from "@/components/Typewriter";

export default function Home() {
  const [typed, setTyped] = useState(false);

  return (
    <main className="page">
      <div className="margin-line" aria-hidden="true" />

      <header className="masthead">
        <span>
          <strong>Pratima Jain</strong>
        </span>
      </header>

      <section className="hero">
        <Typewriter onDone={() => setTyped(true)} />
        <p className={`hero-sub${typed ? " hero-sub--in" : ""}`}>
          Make yourself at home — this little corner of the internet is
          <em> still being written</em>.
        </p>
      </section>

      <footer className="colophon">
        <span>typed, not templated</span>
        <span>
          est. 2026 <span className="dot">·</span> with love
        </span>
      </footer>

      <div className="grain" aria-hidden="true" />
    </main>
  );
}
