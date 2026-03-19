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
