# Kite the Planet: Rider Intelligence Pipeline
## Build Journal Entry — Standard

**Builder:** Ben Giordano
**Date:** 2026-03-19
**Repo:** KTP_V01
**Status:** Complete
**Tier:** Standard

---

## 1. Problem Statement

KTP needed a structured dataset of professional kitesurfing riders and brand ambassadors across Tier 1–3 brands — with Instagram handles, follower counts, bios, and competitive credentials — to power outreach, content seeding, and influencer prioritization. No such dataset existed in structured form. Data was scattered across brand team pages (many JS-rendered, some crashing scrapers) and Instagram profiles.

---

## 2. Solution

Built a three-stage pipeline:

1. **Brand ambassador scraping** — HTTP + Playwright scrapers across 11 Tier 1–3 kite brands (Cabrinha, Core, Duotone, North, F-One, Airush, Naish, Mystic, ION, Manera, Dakine), producing 4 source CSVs
2. **Deduplication and consolidation** — `consolidate_riders.py` normalizes names (accent-stripping), merges multi-brand associations, resolves handle conflicts
3. **Enrichment** — `enrich_riders.py` queries DuckDuckGo (name + handle) for follower counts and bios, with Instagram direct-page fallback for empty/weak bios

Final output: `brand-ambassadors-enriched.csv` — 185 riders with followers, full bios, profile URLs, handle verification flags, and brand associations.

---

## 3. Architecture

```
Brand team pages (HTTP / Playwright)
    ↓
4 source CSVs (per brand group)
    ↓
consolidate_riders.py
    → dedup by normalized name
    → merge brand associations (pipe-separated)
    → resolve handle conflicts (prefer non-empty, then longer)
    ↓
brand-ambassadors-master.csv (219 riders, 185 handles)
    ↓
enrich_riders.py
    → DuckDuckGo search: "{name} {handle} instagram"
    → parse follower count + bio from snippet
    → fallback: fresh Playwright page → instagram.com/{handle} → meta[description]
    → checkpoint every rider (resumable)
    ↓
brand-ambassadors-enriched.csv (185 riders enriched)
```

---

## 4. Key Lessons

- DuckDuckGo with visible browser + 4–8s delays ran 185 searches with zero blocks
- Name + handle queries eliminate generic handle collisions
- Instagram `meta[name="description"]` is the most reliable bio source
- Fresh page for Instagram fallback prevents session state contamination
- Brunotti is permanently unscrapeable (Unicode crash at MCP level) — manual only
- Multi-brand patterns (F-One+Manera 22 shared, Duotone+ION 10 shared) reveal corporate groups
- Bio text surfaces KoTA results, GKA rankings, Red Bull status for free

---

## 5. Commit Log

| Hash | Date | Description |
|------|------|-------------|
| cfdc1a9 | 2026-03-19 | Update PROGRESS.md with rider enrichment session |
| 23433c6 | 2026-03-19 | Add enriched rider dataset with follower counts and bios |
| 9d03eb5 | 2026-03-19 | Add brand ambassador CSV data for Tier 1-3 kite brands |
| e79fbc6 | 2026-03-19 | Complete brand ambassador dataset — 219 riders across all Tier 1-3 brands |
| fa52144 | 2026-03-19 | Add brand ambassador scraping pipeline and kite-brands.md restructure |
| 1427f43 | 2026-03-19 | docs: add kite brands reference + ambassador scraper tools |

---

# Session 2: Google Maps Spot Pipeline (A1)
## Daily Recap — 2026-03-19 (evening)

**Status:** In Progress — A1 complete, A3–B4 queued for next session

---

## Accomplished

Built and ran the full **A1 spot input pipeline** for the KTP Places API data collection system.

**Scraper engineering:**
- Rewrote `scrape_ktp_list.py` three times to fix selector and coordinate issues:
  - v1: `a[href*="/maps/place/"]` — wrong (list uses buttons, not links)
  - v2: `button[aria-label]` — wrong (place buttons have class `SMP2wb`, no aria-label)
  - v3 final: `.m6QErb.DxyBCb.kA9KIf button.SMP2wb` — confirmed via live MCP DOM inspection
- Fixed coordinate extraction: `!3d!4d` URL pattern (actual place coords) over `@lat,lng` (map view center, was 78° off)
- Fixed name extraction: h1 returned the list title "Kite the planet - locations" for every entry — switched to URL path decode
- Fixed post-`go_back()` click failures: Google Maps only loads ~20 cards on restore — added `wait_for_card_count(page, i+2)` before each click

**Data pipeline:**
- Scraped all 186 entries from the shared list → `data/spots-input.csv`
- Ran junk review (full 186-entry table, reviewed in batches of 10)
- Removed 7 junk entries (airport, waterfalls, Berlin street, hotel branding, state monument, admin region, cafe)
- Extracted 12 operator entries → `data/operators-raw.csv`; replaced with nearest beach spots where not covered
- Added 4 new beach spots: Sorobon Beach (Bonaire), Ninh Chu/Phan Rang (Vietnam), Caribbean Colombia Coast, North Queensland/Cape Flattery
- Kept 2 broad destination zones (Cocos Keeling, Rodrigues) per Dakhla multi-launch-area precedent
- Renamed parking lot entry to "Praia de Foz do Lizandro"

**Final output:** 171 curated kite spots with lat/lng and Google Maps URLs

---

## Open Items

- Caribbean Colombia Coast (10.87, -75.1) — exact beach name needs geo research
- North Queensland / Cape Flattery (-15.23, 145.26) — remote FNQ, needs ground truth

---

## Next Session

Run order (all scripts in `tools/gmaps-scraper/`):
1. `python3 scrape_iko.py` — IKO school directory (A3)
2. `python3 discover_new_spots.py` — gap-fill from IKO + OSM (A5)
3. `python3 scrape_kite_schools.py` — Google Maps UI schools (A4) → `data/gmaps-schools.csv`
4. `python3 consolidate_schools.py` — merge → `data/schools-master.csv` (A6)
5. Restrict API key to Places API only in GCP console
6. `python3 search_nearby.py --category [schools|gear|accommodation]` (B1–B3)
7. `python3 fetch_place_details.py` (B4)

---

## Commits

| Hash | Date | Description |
|------|------|-------------|
| 3daf5a1 | 2026-03-19 | feat(gmaps-scraper): complete A1 spot pipeline — 171 curated kite spots |
| e35e048 | 2026-03-19 | phase 5d: multi-engine discovery + Jesse Richman + bio parser fix |
| 079340f | 2026-03-19 | phase 5c: Red Bull athlete roster — Robby Naish + Tom Bridge |
| 4d6a5aa | 2026-03-19 | feat: Phase 5a — GKA profile scraper + handle enrichment |
| 681477b | 2026-03-19 | Add brand positioning analysis to competitive docs |
| ca2219c | 2026-03-19 | Add 5-year growth projections with four scenario tracks |
