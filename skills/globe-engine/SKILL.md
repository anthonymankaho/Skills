---
name: globe-engine
description: Use when building or porting a self-contained single-HTML dashboard whose centerpiece is a procedural 3D globe (three.js, no photo textures) that must open from file:// with no server, network, or CDN - covers the three embedding contracts (blob-module import, inert JSON data islands, CSS-token theming), the globe architecture, and headless render verification. Triggers on "3D earth", "globe dashboard", "offline HTML", "file:// single file", three.js in one file.
---

# Globe Engine (offline single-file 3D dashboards)

## Overview

A wall-dashboard 3D earth packed into ONE HTML that double-clicks open from `file://`.
The whole approach rests on three embedding contracts; breaking any one of them is the
usual cause of "works in dev, blank when I email it".

## The three embedding contracts

**1. ESM library → blob module, never `<script src>`.** Modern three.js ships ESM only.
Embed the source as an inert JSON string, revive at runtime:
```js
const src = JSON.parse(document.getElementById('gpr-three').textContent);
const url = URL.createObjectURL(new Blob([src], { type: 'text/javascript' }));
const THREE = await import(url);   // blob import WORKS from file:// pages
```
Why JSON-in-a-tag: browser never executes it; `JSON.stringify` neutralizes every
`</script>` hazard; no bundler needed. Memoize the promise; load lazily so panels
paint before the 3D work. `fetch()` of local files is dead on file:// — never reach.

**2. Assets → inert `<script type="application/json">` islands.** Land geometry
(world-atlas land-110m TopoJSON, ~55 KB) and the row data both ride as JSON islands,
`JSON.parse(el.textContent)` at boot. Before shipping, scan the built file: any payload
containing `</script` or `<!--` must be escaped or the page self-destructs.

**3. Colors → CSS custom properties read live.** Every globe color/alpha is a
`--globe-*` token; the theme flip only rewrites uniform **values** (`retheme()`), so
there is no shader recompile and no geometry rebuild. Light theme is tuned by tokens
(less atmosphere alpha, deeper land inks), not a second code path.

## Globe anatomy (what makes it read as a planet, in payoff order)

1. **Coastline line pass** over a dot field — one LineSegments, drop segments whose
   endpoints jump >170° longitude (antimeridian seams, not coasts).
2. **Terminator from a world-space sun**: `dot(normal, uSun)` smoothstepped; the sun
   vector does NOT rotate with the earth; one full turn per ~90 s → the sweep is a clock.
3. **Tight Fresnel rim** (1.035R shell, high exponent) — a wide halo reads as soap bubble.
4. Land dots on an **equal-area** lat/lon lattice (fixed lon step piles points at poles);
   sample via land mask rasterized once to an offscreen canvas (`fill('evenodd')`,
   alpha>90 hit test) instead of point-in-polygon on thousands of candidates.
   ~1/3 of dots carry a stable pseudo-random city-light weight, latitude-damped.
5. Entity markers as CanvasTexture sprites + ping rings; click → Raycaster on
   `markGroup` → filter callback. Off-screen hosts pause via IntersectionObserver;
   `visibilitychange` stop/start; clamp `Math.max(1,w)` before setting camera.aspect.

## Verification (no human, no browser)

Headless Edge on the file:// URL:
```
msedge --headless=new --disable-gpu --virtual-time-budget=7000 --dump-dom "file:///...html"
```
- `--dump-dom`: assert real numbers appear (KPI values, row counts) — proves boot + render.
- `--screenshot --window-size=1920,1080`: pixel proof the globe drew (SwiftShader renders
  WebGL even with `--disable-gpu`).
- `?lang=`/`?fixture=` URL params make both language states testable headless.
- Cross-check headline aggregates against an INDEPENDENT recomputation from the raw
  seed (a tiny `expected.mjs`), not against the page's own math.

## Common mistakes

- CDN `<script src>` or import maps → blank page offline. Vendored blobs only.
- `fetch('./x.json')` on file:// → CORS-blocked; islands only.
- Raw library text in a `<script>` tag → one `</script>` in a string literal kills the page.
- Theme colors baked into JS consts → dark smear on light theme; tokens + `retheme()`.
- Trusting that "the page opened" = working: run the headless dump-dom gate every rebuild.

## Reference

Production example: `Desktop\Global Purchase Report Claude\3D Earth Dashboard\build\`
(`src/globe.js`, `src/core.js`, `src/main.js`, `build.mjs`) — same architecture shipped at
14.4 MB / 56,370 rows / dark+light / zh+EN. See [[excel-to-interactive-html-report]] for
the tabular-report family this complements.
