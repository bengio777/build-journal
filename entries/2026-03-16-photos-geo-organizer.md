# photos-geo-organizer: Insta360 Rename Complete
## Build Journal Entry — Standard

**Builder:** Ben Giordano
**Date:** 2026-03-16
**Repo:** https://github.com/bengio777/photos-geo-organizer
**Status:** Complete (Insta360 phase)
**Tier:** Standard

---

## 1. Problem Statement

All Insta360 camera files across 7 country folders needed to be renamed to the standard geo-naming convention (`[Location]_[YYYY-MM-DD]_[Device]_[Duration]_[Notes]_[Original].ext`). Three code gaps blocked completion: (1) generic subfolders like `Timelapse/` and `edited/` were being treated as distinct locations instead of inheriting the parent spot, (2) a hybrid Insta360 filename format (`VID_notes_YYYY-MM-DD_HHMMSS_CC_NNN`) wasn't handled, and (3) the location resolver was flagging block-map date vs. folder-name mismatches as conflicts, blocking Nepal sub-region resolution.

---

## 2. Solution

Fixed all three code gaps in `media_rename.py`, executed Vietnam rename (51 files), verified all remaining folders (Thailand, Nepal, Madagascar, Australia already complete from prior session), and wrapped up with full documentation — `MediaLibraryAgent.md`, updated design spec, project `CLAUDE.md`, and two new reusable skills.

---

## 3. Architecture

### Code Changes (`media_rename.py`)

**Generic subfolder inheritance**
Added `GENERIC_SUBFOLDERS = {'timelapse', 'edited', 'exports', 'raw', ...}`. When `f.parent.name.lower()` is in this set, walk up one level to find the real spot. `Vietnam/HaGiangLoop/Timelapse/` → `Vietnam-HaGiangLoop`, not `Vietnam-Timelapse`.

**Hybrid Insta360 filename**
Added `_INSTA_CUSTOM_FULL_RE` to catch `VID_notes_YYYY-MM-DD_HHMMSS_CC_NNN.ext`. Compresses original to `HHMM-SS_CC_NNN.ext`, consistent with standard Insta360 compression. Tried before the simpler `YYYY-MM-DD_NNN` pattern.

**Location resolver conflict fix**
`resolve_location()` was treating block-map date vs. folder-name as a conflict. Fixed to let date from block map win silently — block map is more specific than a folder name. GPS conflicts remain flagged.

### New Files
- `nepal_rename_blocks.json` — non-overlapping Pokhara/Lower-Mustang date blocks (main blocks.json had Kathmandu overlap that prevented unambiguous date resolution)
- `docs/agents/MediaLibraryAgent.md` — full naming SOP: convention, location resolution, device detection, Insta360 patterns, country folder status, iPhoto restructure rules
- `CLAUDE.md` — project-level context for future sessions

### New Skills
- `media-rename` — operational skill covering all rename conventions, country status, common issues
- `media-restructure` — Apple Photos restructure workflow, block map schema, CLI flags

---

## 4. Component Specifications

### Insta360 Folder Status (all complete)

| Country | Convention | Notes |
|---|---|---|
| Australia (Aus) | Root level | Short name kept |
| Brazil | Brazil-Jeri, Brazil-Atins | |
| Japan | Japan-Niseko, Japan-Teine, Japan-Rasutsu | Rasutsu2/RasutsuGuide collapsed |
| Madagascar | Madagascar-Emerald-Sea, Madagascar-Motorbike | |
| Nepal | Nepal-Pokhara, Nepal-Lower-Mustang | Via nepal_rename_blocks.json |
| Thailand | Root level | Already done prior session |
| Vietnam | Vietnam-HaGiangLoop, Vietnam-Kiting | 51 files renamed this session |

### Vietnam Execute
- 51 files renamed (HaGiangLoop: 41 insv + 6 mp4/mov; Kiting: 10 insv)
- Timelapse/ and edited/ correctly inherited Vietnam-HaGiangLoop
- BanterAtStopWithGuides hybrid file correctly compressed to `0144-30_00_017`

---

## 5. Lessons Learned

**Generic subfolders need explicit transparency.** `Timelapse/` and `edited/` look like meaningful locations but they're workflow artifacts. A hardcoded set of transparent folder names is the right pattern — simple, predictable, easy to extend.

**Block map conflicts need priority clarity.** The original conflict rule was symmetric (any two sources disagreeing = skip). In practice, block map date is always more specific than folder name — it should win silently. Only GPS conflicts are ambiguous enough to warrant skipping.

**Country-specific block maps beat tuning the main one.** Rather than tightening `blocks.json` date ranges (which risks breaking iPhoto restructure), a separate Nepal block map with clean non-overlapping ranges solved the sub-region resolution cleanly.

**Document conventions as you establish them.** The naming rules grew organically across sessions. Capturing them in `MediaLibraryAgent.md` immediately after validating them in production prevents drift and makes future sessions self-contained.

---

## 6. Build History

| Session | Date | Work |
|---|---|---|
| 1 | 2026-03-12 | Built media_rename.py, DJI naming convention, design spec, initial tests |
| 2 | 2026-03-12 | Brazil, Japan renames; Country-Spot naming; spot stripping; Rasutsu collapse |
| 3 | 2026-03-13 | Nepal blocks, Madagascar, Thailand; location resolver fixes |
| 4 | 2026-03-16 | Vietnam; generic subfolder inheritance; hybrid filename; all docs; 2 skills |

---

## 7. Commit Log

| Hash | Date | Description |
|------|------|-------------|
| a2467ec | 2026-03-16 | feat: Insta360 rename complete — generic subfolder inheritance, hybrid filename, conventions doc |
| 8dc2bd2 | 2026-03-12 | docs: mark Madagascar complete in TODO |
| 6cd2afd | 2026-03-12 | docs: log incomplete rename work for next session |
| 3f3b140 | 2026-03-12 | feat: strip location-prefix tokens from notes generically |
| c092236 | 2026-03-12 | fix: check parent folder for device detection fallback |
| 5f74d8a | 2026-03-12 | docs: update design spec with DJI Action4 official naming standard |
| 2804810 | 2026-03-12 | refactor: compress DJI original filename segment |
| 11e62e3 | 2026-03-12 | feat: add media_rename.py — local file renaming pipeline |
| c57e8fc | 2026-03-12 | docs: add media_rename implementation plan |
| 992b51f | 2026-03-12 | docs: revise media_rename spec — address all review issues |
| 234ca17 | 2026-03-12 | docs: add media_rename.py design spec |
| 077e055 | 2026-03-12 | feat: add incremental run support via --incremental flag |
| 06307cb | 2026-03-12 | feat: initial commit — media_discovery, media_restructure, blocks template |
