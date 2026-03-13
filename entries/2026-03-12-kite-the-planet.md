# Kite the Planet: Media Library Discovery & Restructure Pipeline
## Build Journal Entry — Standard

**Builder:** Ben Giordano
**Date:** 2026-03-12
**Repo:** bengio777/KTP_V01
**Status:** In Progress (Ireland test case complete — full 38-block run next)
**Tier:** Standard

---

## 1. Problem Statement

19,034 photos and videos across 2024–2026 sitting in a disorganized Apple Photos library with inconsistent manual albums, no systematic geographic structure, and 38% of assets missing GPS data. Goal: programmatically restructure the entire library into geographic time blocks with consistent nested sub-albums, as a prerequisite for surfacing KTP's best travel media for the platform.

---

## 2. Solution

Two-script pipeline:

1. **`media_discovery.py`** — scans Apple Photos via osxphotos, clusters GPS assets by location + time, detects no-GPS device ranges, and outputs a structured discovery report. Run once (or when new media is imported).

2. **`media_restructure.py`** — reads an approved `blocks.json` block map and writes a nested album structure into Photos via AppleScript. Fully additive, safe to re-run. Supports dry-run, `--yes` flag, and `--sync-favorites`.

Album structure per location block:
```
[Year Folder]
  └── [Location] [Date Range]  (sub-folder)
        ├── Master
        ├── Sony Mirrorless  (if content)
        ├── DJI              (if content)
        ├── Videos           (if content)
        └── Favorites        (if content)
```

---

## 3. Architecture

**Photo assignment logic (priority order):**
1. GPS match → block centroid + radius → Master
2. No-GPS device override (Sony, DJI) → date range match → Master + device sub-album
3. Date-range fallback (unambiguous only) → Master + Unlocated/Review
4. No match → Unlocated/Review only
5. Favorites flag → additionally added to Favorites sub-album

**Block map format (`blocks.json`):**
- 38 location blocks covering 2024–2026
- `location` field (display name prefix)
- `album` field (internal key, referenced by `no_gps_overrides`)
- `year`, `start_date`, `end_date`, `centroid_lat`, `centroid_lon`, `radius_km`
- `no_gps_overrides`: Sony Mirrorless date ranges mapped to album keys

**Date display name auto-generation:**
- Same month: `Ireland Sep 11–24, 2025`
- Cross-month: `Baja Mar 27–Apr 7, 2024`
- Cross-year: `Thailand Dec 28, 2024–Jan 15, 2025`
- Single day: `Hong Kong Dec 28, 2024`

---

## 4. Component Specifications

| Component | File | Purpose |
|-----------|------|---------|
| Discovery scan | `tools/media_discovery.py` | GPS clustering, device breakdown, no-GPS ranges |
| Restructure engine | `tools/media_restructure.py` | Block matching, AppleScript writes, sub-album creation |
| Block map | `tools/blocks.json` | 38 blocks, 10 Sony overrides, 2024–2026 |
| Ireland test | `tools/blocks_ireland_test.json` | Single-block test case |
| Discovery output | `tools/discovery_report.json` | Full scan results (19,034 assets, 220 raw GPS clusters) |

**Key stats from discovery:**
- 19,034 assets (16,153 photos, 2,881 videos)
- 61.9% GPS coverage (11,779 with GPS)
- Dominant devices: iPhone 14 Pro Max (11,146), Sony Mirrorless (3,973), Unknown (3,020)
- 10 Sony no-GPS override ranges mapped

**Ireland test case results:**
- Master: 500 · Sony Mirrorless: 169 · Videos: 57 · Favorites: 46
- Date-range fallback rescued 48 no-GPS photos into Master (down from 4,074 → 822 truly unlocatable)

---

## 5. Lessons Learned

- **`items` is reserved in AppleScript** — caused a silent failure when the variable was renamed from `targetMediaItems`. Always use distinct variable names in AppleScript.
- **JSON doesn't support comments** — blocks.json had `//` comment lines that broke `json.load()`. Stripped in final version.
- **Date-range fallback is high-value** — routing no-GPS/screenshot photos into their contextual location album (when unambiguous) dropped truly unlocatable photos from 4,074 to 822. Screenshots tell part of the travel story.
- **Nested folder structure requires 3-level AppleScript traversal** — `year → location sub-folder → album` is more code than flat, but Photos supports it cleanly and the UX is significantly better.
- **Sub-albums should only be created when populated** — prevents empty Sony/DJI/Favorites albums cluttering blocks where they don't apply (e.g. Colorado home base).
- **`--yes` flag essential for non-interactive execution** — stdin isn't connected in background tasks; interactive confirmation prompts hang indefinitely.

---

## 6. Build History

| Phase | Status | Notes |
|-------|--------|-------|
| Discovery scan + tools | ✅ Complete | FDA granted to iTerm2, scan run, 220 clusters detected |
| Review Gate 1 — block proposal | ✅ Complete | 38 blocks approved, Sony overrides mapped |
| blocks.json generation | ✅ Complete | All edge cases handled (cross-year, single-day, Colorado splits) |
| Script v1 — flat albums | ✅ Complete | Ireland test passed (452 photos) |
| Script v2 — sub-album structure | ✅ Complete | Master/Sony/Videos/Favorites per block |
| Script v3 — nested folders | ✅ Complete | Ireland test: nested 2025 → Ireland Sep 11–24, 2025 → sub-albums |
| Full 38-block run | ⏳ Next session | Run `python3 tools/media_restructure.py --block-map tools/blocks.json --yes` |
| --sync-favorites | ⏳ Implemented, not tested | Run after full restructure |

---

## 7. Commit Log

| Hash | Date | Description |
|------|------|-------------|
| dc91b9e | 2026-03-12 | feat(tools): add media library discovery and restructure pipeline |
