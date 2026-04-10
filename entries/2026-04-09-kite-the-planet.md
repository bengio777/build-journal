# KTP — Build Journal
**Date:** 2026-04-09
**Tier:** Standard
**Type:** Retrospective
**Repos touched:** kite-the-planet, kite-school-scraper (new), airline-baggage-scraper (new)

---

## What Was Built

### 1. Trip Builder — 5 Bug Fixes
File: `app/trip-builder/TripBuilderClient.tsx` — committed in `63331c4`

- **Progress dots bug** — style dot was lighting up before any style was selected (`>= 0` → `> 0`)
- **Iframe loading spinner** — spot guide modal now shows spinner until iframe loads
- **Comparison cost label** — added `/ person` label to comparison panel cost display
- **Edit in-place** — history card labels and progress dots are now clickable from results; selecting jumps back to that step and returns to results after answering; editing banner shown in step card
- **8-spot comparison** — removed 3-column cap, added overflow-x-auto, responsive column widths, capped at 8 selections

### 2. GMaps Scraper — Field Coverage Improvements
File: `tools/gmaps-scraper/scrape_kite_schools.py` + `test_15_schools.py`

Iterative test-driven development on `test_15_schools.py` to diagnose and fix:
- **Multi-h1 problem** — results list `<h1>` ("Results") loaded before detail panel `<h1>`; fixed by scanning all h1s + URL-decoded name fallback
- **Lat/lng accuracy** — `@lat,lng` is viewport center, not place; fixed by prioritizing `!3d!4d` coords from URL
- **review_count = 4** — regex was grabbing first number in string ("4" from "4.8 stars"); fixed with `([\d,]+)\s+reviews?/i`
- **hours_summary = "?"** — selector was matching Unicode clock emoji; fixed with JS span text scan
- **booking_options** — JS walk from "Booking options" heading; 47% coverage confirmed
- Final test coverage: 15/15 on all core fields

### 3. kite-school-scraper — Standalone Repo
Repo: `bengio777/kite-school-scraper` (private) · Local: `~/Projects/kite-school-scraper/`

Extracted from KTP `tools/gmaps-scraper/`. Simplified .env, headless flag, launchd plist (Sunday 2am), RUN.md.

### 4. airline-baggage-scraper — Standalone Repo
Repo: `bengio777/airline-baggage-scraper` (private) · Local: `~/Projects/airline-baggage-scraper/`

Extracted from KTP `tools/baggage-scraper/`. 93 airlines, 6 layers. Simplified .env, launchd plist (Sunday 3am), RUN.md.

### 5. Scraper Data Quality Fix
3,640 "Results" rows diagnosed and cleared. Bad shard CSVs (s0/s1/s2) deleted, checkpoints reset. Re-run queued.

---

## Commits

| Hash | Repo | Description |
|------|------|-------------|
| `63331c4` | kite-the-planet | trip builder updates, bot improvements, gmaps scraper |
| `e6bd458` | kite-the-planet | Add living E2E test checklist |
| `34a7d0a` | kite-school-scraper | Rename MAC-MINI-DEPLOY.md to RUN.md |
| `9a606ef` | kite-school-scraper | Add Mac mini deployment instructions |
| `d599748` | kite-school-scraper | Initial commit: kite school scraper pipeline |
| `3a71bcb` | airline-baggage-scraper | Initial commit: airline baggage scraper pipeline |

---

## Lessons

- Test scraper output quality before full production runs — add `grep -c "^Results,"` as a post-merge gate
- About tab fields unreliable at scale — dropped from scope
- Shard files accumulate bad data silently — checkpoint system doesn't protect against pre-filter writes
