# photos-geo-organizer: GPS-Based Apple Photos Restructure + Local File Rename Pipeline
## Build Journal Entry — Standard

**Builder:** Ben Giordano
**Date:** 2026-03-12 (retroactive — logged 2026-03-16)
**Repo:** bengio777/photos-geo-organizer
**Status:** In Progress (full 38-block restructure run pending; rename pipeline partially complete)
**Tier:** Standard

---

## 1. Problem Statement

A 19,034-asset Apple Photos library covering multi-year travel (2024–present) had no geographic organization — all media was flat or in ad-hoc albums with no consistent structure. Devices used include iPhone, Sony mirrorless (no GPS), DJI Action4, DJI Drone, and Insta360, each with different naming conventions and GPS availability.

Secondary problem: local raw media files (MP4, MOV, ARW, DNG, JPG) on disk used opaque camera-native names (`DJI_20251030215911_0001_D.MP4`, `C0002.MP4`) with no location, device, or duration context visible from the filename. Files also had inconsistent manual prefixes with legacy location abbreviations that needed to be preserved but normalized.

---

## 2. Solution

Two-track system built in a single repo:

**Track 1 — Apple Photos Library Restructure:**
- `media_discovery.py`: scans the Photos library via osxphotos, clusters GPS assets by location and time (50km radius, 3-day gap splits), reverse geocodes cluster centroids via Nominatim, and outputs a structured JSON discovery report with GPS timeline, device breakdown, and no-GPS date ranges by device.
- `media_restructure.py`: reads an approved `blocks.json` block map and writes a nested album structure into Photos via AppleScript batches. Fully additive, safe to re-run.

**Track 2 — Local File Rename Pipeline (new this session):**
- `media_rename.py`: renames local camera files to a consistent `Location_Date_Device_Duration_Notes_Original.ext` convention. Zero external dependencies — uses stdlib only plus macOS `mdls` for date fallback. Reads device from MP4's `©too` atom, duration from `mvhd` box (both read from last 2MB of file). Full dry-run preview, collision detection, idempotency, and a `rename_log.json` append log.

---

## 3. Architecture

```
photos-geo-organizer/
├── media_discovery.py      — Apple Photos scan + GPS clustering + Nominatim geocoding
├── media_restructure.py    — AppleScript-driven album creation and photo assignment
├── media_rename.py         — Local file rename pipeline (new this session)
├── blocks_template.json    — Block map schema and example
├── tests/
│   └── test_media_rename.py
└── docs/superpowers/
    ├── specs/2026-03-12-media-rename-design.md
    └── plans/2026-03-12-media-rename.md
```

**Library restructure flow:**
1. Run `media_discovery.py` → review GPS timeline → build `blocks.json`
2. Run `media_restructure.py --dry-run` → review assignment plan
3. Run `media_restructure.py --yes` → execute (15–30 min for full library)
4. Run `--sync-favorites` periodically as new photos are favorited

**Rename pipeline flow:**
1. Point `media_rename.py` at a device folder with `--dry-run`
2. Review proposed names and location resolution sources
3. Execute with `--yes`; `rename_log.json` created in the folder for rollback reference

---

## 4. Component Specifications

### media_discovery.py
- Uses `osxphotos.PhotosDB()` to read the Photos library (no AppleScript needed for reads)
- GPS clustering: greedy spatial+temporal algorithm — points within 50km of cluster centroid AND within 3 days of last point stay in cluster; gap in either dimension starts a new cluster
- Nominatim reverse geocoding with 1.1s rate limiting (ToS compliance)
- Reports: total/photo/video counts, GPS coverage %, device breakdown, GPS timeline with human date ranges, no-GPS asset ranges by device

### media_restructure.py
- Album structure: `[Year] → [Location Date Range] → {Master, Sony Mirrorless, DJI, Videos, Favorites}`
- Assignment priority: GPS match → no-GPS device override → date-range fallback → Unlocated/Review Needed
- AppleScript batched in groups of 50 UUIDs to avoid size limits
- Incremental mode: saves `restructure_state.json` after each run; `--incremental` skips photos imported before last run timestamp
- `--sync-favorites`: fast additive re-scan of favorites only; optionally scoped to a single block with `--block NAME`

### media_rename.py
- **Filename format:** `Location_YYYY-MM-DD_Device_[Duration]_[Notes]_CompressedOriginal.ext`
- **DJI filename compression:** `DJI_20251030223255_0013_D.MP4` → `2232-55__13_D.MP4` (date already in prefix; only time + clip + mode suffix retained)
- **Date sources:** DJI regex → Insta360 regex → `mdls kMDItemContentCreationDate`
- **Device sources:** MP4 `©too` atom → parent folder name → `Unknown`
- **Duration:** MP4 `mvhd` box parsed from last 2MB; handles both version 0 (DJI) and version 1 (Sony MOV)
- **Notes extraction:** camera token regex splits filename; legacy location abbreviations (2–4 uppercase letters) stripped from prefix; remaining notes preserved verbatim
- **Location resolution:** GPS (Haversine vs block centroids) → unambiguous date match → folder name; any two-source conflict skips the file with a warning
- **Idempotency regex:** `^[A-Za-z][A-Za-z0-9-]+_\d{4}-\d{2}-\d{2}_(DJI-Action4|DJI-Drone|Insta360|Sony)_`

---

## 5. Lessons Learned

**mvhd box is reliable for DJI duration but must handle both version 0 and version 1.** DJI Action4 uses version 0 (32-bit timestamps), some Sony MOV files use version 1 (64-bit timestamps). Detecting from the first byte after the tag and branching on version is the correct approach.

**©too atom device detection from last 2MB is sufficient.** The moov box sits at the end of most MP4 files. Reading the last 2MB and scanning for `\xa9too` then the `data` sub-box works reliably for DJI and is compatible with Insta360.

**Folder name as location fallback is viable but fragile.** When no blocks.json is available, the folder name is used as-is. This means a misspelled folder name (`Morraco`) propagates into every renamed file. The correct fix is to cross-reference against blocks.json before running `--yes`.

**Location conflict detection prevents silent errors.** The three-source conflict check (GPS vs date vs folder) was critical — without it, a file whose date falls in Dakhla but whose folder is Morocco would silently get the wrong location. The design to skip-with-warning rather than guess is the right call.

**Incremental flag for restructure requires state file adjacent to blocks.json.** The state file path is derived from `block_map_path`, not the script location. This is correct but means the state file moves with the block map if the map is relocated.

---

## 6. Build History

**Session 1 (2026-03-12):**
- Initial commit with `media_discovery.py`, `media_restructure.py`, and `blocks_template.json` (ported and enhanced from kite-the-planet `tools/`)
- Added `--incremental` flag to `media_restructure.py`
- Full design spec written for `media_rename.py` (3 revision passes to address review issues)
- Implementation plan written with TDD structure (8 tasks, 2 chunks)
- `media_rename.py` built end-to-end: metadata extraction, location resolver, rename engine, CLI
- `_compress_dji_original` added post-initial-implementation (DJI filenames compressed in output)
- `_strip_location_abbrev` updated to also strip location-prefix tokens that are prefix-matches of the resolved location name (e.g., `Fuerte` stripped when location is `Fuerteventura`)
- Parent folder device detection fallback added (checks `folder.parent.name` when direct folder name gives no device match)
- Rename pipeline executed against 6 destination folders: Florida (28), Fuerteventura (13), Hawaii (16, top-level only), Madagascar (40, recursive), Morocco (98, top-level only), Portugal (18)
- Incomplete subfolders logged in `TODO-rename-incomplete.md`

---

## 7. Commit Log

| Hash | Date | Description |
|------|------|-------------|
| `8dc2bd2` | 2026-03-12 | docs: mark Madagascar complete in TODO |
| `6cd2afd` | 2026-03-12 | docs: log incomplete rename work for next session |
| `3f3b140` | 2026-03-12 | feat: strip location-prefix tokens from notes generically |
| `c092236` | 2026-03-12 | fix: check parent folder for device detection fallback |
| `2804810` | 2026-03-12 | docs: update design spec with DJI Action4 official naming standard |
| `11e62e3` | 2026-03-12 | refactor: compress DJI original filename segment |
| `c57e8fc` | 2026-03-12 | feat: add media_rename.py — local file renaming pipeline |
| `992b51f` | 2026-03-12 | docs: add media_rename implementation plan |
| `234ca17` | 2026-03-12 | docs: revise media_rename spec — address all review issues |
| `077e055` | 2026-03-12 | docs: add media_rename.py design spec |
| `06307cb` | 2026-03-12 | feat: add incremental run support via --incremental flag |
| `06307cb` | 2026-03-12 | feat: initial commit — media_discovery, media_restructure, blocks template |
| `8b72e7b` | 2026-03-12 | Initial commit |
