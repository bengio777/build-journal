# Kite the Planet: World Map Hover-Bridge Fix
## Build Journal Entry — Quick

**Builder:** Ben Giordano
**Date:** 2026-04-29
**Repo:** bengio777/KTP_V01
**Tier:** Quick

---

## 1. Problem Statement

On the homepage and `/spots` world map, hovering a spot tile (e.g. Fuerteventura) showed a dispatch card with reliability, skill floor, coords, and an OPEN GUIDE CTA. Moving the cursor from the tile toward the OPEN GUIDE button dismissed the card mid-traverse, before the click could land. Logged as Notion KTP Task Tracker `351fb3a7-cad4-81ed-a91f-cbbffe60fcf0`.

Root cause: classic hover-bridge bug. The pin's `onMouseLeave` handler nulled `activeSlug` immediately, and the `DispatchCard` overlay — sitting 14px offset from the pin via a `translateX/Y(±14px)` transform — had no hover handlers of its own. The unhandled gap between pin and card always triggered dismissal.

## 2. Solution

Single file change in `app/components/WorldMap.tsx`. Implemented option (a) from the briefing — shared hover state with a small grace timer:

- Added `closeTimerRef` + memoized `cancelClose` / `scheduleClose` / `openSlug` callbacks at the `WorldMap` root.
- Pin `onMouseLeave` now calls `scheduleClose` (150ms grace) instead of zeroing state instantly.
- `DispatchCard` accepts and wires `onMouseEnter={cancelClose}` / `onMouseLeave={scheduleClose}` on its outer `<div>`, which already had `pointer-events-auto`.
- Added `useEffect` cleanup to clear any pending timer on unmount.
- Constant: `HOVER_CLOSE_DELAY_MS = 150`.

Verified live on the dev server via Playwright through four phases: pin hover opens card → pin leave + card hover within 150ms keeps card mounted past the original close deadline → OPEN GUIDE link reachable while held → card dismisses ~150ms after cursor leaves the card. Pin-to-pin swap and unmount cleanup also exercised.

After shipping, added a Vitest regression suite (`__tests__/components/WorldMap.test.tsx`, 4 tests, ~67ms wall) using fake timers and React-friendly `mouseover` / `mouseout` events. The suite locks in: card opens on hover, survives pin→card traversal, dismisses after card leave, swaps targets when moving from pin A to pin B mid-grace.

Deploy + push: `vercel --prod` aliased to `https://www.kitetheplanet.com`, then commits pushed to `main` (single atomic operation per project CLAUDE.md). Notion task marked Done with Date Completed = 2026-04-29.

## 3. Lessons Learned

- **React's `onMouseEnter` / `onMouseLeave` don't fire from synthetic `mouseenter` / `mouseleave` `dispatchEvent` calls.** React delegates via the bubbling pair `mouseover` / `mouseout`. First Playwright verification attempt got `cardOpenedOnPinEnter: false` — wasted a round trip. Switched to `mouseover` / `mouseout` and all four phases passed. The same trick made the Vitest suite work without `@testing-library/user-event`. Worth remembering for any future React event-driven test.

- **`HOVER_CLOSE_DELAY_MS = 150` is a usability constant, not a magic number.** It bridges the 14px transform gap at any reasonable cursor speed without leaving stale cards on the screen when the user pans away. If the offset transform changes, this constant should be revisited — the regression test asserts behavior, not geometry, so a too-large offset could regress silently.

- **Grace-timer + shared handlers > invisible bridge element > co-anchored card.** The bridge-element approach pollutes the DOM and adds hit-testing complexity; co-anchoring requires rewriting the layout math. The grace-timer pattern is ~20 lines and has no visual side effects.

## 4. Commit Log

| Hash | Date | Description |
|------|------|-------------|
| d3d9e68 | 2026-04-29 | fix: world map hover card stays open during pin→card traversal |
| 4910b5b | 2026-04-29 | test: regression coverage for WorldMap hover bridge |
