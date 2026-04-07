# Kite the Planet: Major Platform Expansion
## Build Journal Entry — Full

**Builder:** Ben Giordano
**Date:** 2026-04-06
**Repo:** bengio777/KTP_V01
**Status:** In Progress
**Tier:** Full

---

## Summary

Six independent workstreams across one session (48 commits): (1) Spot list redesign — replaced card grids on both Explore and Settings with a compact country-row chip layout. (2) 40 new shell spot pages across GB, Ireland, Netherlands, Brazil South, Australia, New Zealand, and Iceland. (3) Inline action panel — chips now expand in-place instead of opening a displaced map panel. (4) Global input text fix — OS dark mode was cascading white text into all form inputs via CSS variable inheritance; fixed globally with an unlayered rule in globals.css. (5) Baggage scraper expanded from 93 → 183 airlines with a Playwright-based URL discovery engine and autonomous run_canonical.sh pipeline. (6) Trip builder completed — gear config step, per-person cost toggle, save trip, carry-on policy display, correct cost math, and gear estimate labelling.

---

## Key Changes

### Spot List Redesign
Both `/spots` (Explore) and `/settings` (My Spots) replaced card grids with compact country-row chip layouts. Each continent is one section; each country is one row with spot chips flowing right. Color-coded: green = visited, violet = wishlist, gray = unlogged.

### 40 New Shell Spot Pages
- **Great Britain (7):** Gwithian/Hayle, Rhosneigr, Hayling Island, Tiree, West Wittering, Camber Sands, Bamburgh
- **Ireland (4):** Dollymount Strand, Brandon Bay, Ballyheigue Bay, Strandhill/Sligo
- **Netherlands (6):** Scheveningen, Zandvoort, Workum, Maasvlakte, IJmuiden, Grevelingenmeer
- **Brazil South (6):** Cabo Frio, Arraial do Cabo, Laguna, Garopaba, Ilha do Mel, Imbituba
- **Australia (10):** Geraldton, Noosa, Gold Coast, Port Noarlunga, Cape Paterson, Bowen, Safety Beach, St Kilda/Elwood, Altona, Torquay
- **New Zealand (6):** Takapuna/Auckland, Omaha Beach, Ruakaka, Paraparaumu, Kite Beach/Westshore, Nelson
- **Iceland (1):** Reykjavik/Seltjarnarnes (only documented kite spot — others rejected without evidence)

### Inline Action Panel
`activeListSlug` state tracks open chip. Action row (visited / wishlist / remove / review) renders inline below chip. Map panel reserved for map pin clicks only.

### Global Input Fix
Root cause: `@media (prefers-color-scheme: dark)` → `--foreground: #ededed` → `body { color: white }` cascades into inputs. Fixed with unlayered rule outside any `@layer` in globals.css: `input, textarea, select { color: #171717; background-color: #ffffff }`. Unlayered styles beat Tailwind utilities in the cascade.

### Baggage Scraper Expansion
- 93 → 183 airlines via Playwright URL discovery engine
- `run_canonical.sh`: spawns `claude --dangerously-skip-permissions -p` per airline, max 5 concurrent (PID semaphore), logs per IATA, pass/fail summary + retry command
- Removed Anthropic API from process_canonical — replaced with rules-based extraction
- SerpApi IATA normalization, live EUR→USD exchange rate

### Trip Builder Completion
- Gear config step: items per person + packed weight
- Per-person cost toggle
- Save trip → `saved_trips` Supabase table
- Carry-on policy on flight cards
- Cost math fixed for all group/solo/bag combos
- Gear estimates in amber labelled "est.", excluded from totals when uncertain
- "Fee unknown" instead of fabricated $65 for missing airline data
- Gateway airport remapping with bundled connection booking

### Additional
- Gear locker: bare weight column, year/weight filters, category breakdown, kite weight estimates for 8 blocked brands
- Airline loyalty program tracking with gear fee savings detection
- Dynamic homepage stats (gear + airline counts from Supabase)
- Global contrast enforcement CSS for dark surfaces

---

## Lessons

- Stale task tracker blockers ("Requires user_saved_spots migration") can misdirect investigation — always verify against actual code state.
- `--dangerously-skip-permissions` enables fully autonomous Claude Code batch pipelines.
- Never suggest kite spots without documented evidence. Mullaghmore (big wave surf), Darwin (crocs), and undocumented Iceland spots were correctly rejected.
- Unlayered CSS beats Tailwind for globals that must win regardless of utility classes.

---

## Commit Log (48 commits)

| Hash | Date | Description |
|------|------|-------------|
| b59f8fa | 2026-04-06 | fix(globals): force dark text on all inputs/textareas/selects |
| 8ee0dc9 | 2026-04-06 | fix(settings): explicit text-gray-900 + bg-white on inputs and selects |
| 3484685 | 2026-04-06 | feat(spots): add 7 shell spot pages — New Zealand (6) + Iceland (1) |
| 3e939db | 2026-04-06 | feat(spots): add 33 shell spot pages — GB, Ireland, Netherlands, Brazil South, Australia |
| 198325f | 2026-04-06 | fix(spots): inline action panel on list chips |
| 0ced91b | 2026-04-06 | refactor(explore): replace card grid with compact country-row chip layout |
| ee11c37 | 2026-04-06 | refactor(spots): replace card grid with compact country-row chip layout |
| bbb74cd | 2026-04-06 | Expand all remaining raw airport codes in trip builder |
| 86bf455 | 2026-04-06 | Fix badge/card contrast across all 45 spot pages |
| d538c30 | 2026-04-06 | Global contrast enforcement: light-bg elements always render readable text |
| 72bbd47 | 2026-04-06 | Force class-based dark mode site-wide |
| 1f125b4 | 2026-04-06 | Trip builder UX: airline names, compact filters, spot guide modal |
| 7ef158d | 2026-04-06 | Show city names for layover airports on flight cards |
| 74e7d61 | 2026-04-06 | feat: gateway airport remapping with bundled connection booking |
| 52da1fc | 2026-04-06 | Expand baggage scraper to 183 airlines (58 new) with Playwright-based discovery engine |
| 4fdd11e | 2026-04-06 | Add airline loyalty program tracking with gear fee savings detection |
| 9394ca6 | 2026-04-06 | feat: gear locker Phase 1+2 — bare weight col, year/weight filters, category breakdown |
| 04a492e | 2026-04-06 | Fix pipeline bugs found during TB end-to-end test + add TB |
| 001198a | 2026-04-06 | Show gear cost + departure month on all flight card rows |
| 71d490c | 2026-04-06 | Add autonomous pipeline: registry, URL discovery, orchestrator |
| 727e0ca | 2026-04-06 | Layer 8: Add 21 Spain/Brazil airlines + remove Anthropic API from process_canonical |
| 9e4133c | 2026-04-06 | Normalize SerpApi airline names to IATA codes |
| 53eeb41 | 2026-04-06 | Fix gear label per-person display and upgrade fallback log to error level |
| d9bf940 | 2026-04-06 | Fix all DB region mismatches in baggage lookup fallback chain |
| ed6d320 | 2026-04-06 | Fix baggage lookup missing intercontinental routes for AA, AC, and others |
| a1a52f5 | 2026-04-06 | feat(baggage-scraper): content gate, stealth, XHR interception + 8 new canonicals |
| 25f5b26 | 2026-04-06 | Show gear fee estimates in amber with est. label in trip builder |
| 48e0865 | 2026-04-06 | fix(trip-builder): exclude uncertain gear estimates from totals |
| 48b9edd | 2026-04-06 | fix(trip-builder): correct cost math for all group/solo/bag combinations |
| b09d936 | 2026-04-06 | feat: dynamic homepage stats — gear + airline counts from Supabase |
| 665bdc4 | 2026-04-06 | feat(flights): carry-on policy display on flight cards |
| b519890 | 2026-04-06 | feat(trip-builder): save trip button + saved_trips table |
| 979b837 | 2026-04-06 | feat(trip-builder): gear config step + per-person cost toggle |
| 7ffc735 | 2026-04-06 | feat(baggage): wire live EUR→USD exchange rate into fee calculations |
| e948d29 | 2026-04-06 | ui: prefix bag weight with ~ in packed kg tooltip |
| 440fbd2 | 2026-04-06 | ui: add weight breakdown tooltip on packed kg cell in gear locker |
| f8d586c | 2026-04-06 | ui: add kite + bag sub-label to Packed kg column header |
| 32224d5 | 2026-04-06 | feat: seed estimated kite weights for 8 blocked brands + gear locker tooltip |
| 3d08fad | 2026-04-06 | fix(ui): show fee unknown instead of estimated $65 for missing airline data |
| b0072e4 | 2026-04-06 | docs: update PROGRESS.md with 2026-04-05/06 session |
| a6b2193 | 2026-04-06 | feat: schema v2.3, recheck wiring, flight card breakdown, autocomplete fix |
| c49385a | 2026-04-06 | feat(gear): scrape pipeline + admin gear data view |
| 7bb4b40 | 2026-04-05 | docs: build journal 2026-04-05 + run_canonical.sh |
| 79ecc35 | 2026-04-05 | Update gear catalog stat to 210 items |
| 799a79d | 2026-04-05 | fix(airports): accept city type from Travelpayouts autocomplete |
| c7912ee | 2026-04-05 | fix(flights): proxy airport autocomplete through Next.js to fix CORS |
| 5c2fe32 | 2026-04-05 | fix(flights): auto-select airport when user types raw IATA code |
| bbc61b2 | 2026-04-05 | fix: baggage calculator bugs + comprehensive airport coverage |

---

## Open Items

| Item | Status |
|------|--------|
| Top 10 spots feature | Design agreed, not yet built |
| Brand ambassador role | Notion task created, not started |
| Spot pages flow fix | Noted, not yet scoped |
| CJ affiliate (World Nomads) | Blocked — external API 500 bug |
| run_canonical.sh test run | Script built, not yet run against full layer |
| ANTHROPIC_API_KEY in tools/.env | Still invalid |
