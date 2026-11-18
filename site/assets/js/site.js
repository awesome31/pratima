/* Pratima Jain — site behaviour. Every interaction here is optional: the page reads fully without it. */
(() => {
  const d = document;
  const root = d.documentElement;
  const reduce = matchMedia('(prefers-reduced-motion: reduce)').matches;
  const fine = matchMedia('(hover: hover) and (pointer: fine)').matches;
  const $$ = (s, c = d) => [...c.querySelectorAll(s)];
  const $ = (s, c = d) => c.querySelector(s);

  /* ---- Entrances: fade-ups, marks and drawings draw once ---- */
  const io = new IntersectionObserver((entries) => {
    entries.forEach((e) => {
      if (!e.isIntersecting) return;
      e.target.classList.add('is-in');
      e.target.dispatchEvent(new CustomEvent('seen'));
      io.unobserve(e.target);
    });
  }, { threshold: 0.12, rootMargin: '0px 0px -6% 0px' });
  $$('[data-io]').forEach((el) => io.observe(el));

  /* ---- Header: colour follows the surface, hides on the way down ---- */
  const header = $('.header');
  let lastY = scrollY, ticking = false;
  const surfaceAt = (y) => {
    for (const el of d.elementsFromPoint(innerWidth / 2, y)) {
      const s = el.closest && el.closest('[data-surface]');
      if (s) return s.dataset.surface;
    }
    return 'chalk';
  };
  const onScroll = () => {
    ticking = false;
    const y = scrollY;
    header.classList.toggle('on-board', surfaceAt(32) === 'board');
    if (!root.classList.contains('menu-open')) {
      if (y > 240 && y > lastY + 2) header.classList.add('is-hidden');
      else if (y < lastY - 2 || y < 240) header.classList.remove('is-hidden');
    }
    // Mid-page, the header items sit on small chips so they never collide with the text below.
    header.classList.toggle('is-float', y > 240);
    lastY = y;
    updateRuler();
  };
  addEventListener('scroll', () => { if (!ticking) { ticking = true; requestAnimationFrame(onScroll); } }, { passive: true });
  addEventListener('resize', onScroll);

  /* ---- Scroll ruler ---- */
  const ruler = $('.ruler');
  const stops = $$('[data-ruler]');
  let groups = [];
  if (ruler && stops.length > 1) {
    groups = stops.map(() => {
      const g = d.createElement('span');
      g.className = 'ruler__g';
      g.innerHTML = '<i></i><i></i><i></i><i></i><i></i>';
      ruler.append(g);
      return g;
    });
  }
  function updateRuler() {
    if (!groups.length) return;
    let on = 0;
    stops.forEach((s, i) => { if (s.getBoundingClientRect().top <= innerHeight * 0.5) on = i; });
    groups.forEach((g, i) => g.classList.toggle('is-on', i === on));
  }

  /* ---- Menu ---- */
  const menu = $('#menu');
  const menuBtn = $('[data-menu]');
  if (menu && menuBtn) {
    const label = $('span', menuBtn);
    const openText = label.textContent;
    const closeText = menuBtn.dataset.close;
    const setMenu = (open) => {
      root.classList.toggle('menu-open', open);
      menuBtn.setAttribute('aria-expanded', String(open));
      label.textContent = open ? closeText : openText;
      menu.setAttribute('aria-hidden', String(!open));
      menu.inert = !open;
      header.classList.remove('is-hidden');
      if (open) { const first = $('a', menu); first && first.focus(); } else { menuBtn.focus(); }
    };
    menu.inert = true;
    menuBtn.addEventListener('click', () => setMenu(!root.classList.contains('menu-open')));
    addEventListener('keydown', (e) => { if (e.key === 'Escape' && root.classList.contains('menu-open')) setMenu(false); });
    $$('a', menu).forEach((a) => a.addEventListener('click', () => { root.classList.remove('menu-open'); }));
  }

  /* ---- Greeting sticker: hello in every script ---- */
  const greetings = [
    ['Hello', 'en'], ['Ciao', 'it'], ['नमस्ते', 'hi'], ['नमस्कार', 'mr'],
    ['નમસ્તે', 'gu'], ['ਸਤ ਸ੍ਰੀ ਅਕਾਲ', 'pa'], ['こんにちは', 'ja'],
  ];
  $$('[data-greeting]').forEach((btn) => {
    const txt = $('.sticker__txt', btn);
    let i = Number(btn.dataset.start || 0), paused = false, timer;
    const show = (n, animate) => {
      i = (n + greetings.length) % greetings.length;
      const [t, lang] = greetings[i];
      const swap = () => { txt.textContent = t; txt.lang = lang; txt.classList.remove('is-out'); };
      if (animate && !reduce) { txt.classList.add('is-out'); setTimeout(swap, 180); } else swap();
    };
    show(i, false);
    const tick = () => { if (!paused && !d.hidden) show(i + 1, true); };
    if (!reduce) timer = setInterval(tick, 2500);
    btn.addEventListener('click', () => { show(i + 1, true); if (timer) { clearInterval(timer); timer = setInterval(tick, 2500); } });
    ['pointerenter', 'focus'].forEach((ev) => btn.addEventListener(ev, () => { paused = true; }));
    ['pointerleave', 'blur'].forEach((ev) => btn.addEventListener(ev, () => { paused = false; }));
  });

  /* ---- Index rows: open on hover, focus or tap ---- */
  $$('.index').forEach((index) => {
    const rows = $$('.row', index);
    const activate = (row) => rows.forEach((r) => r.classList.toggle('is-active', r === row));
    rows.forEach((row) => {
      const btn = $('button.row__btn', row);
      if (!btn) return;
      const set = (open) => { row.classList.toggle('is-open', open); btn.setAttribute('aria-expanded', String(open)); if (open) activate(row); };
      btn.addEventListener('click', () => {
        // A row the pointer just opened stays open on the first click; after that, clicks toggle.
        if (row.dataset.hover) { delete row.dataset.hover; set(true); return; }
        set(!row.classList.contains('is-open'));
      });
      if (fine) row.addEventListener('pointerenter', (e) => {
        if (e.pointerType !== 'mouse') return;
        if (!row.classList.contains('is-open')) { row.dataset.hover = '1'; set(true); } else activate(row);
      });
      btn.addEventListener('focus', () => activate(row));
    });
    if (index.classList.contains('index--exp') && rows[0]) {
      index.addEventListener('seen', () => { const b = $('button.row__btn', rows[0]); rows[0].classList.add('is-open', 'is-active'); b && b.setAttribute('aria-expanded', 'true'); });
    }
  });

  /* ---- Figures count up once ---- */
  $$('.figures').forEach((list) => {
    const nums = $$('[data-count]', list);
    list.addEventListener('seen', () => {
      if (reduce) return;
      nums.forEach((el) => {
        const end = Number(el.dataset.count), suffix = el.dataset.suffix || '';
        const t0 = performance.now(), dur = 1200;
        const step = (now) => {
          const p = Math.min(1, (now - t0) / dur);
          const eased = 1 - Math.pow(1 - p, 3);
          el.firstChild.textContent = Math.round(end * eased) + suffix;
          if (p < 1) requestAnimationFrame(step);
        };
        requestAnimationFrame(step);
      });
    });
  });

  /* ---- Card strip: drag sideways with a mouse ---- */
  $$('.strip').forEach((strip) => {
    let down = false, startX = 0, startLeft = 0, moved = false;
    strip.addEventListener('pointerdown', (e) => {
      if (e.pointerType !== 'mouse' || e.button !== 0) return;
      down = true; moved = false; startX = e.clientX; startLeft = strip.scrollLeft;
    });
    addEventListener('pointermove', (e) => {
      if (!down) return;
      const dx = e.clientX - startX;
      if (Math.abs(dx) > 4 && !moved) { moved = true; strip.classList.add('is-drag'); }
      if (moved) strip.scrollLeft = startLeft - dx;
    });
    addEventListener('pointerup', () => { down = false; strip.classList.remove('is-drag'); });
  });

  /* ---- Chalk trail on board panels (mouse only) ---- */
  if (fine && !reduce) {
    const TEXTY = 'h1,h2,h3,p,a,button,li,figure,form,input,textarea,label,img,svg';
    $$('.panel:not(.game)').forEach((panel) => {
      const c = d.createElement('canvas');
      c.className = 'chalk-layer';
      c.setAttribute('aria-hidden', 'true');
      panel.prepend(c);
      const ctx = c.getContext('2d');
      let w = 0, h = 0, dpr = 1, trail = [], kept = [], cur = null, raf = 0;

      const size = () => {
        dpr = Math.min(devicePixelRatio || 1, 2);
        w = c.clientWidth; h = c.clientHeight;
        c.width = Math.round(w * dpr); c.height = Math.round(h * dpr);
        ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
        paint();
      };
      const stroke = (a, b, alpha, width) => {
        ctx.strokeStyle = 'rgba(243,245,241,' + alpha + ')';
        ctx.lineWidth = width;
        ctx.beginPath(); ctx.moveTo(a.x + a.j, a.y - a.j); ctx.lineTo(b.x + b.j, b.y - b.j); ctx.stroke();
      };
      function paint() {
        raf = 0;
        ctx.clearRect(0, 0, w, h);
        ctx.lineCap = 'round'; ctx.lineJoin = 'round';
        kept.forEach((s) => { for (let i = 1; i < s.length; i++) stroke(s[i - 1], s[i], 0.8, 2.4 + s[i].j * 0.5); });
        const now = performance.now();
        trail = trail.filter((p) => now - p.t < 1500);
        for (let i = 1; i < trail.length; i++) {
          const a = trail[i - 1], b = trail[i];
          if (b.brk) continue;
          stroke(a, b, 0.55 * (1 - (now - b.t) / 1500), 2 + b.j * 0.5);
        }
        if (trail.length) raf = requestAnimationFrame(paint);
      }
      const point = (e, brk) => {
        const r = c.getBoundingClientRect();
        return { x: e.clientX - r.left, y: e.clientY - r.top, t: performance.now(), j: Math.random() * 1.2 - 0.6, brk };
      };
      let inside = false;
      panel.addEventListener('pointerenter', () => { inside = false; });
      panel.addEventListener('pointermove', (e) => {
        if (e.pointerType !== 'mouse') return;
        const p = point(e, !inside);
        const prev = cur ? cur[cur.length - 1] : trail[trail.length - 1];
        // A jump (pointer left and came back elsewhere) starts a new line instead of joining the dots.
        if (prev && Math.hypot(p.x - prev.x, p.y - prev.y) > 90) { if (cur) { cur = [p]; kept.push(cur); return; } p.brk = true; }
        inside = true;
        if (cur) cur.push(p); else trail.push(p);
        if (!raf) raf = requestAnimationFrame(paint);
      });
      panel.addEventListener('pointerleave', () => { inside = false; cur = null; });
      panel.addEventListener('pointerdown', (e) => {
        if (e.pointerType !== 'mouse' || e.button !== 0 || e.target.closest(TEXTY)) return;
        e.preventDefault();
        cur = [point(e)]; kept.push(cur);
      });
      addEventListener('pointerup', () => { cur = null; });
      new ResizeObserver(size).observe(panel);
    });
  }

  /* ---- The hello board: rub the board like a chalk rubbing to find seven hellos ---- */
  const game = $('[data-game]');
  if (game) {
    const FONT = {
      en: '700 {s}px "Bricolage Grotesque"', it: '700 {s}px "Bricolage Grotesque"',
      hi: '600 {s}px "Noto Sans Devanagari"', mr: '600 {s}px "Noto Sans Devanagari"',
      gu: '600 {s}px "Noto Sans Gujarati"', pa: '600 {s}px "Noto Sans Gurmukhi"', ja: '600 {s}px "Noto Sans JP"',
    };
    // Where each hello sits: [x %, y %, size, tilt in degrees], for wide and narrow boards.
    const WIDE = [[24, 58, 1, -4], [66, 22, 0.85, 5], [54, 44, 0.95, 3], [82, 58, 0.8, -3], [46, 75, 0.9, -5], [20, 79, 0.62, 2], [76, 83, 0.72, 4]];
    const NARROW = [[30, 42, 1, -4], [76, 48, 0.95, 5], [34, 55, 0.95, 3], [64, 62, 0.9, -3], [30, 69, 0.95, -5], [58, 76, 0.72, 2], [36, 83, 0.8, 4]];
    const CHALK = '#F3F5F1';
    const CELL = 12;

    const items = $$('[data-game-list] li', game).map((li) => {
      const [word, name] = $$('span', li);
      return { text: word.textContent, lang: word.lang, name: name.textContent, found: false };
    });
    const countEl = $('[data-game-count]', game), sticker = countEl.parentNode;
    const intro = $('[data-game-intro]', game), doneEl = $('[data-game-done]', game);

    const canvas = d.createElement('canvas');
    canvas.className = 'game__canvas';
    canvas.setAttribute('aria-hidden', 'true');
    const names = d.createElement('div');
    names.className = 'game__names';
    names.setAttribute('aria-hidden', 'true');
    game.prepend(canvas);
    game.append(names);
    items.forEach((it) => {
      it.label = d.createElement('span');
      it.label.className = 'game__name util';
      it.label.textContent = it.name;
      names.append(it.label);
    });

    const ctx = canvas.getContext('2d');
    const layer = () => d.createElement('canvas');
    const strokes = layer(), words = layer(), kept = layer(), tmp = layer();
    const sx = strokes.getContext('2d'), wx = words.getContext('2d'), kx = kept.getContext('2d'), tx = tmp.getContext('2d');
    let w = 0, h = 0, dpr = 1, cols = 0, grid = new Uint8Array(0), last = null, raf = 0, demoing = false;

    const drawWord = (c, it) => {
      c.save();
      c.translate(it.cx, it.cy); c.rotate(it.rot);
      c.font = FONT[it.lang].replace('{s}', it.size);
      c.textAlign = 'center'; c.textBaseline = 'middle'; c.fillStyle = CHALK;
      c.fillText(it.text, 0, 0);
      c.restore();
    };
    const render = () => {
      raf = 0;
      ctx.setTransform(1, 0, 0, 1, 0, 0);
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      ctx.globalAlpha = 0.13; ctx.drawImage(strokes, 0, 0);           // the faint scribble itself
      tx.setTransform(1, 0, 0, 1, 0, 0);
      tx.globalCompositeOperation = 'source-over';
      tx.clearRect(0, 0, tmp.width, tmp.height); tx.drawImage(words, 0, 0);
      tx.globalCompositeOperation = 'destination-in'; tx.drawImage(strokes, 0, 0);
      ctx.globalAlpha = 0.95; ctx.drawImage(tmp, 0, 0);                // hidden words, only where rubbed
      ctx.globalAlpha = 1; ctx.drawImage(kept, 0, 0);                  // words already found
    };
    const queue = () => { if (!raf) raf = requestAnimationFrame(render); };

    const layout = () => {
      dpr = Math.min(devicePixelRatio || 1, 2);
      w = canvas.clientWidth; h = canvas.clientHeight;
      [canvas, strokes, words, kept, tmp].forEach((c) => { c.width = Math.round(w * dpr); c.height = Math.round(h * dpr); });
      [sx, wx, kx].forEach((c) => c.setTransform(dpr, 0, 0, dpr, 0, 0));
      cols = Math.ceil(w / CELL); grid = new Uint8Array(cols * Math.ceil(h / CELL)); last = null;
      const spots = w < 700 ? NARROW : WIDE;
      const base = w < 700 ? w * 0.125 : Math.max(48, Math.min(104, w * 0.075));
      items.forEach((it, i) => {
        const [px, py, scale, tilt] = spots[i];
        it.cx = w * px / 100; it.cy = h * py / 100; it.size = Math.round(base * scale); it.rot = tilt * Math.PI / 180;
        wx.font = FONT[it.lang].replace('{s}', it.size);
        it.bw = wx.measureText(it.text).width; it.bh = it.size * 0.9;
        drawWord(it.found ? kx : wx, it);
        it.label.style.left = it.cx + 'px';
        it.label.style.top = (it.cy + it.size * 0.62) + 'px';
      });
      queue();
    };

    const update = () => {
      const n = items.filter((it) => it.found).length;
      countEl.textContent = n;
      const all = n === items.length;
      intro.hidden = all; doneEl.hidden = !all;
    };
    const find = (it) => {
      if (it.found) return;
      it.found = true;
      drawWord(kx, it);
      it.label.classList.add('is-found');
      sticker.classList.remove('is-bump'); void sticker.offsetWidth; sticker.classList.add('is-bump');
      update(); queue();
    };
    const check = () => {
      items.forEach((it) => {
        if (it.found) return;
        const x0 = Math.floor((it.cx - it.bw * 0.46) / CELL), x1 = Math.ceil((it.cx + it.bw * 0.46) / CELL);
        const y0 = Math.floor((it.cy - it.bh * 0.5) / CELL), y1 = Math.ceil((it.cy + it.bh * 0.5) / CELL);
        let hit = 0, total = 0;
        for (let y = y0; y < y1; y++) for (let x = x0; x < x1; x++) { total++; if (grid[y * cols + x]) hit++; }
        if (total && hit / total >= 0.55) find(it);
      });
    };
    const cover = (x, y, r) => {
      const n = Math.ceil(r / CELL);
      const cx = Math.floor(x / CELL), cy = Math.floor(y / CELL);
      for (let j = -n; j <= n; j++) for (let i = -n; i <= n; i++) {
        const gx = cx + i, gy = cy + j;
        if (gx >= 0 && gx < cols && gy >= 0 && i * i + j * j <= n * n) grid[gy * cols + gx] = 1;
      }
    };
    // One pass of the side of a chalk stick: a band of thin, uneven streaks.
    const rub = (a, b, counts) => {
      const dx = b.x - a.x, dy = b.y - a.y, len = Math.hypot(dx, dy) || 1;
      const nx = -dy / len, ny = dx / len;
      sx.strokeStyle = CHALK; sx.lineCap = 'round';
      for (let k = -3; k <= 3; k++) {
        const o = k * 8 + (Math.random() * 4 - 2);
        sx.lineWidth = 5 + Math.random() * 5;
        sx.beginPath(); sx.moveTo(a.x + nx * o, a.y + ny * o); sx.lineTo(b.x + nx * o, b.y + ny * o); sx.stroke();
      }
      if (counts) {
        for (let t = 0; t <= len; t += CELL) cover(a.x + dx * t / len, a.y + dy * t / len, 30);
        check();
      }
      queue();
    };
    const at = (e) => { const r = canvas.getBoundingClientRect(); return { x: e.clientX - r.left, y: e.clientY - r.top }; };
    const moveTo = (p) => {
      if (last && Math.hypot(p.x - last.x, p.y - last.y) < 120) rub(last, p, true);
      last = p;
    };
    game.addEventListener('pointerenter', () => { last = null; });
    game.addEventListener('pointerleave', () => { last = null; });
    game.addEventListener('pointercancel', () => { last = null; });
    game.addEventListener('pointermove', (e) => { if (!demoing) moveTo(at(e)); });
    game.addEventListener('pointerdown', (e) => {
      if (e.target.closest('a, button')) return;
      // A tap leaves a short scribble, so touch screens can play without dragging.
      const p = at(e);
      for (let i = 0; i < 3; i++) rub({ x: p.x - 34, y: p.y - 16 + i * 16 }, { x: p.x + 34, y: p.y - 10 + i * 16 }, true);
      last = p;
    });

    $('[data-game-all]', game).addEventListener('click', () => items.forEach(find));
    $('[data-game-wipe]', game).addEventListener('click', () => {
      items.forEach((it) => { it.found = false; it.label.classList.remove('is-found'); });
      update(); layout();
    });

    // Show the trick once: a quick scribble across part of the first hello.
    game.addEventListener('seen', () => {
      if (reduce || items[0].found) return;
      const it = items[0], t0 = performance.now();
      let prev = null;
      demoing = true;
      const step = (now) => {
        const p = Math.min(1, (now - t0) / 800);
        const pt = { x: it.cx - it.bw * 0.5 + it.bw * p, y: it.cy - it.bh * 0.12 + Math.sin(p * Math.PI * 5) * it.bh * 0.22 };
        if (prev) rub(prev, pt, false);
        prev = pt;
        if (p < 1) requestAnimationFrame(step); else demoing = false;
      };
      requestAnimationFrame(step);
    });
    game.dataset.io = '';
    io.observe(game);

    let lastW = 0;
    const ready = () => {
      layout();
      new ResizeObserver(() => { if (canvas.clientWidth !== lastW) { lastW = canvas.clientWidth; layout(); } }).observe(game);
    };
    Promise.all(items.map((it) => d.fonts.load(FONT[it.lang].replace('{s}', 40), it.text))).then(ready, ready);
  }

  /* ---- Contact form ---- */
  const form = $('[data-form]');
  if (form) {
    const sent = $('[data-sent]', form.parentNode), failed = $('[data-failed]', form.parentNode);
    const fields = $$('.field', form);
    const valid = (f) => {
      const input = $('input, textarea', f), err = $('.field__err', f);
      const v = input.value.trim();
      const ok = input.type === 'email' ? /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v) : v.length > 0;
      err.hidden = ok; input.setAttribute('aria-invalid', String(!ok));
      return ok;
    };
    fields.forEach((f) => $('input, textarea', f).addEventListener('blur', () => { if ($('input, textarea', f).getAttribute('aria-invalid') === 'true') valid(f); }));
    form.addEventListener('submit', async (e) => {
      e.preventDefault();
      sent.hidden = true; failed.hidden = true;
      const results = fields.map(valid);
      if (results.includes(false)) { $('[aria-invalid="true"]', form).focus(); return; }
      if (form.elements.company && form.elements.company.value) { sent.hidden = false; return; } // honeypot
      // The message goes to a Google Form behind this form. Google does not let the page read
      // its reply, so "sent" means the browser handed the message over without a network error.
      const { action, entryName, entryEmail, entryMessage } = form.dataset;
      try {
        if (!action) throw new Error('No Google Form connected yet');
        const body = new URLSearchParams();
        body.append(entryName, form.elements.name.value.trim());
        body.append(entryEmail, form.elements.email.value.trim());
        body.append(entryMessage, form.elements.message.value.trim());
        await fetch(action, { method: 'POST', mode: 'no-cors', body });
        form.reset(); sent.hidden = false; sent.classList.add('is-in');
      } catch (err) { failed.hidden = false; }
    });
  }

  onScroll();
})();
