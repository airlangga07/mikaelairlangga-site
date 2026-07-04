# Handoff — v1.1.0 "Generative landing page"

> Implementation brief for the repo's coding agent. Groomed in homebase
> (`/obsidian:project-work`) with an independent design review **and** a Codex engineering
> review. This document is the single on-ramp: it captures the feature, the reviewed
> decisions, the build order, and the guardrails. The authoritative per-story acceptance
> criteria live on the GitHub issues linked below.

## What we're building

Turn the static landing page into a **generative** one. On every page **load** — and whenever
the visitor **clicks empty space** (clicking the real links must still follow them; there is
**no visible "Randomize" control** anywhere) — the page picks a fresh, coherent **theme** and
**cross-fades** to it (~300–400 ms, so it reads as an intentional restyle, not a glitch).

The **centered layout never changes**: name centered, tagline below, GitHub/Email centered on
the second row. Only the *look* changes.

### Randomized dimensions
1. **Background color** — from a curated palette set.
2. **Background animation** — from a small library of types (the current gradient orbs is one).
3. **Name** — font family + color + a subtle, one-shot per-letter "glitch" (stays fully legible).
4. **Tagline + foreground text color** — coordinated with the background.
5. **GitHub & email link text** — varied wording, occasionally the raw values
   (`github.com/airlangga07`, the email address); `href`s always valid.

## Non-negotiable principles (from the two reviews)

- **Randomize the theme as a curated *unit*, never 5 independent dice.** `pickTheme()` returns
  one coherent theme; enforce a "loudness budget" (≤ 2 "loud" dimensions per load) so every
  combination looks hand-picked.
- **Contrast is computed, never assumed.** No theme may render below **WCAG AA (≥ 4.5:1)** for
  the name/body text. Enforce with a validator + **bounded re-roll (~20 attempts) → a fixed,
  guaranteed-readable fallback theme.** This lives in the spine (Story #14) so an unreadable
  theme is impossible by construction.
- **`prefers-reduced-motion`**: actually **stop** the animation loops (don't just hide via CSS),
  render a static frame, disable the glitch, and **react to live media-query changes**.
- **The name's identity is fixed**: `<h1>` text stays "Mikael Airlangga"; `<title>`, link
  `href`s, and any OG metadata stay stable. Randomize *presentation* and *visible label text*
  only.

## Hard constraints (repo rules — do not break)

- **No build step, no backend, no database, no external CDN / network fetches.** Everything is
  hand-authored static files under `site/`. Fonts must be local (system stacks now — see #17).
- `linux/arm64` compatible; port **3000** fixed (`cloudflared` expects `http://web:3000`).
- **`/healthz`** returns `{"status":"ok"}` with `Content-Type: application/json` — never remove.
- Never commit `.env`.
- **Single-file is preferred** (`site/index.html`, all CSS/JS inline). A local same-origin split
  (`site/app.js`, `site/styles.css`) is acceptable *only* if it stays build-free and fetches
  nothing external. Do **not** let "generative" turn into a mini frontend framework.

## Build order (issues)

Epic: **[#13](https://github.com/airlangga07/mikaelairlangga-site/issues/13)**. Build in order —
each issue body has the full `Given/When/Then` acceptance criteria:

1. **[#14](https://github.com/airlangga07/mikaelairlangga-site/issues/14) — Theme engine, safe by
   construction (the spine).** Theme object shape, `pickTheme()`/`applyTheme()` via CSS custom
   properties, cross-fade, contrast validator + bounded re-roll + fallback, load + background-click
   reshuffle (pointer-move threshold; ignore `<a>`/headings/tagline/controls/selection; keyboard
   `R`), reduced-motion loop-stop, single-active-renderer lifecycle (`cancelAnimationFrame`,
   `AbortController`, clear nodes, pause on `document.hidden`), cursor-only click affordance.
   **Ships with the current colors + orbs/particles as theme #1 → zero visual/layout regression.**
2. **[#15](https://github.com/airlangga07/mikaelairlangga-site/issues/15) — Readable palettes +
   text/link-label variants.** 8–12 curated palettes (designed ≥ 7:1, source-level AA assertion),
   mix of dark + light, radial scrim floor, curated GitHub/Email label *pairs* incl. occasional
   raw values (verified at 320px).
3. **[#16](https://github.com/airlangga07/mikaelairlangga-site/issues/16) — Animation library.**
   Renderer interface `start(container,palette)/setPalette(palette)/stop()`; keep orbs+particles;
   add 3 cheap types (aurora-mesh [CSS], flow-field [canvas, capped], dot-grid [CSS]); palette-
   tinted; reduced-motion static frame.
4. **[#17](https://github.com/airlangga07/mikaelairlangga-site/issues/17) — Name typography +
   glitch.** Hybrid font pool: distinct **system-font stacks** now, structured so self-hosted
   woff2 can drop in later (self-hosting deferred). No layout shift on swap. Subtle one-shot micro
   RGB-split glitch on 1–2 letters (~400 ms), disabled under reduced-motion.
5. **[#18](https://github.com/airlangga07/mikaelairlangga-site/issues/18) — QA, a11y hardening &
   release.** Extend `tests/test.sh` (adds **"no external resource fetches"** assertion);
   manual browser QA checklist; then the versioned release (see below).

**Deferred to v1.2+** (do not build now): seeded/shareable theme URLs (`?seed=`), auto-cycle
mode, a 4th+ animation (starfield), WebGL/Three.js, screenshot-regression matrix, self-hosted
woff2 fonts.

## Testing

- `bash tests/test.sh` runs the curl-based integration checks (already covers `/` 200, `/healthz`
  body + `application/json`, 404, and root contains "Mikael Airlangga"). #18 adds the
  no-external-fetch guard.
- A static `test.sh` **cannot** prove the interactive/visual behavior (click-vs-link semantics,
  computed contrast over animated pixels, reduced-motion actually stopping loops, canvas cleanup,
  320px fit, FOUC). Cover those with the manual browser QA checklist in #18. A lightweight
  Playwright/Chrome smoke is optional, **not required** for v1.1.0.

## Release & deploy (outward — confirm before doing)

- Bump the version and push a **`v1.1.0`** git tag → CI (`.github/workflows/ci.yml`) builds and
  pushes the multi-arch image to GHCR.
- Deploy on `rpi3` by updating the **pinned digest** in the host's `docker-compose.yml`
  (`~/apps/mikaelairlangga-site`), then `docker compose pull web && docker compose up -d web`;
  verify `curl localhost:3001/healthz` → `{"status":"ok"}`.
- Progress is pulled back into the Obsidian roadmap by `/obsidian:project-sync` — no manual
  roadmap edits needed.

## Known drift (not fixed here — flag before relying on it)

- The repo `docker-compose.yml` / `deploy.sh` use a **tag** (`WEB_TAG:-latest`), but the **live
  Pi** `docker-compose.yml` pins the image by **digest**. The Pi's compose was edited in place.
  Reconcile deliberately when you next touch deploy — don't assume `./deploy.sh` reproduces the
  running config.
